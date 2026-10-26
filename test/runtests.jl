using Test
using LinearAlgebra
using Random

using DataFrames

include(joinpath(@__DIR__, "..", "src", "onsagernetwork.jl"))
using .OnsagerNetwork
include(joinpath(@__DIR__, "..", "examples", "reversible_onsager_mock.jl"))
using .ReversibleOnsagerMock
include(joinpath(@__DIR__, "..", "examples", "evolving_onsager_mock.jl"))
using .EvolvingOnsagerMock

@testset "OnsagerNetwork" begin

    @testset "normalize_biomass returns fractions and total" begin
        fractions, total_biomass = normalize_biomass([10.0, 20.0, 30.0])
        @test isapprox(sum(fractions), 1.0; atol=1e-12)
        @test total_biomass == 60.0
        @test all(fractions .>= 0)
        @test_throws ArgumentError normalize_biomass([0.0, 0.0])
        @test_throws ArgumentError normalize_biomass([1.0, -1.0])
    end

    @testset "weighted interaction matrix is not regularized" begin
        abundances = [120.0, 40.0, 12.0]
        body_masses = [0.01, 0.05, 1.5]
        interaction_matrix = [-0.1 0.02 -0.5; 0.01 -0.2 -0.3; 0.2 0.1 -0.05]
        result = weighted_interaction_matrix(abundances, body_masses, interaction_matrix)
        expected = -Diagonal(body_masses .^ (-0.25)) * interaction_matrix *
                   Diagonal(result.biomass_fractions)
        @test result.weighted_matrix ≈ expected
        @test result.mass_exponent == 0.25
        @test isapprox(sum(result.biomass_fractions), 1.0)
        @test result.asymmetry ≈ matrix_asymmetry(expected).index
        @test_throws DimensionMismatch weighted_interaction_matrix(
            abundances, body_masses[1:2], interaction_matrix)
        exponent_diagnostics = sensitivity_allometry(
            abundances, body_masses, interaction_matrix; exponents=[0.2, 0.3])
        @test keys(exponent_diagnostics) == Set([0.2, 0.3])
        @test all(x -> x.matrix_norm >= 0, values(exponent_diagnostics))
        @test all(x -> x.asymmetry isa Float64, values(exponent_diagnostics))
    end

    @testset "biomass Jacobian diagnostic preserves raw output" begin
        model_parameters = Dict(
            :reference_masses => [0.01, 0.05, 1.5],
            :interaction_matrix => [-0.1 0.02 -0.5; 0.01 -0.2 -0.3; 0.2 0.1 -0.05],
            :carrying_capacities => fill(1000.0, 3))
        state_biomasses = [120.0, 40.0, 12.0]
        result = biomass_jacobian_diagnostic(
            state_biomasses, ibm_biomass_rate, model_parameters)
        @test result.weighted_matrix ≈
              -result.jacobian * Diagonal(result.biomass_fractions)
        @test result.total_biomass == sum(state_biomasses)
        @test result.asymmetry ≈ matrix_asymmetry(result.weighted_matrix).index
        @test_throws ArgumentError biomass_jacobian_diagnostic(
            zeros(3), ibm_biomass_rate, model_parameters)
    end

    @testset "persistent_asymmetry" begin
        @test persistent_asymmetry([0.0, 0.0, 0.0]) == false
        @test persistent_asymmetry([0.3, 0.3, 0.3]) == true
        @test persistent_asymmetry([0.3, 0.1, 0.3, 0.3, 0.3]) == true
        @test persistent_asymmetry([0.3, 0.3]) == false  # min_run=3
        @test_throws ArgumentError persistent_asymmetry([0.1, NaN, 0.3])
    end

    @testset "asymmetry_null breaks row/column pairing" begin
        Ls = [[1.0 2.0 0.0; 0.0 1.0 3.0; 4.0 0.0 1.0]]
        n = asymmetry_null(Ls; n_perm=20, rng=MersenneTwister(12))
        @test length(n) == 20
        @test all(0 .<= n .<= 2)
        @test length(unique(round.(n; digits=8))) > 1
        @test_throws DimensionMismatch asymmetry_null([rand(2, 3)])
    end

    @testset "VAR estimation and time-series uncertainty" begin
        Random.seed!(27)
        A = [0.55 0.10; -0.15 0.35]
        series = zeros(400, 2)
        for t in 2:size(series, 1)
            series[t, :] = A * series[t - 1, :] + 0.15 .* randn(2)
        end
        model = fit_var(series; p=1)
        for i in 1:2, j in 1:2
            @test abs(model.lags[1][i, j] - A[i, j]) <= 3 * model.standard_errors[j + 1, i]
        end
        @test size(model.standard_errors) == (3, 2)
        @test size(model.residuals) == (399, 2)
        rolling = rolling_var_asymmetry(series; window=100, p=1, step=50)
        @test length(rolling.asymmetry) == 7
        boot = bootstrap_var_asymmetry(series; p=1, n_boot=20, block_length=8,
                                       rng=MersenneTwister(5))
        @test length(boot.bootstrap_samples) == 20
        @test boot.interval.lower <= boot.interval.upper
        @test_throws ArgumentError fit_var(series[1:4, :]; p=1)

        dt = 1.0
        decay = exp.([-0.1, -0.3] .* dt)
        innovation_sd = sqrt.(1 .- decay .^ 2)
        stationary = zeros(2000, 2)
        stationary[1, :] = randn(2)
        for t in 2:size(stationary, 1)
            stationary[t, :] = decay .* stationary[t - 1, :] .+ innovation_sd .* randn(2)
        end
        population_result = estimate_population_covariance_weighted_drift(stationary; dt=dt)
        @test population_result.drift_stable
        @test population_result.covariance_weighted_drift ≈
              -population_result.drift * population_result.covariance
        @test isapprox(population_result.symmetric_part, population_result.symmetric_part'; atol=1e-12)
        @test isfinite(population_result.asymmetry)
        @test isfinite(population_result.minimum_symmetric_eigenvalue)
        @test population_result.symmetric_part_psd_within_roundoff
        @test_throws ArgumentError estimate_population_covariance_weighted_drift(
            hcat(stationary[:, 1], stationary[:, 1]); dt=dt)
    end

    @testset "three-state linear relaxation" begin
        K = Diagonal([0.2, 0.5, 1.0])
        result = simulate_three_state_relaxation(K, [1.0, -2.0, 0.5]; dt=0.1, t_end=2.0)
        @test size(result.deviation) == (21, 3)
        @test size(result.rate) == (21, 3)
        @test result.quadratic_diagnostic[end] < result.quadratic_diagnostic[1]
        @test isapprox(result.deviation[end, :], exp.(-2 .* diag(K)) .* [1.0, -2.0, 0.5])
        @test_throws ArgumentError simulate_three_state_relaxation([1.0 1 0; 0 1 0; 0 0 1], ones(3))
        @test_throws ArgumentError simulate_three_state_relaxation(Diagonal([1.0, -1.0, 1.0]), ones(3))
        tiny_negative_mode = simulate_three_state_relaxation(
            Diagonal([1.0, 1.0, -1e-12]), [0.0, 0.0, 1.0]; dt=0.1, t_end=0.1)
        @test tiny_negative_mode.quadratic_diagnostic[1] == -1e-12
        @test tiny_negative_mode.deviation[end, 3] > 1.0
    end

    @testset "ecosystem_simulation runs" begin
        options = simulation_options(n_species=4, simulation_duration=5.0,
                                     time_step=1.0, output_interval=5.0,
                                     rng=MersenneTwister(4))
        simulation_result = ecosystem_simulation(options)
        @test simulation_result.biomass isa DataFrame
        @test simulation_result.parameters === options.parameters
        @test nrow(simulation_result.biomass) >= 1
        @test :time in propertynames(simulation_result.biomass)
        @test :weighted_jacobian_asymmetry in propertynames(simulation_result.metrics)
    end

    @testset "agent simulation is reproducible and records exact endpoint" begin
        first_options = simulation_options(
            n_species=3, simulation_duration=2.5, time_step=1.0,
            output_interval=1.5, rng=MersenneTwister(18))
        second_options = simulation_options(
            n_species=3, simulation_duration=2.5, time_step=1.0,
            output_interval=1.5, rng=MersenneTwister(18))
        first_result = ecosystem_simulation(first_options)
        second_result = ecosystem_simulation(second_options)

        @test first_result.biomass == second_result.biomass
        @test first_result.biomass.time == [0.0, 2.0, 2.5]
    end

    @testset "reversible Gillespie Onsager mock" begin
        rate_constants = [2.0, 3.0]
        site_concentration = 0.2
        exact_conductivity = exact_two_pathway_conductivity(
            rate_constants, site_concentration)
        @test exact_conductivity ≈ exact_conductivity'
        @test exact_conductivity * ones(2) ≈ zeros(2) atol=1e-14
        @test minimum(eigvals(Symmetric(exact_conductivity))) >= -1e-14
        @test equilibrium_occupancy_fraction(0.0) == 0.5
        @test equilibrium_occupancy_fraction(-GAS_CONSTANT * 298.15) > 0.5
        nonzero_gap_conductivity = exact_two_pathway_conductivity(
            rate_constants, site_concentration;
            state_free_energy_change=GAS_CONSTANT * 298.15 * 0.6)
        @test nonzero_gap_conductivity ≈ nonzero_gap_conductivity'
        @test norm(nonzero_gap_conductivity) < norm(exact_conductivity)

        simulation_arguments = (
            site_count=40, site_concentration=site_concentration, burn_in=0.2,
            measurement_duration=2.0)
        first_simulation = simulate_channel_current_density(
            [0.5, 0.0], rate_constants; simulation_arguments...,
            rng=MersenneTwister(31))
        repeated_simulation = simulate_channel_current_density(
            [0.5, 0.0], rate_constants; simulation_arguments...,
            rng=MersenneTwister(31))
        @test first_simulation == repeated_simulation
        @test all(isfinite, first_simulation.current_density)

        test_temperature = 298.15
        test_state_gap = GAS_CONSTANT * test_temperature * 0.6
        estimated_conductivity = estimate_two_pathway_conductivity(
            rate_constants; site_count=40, site_concentration=site_concentration,
            n_replicates=2, burn_in=0.2, measurement_duration=2.0,
            state_free_energy_change=test_state_gap,
            temperature=test_temperature, force_step=0.5, seed=32)
        @test size(estimated_conductivity.conductivity) == (2, 2)
        @test all(isfinite, estimated_conductivity.conductivity)
        @test all(>=(0), estimated_conductivity.standard_errors)
        @test estimated_conductivity.state_free_energy_change == test_state_gap
        @test estimated_conductivity.temperature == test_temperature
    end

    @testset "slow trait evolution changes local Onsager response" begin
        evolving_arguments = (
            n_epochs=3, epoch_duration=3.0, measurement_duration=1.0,
            site_count=40, site_concentration=0.2, n_replicates=2,
            burn_in=0.2, initial_trait=-0.4, trait_optimum=0.4,
            selection_strength=0.25, mutation_sd=0.0, seed=41)
        first_evolution = simulate_evolving_local_conductivity(; evolving_arguments...)
        repeated_evolution = simulate_evolving_local_conductivity(; evolving_arguments...)

        @test first_evolution.trait ≈ [-0.4, -0.2, -0.05]
        @test first_evolution.trait == repeated_evolution.trait
        @test first_evolution.occupancy_fraction == repeated_evolution.occupancy_fraction
        @test first_evolution.conductivity == repeated_evolution.conductivity
        @test all(0 .<= first_evolution.occupancy_fraction .<= 1)
        @test first_evolution.equilibrium_occupancy_fraction[1] >
              first_evolution.equilibrium_occupancy_fraction[end]
        @test first_evolution.exact_conductivity[1] !=
              first_evolution.exact_conductivity[end]
    end

    @testset "gillespie non-negative counts" begin
        params = PopulationJumpParams(
            birth_rates=[10.0, 3.0, 0.5],
            death_rates=[2.0, 0.8, 0.1],
            competition_coefficients=[0.01, 0.02, 0.05],
            predation_coefficients=[0.0 0.0 0.0;
                                    0.1 0.0 0.0;
                                    0.0 0.05 0.0],
            body_masses=[1.0, 10.0, 100.0],
            volume=100.0,
            conversion_efficiency=0.2)
        result = run_gillespie_population([500, 50, 5], params, 2.0;
                                          rng=MersenneTwister(8))
        @test all(result.counts) do counts; all(>=(0), counts); end
        @test length(result.time) == length(result.counts) == length(result.biomass_density)
        @test all(result.time .<= 2.0)
        @test all(isfinite, reduce(vcat, result.biomass_density))
        short_result = run_gillespie_population([500, 50, 5], params, 1e-12;
                                                rng=MersenneTwister(9))
        @test all(short_result.time .<= 1e-12)
        @test short_result.stop_reason == :end_time
        @test_throws ArgumentError PopulationJumpParams(
            birth_rates=Float64[], death_rates=Float64[],
            competition_coefficients=Float64[], predation_coefficients=zeros(0, 0),
            body_masses=Float64[], volume=0.0, conversion_efficiency=0.0)
    end

end
