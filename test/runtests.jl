using Test
using LinearAlgebra
using Random

include(joinpath(@__DIR__, "..", "src", "onsagernetwork.jl"))
using .OnsagerNetwork

include(joinpath(@__DIR__, "..", "thermodynamics_onsager.jl"))

@testset "OnsagerNetwork" begin

    @testset "1. Matrix asymmetry and thermodynamic primitives (Section 2)" begin
        M = [1.0 2.0 0.0; 0.0 1.0 3.0; 4.0 0.0 1.0]
        asym = matrix_asymmetry(M)
        @test asym.A_F ≈ norm(M - M') / norm(M)
        @test asym.symmetric + asym.skew ≈ M
        @test isapprox(asym.symmetric, asym.symmetric'; atol=1e-12)
        @test isapprox(asym.skew, -asym.skew'; atol=1e-12)
        @test_throws DimensionMismatch matrix_asymmetry(ones(2, 3))

        @test persistent_asymmetry([0.0, 0.0, 0.0]) == false
        @test persistent_asymmetry([0.3, 0.3, 0.3]) == true
        @test persistent_asymmetry([0.3, 0.1, 0.3, 0.3, 0.3]) == true
        @test persistent_asymmetry([0.3, 0.3]; min_run=3) == false
        @test_throws ArgumentError persistent_asymmetry([0.1, NaN, 0.3])

        null_vals = asymmetry_null([M]; n_perm=20, rng=MersenneTwister(12))
        @test length(null_vals) == 20
        @test all(0 .<= null_vals .<= 2)
        @test_throws DimensionMismatch asymmetry_null([ones(2, 3)])

        # Extremum entropy production at fixed forces vs fixed flows (Reis 2014)
        L0 = [2.0 0.5; 0.5 1.0]
        M_curv = [1.0 0.2; 0.2 0.5]
        X = [0.7, -0.3]
        J = [0.4, 0.9]
        d2L = -2.0 .* M_curv

        @test entropy_production(L0, X; constraint=:forces) ≈ dot(X, L0 * X)
        @test entropy_production(L0, J; constraint=:flows) ≈ dot(J, L0 \ J)

        curv_X = entropy_production_curvature(L0, d2L, X; constraint=:forces)
        curv_J = entropy_production_curvature(L0, d2L, J; constraint=:flows)
        @test curv_X.regime == :maximum
        @test curv_J.regime == :minimum
        @test curv_X.d2sigma < 0
        @test curv_J.d2sigma > 0

        # Rank-deficient L is admissible under fixed forces, rejected under fixed flows
        L_sing = [1.0 1.0; 1.0 1.0]
        @test entropy_production(L_sing, [1.0, 1.0]; constraint=:forces) ≈ 4.0
        @test entropy_production(L_sing, [1.0, -1.0]; constraint=:forces) ≈ 0.0 atol=1e-14
        @test_throws ArgumentError entropy_production(L_sing, [1.0, 1.0]; constraint=:flows)

        # Le Chatelier-Braun Schur complement moderation (eq. 43)
        schur_1 = schur_effective_conductivity(L0, 1)
        @test schur_1.L_ii == 2.0
        @test schur_1.L_ii_eff ≈ 2.0 - 0.5^2 / 1.0
        @test schur_1.L_ii_eff < schur_1.L_ii
        @test schur_1.R_ii_unclamped < schur_1.R_ii_clamped
        @test_throws ArgumentError schur_effective_conductivity(L_sing, 1)
    end

    @testset "2. Community Matrix <-> Onsager Conductivity Bridge (Section 3)" begin
        # Worked two-pool synthetic example (eqs. 20-22)
        B = [-1.0 -1.0; 1.0 0.0]
        H = [2.0 0.5; 0.5 1.0]
        L = [1.0 0.2; 0.2 0.5]

        fwd = forward_community_matrix(L, H; B=B)
        @test fwd.L_x ≈ [1.9 -1.2; -1.2 1.0]
        @test fwd.A ≈ [-3.2 0.25; 1.9 -0.4]
        @test isapprox(fwd.A_F_A, 0.6220; atol=1e-3)
        @test isapprox(fwd.A_F_Lx, 0.0; atol=1e-14)
        @test all(real.(fwd.eigenvalues_A) .< 0)

        inv_sq = inverse_onsager_conductivity(fwd.A, H; B=B)
        @test inv_sq.regime == :square_invertible
        @test inv_sq.L_x ≈ fwd.L_x
        @test inv_sq.L ≈ L

        inv_dense = inverse_onsager_conductivity(fwd.A, H)
        @test inv_dense.regime == :dense_pool
        @test inv_dense.L ≈ fwd.L_x

        # Rectangular rank-deficient stoichiometry (eq. 19)
        B_rect = [1.0 1.0; 0.0 1.0; -1.0 0.0]' # 2 x 3
        L_3 = Matrix{Float64}(I, 3, 3)
        fwd_rect = forward_community_matrix(L_3, H; B=B_rect)
        inv_rect = inverse_onsager_conductivity(fwd_rect.A, H; B=B_rect)
        @test inv_rect.regime == :rank_deficient_pseudoinverse
        @test B_rect * inv_rect.L * B_rect' ≈ fwd_rect.L_x

        demo_bridge = run_stoichiometric_inversion_demo()
        @test demo_bridge.forward.A ≈ fwd.A
        @test demo_bridge.inverse.L ≈ L
        @test demo_bridge.naive_asymmetry.A_F ≈ fwd.A_F_A
    end

    @testset "3. Canonical Estimator & Physical Thermal Network (Sections 4 & 5.1)" begin
        model = ThermalTwoMode()
        mats = thermal_network_matrices(model)

        @test maximum(abs.(mats.A + mats.L * mats.H)) <= 1e-15 * norm(mats.A)
        @test mats.H ≈ k_B .* inv(mats.C)
        @test mats.D ≈ k_B .* mats.L
        @test mats.K_cov ≈ mats.D
        @test norm(mats.Omega) <= 1e-12 * norm(mats.D)
        @test mats.sigma < 1e-45

        # Driven non-reciprocal steady state (kappa = 0.5)
        driven = thermal_network_matrices(model; kappa=0.5)
        @test 0.5 .* (driven.K_cov .+ driven.K_cov') ./ k_B ≈ mats.L
        @test norm(driven.Omega) > 0
        @test driven.sigma > 0
        @test isapprox(driven.sigma, 1.4524e-23; rtol=1e-3)

        # Exact innovation-to-diffusion quadrature inversion
        dt = 0.02
        Phi = exp(mats.A .* dt)
        Q = mats.C - Phi * mats.C * Phi'
        @test Matrix(diffusion_from_innovation(mats.A, Q, dt)) ≈ mats.D rtol=1e-10

        # Trajectory simulation and canonical estimation
        X_data = simulate_ou_process(
            mats.A, mats.D; dt=0.05, n_steps=20_000, C=mats.C,
            rng=MersenneTwister(11))
        est = estimate_ou_onsager(X_data; dt=0.05, scale=k_B)
        @test norm(est.L_x - mats.L) / norm(mats.L) < 0.10
        @test norm(est.L_from_D - mats.L) / norm(mats.L) < 0.10
        @test norm(est.H - mats.H) / norm(mats.H) < 0.15
        @test est.lyapunov_residual < 0.05
        @test est.drift_stable
        @test est.psd_within_roundoff

        # Tensor covariance under linear transformation y = Lambda * x (eq. 30)
        Lambda = Diagonal([2.0, 0.5])
        Y_data = X_data * Matrix(Lambda)'
        est_Y = estimate_ou_onsager(Y_data; dt=0.05, scale=k_B)
        L_Y_exact = Matrix(Lambda) * mats.L * Matrix(Lambda)'
        @test norm(est_Y.L_x - L_Y_exact) / norm(L_Y_exact) < 0.10

        # Silent rescaling under non-thermal noise (alpha = 4.0)
        mats_alpha = thermal_network_matrices(model; noise_scale=4.0)
        X_alpha = simulate_ou_process(
            mats_alpha.A, mats_alpha.D; dt=0.05, n_steps=20_000, C=mats_alpha.C,
            rng=MersenneTwister(11))
        est_alpha = estimate_ou_onsager(X_alpha; dt=0.05, scale=k_B)
        @test est_alpha.L_x ≈ 4.0 .* est.L_x rtol=1e-8
        @test est_alpha.lyapunov_residual ≈ est.lyapunov_residual rtol=1e-8

        # 4-mode marginal coarse-graining (eq. 31)
        C4_heat = [1.0, 2.0, 1.5, 0.8]
        G4 = [1.10 -0.30 -0.20 -0.10;
             -0.30  1.00 -0.40 -0.10;
             -0.20 -0.40  1.20 -0.30;
             -0.10 -0.10 -0.30  0.90]
        H4 = Matrix(Diagonal(1.0 ./ (C4_heat .* (model.T^2))))
        L4 = (model.T^2) .* G4
        A4 = -L4 * H4
        C4 = Matrix(solve_lyapunov_covariance(A4, k_B .* L4))

        L11_cont = marginal_coarse_grained_conductivity(A4, C4, 1:2; dt=0.0, scale=k_B)
        @test L11_cont ≈ L4[1:2, 1:2] rtol=1e-12
        L11_dt = marginal_coarse_grained_conductivity(A4, C4, 1:2; dt=0.02, scale=k_B)
        bias_02 = norm(L11_dt - L4[1:2, 1:2]) / norm(L4[1:2, 1:2])
        @test 8.0e-4 < bias_02 < 1.2e-3
    end

    @testset "4. Reversible Gillespie & Evolving Trait Models (Sections 5.2-5.3)" begin
        kappa = [2.0, 3.0]
        c_s = 0.2
        L_exact = exact_two_pathway_conductivity(kappa, c_s)
        @test L_exact ≈ L_exact'
        @test L_exact * ones(2) ≈ zeros(2) atol=1e-14
        @test minimum(eigvals(Symmetric(L_exact))) >= -1e-14
        @test equilibrium_occupancy_fraction(0.0) == 0.5
        @test equilibrium_occupancy_fraction(-R_GAS * 298.15) > 0.5

        sim1 = simulate_channel_current_density(
            [0.5, 0.0], kappa; N_sites=40, c_s=c_s, burn_in=0.2, T_obs=2.0,
            rng=MersenneTwister(31))
        sim2 = simulate_channel_current_density(
            [0.5, 0.0], kappa; N_sites=40, c_s=c_s, burn_in=0.2, T_obs=2.0,
            rng=MersenneTwister(31))
        @test sim1 == sim2

        est = estimate_two_pathway_conductivity(
            kappa; N_sites=40, c_s=c_s, n_replicates=2, burn_in=0.2,
            T_obs=2.0, delta_X=0.5, seed=32)
        @test size(est.L) == (2, 2)
        @test all(isfinite, est.L)
        @test all(>=(0), est.standard_errors)

        evo1 = simulate_evolving_conductivity(
            n_epochs=3, epoch_duration=3.0, T_obs=1.0, N_sites=40, c_s=0.2,
            n_replicates=2, burn_in=0.2, theta_0=-0.4, theta_star=0.4,
            s=0.25, sigma_theta=0.0, seed=41)
        evo2 = simulate_evolving_conductivity(
            n_epochs=3, epoch_duration=3.0, T_obs=1.0, N_sites=40, c_s=0.2,
            n_replicates=2, burn_in=0.2, theta_0=-0.4, theta_star=0.4,
            s=0.25, sigma_theta=0.0, seed=41)
        @test evo1.theta ≈ [-0.4, -0.2, -0.05]
        @test evo1.L_hat == evo2.L_hat
        @test evo1.p_occ_eq[1] > evo1.p_occ_eq[end]
    end

    @testset "5. Ecological Networks, Mock OU & Cone Spring (Sections 3.3, 5.4, 6)" begin
        b, B_tot = normalize_biomass([10.0, 20.0, 30.0])
        @test sum(b) ≈ 1.0
        @test B_tot == 60.0
        @test_throws ArgumentError normalize_biomass([0.0, 0.0])
        @test_throws ArgumentError normalize_biomass([1.0, -1.0])

        N = [120.0, 40.0, 12.0]
        M = [0.01, 0.05, 1.5]
        A = [-0.1 0.02 -0.5; 0.01 -0.2 -0.3; 0.2 0.1 -0.05]
        w_res = weighted_interaction_matrix(N, M, A; k=0.25)
        @test w_res.W ≈ Diagonal(M .^ (-0.25)) * A * Diagonal(w_res.b)
        @test w_res.W_B ≈ A * Diagonal(w_res.b)
        @test w_res.A_F ≈ matrix_asymmetry(w_res.W).A_F

        sens = sensitivity_allometry(N, M, A; exponents=[0.20, 0.30])
        @test keys(sens) == Set([0.20, 0.30])

        params = (M = M, A = A, K = fill(1000.0, 3), k = 0.25)
        j_diag = biomass_jacobian_diagnostic([120.0, 40.0, 12.0], biomass_rate, params)
        @test j_diag.W_B ≈ j_diag.A * Diagonal(j_diag.b)

        # Synthetic 3-species OU mock (Table 6)
        mock = run_population_response_mock()
        @test isapprox(mock.A_F_A, 0.0582; atol=1e-3)
        @test isapprox(mock.A_F_WB, 0.3405; atol=1e-3)
        @test isapprox(mock.A_F_W, 0.6522; atol=1e-3)
        @test isapprox(mock.min_eig_neg_sym_WB, 0.0186; atol=1e-3)
        @test mock.rel_error_K_cov < 0.05
        @test mock.estimate.drift_stable
        @test mock.estimate.psd_within_roundoff

        # Published Cone Spring community matrix analysis (Tables 2 & 6, eqs. 22a-c, 39b-c)
        cs = analyze_cone_spring()
        A_CS = cs.network.A
        @test all(real.(cs.eigenvalues_A) .< 0)
        @test A_CS[1, 2] < 0 && A_CS[2, 1] > 0
        @test A_CS[2, 3] < 0 && A_CS[3, 2] > 0
        @test cs.L_naive[1, 2] ≈ 75.0
        @test cs.L_naive[2, 3] ≈ 370.0
        @test cs.L_naive[3, 2] ≈ -167.0
        @test isapprox(minimum(cs.L_naive_sym_eigs), -29.163; atol=1e-2)
        @test isapprox(cs.min_eig_neg_sym_WB, -0.1506; atol=1e-3)
        @test 0.5 .* (cs.K_cov .+ cs.K_cov') ≈ cs.D
        @test isapprox(cs.min_sym_eig_K_cov, 345.10; atol=1e-2)
        @test isapprox(cs.circulation_rate, 90.3527; atol=1e-2)
        @test cs.C[1, 3] < 0  # Indirect trophic cascade covariance
        @test cs.Omega[1, 3] != 0  # Indirect 3-step circulation
        @test cs.rel_error_K_cov < 0.05
        @test cs.estimate.drift_stable
        @test cs.estimate.psd_within_roundoff

        # VAR and demographic jump process
        var_rng = MersenneTwister(27)
        Phi_var = [0.55 0.10; -0.15 0.35]
        X_var = zeros(400, 2)
        for t in 2:size(X_var, 1)
            X_var[t, :] = Phi_var * X_var[t - 1, :] + 0.15 .* randn(var_rng, 2)
        end
        var_fit = fit_var(X_var; p=1)
        @test size(var_fit.lags[1]) == (2, 2)
        roll = rolling_var_asymmetry(X_var; window=100, p=1, step=100)
        @test length(roll.A_F) == 4
        boot = bootstrap_var_asymmetry(
            X_var[1:200, :]; p=1, n_boot=10, block_length=10,
            rng=MersenneTwister(5))
        @test boot.interval.lower <= boot.interval.upper

        jump_params = PopulationJumpParams(
            r=[10.0, 3.0, 0.5],
            d=[2.0, 0.8, 0.1],
            c=[0.01, 0.02, 0.05],
            gamma=[0.0 0.0 0.0; 0.1 0.0 0.0; 0.0 0.05 0.0],
            M=[1.0, 10.0, 100.0],
            V=100.0,
            epsilon=0.2)
        jump_res = run_gillespie_population(
            [500, 50, 5], jump_params, 2.0; rng=MersenneTwister(8))
        @test all(N_vec -> all(>=(0), N_vec), jump_res.N_history)
        @test all(jump_res.time .<= 2.0)
    end

    @testset "6. Metabolic size spectra and size-class responses" begin
        spectrum_params = SizeSpectrumParams(
            m_min=1.0, m_max=10.0, abundance_scale=2.0,
            abundance_exponent=1.0, metabolic_scale=3.0,
            metabolic_exponent=1.0, temperature=300.0,
            reference_mass=1.0)
        indices = compute_size_spectrum_indices(spectrum_params; n_bins=10_001)
        @test indices.beta == 0.0
        @test indices.biomass_total ≈ 18.0 rtol=1e-7
        @test indices.power_total ≈ 54.0 rtol=1e-7
        @test indices.entropy_production_proxy ≈ 0.18 rtol=1e-7
        @test indices.specific_power_proxy ≈ 3.0 rtol=1e-7
        @test_throws ArgumentError SizeSpectrumParams(m_min=0.0)
        @test_throws ArgumentError compute_size_spectrum_indices(spectrum_params; n_bins=1)

        filtering = simulate_size_spectrum_filtering(
            spectrum_params; n_scales=4, duration=1.0, dt=0.1,
            frequencies=[0.0], amplitudes=[1.0], reference_time=0.5)
        @test size(filtering.response) == (11, 4)
        @test all(iszero, filtering.response)
        @test all(diff(filtering.response_time) .>= 0)

        wave = simulate_size_spectrum_wave(
            spectrum_params; n_bins=20, duration=1.0, dt=0.05,
            transport_rate=0.15, snapshot_times=[0.0, 0.5, 1.0])
        @test size(wave.relative_anomaly) == (20, 3)
        @test length(wave.potential) == 21
        @test all(diff(wave.potential) .<= 1e-12)
        @test wave.potential[end] < wave.potential[1]
        @test_throws ArgumentError simulate_size_spectrum_wave(
            spectrum_params; n_bins=20, duration=1.0, dt=0.05,
            snapshot_times=[0.0, 0.01])

        demo = run_size_spectrum_demo()
        @test demo.indices.beta ≈ 0.20
        @test last(demo.perturbation.potential) < first(demo.perturbation.potential)
    end

    @testset "7. Illustrative NPZD and NPZD–fish models" begin
        npzd_params = NPZDParams()
        npzd_reference = npzd_reference_state(npzd_params)
        npzd = npzd_diagnostics(npzd_params)
        @test all(>(0), npzd_reference.state)
        @test npzd_reference.nutrient_input > 0
        @test norm(npzd_rhs(npzd_reference.state, npzd_params)) < 1e-12
        @test all(real.(npzd.eigenvalues) .< 0)
        @test isposdef(Symmetric(npzd.C))
        @test isposdef(Symmetric(npzd.D))
        @test npzd.lyapunov_residual < 1e-12
        @test npzd.decomposition.K_cov ≈ npzd.D - npzd.decomposition.Omega
        @test isfinite(npzd.decomposition.circulation_rate)

        fish_params = NPZDFishParams()
        fish_reference = npzd_fish_reference_state(fish_params)
        fish = npzd_fish_diagnostics(fish_params)
        @test all(>(0), fish_reference.state)
        @test fish_reference.nutrient_input > 0
        @test norm(npzd_fish_rhs(fish_reference.state, fish_params)) < 1e-12
        @test npzd_fish_rhs(fish_reference.state, fish_params;
                            harvest_multiplier=2.0)[5] ≈
              -fish_params.harvest_mortality * fish_reference.state[5]
        @test all(real.(fish.eigenvalues) .< 0)
        @test isposdef(Symmetric(fish.C))
        @test isposdef(Symmetric(fish.D))
        @test fish.lyapunov_residual < 1e-12
        @test fish.decomposition.K_cov ≈ fish.D - fish.decomposition.Omega
        @test isfinite(fish.decomposition.circulation_rate)

        harvest = simulate_npzd_fish_harvest(
            fish_params; duration=0.02, dt=0.001, harvest_time=0.01,
            rng=MersenneTwister(53))
        @test size(harvest.states) == (21, 5)
        @test all(isfinite, harvest.states)
        @test harvest.states[1, :] ≈ fish_reference.state
        @test_throws ArgumentError NPZDParams(nutrient_reference=0.0)
    end

end
