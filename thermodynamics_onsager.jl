# thermodynamics_onsager.jl
#  Demonstration and numerical verification suite for:
# "Onsager's relations and Ecology II: From community matrices to
#  phenomenological conductivities" (Choi 2026).
#
# This file consolidates all analytical and stochastic demonstrations of the
# paper into one self-contained driver script built on `src/onsagernetwork.jl`:
#   - Section 3.3: Synthetic two-pool stoichiometric inversion (eqs. 20-22)
#   - Section 5.1: Physical two-mode and four-mode thermal networks (Table 4)
#   - Section 5.2: Reversible two-pathway Gillespie reaction network (eqs. 34-37)
#   - Section 5.3: Fast-slow evolving trait conditional conductivity (Table 5)
#   - Section 5.4 & 6: Synthetic 3-species Ornstein-Uhlenbeck mock system and
#     published Cone Spring food-web community matrix analysis (Tables 2 & 6)
#   - Size-spectrum diagnostics: integrated biomass/power indices and
#     phenomenological size-dependent response models
#   - Illustrative four-pool NPZD and five-pool NPZD–fish diagnostics
#
# Run:
#   julia --project=. thermodynamics_onsager.jl

using LinearAlgebra
using Printf
using Random
using Statistics

if !isdefined(@__MODULE__, :OnsagerNetwork)
    include(joinpath(@__DIR__, "src", "onsagernetwork.jl"))
end
using .OnsagerNetwork

"""
    relative_error(estimate, exact)

Compute the relative Frobenius norm error
``\\|\\widehat{\\mathbf{M}} - \\mathbf{M}\\|_F / \\|\\mathbf{M}\\|_F`` between an
estimated matrix `estimate` and a reference matrix `exact`.

Inputs:
- `estimate`: Estimated real matrix.
- `exact`: Nonzero reference real matrix of matching dimensions.

Outputs:
Dimensionless relative Frobenius error.
"""
function relative_error(estimate::AbstractMatrix{<:Real},
                        exact::AbstractMatrix{<:Real})
    return norm(Matrix(estimate) - Matrix(exact)) / norm(Matrix(exact))
end

function print_matrix(label::AbstractString, mat::AbstractMatrix; digits::Int=6)
    println(label)
    display(round.(Matrix(mat); sigdigits=digits))
    println()
end

"""
    run_stoichiometric_inversion_demo()

Demonstrate the exact forward mapping
``\\mathbf{A} = -\\mathbf{B}\\mathbf{L}\\mathbf{B}^{\\mathsf{T}}\\mathbf{H} = -\\mathbf{L}_x\\mathbf{H}``
and congruence inversion ``\\mathbf{L}_x = -\\mathbf{A}\\mathbf{H}^{-1}``,
``\\mathbf{L} = \\mathbf{B}^{-1}\\mathbf{L}_x\\mathbf{B}^{-\\mathsf{T}}`` on the
synthetic two-pool reversible transport network of Section 3.3 (eqs. 20-22).

Outputs:
Named tuple `(B, H, L, forward, inverse, naive_asymmetry)` containing the
exact and recovered matrices and Frobenius asymmetry indices.
"""
function run_stoichiometric_inversion_demo()
    B = [-1.0 -1.0;
          1.0  0.0]
    H = [2.0 0.5;
         0.5 1.0]
    L = [1.0 0.2;
         0.2 0.5]

    fwd = forward_community_matrix(L, H; B=B)
    inv_res = inverse_onsager_conductivity(fwd.A, H; B=B)
    naive_asym = matrix_asymmetry(-fwd.A)

    return (
        B = B,
        H = H,
        L = L,
        forward = fwd,
        inverse = inv_res,
        naive_asymmetry = naive_asym,
    )
end

"""
    run_thermal_network_demo(; dt=0.02, n_steps=500_000, n_replicates=200,
                             kappa=0.5, noise_scale=4.0, seed=20261027)

Section 5.1 (Table 4, eqs. 32a-33):
- Single-trajectory recovery of ``\\mathbf{L}``, ``\\mathbf{D}/k_{\\mathrm{B}}``,
  and ``\\mathbf{H} = k_{\\mathrm{B}}\\mathbf{C}^{-1}`` on a two-mode network at
  ``T = 300\\,\\mathrm{K}``.
- Replicate reciprocity distribution under equilibrium (``\\kappa = 0``).
- Exact isolation of non-equilibrium circulation ``-\\boldsymbol{\\Omega}/k_{\\mathrm{B}}``
  and steady-state entropy production ``\\sigma`` under driven skew-symmetric
  coupling (``\\kappa = 0.5\\,\\mathrm{s^{-1}}``).
- Silent rescaling under non-thermal noise inflation (``\\alpha = 4.0``).
- Contravariant tensor transformation ``\\widehat{\\mathbf{L}}_y = \\boldsymbol{\\Lambda}\\widehat{\\mathbf{L}}_x\\boldsymbol{\\Lambda}^{\\mathsf{T}}``
  and four-mode marginal coarse-graining ``\\widehat{\\mathbf{L}}_{11,\\mathrm{eff}} \\to \\mathbf{L}_{11}``.

Inputs:
- `dt`: Sampling interval in seconds (default `0.02`).
- `n_steps`: Number of transitions in the primary single trajectory (default `500_000`).
- `n_replicates`: Number of independent replicate trajectories (default `200`).
- `kappa`: Driven non-reciprocal coupling in ``\\mathrm{s^{-1}}`` (default `0.5`).
- `noise_scale`: Non-thermal noise inflation factor ``\\alpha`` (default `4.0`).
- `seed`: Random seed for `MersenneTwister` (default `20261027`).

Outputs:
Named tuple summarizing all five experiments and their relative errors.
"""
function run_thermal_network_demo(
    ; dt::Real=0.02,
    n_steps::Integer=500_000,
    n_replicates::Integer=200,
    kappa::Real=0.5,
    noise_scale::Real=4.0,
    seed::Integer=20261027,
)
    model = ThermalTwoMode()
    T = model.T
    exact = thermal_network_matrices(model)

    # 1. Single stationary trajectory
    X_data = simulate_ou_process(
        exact.A, exact.D; dt=dt, n_steps=n_steps, C=exact.C,
        rng=MersenneTwister(seed))
    single_est = estimate_ou_onsager(X_data; dt=dt, scale=k_B)

    # 2. Equilibrium replicate study
    eq_replicates = replicate_thermal_study(
        model; n_replicates=n_replicates, dt=dt, seed=seed)

    # 3. Driven non-reciprocal steady state
    driven_exact = thermal_network_matrices(model; kappa=kappa)
    driven_replicates = replicate_thermal_study(
        model; n_replicates=n_replicates, dt=dt, seed=seed, kappa=kappa)

    # 4. Non-thermal noise inflation
    inflated_replicates = replicate_thermal_study(
        model; n_replicates=n_replicates, dt=dt, seed=seed,
        noise_scale=noise_scale)

    # 5. Linear coordinate reparameterization and 4-mode coarse-graining
    Lambda = Diagonal([2.0, 0.5])
    Y_data = X_data * Matrix(Lambda)'
    rescaled_est = estimate_ou_onsager(Y_data; dt=dt, scale=k_B)
    L_Y_exact = Matrix(Lambda) * exact.L * Matrix(Lambda)'

    C4_heat = [1.0, 2.0, 1.5, 0.8]
    G4 = [ 1.10 -0.30 -0.20 -0.10;
          -0.30  1.00 -0.40 -0.10;
          -0.20 -0.40  1.20 -0.30;
          -0.10 -0.10 -0.30  0.90]
    H4 = Matrix(Diagonal(1.0 ./ (C4_heat .* (T^2))))
    L4 = (T^2) .* G4
    A4 = -L4 * H4
    C4 = Matrix(solve_lyapunov_covariance(A4, k_B .* L4))
    L11_dt = marginal_coarse_grained_conductivity(A4, C4, 1:2; dt=dt, scale=k_B)

    return (
        model = model,
        exact = exact,
        single_est = single_est,
        err_Lx = relative_error(single_est.L_x, exact.L),
        err_D = relative_error(single_est.L_from_D, exact.L),
        err_H = relative_error(single_est.H, exact.H),
        eq_replicates = eq_replicates,
        driven_exact = driven_exact,
        driven_replicates = driven_replicates,
        inflated_replicates = inflated_replicates,
        err_tensor = relative_error(rescaled_est.L_x, L_Y_exact),
        err_untransformed = relative_error(rescaled_est.L_x, exact.L),
        L11_dt = L11_dt,
        L11_exact = L4[1:2, 1:2],
        err_coarse = relative_error(L11_dt, L4[1:2, 1:2]),
    )
end

"""
    run_reversible_gillespie_demo(; N_sites=1000, c_s=0.2, kappa=[2.0, 3.0],
                                  n_replicates=4, burn_in=2.0, T_obs=400.0,
                                  T=298.15, delta_X=1.0, seed=20261027)

Section 5.2 (eqs. 34-37):  two-path reversible Markov jump reaction network 
compare the finite-difference Gillespie estimate
``\\widehat{\\mathbf{L}}`` against the rank-1 analytical conductivity matrix
``\\mathbf{L}_{\\mathrm{mock}}``.

Outputs:
Named tuple `(estimate, L_exact, A_F, min_sym_eig)`.
"""
function run_reversible_gillespie_demo(
    ; N_sites::Integer=1000,
    c_s::Real=0.2,
    kappa::AbstractVector{<:Real}=[2.0, 3.0],
    n_replicates::Integer=4,
    burn_in::Real=2.0,
    T_obs::Real=400.0,
    T::Real=298.15,
    delta_X::Real=1.0,
    seed::Integer=20261027,
)
    est = estimate_two_pathway_conductivity(
        kappa; N_sites=N_sites, c_s=c_s, n_replicates=n_replicates,
        burn_in=burn_in, T_obs=T_obs, T=T, delta_X=delta_X, seed=seed)
    L_exact = exact_two_pathway_conductivity(kappa, c_s; T=T)
    asym = matrix_asymmetry(est.L)
    min_eig = minimum(eigvals(Symmetric(asym.symmetric)))
    return (
        estimate = est,
        L_exact = L_exact,
        A_F = asym.A_F,
        min_sym_eig = min_eig,
    )
end

"""
    run_evolving_trait_demo(; n_epochs=12, epoch_duration=200.0, T_obs=40.0,
                            N_sites=600, n_replicates=3, delta_X=1.0,
                            seed=20261028)

(Section 5.3, Table 5, eq. 38):  fast-slow evolutionary hierarchy trait-conditional conductivity
``\\widehat{L}_{11}(\\theta_k)`` across `n_epochs` evolutionary updates.
"""
function run_evolving_trait_demo(
    ; n_epochs::Integer=12,
    epoch_duration::Real=200.0,
    T_obs::Real=40.0,
    N_sites::Integer=600,
    n_replicates::Integer=3,
    delta_X::Real=1.0,
    seed::Integer=20261028,
)
    return simulate_evolving_conductivity(
        n_epochs=n_epochs, epoch_duration=epoch_duration, T_obs=T_obs,
        N_sites=N_sites, n_replicates=n_replicates, delta_X=delta_X,
        seed=seed)
end

"""
    run_population_response_mock(; dt=0.2, n_obs=20_000, seed=20261026)

Run the synthetic three-species reversible Ornstein-Uhlenbeck mock system of
Section 5.4 (Table 6, eq. 39a) and compare exact versus estimated
covariance-weighted drift ``\\mathbf{K}_{\\mathrm{cov}} = -\\mathbf{A}\\mathbf{C}``,
allometrically weighted interaction matrix ``\\mathbf{W}``, and
biomass-fraction weighted matrix ``\\mathbf{W}_B``.

Outputs:
Named tuple `(A, C, K_cov, eigenvalues_A, A_F_A, W, W_B, b, B_tot, A_F_W,
A_F_WB, min_eig_neg_sym_WB, allometric_sensitivity, estimate, abs_error_K_cov,
rel_error_K_cov)`.
"""
function run_population_response_mock(; dt::Real=0.2,
                                      n_obs::Integer=20_000,
                                      seed::Integer=20261026)
    C_mock = [1.00 0.35 0.10;
              0.35 1.40 0.20;
              0.10 0.20 0.80]
    K_cov_mock = [ 0.80 -0.10  0.05;
                  -0.10  0.60 -0.08;
                   0.05 -0.08  0.50]
    A_mock = -K_cov_mock / C_mock

    M_mock = [1.0, 10.0, 100.0]
    N_mock = [100.0, 50.0, 20.0]
    w_diag = weighted_interaction_matrix(N_mock, M_mock, A_mock)
    allom_sens = sensitivity_allometry(N_mock, M_mock, A_mock)
    min_eig_neg_sym_WB = minimum(eigvals(Symmetric(
        -0.5 .* (w_diag.W_B .+ transpose(w_diag.W_B)))))

    rng = MersenneTwister(seed)
    X_data = simulate_ou_process(
        A_mock, K_cov_mock; dt=dt, n_steps=n_obs - 1, C=C_mock, rng=rng)
    est = estimate_ou_onsager(X_data; dt=dt, scale=1.0)
    abs_err = norm(est.K_cov - K_cov_mock)
    rel_err = abs_err / norm(K_cov_mock)

    return (
        A = A_mock,
        C = C_mock,
        K_cov = K_cov_mock,
        eigenvalues_A = eigvals(A_mock),
        A_F_A = matrix_asymmetry(A_mock).A_F,
        W = w_diag.W,
        W_B = w_diag.W_B,
        b = w_diag.b,
        B_tot = w_diag.B_tot,
        A_F_W = w_diag.A_F,
        A_F_WB = w_diag.A_F_B,
        min_eig_neg_sym_WB = min_eig_neg_sym_WB,
        allometric_sensitivity = allom_sens,
        estimate = est,
        abs_error_K_cov = abs_err,
        rel_error_K_cov = rel_err,
    )
end

"""
    run_size_spectrum_demo()

Metabolic size-spectrum indices, size-dependent
low-pass responses, and a dissipative size-class perturbation model.
"""
function run_size_spectrum_demo()
    params = SizeSpectrumParams(
        m_min=1e-12,
        m_max=1e1,
        abundance_scale=1e3,
        abundance_exponent=0.95,
        metabolic_scale=0.25,
        metabolic_exponent=0.75,
        temperature=298.15,
        reference_mass=1.0,
    )
    indices = compute_size_spectrum_indices(params)
    filtering = simulate_size_spectrum_filtering(params; duration=50.0, dt=0.01)
    perturbation = simulate_size_spectrum_wave(params; duration=50.0, dt=0.01)

    return (params=params, indices=indices, filtering=filtering,
            perturbation=perturbation)
end

function main()
    # ------------------------------------------------------------------
    # 1. Section 3.3: Synthetic Two-Pool Stoichiometric Inversion
    # ------------------------------------------------------------------
    println("="^72)
    println("1. Section 3.3: Synthetic Two-Pool Stoichiometric Inversion")
    println("="^72)
    inv_demo = run_stoichiometric_inversion_demo()
    print_matrix("Pool-space conductivity L_x = B * L * B':", inv_demo.forward.L_x)
    print_matrix("Community matrix A = -L_x * H:", inv_demo.forward.A)
    println("Frobenius asymmetry A_F(A)   = ", round(inv_demo.forward.A_F_A; digits=4))
    println("Eigenvalues of A             = ", round.(inv_demo.forward.eigenvalues_A; digits=4))
    println("Recovered L relative error   = ",
            relative_error(inv_demo.inverse.L, inv_demo.L))
    println("Inversion regime             = ", inv_demo.inverse.regime)
    println()

    # ------------------------------------------------------------------
    # 2. Section 5.1: Physical Two-Mode Thermal Network
    # ------------------------------------------------------------------
    println("="^72)
    println("2. Section 5.1: Physical Two-Mode Thermal Network (Table 4)")
    println("="^72)
    therm = run_thermal_network_demo()
    print_matrix("Exact Onsager conductivity L (W K):", therm.exact.L)
    print_matrix("Estimated L_x = -A * C / k_B (W K):", therm.single_est.L_x)
    println("Single-trajectory rel. error (L_x) : ", therm.err_Lx)
    println("Single-trajectory rel. error (D)   : ", therm.err_D)
    println("Single-trajectory rel. error (H)   : ", therm.err_H)
    println("Single-trajectory Lyapunov residual: ", therm.single_est.lyapunov_residual)
    println("Equilibrium replicate z-score      : ", therm.eq_replicates.reciprocity_z)
    println("Driven exact sigma (W K^-1)        : ", therm.driven_exact.sigma)
    println("Driven replicate z-score           : ", therm.driven_replicates.reciprocity_z)
    println("Noise-inflated (4x) L_12 ratio     : ",
            therm.inflated_replicates.mean_L12 / therm.exact.L[1, 2])
    println("Tensor transformation rel. error   : ", therm.err_tensor)
    println("4-mode coarse-graining rel. error  : ", therm.err_coarse)
    println()

    # ------------------------------------------------------------------
    # 3. Section 5.2: Reversible Two-Pathway Gillespie Network
    # ------------------------------------------------------------------
    println("="^72)
    println("3. Section 5.2: Two-Pathway Reversible Gillespie Network")
    println("="^72)
    gill = run_reversible_gillespie_demo()
    print_matrix("Estimated L_hat (mol^2 K J^-1 m^-3 s^-1):", gill.estimate.L)
    print_matrix("Exact L_mock (mol^2 K J^-1 m^-3 s^-1):", gill.L_exact)
    println("Frobenius asymmetry A_F(L_hat) : ", gill.A_F)
    println("Min symmetric eigenvalue       : ", gill.min_sym_eig)
    println()

    # ------------------------------------------------------------------
    # 4. Section 5.3: Fast-Slow Evolving Conditional Conductivity
    # ------------------------------------------------------------------
    println("="^72)
    println("4. Section 5.3: Fast-Slow Evolving Conditional Conductivity (Table 5)")
    println("="^72)
    evo = run_evolving_trait_demo()
    println("Columns: epoch, elapsed_s, theta, p_occ, p_occ_eq, L11_hat, L11_exact, SE(L11)")
    for idx in eachindex(evo.epoch)
        @printf("%5d %10.1f %8.4f %9.4f %11.4f %11.6f %11.6f %10.6f\n",
                evo.epoch[idx],
                evo.elapsed_time[idx],
                evo.theta[idx],
                evo.p_occ[idx],
                evo.p_occ_eq[idx],
                evo.L_hat[idx][1, 1],
                evo.L_exact[idx][1, 1],
                evo.standard_errors[idx][1, 1])
    end
    println()

    # ------------------------------------------------------------------
    # 5. Section 5.4 & 6: 3-Species OU Mock & Published Cone Spring
    # ------------------------------------------------------------------
    println("="^72)
    println("5. Section 5.4 & 6: 3-Species OU Mock & Cone Spring Food Chain (Table 6)")
    println("="^72)
    mock = run_population_response_mock()
    print_matrix("3-species OU mock exact K_cov = -A * C:", mock.K_cov)
    print_matrix("3-species OU mock estimated K_cov_hat:", mock.estimate.K_cov)
    println("Mock K_cov relative error : ", mock.rel_error_K_cov)
    println("Mock A_F(A) = $(mock.A_F_A), A_F(W_B) = $(mock.A_F_WB), A_F(W) = $(mock.A_F_W)")
    println()

    cs = analyze_cone_spring()
    print_matrix("Cone Spring community matrix A_CS (yr^-1):", cs.network.A)
    print_matrix("Naive capacity-weighted -A_CS * Diag(B^*):", cs.L_naive)
    println("Eigenvalues of sym(-A_CS * Diag(B^*)) : ", cs.L_naive_sym_eigs)
    print_matrix("Stationary Lyapunov covariance C_CS ((kcal m^-2)^2):", cs.C)
    print_matrix("Exact Lyapunov K_cov,CS = -A_CS * C_CS:", cs.K_cov)
    print_matrix("Exact circulation -Omega_CS:", -cs.Omega)
    println("Exact min_sym_eig(K_cov,CS) = $(cs.min_sym_eig_K_cov), " *
            "estimated = $(cs.estimate.min_sym_eig)")
    println("Exact A_F(K_cov,CS) = $(cs.A_F_K_cov), " *
            "estimated = $(cs.estimate.A_F)")
    println("Dimensionless circulation rate = $(cs.circulation_rate) yr^-1")
    println("Cone Spring K_cov relative estimation error = $(cs.rel_error_K_cov)")
    println()

    # ------------------------------------------------------------------
    # 6. Metabolic Size Spectrum and Size-Dependent Responses
    # ------------------------------------------------------------------
    println("="^72)
    println("6. Metabolic Size Spectrum and Size-Class Response Models")
    println("="^72)
    spectrum = run_size_spectrum_demo()
    println("Metabolic spectrum exponent beta       = ", spectrum.indices.beta)
    println("Integrated standing biomass           = ", spectrum.indices.biomass_total)
    println("Integrated metabolic power             = ", spectrum.indices.power_total)
    println("Power / biomass proxy                  = ", spectrum.indices.specific_power_proxy)
    println("Size-class response times              = ", spectrum.filtering.response_time)
    println("Perturbation potential initial/final   = ",
            first(spectrum.perturbation.potential), " / ",
            last(spectrum.perturbation.potential))
    println()

    # ------------------------------------------------------------------
    # 7. Illustrative NPZD and NPZD–Fish Ecosystem Models
    # ------------------------------------------------------------------
    println("="^72)
    println("7. Illustrative NPZD and NPZD–Fish Ecosystem Models")
    println("="^72)
    npzd_params = NPZDParams()
    npzd = npzd_diagnostics(npzd_params)
    println("NPZD reference state (N, P, Z, D) = ", npzd.reference_state)
    println("NPZD external nutrient input       = ", npzd.nutrient_input, " per day")
    println("NPZD eigenvalues (yr^-1)           = ", npzd.eigenvalues)
    println("NPZD Lyapunov residual             = ", npzd.lyapunov_residual)
    println("NPZD circulation-rate proxy        = ",
            npzd.decomposition.circulation_rate, " yr^-1")
    println()

    fish_params = NPZDFishParams()
    fish = npzd_fish_diagnostics(fish_params)
    println("NPZD–fish reference (N, P, Z, D, F) = ", fish.reference_state)
    println("NPZD–fish external nutrient input   = ", fish.nutrient_input, " per day")
    println("NPZD–fish eigenvalues (yr^-1)       = ", fish.eigenvalues)
    println("NPZD–fish Lyapunov residual         = ", fish.lyapunov_residual)
    println("NPZD–fish circulation-rate proxy    = ",
            fish.decomposition.circulation_rate, " yr^-1")
    harvest = simulate_npzd_fish_harvest(
        fish_params; duration=2.0, dt=1e-3, harvest_time=1.0,
        harvest_multiplier=2.5, rng=MersenneTwister(2026))
    println("Harvest simulation states (rows × pools) = ", size(harvest.states))
    println("Mean fish deviation after harvest       = ",
            mean(harvest.deviations[harvest.time .>= harvest.harvest_time, 5]))
end

if abspath(PROGRAM_FILE) == abspath(@__FILE__)
    main()
end
