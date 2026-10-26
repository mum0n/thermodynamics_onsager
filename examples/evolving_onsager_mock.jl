module EvolvingOnsagerMock

using LinearAlgebra
using Printf
using Random

include(joinpath(@__DIR__, "reversible_onsager_mock.jl"))
using .ReversibleOnsagerMock: simulate_channel_current_density,
                              estimate_two_pathway_conductivity,
                              exact_two_pathway_conductivity,
                              equilibrium_occupancy_fraction, GAS_CONSTANT

export simulate_evolving_local_conductivity, main

"""
    simulate_evolving_local_conductivity(; n_epochs=12, epoch_duration=200.0,
        measurement_duration=40.0, site_count=600, n_replicates=3,
        initial_trait=-0.8, trait_optimum=0.8, selection_strength=0.05,
        mutation_sd=0.005, state_energy_scale=1.0, seed=20261028)

Simulate fast reversible site switching while a slow trait changes the channel
rates and state free-energy difference. The fast process is detailed-balanced at
zero applied force for each frozen trait value. A local Onsager matrix is
estimated by force perturbations at each trait value. The trait update is an
imposed mutation-selection-like process, not a mechanistic evolutionary model.
"""
function simulate_evolving_local_conductivity(
    ; n_epochs::Integer=12,
    epoch_duration::Real=200.0,
    measurement_duration::Real=40.0,
    site_count::Integer=600,
    site_concentration::Real=0.2,
    n_replicates::Integer=3,
    burn_in::Real=2.0,
    base_rate::Real=2.5,
    temperature::Real=298.15,
    state_energy_scale::Real=1.0,
    initial_trait::Real=-0.8,
    trait_optimum::Real=0.8,
    selection_strength::Real=0.05,
    mutation_sd::Real=0.005,
    force_step::Real=1.0,
    seed::Integer=20261028,
)
    n_epochs > 0 || throw(ArgumentError("n_epochs must be positive"))
    isfinite(epoch_duration) && epoch_duration > 0 ||
        throw(ArgumentError("epoch_duration must be finite and positive"))
    isfinite(measurement_duration) && measurement_duration > 0 ||
        throw(ArgumentError("measurement_duration must be finite and positive"))
    measurement_duration < epoch_duration ||
        throw(ArgumentError("measurement_duration must be shorter than epoch_duration"))
    isfinite(base_rate) && base_rate > 0 ||
        throw(ArgumentError("base_rate must be finite and positive"))
    isfinite(temperature) && temperature > 0 ||
        throw(ArgumentError("temperature must be finite and positive"))
    isfinite(state_energy_scale) ||
        throw(ArgumentError("state_energy_scale must be finite"))
    isfinite(initial_trait) && isfinite(trait_optimum) ||
        throw(ArgumentError("trait values must be finite"))
    0 <= selection_strength <= 1 ||
        throw(ArgumentError("selection_strength must be between zero and one"))
    isfinite(mutation_sd) && mutation_sd >= 0 ||
        throw(ArgumentError("mutation_sd must be finite and nonnegative"))

    fast_rng = MersenneTwister(seed)
    trait_rng = MersenneTwister(seed + 1)
    trait = Float64(initial_trait)
    occupied_sites = nothing
    trait_history = Float64[]
    occupancy_history = Float64[]
    equilibrium_occupancy_history = Float64[]
    rate_history = Vector{Float64}[]
    estimated_conductivity = Matrix{Float64}[]
    exact_conductivity = Matrix{Float64}[]
    conductivity_standard_errors = Matrix{Float64}[]

    for epoch in 1:n_epochs
        rate_constants = Float64(base_rate) .* exp.([trait, -trait])
        all(isfinite, rate_constants) && all(>(0), rate_constants) ||
            throw(ArgumentError("trait produced nonfinite or nonpositive reaction rates"))

        state_free_energy_change = GAS_CONSTANT * Float64(temperature) *
                                  Float64(state_energy_scale) * trait
        equilibrium_occupancy = equilibrium_occupancy_fraction(
            state_free_energy_change, temperature)
        if isnothing(occupied_sites)
            occupied_sites = count(_ -> rand(fast_rng) < equilibrium_occupancy,
                                   1:site_count)
        end
        baseline = simulate_channel_current_density(
            zeros(2), rate_constants; site_count=site_count,
            site_concentration=site_concentration, burn_in=0.0,
            measurement_duration=epoch_duration,
            state_free_energy_change=state_free_energy_change,
            temperature=temperature,
            initial_occupied_sites=occupied_sites, rng=fast_rng)
        occupied_sites = baseline.final_occupied_sites

        local_seed = seed + 1000 * epoch
        local_estimate = estimate_two_pathway_conductivity(
            rate_constants; site_count=site_count,
            site_concentration=site_concentration, n_replicates=n_replicates,
            burn_in=burn_in, measurement_duration=measurement_duration,
            state_free_energy_change=state_free_energy_change,
            temperature=temperature, force_step=force_step, seed=local_seed)

        push!(trait_history, trait)
        push!(occupancy_history, occupied_sites / site_count)
        push!(equilibrium_occupancy_history, equilibrium_occupancy)
        push!(rate_history, rate_constants)
        push!(estimated_conductivity, local_estimate.conductivity)
        push!(conductivity_standard_errors, local_estimate.standard_errors)
        push!(exact_conductivity, exact_two_pathway_conductivity(
            rate_constants, site_concentration;
            state_free_energy_change=state_free_energy_change,
            temperature=temperature))

        trait += selection_strength * (Float64(trait_optimum) - trait) +
                 mutation_sd * randn(trait_rng)
    end

    return (epoch=collect(1:n_epochs),
            elapsed_time=(collect(0:(n_epochs - 1)) .* Float64(epoch_duration)),
            trait=trait_history, occupancy_fraction=occupancy_history,
            equilibrium_occupancy_fraction=equilibrium_occupancy_history,
            rate_constants=rate_history,
            conductivity=estimated_conductivity,
            exact_conductivity=exact_conductivity,
            standard_errors=conductivity_standard_errors,
            epoch_duration=Float64(epoch_duration),
            measurement_duration=Float64(measurement_duration))
end

function main()
    temperature = 298.15 # K
    affinity_step = 298.15 # J mol^-1, giving force_step = 1 J mol^-1 K^-1
    force_step = affinity_step / temperature
    result = simulate_evolving_local_conductivity(
        n_epochs=12, epoch_duration=200.0, measurement_duration=40.0,
        site_count=600, n_replicates=3, force_step=force_step,
        seed=20261028)

    println("Slowly evolving reversible Gillespie mock")
    println("Each frozen fast process is detailed-balanced at zero force.")
    println("Trait updates are imposed and are not a thermodynamic evolution model.")
    println("Affinity perturbation: $affinity_step J mol^-1 at $temperature K")
    println("Epochs are 200 s; local response windows are 40 s.")
    println("Selection strength per epoch: 0.05 (nominal trait time scale 4000 s).")
    println("Columns: epoch, elapsed_s, trait, occupancy, occupancy_eq, L11_est, L11_exact, SE(L11)")
    for index in eachindex(result.epoch)
        @printf("%5d %10.1f %8.4f %9.4f %11.4f %11.6f %11.6f %10.6f\n",
                result.epoch[index], result.elapsed_time[index],
                result.trait[index], result.occupancy_fraction[index],
                result.equilibrium_occupancy_fraction[index],
                result.conductivity[index][1, 1],
                result.exact_conductivity[index][1, 1],
                result.standard_errors[index][1, 1])
    end
end

end # module EvolvingOnsagerMock

if abspath(PROGRAM_FILE) == abspath(@__FILE__)
    EvolvingOnsagerMock.main()
end
