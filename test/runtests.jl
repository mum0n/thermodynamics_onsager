using Test
using LinearAlgebra
using Random
using Statistics
using DataFrames

include(joinpath(@__DIR__, "..", "src", "onsagernetwork.jl"))
using .OnsagerNetwork

@testset "OnsagerNetwork" begin

    @testset "biovolume_concentration sums to 1" begin
        b, V = biovolume_concentration([10.0, 20.0, 30.0])
        @test isapprox(sum(b), 1.0; atol=1e-12)
        @test V == 60.0
        @test all(b .>= 0)
    end

    @testset "intensive_thermodynamics: L pd, sigma>=0" begin
        Random.seed!(1)
        N = [120.0, 40.0, 12.0]
        masses = [0.01, 0.05, 1.5]
        Araw = [-0.1 0.02 -0.5; 0.01 -0.2 -0.3; 0.2 0.1 -0.05]
        Nstar = [100.0, 50.0, 10.0]
        th = intensive_thermodynamics(N, masses, Araw, Nstar)
        @test minimum(real(eigvals(th.L_matrix))) > 0
        @test th.sigma_dagger >= 0
        @test 0 <= compute_matrix_asymmetry(th.L_raw) <= 2
        # sigma for arbitrary X non-negative
        X = randn(3)
        @test X' * th.L_matrix * X >= -1e-12
    end

    @testset "calculate_thermodynamic_matrices: pd + reproducibility" begin
        params = Dict(:species_ref_masses => [0.01, 0.05, 1.5],
                      :interaction_matrix => [-0.1 0.02 -0.5; 0.01 -0.2 -0.3; 0.2 0.1 -0.05],
                      :carrying_capacities => fill(1000.0, 3))
        N = [120.0, 40.0, 12.0]
        step = (x, p) -> run_ibm_step(x, p)
        r1 = calculate_thermodynamic_matrices(N, step, params)
        r2 = calculate_thermodynamic_matrices(N, step, params)
        @test r1.L == r2.L
        @test minimum(real(eigvals(r1.L))) >= 0
        @test r1.L_raw isa AbstractMatrix
    end

    @testset "persistent_asymmetry" begin
        @test persistent_asymmetry([0.0, 0.0, 0.0]) == false
        @test persistent_asymmetry([0.3, 0.3, 0.3]) == true
        @test persistent_asymmetry([0.3, 0.1, 0.3, 0.3, 0.3]) == true
        @test persistent_asymmetry([0.3, 0.3]) == false  # min_run=3
    end

    @testset "asymmetry_null length" begin
        Ls = [rand(3,3)]
        n = asymmetry_null(Ls; n_perm=5)
        @test length(n) == 5
        @test all(0 .<= n .<= 2)
    end

    @testset "ecosystem_simulation runs" begin
        opts = simulation_options(n_species=4, duration=5.0, dt=1.0, aggregation=5.0)
        res = ecosystem_simulation(opts)
        @test res.biomass isa Any
        @test nrow(res.biomass) >= 1
    end

    @testset "gillespie non-negative counts" begin
        ep = EcoThermodynamicParams(3, [10.0,3.0,0.5],[2.0,0.8,0.1],[0.01,0.02,0.05],
            [0.0 0.0 0.0; 0.1 0.0 0.0; 0.0 0.05 0.0],[1.0,10.0,100.0],100.0,0.2,1.0)
        t, Nh, bh, AFh = run_gillespie_eco_thermo([500,50,5], ep, 2.0)
        @test all(Nh) do n; all(x -> x >= 0, n); end
        @test length(t) == length(Nh)
    end

end
