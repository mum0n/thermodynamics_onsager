# runtests.R
# Test suite for OnsagerNetwork R implementation matching test/runtests.jl.

source("R/onsagernetwork.R")
source("thermodynamics_onsager.R")

test_that <- function(desc, code) {
  cat("  Testing:", desc, "... ")
  tryCatch({
    eval(substitute(code), parent.frame())
    cat("OK
")
  }, error = function(e) {
    cat("FAILED
")
    stop(e)
  })
}

expect_true <- function(cond) {
  if (!isTRUE(cond)) stop("Condition is not TRUE")
}

expect_false <- function(cond) {
  if (!isFALSE(cond)) stop("Condition is not FALSE")
}

expect_equal <- function(a, b, tol = 1e-7) {
  diff <- norm(as.matrix(a) - as.matrix(b), "F")
  denom <- max(1.0, norm(as.matrix(b), "F"))
  if (diff / denom > tol) {
    stop(sprintf("Matrices not equal: diff = %e, tol = %e", diff / denom, tol))
  }
}

expect_error <- function(code) {
  threw <- FALSE
  tryCatch({
    eval(substitute(code), parent.frame())
  }, error = function(e) {
    threw <<- TRUE
  })
  if (!threw) stop("Expected error was not raised")
}

cat("==================================================================
")
cat("Running OnsagerNetwork R Test Suite (matching Julia runtests.jl)
")
cat("==================================================================
")

# ------------------------------------------------------------------
# Testset 1: Matrix asymmetry and thermodynamic primitives
# ------------------------------------------------------------------
cat("
Testset 1: Matrix asymmetry and thermodynamic primitives (Section 2)
")

test_that("Matrix asymmetry decomposition and invariance", {
  M <- matrix(c(1.0, 0.0, 4.0, 2.0, 1.0, 0.0, 0.0, 3.0, 1.0), 3, 3)
  asym <- matrix_asymmetry(M)
  expect_equal(asym$A_F, norm(M - t(M), "F") / norm(M, "F"))
  expect_equal(asym$symmetric + asym$skew, M)
  expect_equal(asym$symmetric, t(asym$symmetric))
  expect_equal(asym$skew, -t(asym$skew))
  expect_error(matrix_asymmetry(matrix(1, 2, 3)))
})

test_that("Persistent asymmetry runs", {
  expect_false(persistent_asymmetry(c(0.0, 0.0, 0.0)))
  expect_true(persistent_asymmetry(c(0.3, 0.3, 0.3)))
  expect_true(persistent_asymmetry(c(0.3, 0.1, 0.3, 0.3, 0.3)))
  expect_false(persistent_asymmetry(c(0.3, 0.3), min_run = 3L))
  expect_error(persistent_asymmetry(c(0.1, NaN, 0.3)))
})

test_that("Exchangeability null distribution", {
  M <- matrix(c(1.0, 0.0, 4.0, 2.0, 1.0, 0.0, 0.0, 3.0, 1.0), 3, 3)
  null_vals <- asymmetry_null(list(M), n_perm = 20L, seed = 12)
  expect_true(length(null_vals) == 20L)
  expect_true(all(null_vals >= 0 & null_vals <= 2))
  expect_error(asymmetry_null(list(matrix(1, 2, 3))))
})

test_that("Entropy production and second differentials", {
  L0 <- matrix(c(2.0, 0.5, 0.5, 1.0), 2, 2)
  M_curv <- matrix(c(1.0, 0.2, 0.2, 0.5), 2, 2)
  X <- c(0.7, -0.3)
  J <- c(0.4, 0.9)
  d2L <- -2.0 * M_curv
  
  expect_equal(entropy_production(L0, X, constraint = "forces"), as.numeric(t(X) %*% (L0 %*% X)))
  expect_equal(entropy_production(L0, J, constraint = "flows"), as.numeric(t(J) %*% solve(L0, J)))
  
  curv_X <- entropy_production_curvature(L0, d2L, X, constraint = "forces")
  curv_J <- entropy_production_curvature(L0, d2L, J, constraint = "flows")
  expect_true(curv_X$regime == "maximum")
  expect_true(curv_J$regime == "minimum")
  expect_true(curv_X$d2sigma < 0)
  expect_true(curv_J$d2sigma > 0)
  
  L_sing <- matrix(c(1.0, 1.0, 1.0, 1.0), 2, 2)
  expect_equal(entropy_production(L_sing, c(1.0, 1.0), constraint = "forces"), 4.0)
  expect_equal(entropy_production(L_sing, c(1.0, -1.0), constraint = "forces"), 0.0)
  expect_error(entropy_production(L_sing, c(1.0, 1.0), constraint = "flows"))
})

test_that("Schur complement Le Chatelier moderation", {
  L0 <- matrix(c(2.0, 0.5, 0.5, 1.0), 2, 2)
  schur_1 <- schur_effective_conductivity(L0, 1L)
  expect_equal(schur_1$L_ii, 2.0)
  expect_equal(schur_1$L_ii_eff, 2.0 - 0.5^2 / 1.0)
  expect_true(schur_1$L_ii_eff < schur_1$L_ii)
  expect_true(schur_1$R_ii_unclamped < schur_1$R_ii_clamped)
})

# ------------------------------------------------------------------
# Testset 2: Community Matrix <-> Onsager Conductivity Bridge
# ------------------------------------------------------------------
cat("
Testset 2: Community Matrix <-> Onsager Conductivity Bridge (Section 3)
")

test_that("Two-pool stoichiometric inversion and congruence", {
  B <- matrix(c(-1.0, 1.0, -1.0, 0.0), 2, 2)
  H <- matrix(c(2.0, 0.5, 0.5, 1.0), 2, 2)
  L <- matrix(c(1.0, 0.2, 0.2, 0.5), 2, 2)
  
  fwd <- forward_community_matrix(L, H, B = B)
  expect_equal(fwd$L_x, matrix(c(1.9, -1.2, -1.2, 1.0), 2, 2))
  expect_equal(fwd$A, matrix(c(-3.2, 1.9, 0.25, -0.4), 2, 2))
  expect_equal(fwd$A_F_A, 0.6220, tol = 1e-3)
  expect_equal(fwd$A_F_Lx, 0.0, tol = 1e-12)
  expect_true(all(Re(fwd$eigenvalues_A) < 0))
  
  inv_sq <- inverse_onsager_conductivity(fwd$A, H, B = B)
  expect_true(inv_sq$regime == "square_invertible")
  expect_equal(inv_sq$L_x, fwd$L_x)
  expect_equal(inv_sq$L, L)
  
  inv_dense <- inverse_onsager_conductivity(fwd$A, H)
  expect_true(inv_dense$regime == "dense_pool")
  expect_equal(inv_dense$L, fwd$L_x)
  
  B_rect <- t(matrix(c(1.0, 1.0, 0.0, 1.0, -1.0, 0.0), 3, 2)) # 2 x 3
  L_3 <- diag(3)
  fwd_rect <- forward_community_matrix(L_3, H, B = B_rect)
  inv_rect <- inverse_onsager_conductivity(fwd_rect$A, H, B = B_rect)
  expect_true(inv_rect$regime == "rank_deficient_pseudoinverse")
  expect_equal(B_rect %*% inv_rect$L %*% t(B_rect), fwd_rect$L_x)
})

# ------------------------------------------------------------------
# Testset 3: Canonical Estimator & Physical Thermal Network
# ------------------------------------------------------------------
cat("
Testset 3: Canonical Estimator & Physical Thermal Network (Sections 4 & 5.1)
")

test_that("Thermal network analytical properties", {
  model <- thermal_two_mode()
  mats <- thermal_network_matrices(model)
  
  expect_true(max(abs(mats$A + mats$L %*% mats$H)) <= 1e-14 * norm(mats$A, "F"))
  expect_equal(mats$H, k_B * solve(mats$C))
  expect_equal(mats$D, k_B * mats$L)
  expect_equal(mats$K_cov, mats$D)
  expect_true(norm(mats$Omega, "F") <= 1e-12 * norm(mats$D, "F"))
  expect_true(mats$sigma < 1e-45)
  
  driven <- thermal_network_matrices(model, kappa = 0.5)
  K_sym <- 0.5 * (driven$K_cov + t(driven$K_cov))
  expect_equal(K_sym / k_B, mats$L)
  expect_true(norm(driven$Omega, "F") > 0)
  expect_true(driven$sigma > 0)
  expect_equal(driven$sigma, 1.4524e-23, tol = 1e-3)
})

test_that("Innovation diffusion quadrature and OU trajectory recovery", {
  model <- thermal_two_mode()
  mats <- thermal_network_matrices(model)
  dt <- 0.02
  Phi <- as.matrix(Matrix::expm(mats$A * dt))
  Q <- mats$C - Phi %*% mats$C %*% t(Phi)
  D_rec <- diffusion_from_innovation(mats$A, Q, dt)
  expect_equal(D_rec, mats$D, tol = 1e-8)
  
  X_data <- simulate_ou_process(mats$A, mats$D, dt = 0.05, n_steps = 20000L,
                                C = mats$C, seed = 11)
  est <- estimate_ou_onsager(X_data, dt = 0.05, scale = k_B)
  expect_true(norm(est$L_x - mats$L, "F") / norm(mats$L, "F") < 0.15)
  expect_true(norm(est$H - mats$H, "F") / norm(mats$H, "F") < 0.20)
  expect_true(est$drift_stable)
  expect_true(est$psd_within_roundoff)
  
  Lambda <- diag(c(2.0, 0.5))
  Y_data <- X_data %*% t(Lambda)
  est_Y <- estimate_ou_onsager(Y_data, dt = 0.05, scale = k_B)
  L_Y_exact <- Lambda %*% mats$L %*% t(Lambda)
  expect_true(norm(est_Y$L_x - L_Y_exact, "F") / norm(L_Y_exact, "F") < 0.15)
})

# ------------------------------------------------------------------
# Testset 4: Reversible Gillespie & Evolving Trait Models
# ------------------------------------------------------------------
cat("
Testset 4: Reversible Gillespie & Evolving Trait Models (Sections 5.2-5.3)
")

test_that("Two-pathway channel conductivity and occupancy", {
  kappa <- c(2.0, 3.0)
  c_s <- 0.2
  L_exact <- exact_two_pathway_conductivity(kappa, c_s)
  expect_equal(L_exact, t(L_exact))
  expect_equal(as.vector(L_exact %*% c(1.0, 1.0)), c(0.0, 0.0))
  expect_true(min(eigen(L_exact, symmetric = TRUE, only.values = TRUE)$values) >= -1e-14)
  expect_equal(equilibrium_occupancy_fraction(0.0), 0.5)
  expect_true(equilibrium_occupancy_fraction(-R_GAS * 298.15) > 0.5)
})

test_that("Channel current simulation and evolution", {
  kappa <- c(2.0, 3.0)
  c_s <- 0.2
  sim1 <- simulate_channel_current_density(c(0.5, 0.0), kappa, N_sites = 40L,
                                          c_s = c_s, burn_in = 0.2, T_obs = 2.0,
                                          seed = 31)
  sim2 <- simulate_channel_current_density(c(0.5, 0.0), kappa, N_sites = 40L,
                                          c_s = c_s, burn_in = 0.2, T_obs = 2.0,
                                          seed = 31)
  expect_equal(sim1$J, sim2$J)
  
  evo1 <- simulate_evolving_conductivity(
    n_epochs = 3L, epoch_duration = 3.0, T_obs = 1.0, N_sites = 40L, c_s = 0.2,
    n_replicates = 2L, burn_in = 0.2, theta_0 = -0.4, theta_star = 0.4,
    s = 0.25, sigma_theta = 0.0, seed = 41
  )
  expect_equal(round(evo1$theta, 4), c(-0.4, -0.2, -0.05))
  expect_true(evo1$p_occ_eq[1] > evo1$p_occ_eq[3])
})

# ------------------------------------------------------------------
# Testset 5: Ecological Networks, Mock OU & Cone Spring
# ------------------------------------------------------------------
cat("
Testset 5: Ecological Networks, Mock OU & Cone Spring (Sections 3.3, 5.4, 6)
")

test_that("Biomass normalization and weighting", {
  norm_res <- normalize_biomass(c(10.0, 20.0, 30.0))
  expect_equal(sum(norm_res$b), 1.0)
  expect_equal(norm_res$B_tot, 60.0)
  expect_error(normalize_biomass(c(0.0, 0.0)))
  expect_error(normalize_biomass(c(1.0, -1.0)))
  
  N <- c(120.0, 40.0, 12.0)
  M <- c(0.01, 0.05, 1.5)
  A <- matrix(c(-0.1, 0.01, 0.2, 0.02, -0.2, 0.1, -0.5, -0.3, -0.05), 3, 3)
  w_res <- weighted_interaction_matrix(N, M, A, k = 0.25)
  expect_equal(w_res$W, diag(M^(-0.25)) %*% A %*% diag(w_res$b))
  expect_equal(w_res$W_B, A %*% diag(w_res$b))
  expect_equal(w_res$A_F, matrix_asymmetry(w_res$W)$A_F)
})

test_that("Synthetic 3-species OU mock", {
  mock <- run_population_response_mock()
  expect_equal(mock$A_F_A, 0.0582, tol = 1e-3)
  expect_equal(mock$A_F_WB, 0.3405, tol = 1e-3)
  expect_equal(mock$A_F_W, 0.6522, tol = 1e-3)
  expect_equal(mock$min_eig_neg_sym_WB, 0.0186, tol = 1e-3)
  expect_true(mock$rel_error_K_cov < 0.10)
  expect_true(mock$estimate$drift_stable)
  expect_true(mock$estimate$psd_within_roundoff)
})

test_that("Cone Spring food web community analysis", {
  cs <- analyze_cone_spring()
  A_CS <- cs$network$A
  expect_true(all(Re(cs$eigenvalues_A) < 0))
  expect_true(A_CS[1, 2] < 0 && A_CS[2, 1] > 0)
  expect_true(A_CS[2, 3] < 0 && A_CS[3, 2] > 0)
  expect_equal(cs$L_naive[1, 2], 75.0)
  expect_equal(cs$L_naive[2, 3], 370.0)
  expect_equal(cs$L_naive[3, 2], -167.0)
  expect_equal(min(cs$L_naive_sym_eigs), -29.163, tol = 1e-2)
  expect_equal(cs$min_eig_neg_sym_WB, -0.1506, tol = 1e-3)
  K_sym <- 0.5 * (cs$K_cov + t(cs$K_cov))
  expect_equal(K_sym, cs$D)
  expect_equal(cs$min_sym_eig_K_cov, 345.10, tol = 1e-2)
  expect_equal(cs$circulation_rate, 90.3527, tol = 1e-2)
  expect_true(cs$C[1, 3] < 0)  # Indirect trophic cascade covariance
  expect_true(cs$Omega[1, 3] != 0)
  expect_true(cs$rel_error_K_cov < 0.10)
  expect_true(cs$estimate$drift_stable)
  expect_true(cs$estimate$psd_within_roundoff)
})

# ------------------------------------------------------------------
# Testset 6: Size spectra and demographic jump models
# ------------------------------------------------------------------
cat("
Testset 6: Size spectra and demographic jump models (Section 6)
")

test_that("Size spectrum indices and response", {
  params <- size_spectrum_params(
    m_min = 1.0, m_max = 10.0, abundance_scale = 2.0,
    abundance_exponent = 1.0, metabolic_scale = 3.0,
    metabolic_exponent = 1.0, temperature = 300.0, reference_mass = 1.0
  )
  indices <- compute_size_spectrum_indices(params, n_bins = 10001L)
  expect_equal(indices$beta, 0.0)
  expect_equal(indices$biomass_total, 18.0, tol = 1e-3)
  expect_equal(indices$power_total, 54.0, tol = 1e-3)
  expect_equal(indices$entropy_production_proxy, 0.18, tol = 1e-3)
  expect_equal(indices$specific_power_proxy, 3.0, tol = 1e-3)
})

test_that("Demographic Gillespie jump process", {
  j_params <- population_jump_params(
    r = c(10.0, 3.0, 0.5),
    d = c(2.0, 0.8, 0.1),
    c = c(0.01, 0.02, 0.05),
    gamma = matrix(c(0.0, 0.1, 0.0, 0.0, 0.0, 0.05, 0.0, 0.0, 0.0), 3, 3),
    M = c(1.0, 10.0, 100.0),
    V = 100.0,
    epsilon = 0.2
  )
  jump_res <- run_gillespie_population(c(500L, 50L, 5L), j_params, 2.0, seed = 8)
  expect_true(all(sapply(jump_res$N_history, function(n) all(n >= 0))))
  expect_true(all(jump_res$time <= 2.0))
})

# ------------------------------------------------------------------
# Testset 7: NPZD and NPZD-fish ecosystem models
# ------------------------------------------------------------------
cat("
Testset 7: NPZD and NPZD-fish ecosystem models (Section 7)
")

test_that("NPZD reference state and diagnostics", {
  npzd_p <- npzd_params()
  ref <- npzd_reference_state(npzd_p)
  npzd <- npzd_diagnostics(npzd_p)
  expect_true(all(ref$state > 0))
  expect_true(ref$nutrient_input > 0)
  expect_equal(norm(npzd_rhs(ref$state, npzd_p), "2"), 0.0, tol = 1e-10)
  expect_true(all(Re(npzd$eigenvalues) < 0))
  expect_true(min(eigen(npzd$C, symmetric = TRUE, only.values = TRUE)$values) > 0)
  expect_true(min(eigen(npzd$D, symmetric = TRUE, only.values = TRUE)$values) > 0)
  expect_true(npzd$lyapunov_residual < 1e-12)
  expect_true(is.finite(npzd$decomposition$circulation_rate))
})

test_that("NPZD-fish reference state, harvest shock, and diagnostics", {
  fish_p <- npzd_fish_params()
  ref <- npzd_fish_reference_state(fish_p)
  fish <- npzd_fish_diagnostics(fish_p)
  expect_true(all(ref$state > 0))
  expect_true(ref$nutrient_input > 0)
  expect_equal(norm(npzd_fish_rhs(ref$state, fish_p), "2"), 0.0, tol = 1e-10)
  
  rhs_shock <- npzd_fish_rhs(ref$state, fish_p, harvest_multiplier = 2.0)
  expect_equal(rhs_shock[5], -fish_p$harvest_mortality * ref$state[5], tol = 1e-8)
  expect_true(all(Re(fish$eigenvalues) < 0))
  expect_true(min(eigen(fish$C, symmetric = TRUE, only.values = TRUE)$values) > 0)
  expect_true(min(eigen(fish$D, symmetric = TRUE, only.values = TRUE)$values) > 0)
  expect_true(fish$lyapunov_residual < 1e-12)
  expect_true(is.finite(fish$decomposition$circulation_rate))
  
  harvest <- simulate_npzd_fish_harvest(fish_p, duration = 0.02, dt = 0.001,
                                        harvest_time = 0.01, seed = 53)
  expect_equal(nrow(harvest$states), 21L)
  expect_equal(ncol(harvest$states), 5L)
  expect_true(all(is.finite(harvest$states)))
  expect_equal(harvest$states[1, ], ref$state, tol = 1e-10)
})

cat("
All OnsagerNetwork R tests passed successfully!
")
