# thermodynamics_onsager.R
# Demonstration and numerical verification suite for:
# "Onsager's relations and Ecology II: From community matrices to
#  phenomenological conductivities" (Choi 2026).
#
# This file consolidates analytical and stochastic demonstrations built on
# `R/onsagernetwork.R`:
#   - Section 3.3: Synthetic two-pool stoichiometric inversion (eqs. 20-22)
#   - Section 5.1: Physical two-mode and four-mode thermal networks (Table 4)
#   - Section 5.2: Reversible two-pathway Gillespie reaction network (eqs. 34-37)
#   - Section 5.3: Fast-slow evolving trait conditional conductivity (Table 5)
#   - Section 5.4 & 6: Synthetic 3-species Ornstein-Uhlenbeck mock system and
#     published Cone Spring food-web community matrix analysis (Tables 2 & 6)
#   - Size-spectrum diagnostics: integrated biomass/power indices and
#     phenomenological size-dependent response models
#   - Illustrative four-pool NPZD and five-pool NPZD-fish diagnostics

source("R/onsagernetwork.R")

relative_error = function(estimate, exact) {
  norm(as.matrix(estimate) - as.matrix(exact), "F") / norm(as.matrix(exact), "F")
}

print_matrix = function(label, mat, digits = 6) {
  cat(label, "
")
  print(round(as.matrix(mat), digits = digits))
  cat("
")
}

run_stoichiometric_inversion_demo = function() {
  B = matrix(c(-1.0, 1.0, -1.0, 0.0), nrow = 2, ncol = 2)
  H = matrix(c(2.0, 0.5, 0.5, 1.0), nrow = 2, ncol = 2)
  L = matrix(c(1.0, 0.2, 0.2, 0.5), nrow = 2, ncol = 2)
  
  fwd = forward_community_matrix(L, H, B = B)
  inv_res = inverse_onsager_conductivity(fwd$A, H, B = B)
  naive_asym = matrix_asymmetry(-fwd$A)
  
  list(
    B = B,
    H = H,
    L = L,
    forward = fwd,
    inverse = inv_res,
    naive_asymmetry = naive_asym
  )
}

run_thermal_network_demo = function(dt = 0.02, n_steps = 50000L,
                                     n_replicates = 50L, kappa = 0.5,
                                     noise_scale = 4.0, seed = 20261027) {
  model = thermal_two_mode()
  exact = thermal_network_matrices(model)
  
  X_data = simulate_ou_process(exact$A, exact$D, dt = dt, n_steps = n_steps,
                                C = exact$C, seed = seed)
  single_est = estimate_ou_onsager(X_data, dt = dt, scale = k_B)
  
  eq_reps = replicate_thermal_study(model, n_replicates = n_replicates,
                                     dt = dt, n_steps = 10000L, seed = seed)
  driven_exact = thermal_network_matrices(model, kappa = kappa)
  driven_reps = replicate_thermal_study(model, n_replicates = n_replicates,
                                         dt = dt, n_steps = 10000L, seed = seed,
                                         kappa = kappa)
  inflated_reps = replicate_thermal_study(model, n_replicates = n_replicates,
                                           dt = dt, n_steps = 10000L, seed = seed,
                                           noise_scale = noise_scale)
  
  Lambda = diag(c(2.0, 0.5))
  Y_data = X_data %*% t(Lambda)
  est_Y = estimate_ou_onsager(Y_data, dt = dt, scale = k_B)
  L_Y_exact = Lambda %*% exact$L %*% t(Lambda)
  err_tensor = relative_error(est_Y$L_x, L_Y_exact)
  
  C4_heat = c(1.0, 2.0, 1.5, 0.8)
  G4 = matrix(c(
     1.10, -0.30, -0.20, -0.10,
    -0.30,  1.00, -0.40, -0.10,
    -0.20, -0.40,  1.20, -0.30,
    -0.10, -0.10, -0.30,  0.90
  ), 4, 4)
  H4 = diag(1.0 / (C4_heat * (model$T^2)))
  L4 = (model$T^2) * G4
  A4 = -L4 %*% H4
  C4 = solve_lyapunov_covariance(A4, k_B * L4)
  L11_eff = marginal_coarse_grained_conductivity(A4, C4, 1:2, dt = dt, scale = k_B)
  err_coarse = relative_error(L11_eff, L4[1:2, 1:2])
  
  list(
    exact = exact,
    single_est = single_est,
    err_Lx = relative_error(single_est$L_x, exact$L),
    err_D = relative_error(single_est$D, exact$D),
    err_H = relative_error(single_est$H, exact$H),
    eq_replicates = eq_reps,
    driven_exact = driven_exact,
    driven_replicates = driven_reps,
    inflated_replicates = inflated_reps,
    err_tensor = err_tensor,
    err_coarse = err_coarse
  )
}

run_reversible_gillespie_demo = function(N_sites = 1000L, c_s = 0.2,
                                          kappa = c(2.0, 3.0),
                                          n_replicates = 4L, burn_in = 2.0,
                                          T_obs = 40.0, T = 298.15,
                                          delta_X = 1.0, seed = 20261027) {
  est = estimate_two_pathway_conductivity(
    kappa, N_sites = N_sites, c_s = c_s, n_replicates = n_replicates,
    burn_in = burn_in, T_obs = T_obs, T = T, delta_X = delta_X, seed = seed
  )
  L_exact = exact_two_pathway_conductivity(kappa, c_s)
  asym = matrix_asymmetry(est$L)
  min_eig = min(eigen(asym$symmetric, symmetric = TRUE, only.values = TRUE)$values)
  list(
    estimate = est,
    L_exact = L_exact,
    A_F = asym$A_F,
    min_sym_eig = min_eig
  )
}

run_evolving_trait_demo = function(n_epochs = 4L, epoch_duration = 5.0,
                                    T_obs = 2.0, N_sites = 100L,
                                    n_replicates = 2L, delta_X = 0.5,
                                    seed = 20261028) {
  simulate_evolving_conductivity(
    n_epochs = n_epochs, epoch_duration = epoch_duration, T_obs = T_obs,
    N_sites = N_sites, n_replicates = n_replicates, delta_X = delta_X,
    seed = seed
  )
}

run_population_response_mock = function(dt = 0.2, n_obs = 20000L, seed = 20261026) {
  C_mock = matrix(c(
    1.00, 0.35, 0.10,
    0.35, 1.40, 0.20,
    0.10, 0.20, 0.80
  ), 3, 3)
  K_cov_mock = matrix(c(
     0.80, -0.10,  0.05,
    -0.10,  0.60, -0.08,
     0.05, -0.08,  0.50
  ), 3, 3)
  A_mock = -K_cov_mock %*% solve(C_mock)
  
  M_mock = c(1.0, 10.0, 100.0)
  N_mock = c(100.0, 50.0, 20.0)
  w_diag = weighted_interaction_matrix(N_mock, M_mock, A_mock)
  allom_sens = sensitivity_allometry(N_mock, M_mock, A_mock)
  W_B_sym = 0.5 * (w_diag$W_B + t(w_diag$W_B))
  min_eig_neg_sym_WB = min(eigen(-W_B_sym, symmetric = TRUE, only.values = TRUE)$values)
  
  X_data = simulate_ou_process(A_mock, K_cov_mock, dt = dt, n_steps = n_obs - 1,
                                C = C_mock, seed = seed)
  est = estimate_ou_onsager(X_data, dt = dt, scale = 1.0)
  abs_err = norm(est$K_cov - K_cov_mock, "F")
  rel_err = abs_err / norm(K_cov_mock, "F")
  
  list(
    A = A_mock,
    C = C_mock,
    K_cov = K_cov_mock,
    eigenvalues_A = eigen(A_mock, only.values = TRUE)$values,
    A_F_A = matrix_asymmetry(A_mock)$A_F,
    W = w_diag$W,
    W_B = w_diag$W_B,
    b = w_diag$b,
    B_tot = w_diag$B_tot,
    A_F_W = w_diag$A_F,
    A_F_WB = matrix_asymmetry(w_diag$W_B)$A_F,
    min_eig_neg_sym_WB = min_eig_neg_sym_WB,
    allometric_sensitivity = allom_sens,
    estimate = est,
    abs_error_K_cov = abs_err,
    rel_error_K_cov = rel_err
  )
}

run_size_spectrum_demo = function() {
  params = size_spectrum_params(
    m_min = 1e-12, m_max = 1e1, abundance_scale = 1e3,
    abundance_exponent = 0.95, metabolic_scale = 0.25,
    metabolic_exponent = 0.75, temperature = 298.15, reference_mass = 1.0
  )
  indices = compute_size_spectrum_indices(params)
  filtering = simulate_size_spectrum_filtering(params, duration = 50.0, dt = 0.1)
  perturbation = simulate_size_spectrum_wave(params, duration = 50.0, dt = 0.1)
  list(
    params = params,
    indices = indices,
    filtering = filtering,
    perturbation = perturbation
  )
}

main = function() {
  cat(paste(rep("=", 72), collapse = ""), "
")
  cat("1. Section 3.3: Synthetic Two-Pool Stoichiometric Inversion
")
  cat(paste(rep("=", 72), collapse = ""), "
")
  inv_demo = run_stoichiometric_inversion_demo()
  print_matrix("Pool-space conductivity L_x = B * L * B':", inv_demo$forward$L_x)
  print_matrix("Community matrix A = -L_x * H:", inv_demo$forward$A)
  cat("Frobenius asymmetry A_F(A)   = ", round(inv_demo$forward$A_F_A, digits = 4), "
")
  cat("Eigenvalues of A             = ", round(inv_demo$forward$eigenvalues_A, digits = 4), "
")
  cat("Recovered L relative error   = ", relative_error(inv_demo$inverse$L, inv_demo$L), "
")
  cat("Inversion regime             = ", inv_demo$inverse$regime, "

")

  cat(paste(rep("=", 72), collapse = ""), "
")
  cat("2. Section 5.1: Physical Two-Mode Thermal Network (Table 4)
")
  cat(paste(rep("=", 72), collapse = ""), "
")
  therm = run_thermal_network_demo()
  print_matrix("Exact Onsager conductivity L (W K):", therm$exact$L)
  print_matrix("Estimated L_x = -A * C / k_B (W K):", therm$single_est$L_x)
  cat("Single-trajectory rel. error (L_x) : ", therm$err_Lx, "
")
  cat("Single-trajectory rel. error (D)   : ", therm$err_D, "
")
  cat("Single-trajectory rel. error (H)   : ", therm$err_H, "
")
  cat("Single-trajectory Lyapunov residual: ", therm$single_est$lyapunov_residual, "
")
  cat("Driven exact sigma (W K^-1)        : ", therm$driven_exact$sigma, "
")
  cat("Tensor transformation rel. error   : ", therm$err_tensor, "
")
  cat("4-mode coarse-graining rel. error  : ", therm$err_coarse, "

")

  cat(paste(rep("=", 72), collapse = ""), "
")
  cat("3. Section 5.2: Two-Pathway Reversible Gillespie Network
")
  cat(paste(rep("=", 72), collapse = ""), "
")
  gill = run_reversible_gillespie_demo()
  print_matrix("Estimated L_hat (mol^2 K J^-1 m^-3 s^-1):", gill$estimate$L)
  print_matrix("Exact L_mock (mol^2 K J^-1 m^-3 s^-1):", gill$L_exact)
  cat("Frobenius asymmetry A_F(L_hat) : ", gill$A_F, "
")
  cat("Min symmetric eigenvalue       : ", gill$min_sym_eig, "

")

  cat(paste(rep("=", 72), collapse = ""), "
")
  cat("4. Section 5.4 & 6: 3-Species OU Mock & Cone Spring Food Chain (Table 6)
")
  cat(paste(rep("=", 72), collapse = ""), "
")
  mock = run_population_response_mock()
  print_matrix("3-species OU mock exact K_cov = -A * C:", mock$K_cov)
  print_matrix("3-species OU mock estimated K_cov_hat:", mock$estimate$K_cov)
  cat("Mock K_cov relative error : ", mock$rel_error_K_cov, "
")
  cat(sprintf("Mock A_F(A) = %.4f, A_F(W_B) = %.4f, A_F(W) = %.4f

",
              mock$A_F_A, mock$A_F_WB, mock$A_F_W))

  cs = analyze_cone_spring()
  print_matrix("Cone Spring community matrix A_CS (yr^-1):", cs$network$A)
  print_matrix("Naive capacity-weighted -A_CS * Diag(B^*):", cs$L_naive)
  cat("Eigenvalues of sym(-A_CS * Diag(B^*)) : ", round(cs$L_naive_sym_eigs, 4), "
")
  print_matrix("Stationary Lyapunov covariance C_CS ((kcal m^-2)^2):", cs$C)
  print_matrix("Exact Lyapunov K_cov,CS = -A_CS * C_CS:", cs$K_cov)
  print_matrix("Exact circulation -Omega_CS:", -cs$Omega)
  cat("Exact min_sym_eig(K_cov,CS) = ", cs$min_sym_eig_K_cov,
      ", estimated = ", cs$estimate$min_sym_eig, "
")
  cat("Dimensionless circulation rate = ", cs$circulation_rate, " yr^-1
")
  cat("Cone Spring K_cov relative estimation error = ", cs$rel_error_K_cov, "

")

  cat(paste(rep("=", 72), collapse = ""), "
")
  cat("5. Metabolic Size Spectrum and Size-Class Response Models
")
  cat(paste(rep("=", 72), collapse = ""), "
")
  spectrum = run_size_spectrum_demo()
  cat("Metabolic spectrum exponent beta       = ", spectrum$indices$beta, "
")
  cat("Integrated standing biomass            = ", spectrum$indices$biomass_total, "
")
  cat("Integrated metabolic power             = ", spectrum$indices$power_total, "
")
  cat("Power / biomass proxy                  = ", spectrum$indices$specific_power_proxy, "
")
  cat("Perturbation potential initial/final   = ",
      spectrum$perturbation$potential[1], " / ",
      tail(spectrum$perturbation$potential, 1), "

")

  cat(paste(rep("=", 72), collapse = ""), "
")
  cat("6. Illustrative NPZD and NPZD-Fish Ecosystem Models
")
  cat(paste(rep("=", 72), collapse = ""), "
")
  npzd_p = npzd_params()
  npzd = npzd_diagnostics(npzd_p)
  cat("NPZD reference state (N, P, Z, D) = ", round(npzd$reference_state, 4), "
")
  cat("NPZD external nutrient input       = ", round(npzd$nutrient_input, 4), " per day
")
  cat("NPZD eigenvalues (yr^-1)           = ", round(npzd$eigenvalues, 4), "
")
  cat("NPZD Lyapunov residual             = ", npzd$lyapunov_residual, "
")
  cat("NPZD circulation-rate proxy        = ", npzd$decomposition$circulation_rate, " yr^-1

")

  fish_p = npzd_fish_params()
  fish = npzd_fish_diagnostics(fish_p)
  cat("NPZD-fish reference (N, P, Z, D, F) = ", round(fish$reference_state, 4), "
")
  cat("NPZD-fish external nutrient input   = ", round(fish$nutrient_input, 4), " per day
")
  cat("NPZD-fish eigenvalues (yr^-1)       = ", round(fish$eigenvalues, 4), "
")
  cat("NPZD-fish Lyapunov residual         = ", fish$lyapunov_residual, "
")
  cat("NPZD-fish circulation-rate proxy    = ", fish$decomposition$circulation_rate, " yr^-1
")
}

if (sys.nframe() == 0L) {
  main()
}
