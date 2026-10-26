module ReversibleOnsagerMock

using LinearAlgebra
using Random
using Statistics

export simulate_channel_current_density, exact_two_pathway_conductivity,
       estimate_two_pathway_conductivity, equilibrium_occupancy_fraction,
       GAS_CONSTANT, main

const GAS_CONSTANT = 8.31446261815324 # J mol^-1 K^-1

"""Equilibrium occupied fraction for the mock site's molar free-energy gap."""
function equilibrium_occupancy_fraction(state_free_energy_change::Real,
                                        temperature::Real=298.15)
    isfinite(state_free_energy_change) ||
        throw(ArgumentError("state_free_energy_change must be finite"))
    isfinite(temperature) && temperature > 0 ||
        throw(ArgumentError("temperature must be finite and positive"))
    scaled_energy = Float64(state_free_energy_change) /
                    (GAS_CONSTANT * Float64(temperature))
    return scaled_energy >= 0 ?
        exp(-scaled_energy) / (1 + exp(-scaled_energy)) :
        inv(1 + exp(scaled_energy))
end

"""
    simulate_channel_current_density(forces, rate_constants; site_count,
                                      site_concentration, burn_in,
                                      measurement_duration,
                                      state_free_energy_change=0.0,
                                      temperature=298.15,
                                      initial_occupied_sites=nothing, rng)

Simulate a finite population of independent two-state sites. Each reaction
channel reversibly switches a site between vacant and occupied states. A
positive event is vacant-to-occupied; a negative event is occupied-to-vacant.
`forces` are thermodynamic forces `affinity / temperature` in J mol^-1 K^-1,
and `rate_constants` are per-site rates in s^-1. `state_free_energy_change` is the
occupied-minus-vacant molar free-energy difference in J mol^-1. `initial_occupied_sites`
can carry the fast state between intervals. Returns molar channel-current densities
in mol m^-3 s^-1 together with the final occupied-site count. This is a mock
reaction network, not a calibrated ecological model.
"""
function simulate_channel_current_density(
    forces::AbstractVector{<:Real},
    rate_constants::AbstractVector{<:Real};
    site_count::Integer,
    site_concentration::Real,
    burn_in::Real,
    measurement_duration::Real,
    state_free_energy_change::Real=0.0,
    temperature::Real=298.15,
    initial_occupied_sites::Union{Nothing,Integer}=nothing,
    rng::AbstractRNG=Random.default_rng(),
)
    channel_count = length(rate_constants)
    channel_count > 0 || throw(ArgumentError("at least one channel is required"))
    length(forces) == channel_count ||
        throw(DimensionMismatch("forces and rate_constants must have equal lengths"))
    site_count > 0 || throw(ArgumentError("site_count must be positive"))
    all(isfinite, forces) && all(isfinite, rate_constants) ||
        throw(ArgumentError("forces and rate_constants must be finite"))
    all(>(0), rate_constants) ||
        throw(ArgumentError("rate_constants must be positive"))
    isfinite(site_concentration) && site_concentration > 0 ||
        throw(ArgumentError("site_concentration must be finite and positive"))
    isfinite(burn_in) && burn_in >= 0 ||
        throw(ArgumentError("burn_in must be finite and nonnegative"))
    isfinite(measurement_duration) && measurement_duration > 0 ||
        throw(ArgumentError("measurement_duration must be finite and positive"))
    isfinite(state_free_energy_change) ||
        throw(ArgumentError("state_free_energy_change must be finite"))
    isfinite(temperature) && temperature > 0 ||
        throw(ArgumentError("temperature must be finite and positive"))
    isnothing(initial_occupied_sites) ||
        0 <= initial_occupied_sites <= site_count ||
        throw(ArgumentError("initial_occupied_sites must be between zero and site_count"))

    state_exponent = Float64(state_free_energy_change) /
                     (2 * GAS_CONSTANT * Float64(temperature))
    forward_exponents = Float64.(forces) ./ (2 * GAS_CONSTANT) .- state_exponent
    reverse_exponents = -Float64.(forces) ./ (2 * GAS_CONSTANT) .+ state_exponent
    forward_rates = Float64.(rate_constants) .* exp.(forward_exponents)
    reverse_rates = Float64.(rate_constants) .* exp.(reverse_exponents)
    all(isfinite, forward_rates) && all(isfinite, reverse_rates) ||
        throw(ArgumentError("force perturbations produced nonfinite propensities"))
    all(>(0), forward_rates) && all(>(0), reverse_rates) ||
        throw(ArgumentError("force perturbations underflowed a reversible channel rate"))
    total_time = Float64(burn_in + measurement_duration)
    isfinite(total_time) || throw(ArgumentError("total simulation time overflowed"))

    equilibrium_occupancy = equilibrium_occupancy_fraction(
        state_free_energy_change, temperature)
    occupied_sites = isnothing(initial_occupied_sites) ?
        count(_ -> rand(rng) < equilibrium_occupancy, 1:site_count) :
        Int(initial_occupied_sites)
    net_event_counts = zeros(Int, channel_count)
    forward_rate_sum = sum(forward_rates)
    reverse_rate_sum = sum(reverse_rates)
    time = 0.0

    while time < total_time
        vacant_sites = site_count - occupied_sites
        forward_total = vacant_sites * forward_rate_sum
        reverse_total = occupied_sites * reverse_rate_sum
        total_propensity = forward_total + reverse_total
        total_propensity > 0 || break
        isfinite(total_propensity) ||
            throw(ArgumentError("total propensity overflowed"))

        waiting_time = randexp(rng) / total_propensity
        time + waiting_time <= total_time || break
        time += waiting_time
        event_threshold = rand(rng) * total_propensity

        if event_threshold < forward_total
            channel_threshold = event_threshold / vacant_sites
            cumulative_rate = 0.0
            selected_channel = 0
            for channel in 1:channel_count
                cumulative_rate += forward_rates[channel]
                if channel_threshold < cumulative_rate
                    selected_channel = channel
                    break
                end
            end
            selected_channel > 0 || error("failed to select a forward channel")
            occupied_sites += 1
            if time >= burn_in
                net_event_counts[selected_channel] += 1
            end
        else
            channel_threshold = (event_threshold - forward_total) / occupied_sites
            cumulative_rate = 0.0
            selected_channel = 0
            for channel in 1:channel_count
                cumulative_rate += reverse_rates[channel]
                if channel_threshold < cumulative_rate
                    selected_channel = channel
                    break
                end
            end
            selected_channel > 0 || error("failed to select a reverse channel")
            occupied_sites -= 1
            if time >= burn_in
                net_event_counts[selected_channel] -= 1
            end
        end
    end

    current_density = Float64(site_concentration) .* net_event_counts ./
                      (site_count * Float64(measurement_duration))
    return (current_density=current_density, net_event_counts=net_event_counts,
            final_occupied_sites=occupied_sites)
end

"""Exact near-equilibrium conductivity of the two-pathway mock network."""
function exact_two_pathway_conductivity(
    rate_constants::AbstractVector{<:Real}, site_concentration::Real;
    state_free_energy_change::Real=0.0,
    temperature::Real=298.15)
    length(rate_constants) == 2 ||
        throw(DimensionMismatch("the mock network requires exactly two channels"))
    all(isfinite, rate_constants) && all(>(0), rate_constants) ||
        throw(ArgumentError("rate_constants must be finite and positive"))
    isfinite(site_concentration) && site_concentration > 0 ||
        throw(ArgumentError("site_concentration must be finite and positive"))
    isfinite(state_free_energy_change) ||
        throw(ArgumentError("state_free_energy_change must be finite"))
    isfinite(temperature) && temperature > 0 ||
        throw(ArgumentError("temperature must be finite and positive"))

    rates = Float64.(rate_constants)
    total_rate = sum(rates)
    scaled_energy = Float64(state_free_energy_change) /
                    (2 * GAS_CONSTANT * Float64(temperature))
    isfinite(scaled_energy) && isfinite(cosh(scaled_energy)) ||
        throw(ArgumentError("state free-energy scale is outside the numerical range"))
    edge_activity = inv(2 * cosh(scaled_energy))
    isfinite(edge_activity) ||
        throw(ArgumentError("state free-energy scale is outside the numerical range"))
    return (Float64(site_concentration) * edge_activity / GAS_CONSTANT) .* (
        Diagonal(rates) - (rates * rates') / total_rate)
end

"""
    estimate_two_pathway_conductivity(rate_constants; site_count=1000,
                                      site_concentration=0.2, n_replicates=4,
                                      burn_in=2.0, measurement_duration=400.0,
                                      state_free_energy_change=0.0,
                                      temperature=298.15, force_step=1.0,
                                      seed=20261027)

Estimate the two-channel Onsager matrix by central finite differences of
Gillespie-measured stationary currents under independent positive and negative
force perturbations. The returned standard errors are Monte Carlo errors across
independent replicate trajectories; they do not include force-calibration or
model uncertainty.
"""
function estimate_two_pathway_conductivity(
    rate_constants::AbstractVector{<:Real};
    site_count::Integer=1000,
    site_concentration::Real=0.2,
    n_replicates::Integer=4,
    burn_in::Real=2.0,
    measurement_duration::Real=400.0,
    state_free_energy_change::Real=0.0,
    temperature::Real=298.15,
    force_step::Real=1.0,
    seed::Integer=20261027,
)
    length(rate_constants) == 2 ||
        throw(DimensionMismatch("the mock network requires exactly two channels"))
    n_replicates > 1 || throw(ArgumentError("n_replicates must be at least two"))
    isfinite(force_step) && force_step > 0 ||
        throw(ArgumentError("force_step must be finite and positive"))

    channel_count = length(rate_constants)
    conductivity = Matrix{Float64}(undef, channel_count, channel_count)
    standard_errors = similar(conductivity)
    for force_index in 1:channel_count
        positive_currents = Matrix{Float64}(undef, n_replicates, channel_count)
        negative_currents = Matrix{Float64}(undef, n_replicates, channel_count)
        for replicate in 1:n_replicates
            positive_forces = zeros(channel_count)
            negative_forces = zeros(channel_count)
            positive_forces[force_index] = force_step
            negative_forces[force_index] = -force_step
            positive_seed = seed + 2 * ((force_index - 1) * n_replicates + replicate - 1)
            negative_seed = positive_seed + 1
            positive_result = simulate_channel_current_density(
                positive_forces, rate_constants; site_count=site_count,
                site_concentration=site_concentration, burn_in=burn_in,
                measurement_duration=measurement_duration,
                state_free_energy_change=state_free_energy_change,
                temperature=temperature, rng=MersenneTwister(positive_seed))
            negative_result = simulate_channel_current_density(
                negative_forces, rate_constants; site_count=site_count,
                site_concentration=site_concentration, burn_in=burn_in,
                measurement_duration=measurement_duration,
                state_free_energy_change=state_free_energy_change,
                temperature=temperature, rng=MersenneTwister(negative_seed))
            positive_currents[replicate, :] .= positive_result.current_density
            negative_currents[replicate, :] .= negative_result.current_density
        end

        positive_mean = vec(mean(positive_currents; dims=1))
        negative_mean = vec(mean(negative_currents; dims=1))
        positive_variance = vec(var(positive_currents; dims=1))
        negative_variance = vec(var(negative_currents; dims=1))
        conductivity[:, force_index] .=
            (positive_mean - negative_mean) ./ (2 * force_step)
        standard_errors[:, force_index] .=
            sqrt.((positive_variance + negative_variance) ./ n_replicates) ./
            (2 * force_step)
    end

    return (conductivity=conductivity, standard_errors=standard_errors,
            force_step=Float64(force_step), n_replicates=Int(n_replicates),
            state_free_energy_change=Float64(state_free_energy_change),
            temperature=Float64(temperature))
end

function main()
    temperature = 298.15 # K
    affinity_step = 298.15 # J mol^-1
    force_step = affinity_step / temperature # J mol^-1 K^-1
    site_concentration = 0.2 # mol sites m^-3
    rate_constants = [2.0, 3.0] # s^-1 per site
    estimate = estimate_two_pathway_conductivity(
        rate_constants; site_count=1000, site_concentration=site_concentration,
        n_replicates=4, burn_in=2.0, measurement_duration=400.0,
        force_step=force_step, seed=20261027)
    exact = exact_two_pathway_conductivity(rate_constants, site_concentration)

    println("Two-pathway reversible Gillespie mock")
    println("Temperature: $temperature K")
    println("Rate constants (s^-1): $rate_constants")
    println("Site concentration (mol m^-3): $site_concentration")
    println("Affinity perturbation: $affinity_step J mol^-1")
    println("Force perturbation: $(estimate.force_step) J mol^-1 K^-1")
    println("Estimated Onsager matrix (mol^2 K J^-1 m^-3 s^-1):")
    display(estimate.conductivity)
    println("Monte Carlo standard errors:")
    display(estimate.standard_errors)
    println("Exact near-equilibrium matrix:")
    display(exact)
    println("Relative reciprocity residual: $(norm(estimate.conductivity - estimate.conductivity') / norm(estimate.conductivity))")
    println("Minimum eigenvalue of estimated symmetric part: $(minimum(eigvals(Symmetric((estimate.conductivity + estimate.conductivity') / 2))))")
    println("The mock coefficients are illustrative, not empirically calibrated.")
end

end # module ReversibleOnsagerMock

if abspath(PROGRAM_FILE) == abspath(@__FILE__)
    ReversibleOnsagerMock.main()
end
