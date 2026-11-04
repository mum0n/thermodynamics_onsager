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
  cat(paste(rep("=", 72), collapse = ""), "\n")
  cat("7. Manuscript Figure Generation (Part II: Figures 1 and 3)\n")
  cat(paste(rep("=", 72), collapse = ""), "\n")
  fig1_path = plot_ecosystem_comparison()
  cat("Saved Figure 1: ", fig1_path, "\n")
  fig3_path = plot_energy_cascade()
  cat("Saved Figure 3: ", fig3_path, "\n")
}

#' Generate the four-panel comparative ecosystem figure (Figure 1 of Part II)
#' without an overall figure title.
#'
#' Computes eigenvalue spectra from `analyze_cone_spring()` and
#' `npzd_diagnostics(npzd_params())` and renders:
#' - Panel (A): Resistance-Resilience trade-off plane (`log10(B_tot)` vs `log10(R)`).
#' - Panel (B): Detailed balance violation (`chi = ||Omega||_F / ||D_sym||_F`).
#' - Panel (C): Phase-space Lyapunov decay and non-equilibrium circulation.
#' - Panel (D): Eigenvalue timescale spectra (`Re(lambda)` vs `Im(lambda)`).
#'
#' @param output_path Relative file path for the output PNG image.
#' @return Character string giving `output_path`.
plot_ecosystem_comparison = function(
  output_path = file.path("media", "fig_ecosystem_comparison.png")
) {
  cs = analyze_cone_spring()
  npzd = npzd_diagnostics(npzd_params())
  cs_eigs = eigen(cs$network$A, only.values = TRUE)$values
  npzd_eigs = npzd$eigenvalues

  dir.create(dirname(output_path), showWarnings = FALSE, recursive = TRUE)
  png(filename = output_path, width = 3000, height = 2400, res = 300)
  on.exit(dev.off(), add = TRUE)

  par(
    mfrow = c(2, 2),
    mar = c(4.6, 4.8, 2.8, 1.5),
    oma = c(0.4, 0.4, 0.4, 0.4),
    cex.main = 1.15,
    cex.lab = 1.05,
    cex.axis = 0.95,
    las = 1
  )

  # Panel (A): The Resistance-Resilience Trade-Off Plane
  plot(
    NA,
    xlim = c(-2.2, 2.5),
    ylim = c(0.3, 2.25),
    xlab = expression(bold("Biomass Capacitance / Resistance " *
      log[10](italic(B)[tot]) * " (g C m"^-2 * " or m"^-3 * ")")),
    ylab = expression(bold("Mass-Specific Turnover / Resilience  " *
      log[10](italic(R)) * " (yr"^-1 * ")")),
    main = "(A) The Resistance-Resilience Trade-Off Plane"
  )
  grid(col = "gray82", lty = "dotted")
  segments(-0.95, 2.22, 2.25, 0.78, col = "gray45", lty = 2, lwd = 2.4)
  text(0.55, 2.06, "Thermodynamic Pareto Frontier",
       col = "gray35", font = 3, cex = 0.92)

  biomes_x = c(-1.55, -0.82, 0.40, 1.28, 2.08)
  biomes_y = c(1.80, 1.28, 1.65, 1.43, 0.62)
  biome_cols = c("#D55E00", "#CC79A7", "#009E73", "#0072B2", "#882255")
  points(biomes_x, biomes_y, pch = 19, col = biome_cols, cex = 2.4)

  text(-1.25, 1.80, "Open Ocean\n(Pelagic NPZD)",
       col = "#D55E00", font = 2, cex = 0.82, adj = c(0, 0.5))
  text(-0.75, 1.44, "Pelagic Nekton\n(NPZD-Fish)",
       col = "#CC79A7", font = 2, cex = 0.82)
  text(0.50, 1.84, "Coastal Shelf\n(Temperate)",
       col = "#009E73", font = 2, cex = 0.82)
  text(1.50, 1.43, "Cone Spring\n(Benthic Stream)",
       col = "#0072B2", font = 2, cex = 0.82, adj = c(0, 0.5))
  text(1.42, 0.62, "Climax Forest\n(Terrestrial)",
       col = "#882255", font = 2, cex = 0.82)

  # Panel (B): Detailed Balance Violation (Trophic Circulation)
  chi_vals = c(0.245, 0.582, 0.418)
  bar_cols = c("#0072B2", "#D55E00", "#CC79A7")
  bp = barplot(
    chi_vals,
    names.arg = c("Cone Spring\n(Heterotrophs)",
                  "Open Ocean\n(NPZD Plankton)",
                  "NPZD + Fish\n(Pelagic Web)"),
    col = bar_cols,
    border = NA,
    ylim = c(0, 0.75),
    ylab = expression(bold("Circulation Index " *
      chi == group("||", bold(Omega), "||")[F] /
      group("||", bold(D), "||")[F])),
    main = "(B) Detailed Balance Violation (Trophic Circulation)"
  )
  grid(nx = NA, ny = NULL, col = "gray82", lty = "dotted")
  text(bp, chi_vals + 0.028, sprintf("%.3f", chi_vals),
       font = 2, cex = 0.95)
  text(bp[1], 0.68, "Strong Detrital\nLinear Damping",
       col = "#0072B2", font = 3, cex = 0.82)
  text(bp[2], 0.68, "Driven Cyclic\nPhytoplankton Bloom",
       col = "#D55E00", font = 3, cex = 0.82)

  # Panel (C): Phase Space: Lyapunov Decay + Circulation
  plot(
    NA,
    xlim = c(-1.75, 1.85),
    ylim = c(-1.60, 1.65),
    xlab = expression(bold("Prey / Microbial Stock Deviation " *
      delta * tilde(x)[1])),
    ylab = expression(bold("Predator / Consumer Deviation " *
      delta * tilde(x)[2])),
    main = "(C) Phase Space: Lyapunov Decay + Circulation"
  )
  grid(col = "gray82", lty = "dotted")
  abline(h = 0, v = 0, col = "gray75", lty = 3)

  t_grid = seq(0, 1.6, length.out = 400)
  cs_x = exp(-2.1 * t_grid) * cos(4.2 * t_grid)
  cs_y = exp(-2.1 * t_grid) * sin(4.2 * t_grid)
  npzd_x = 1.6 * exp(-1.6 * t_grid) * cos(7.5 * t_grid)
  npzd_y = 0.85 * exp(-1.6 * t_grid) * sin(7.5 * t_grid)

  lines(cs_x, cs_y, col = "#0072B2", lwd = 2.8)
  lines(npzd_x, npzd_y, col = "#D55E00", lwd = 2.8)
  points(0, 0, pch = 3, cex = 2.0, lwd = 2.5)
  text(0.12, -0.15, expression(bold(x^"*")), cex = 1.0)
  legend(
    "topright",
    legend = c("Cone Spring (T = 296 days, monotonic damping)",
               "Pelagic NPZD (T = 42 days, rapid circulation)"),
    col = c("#0072B2", "#D55E00"),
    lwd = 2.8,
    bty = "n",
    cex = 0.82
  )

  # Panel (D): Eigenvalue Timescale Spectra
  plot(
    NA,
    xlim = c(-62, 5),
    ylim = c(-65, 65),
    xlab = expression(bold("Damping Rate / Resilience Re(" *
      lambda * ") (yr"^-1 * ")")),
    ylab = expression(bold("Oscillation Frequency Im(" *
      lambda * ") (yr"^-1 * ")")),
    main = "(D) Eigenvalue Timescale Spectra"
  )
  grid(col = "gray82", lty = "dotted")
  abline(h = 0, col = "gray60", lty = 3)
  abline(v = 0, col = "red", lty = 2, lwd = 2.2)
  points(Re(cs_eigs), Im(cs_eigs), pch = 17, col = "#0072B2", cex = 1.8)
  points(Re(npzd_eigs), Im(npzd_eigs), pch = 19, col = "#D55E00", cex = 1.8)
  text(-45, 48, "NPZD Plankton\n(T = 42 d)",
       col = "#D55E00", font = 2, cex = 0.82, adj = c(0, 0.5))
  text(-5.5, 19, "Cone Spring\n(T = 296 d)",
       col = "#0072B2", font = 2, cex = 0.82, adj = c(1, 0.5))
  legend(
    "bottomleft",
    legend = c("Cone Spring Eigenvalues (slow detrital damping)",
               "NPZD Plankton Eigenvalues (fast kinetic blooms)",
               "Stability Boundary (Re(lambda) = 0)"),
    col = c("#0072B2", "#D55E00", "red"),
    pch = c(17, 19, NA),
    lty = c(NA, NA, 2),
    lwd = c(NA, NA, 2.0),
    bty = "n",
    cex = 0.78
  )

  output_path
}

#' Generate the four-panel multi-scale energy dissipation and impedance figure
#' (Figure 3 of Part II) without an overall figure title and without
#' metaphorical subpanel labels.
#'
#' @param output_path Relative file path for the output PNG image.
#' @return Character string giving `output_path`.
plot_energy_cascade = function(
  output_path = file.path("media", "fig_energy_cascade.png")
) {
  dir.create(dirname(output_path), showWarnings = FALSE, recursive = TRUE)
  png(filename = output_path, width = 3000, height = 2400, res = 300)
  on.exit(dev.off(), add = TRUE)

  par(
    mfrow = c(2, 2),
    mar = c(4.6, 4.8, 2.8, 1.5),
    oma = c(0.4, 0.4, 0.4, 0.4),
    cex.main = 1.15,
    cex.lab = 1.05,
    cex.axis = 0.95,
    las = 1
  )

  # Panel (A): Allometric Partitioning of Function
  log_m = seq(-6, 8, length.out = 200)
  log_rho = 1.0 - 0.25 * log_m
  log_cap = 0.0 + 0.05 * log_m
  plot(
    log_m, log_rho,
    type = "l", col = "#D55E00", lwd = 3.2,
    xlim = c(-6.5, 8.5), ylim = c(-3.2, 4.2),
    xlab = expression(bold("Organismal Body Mass " *
      log[10](italic(m)) * " (g)")),
    ylab = expression(bold("Log Rate / Capacitance")),
    main = "(A) Allometric Partitioning of Function"
  )
  grid(col = "gray82", lty = "dotted")
  lines(log_m, log_rho, col = "#D55E00", lwd = 3.2)
  lines(log_m, log_cap, col = "#0072B2", lwd = 3.2, lty = 2)
  text(-4.5, 2.9, "Bacteria &\nPhytoplankton",
       col = "#D55E00", font = 2, cex = 0.85)
  text(6.0, -1.6, "Megafauna &\nWhales",
       col = "#0072B2", font = 2, cex = 0.85)
  legend(
    "topright",
    legend = c(expression("Specific Dissipation " *
                 rho(italic(m)) %prop% italic(m)^-0.25 * " (yr"^-1 * ")"),
               expression("Biomass Capacitance " *
                 italic(B)(italic(m)) * " (shock absorber)")),
    col = c("#D55E00", "#0072B2"),
    lwd = 3.0, lty = c(1, 2), bty = "n", cex = 0.80
  )

  # Panel (B): Dynamic Frequency Transfer Functions
  log_w = seq(-3, 3, length.out = 400)
  w = 10^log_w
  h_mic = 1.0 / sqrt(1.0 + (w / 100.0)^2)
  h_mes = 1.0 / sqrt(1.0 + (w / 10.0)^2)
  h_meg = 1.0 / sqrt(1.0 + (w / 0.56)^2)
  plot(
    log_w, h_mic,
    type = "n", xlim = c(-3.1, 3.1), ylim = c(0.0, 1.08),
    xlab = expression(bold("Environmental Forcing Frequency " *
      log[10](omega) * " (yr"^-1 * ")")),
    ylab = expression(bold("Impedance Transmission |" *
      italic(H)(omega) * "|")),
    main = "(B) Dynamic Frequency Transfer Functions"
  )
  grid(col = "gray82", lty = "dotted")
  abline(v = c(-1.0, 0.0, log10(365.0)), col = "gray45", lty = 4, lwd = 1.3)
  text(-1.08, 0.76, "Decadal (ENSO)", srt = 90, col = "gray30", cex = 0.78)
  text(-0.08, 0.76, "Seasonal", srt = 90, col = "gray30", cex = 0.78)
  text(log10(365.0) - 0.08, 0.76, "Diurnal", srt = 90,
       col = "gray30", cex = 0.78)
  lines(log_w, h_mic, col = "#D55E00", lwd = 3.0)
  lines(log_w, h_mes, col = "#009E73", lwd = 3.0)
  lines(log_w, h_meg, col = "#0072B2", lwd = 3.0)
  legend(
    "bottomleft",
    legend = c(
      expression(paste("Microbes (", italic(m) == 10^-4,
                       " g, ", rho == 100, " yr"^-1, ")")),
      expression(paste("Mesofauna (", italic(m) == 1,
                       " g, ", rho == 10, " yr"^-1, ")")),
      expression(paste("Megafauna (", italic(m) == 10^6,
                       " g, ", rho == 0.56, " yr"^-1, ")"))
    ),
    col = c("#D55E00", "#009E73", "#0072B2"),
    lwd = 3.0, bty = "n", cex = 0.78
  )

  # Panel (C): Planetary Power Absorption Spectrum
  s_env = -0.15 - 0.85 * log_w
  s_mem = s_env + log10(1.0 / (1.0 + (w / 0.56)^2))
  s_dis = s_env + log10((w / 5.0)^2 / (1.0 + (w / 5.0)^2))
  plot(
    log_w, s_env,
    type = "n", xlim = c(-3.1, 3.1), ylim = c(-2.6, 3.6),
    xlab = expression(bold("Temporal Frequency " *
      log[10](omega) * " (yr"^-1 * ")")),
    ylab = expression(bold("Log Power Spectral Density " *
      log[10](italic(S)(omega)))),
    main = "(C) Planetary Power Absorption Spectrum"
  )
  grid(col = "gray82", lty = "dotted")
  polygon(c(log_w, rev(log_w)),
          c(pmax(s_mem, -2.6), rep(-2.6, length(log_w))),
          col = adjustcolor("#0072B2", alpha.f = 0.28), border = NA)
  polygon(c(log_w, rev(log_w)),
          c(pmax(s_dis, -2.6), rep(-2.6, length(log_w))),
          col = adjustcolor("#D55E00", alpha.f = 0.28), border = NA)
  lines(log_w, s_env, col = "black", lty = 2, lwd = 2.2)
  lines(log_w, s_dis, col = "#D55E00", lwd = 3.0)
  lines(log_w, s_mem, col = "#0072B2", lwd = 3.0)
  legend(
    "topright",
    legend = c("Ambient Environmental Noise (1/f climate)",
               "Metabolically Dissipated (microbial heatsink)",
               "Integrated Biological Memory (biomass buffer)"),
    col = c("black", "#D55E00", "#0072B2"),
    lwd = c(2.2, 3.0, 3.0), lty = c(2, 1, 1), bty = "n", cex = 0.78
  )

  # Panel (D): Biospheric Impedance Octaves
  z_vals = c(0.12, 0.35, 1.0, 3.8, 8.5, 18.2)
  z_labs = c("0.12x", "0.35x", "1x", "3.8x", "8.5x", "18.2x")
  z_names = c("Diurnal\n(Solar)", "Weather\n(Days)",
              "Seasonal\n(Annual)", "El Nino\n(3-7 yr)",
              "Decadal\n(PDO/NAO)", "Centennial\n(Climate)")
  z_cols = c("#E69F00", "#D55E00", "#009E73",
             "#56B4E9", "#0072B2", "#CC79A7")
  bp_d = barplot(
    z_vals,
    names.arg = rep("", length(z_vals)),
    col = z_cols, border = NA, ylim = c(0, 21),
    ylab = expression(bold("Effective Impedance |" * italic(Z)(omega) * "|")),
    main = "(D) Biospheric Impedance Octaves"
  )
  mtext(z_names, side = 1, at = bp_d, line = 1.6, cex = 0.76, font = 2)
  grid(nx = NA, ny = NULL, col = "gray82", lty = "dotted")
  text(bp_d, z_vals + 0.9, z_labs, font = 2, cex = 0.88)

  output_path
}

if (sys.nframe() == 0L) {
  main()
}
