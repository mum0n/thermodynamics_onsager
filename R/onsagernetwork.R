# onsagernetwork.R
# Unified non-equilibrium thermodynamic operators, community-to-Onsager
# transformations, canonical covariance estimators, physical transport models,
# and ecological network diagnostics.
#
# References:
# Onsager, L. (1931a, 1931b). Reciprocal relations in irreversible processes.
# Tomita, K. & Tomita, H. (1974). Prog. Theor. Phys. 51(6), 1731-1749.
# Reis, A. (2014). Minimum and maximum entropy production principles.
# Choi, J.S. (2026). Non-equilibrium thermodynamics and community matrix factorization.

suppressPackageStartupMessages({
  library(Matrix)
  library(MASS)
})

# ------------------------------------------------------------------
# Physical and numerical constants
# ------------------------------------------------------------------
k_B = 1.380649e-23            # Boltzmann constant (J K^-1)
R_GAS = 8.31446261815324      # Molar gas constant (J mol^-1 K^-1)
DEFAULT_ALLOMETRIC_K = 0.25   # Kleiber allometric mass exponent

MATRIX_LOG_IMAG_RTOL = 1e-8
MATRIX_SYM_ATOL = 1e-10
MATRIX_SYM_RTOL = 1e-8
PSD_ROUNDOFF_RTOL = 1e-10

# Five-point Gauss-Legendre quadrature nodes and weights on [0, 1]
GL5_NODES = c(
  0.046910077030668,
  0.230765344947158,
  0.500000000000000,
  0.769234655052841,
  0.953089922969332
)
GL5_WEIGHTS = c(
  0.118463442528095,
  0.239314335249683,
  0.284444444444444,
  0.239314335249683,
  0.118463442528095
)

# ==================================================================
# 1. Matrix Asymmetry and Thermodynamic Primitives (Paper Section 2)
# ==================================================================

#' Compute the Frobenius asymmetry index and decomposition of a square matrix.
#'
#' Evaluates the dimensionless Frobenius asymmetry index:
#' \deqn{\mathcal{A}_F(\mathbf{M}) = \frac{\|\mathbf{M} - \mathbf{M}^{\mathsf{T}}\|_F}{\|\mathbf{M}\|_F} \in [0, 2]}
#' together with the symmetric part \eqn{\mathbf{M}_s = \frac{1}{2}(\mathbf{M} + \mathbf{M}^{\mathsf{T}})}
#' and skew-symmetric part \eqn{\mathbf{M}_a = \frac{1}{2}(\mathbf{M} - \mathbf{M}^{\mathsf{T}})}.
#'
#' @param M Square real matrix with finite entries.
#' @return Named list with elements:
#' \item{A_F}{Dimensionless Frobenius asymmetry scalar.}
#' \item{symmetric}{Symmetric component matrix.}
#' \item{skew}{Skew-symmetric component matrix.}
#' \item{pairwise}{Matrix of pairwise asymmetry ratios.}
#' @export
matrix_asymmetry = function(M) {
  if (!is.matrix(M) || nrow(M) != ncol(M)) {
    stop("M must be a square matrix")
  }
  if (any(!is.finite(M))) {
    stop("M must contain only finite values")
  }
  mat = matrix(as.numeric(M), nrow = nrow(M), ncol = ncol(M))
  diff_mat = mat - t(mat)
  denom = norm(mat, "F")
  A_F = if (denom > 0) norm(diff_mat, "F") / denom else 0.0
  symmetric = 0.5 * (mat + t(mat))
  skew = 0.5 * diff_mat
  n = nrow(mat)
  pairwise = matrix(0.0, nrow = n, ncol = n)
  for (i in seq_len(n)) {
    for (j in seq_len(n)) {
      scale = abs(mat[i, j]) + abs(mat[j, i])
      pairwise[i, j] = if (scale > 0) (mat[i, j] - mat[j, i]) / scale else 0.0
    }
  }
  list(A_F = A_F, symmetric = symmetric, skew = skew, pairwise = pairwise)
}

#' Test for persistent temporal asymmetry in an asymmetry index time series.
#'
#' Evaluates whether a series of asymmetry indices exhibits at least `min_run`
#' consecutive values strictly greater than `threshold`.
#'
#' @param A_F_series Vector of finite real asymmetry values.
#' @param threshold Finite real threshold (default 0.2).
#' @param min_run Positive integer run length requirement (default 3).
#' @return Logical scalar indicating persistence.
#' @export
persistent_asymmetry = function(A_F_series, threshold = 0.2, min_run = 3L) {
  if (min_run <= 0) {
    stop("min_run must be positive")
  }
  if (!is.finite(threshold)) {
    stop("threshold must be finite")
  }
  if (length(A_F_series) == 0 || any(!is.finite(A_F_series))) {
    stop("A_F_series must contain only finite values")
  }
  run_count = 0L
  for (val in A_F_series) {
    run_count = if (val > threshold) run_count + 1L else 0L
    if (run_count >= min_run) {
      return(TRUE)
    }
  }
  FALSE
}

#' Construct an exchangeability null distribution of the Frobenius asymmetry.
#'
#' Applies independent random row and column permutations to square matrices.
#'
#' @param matrices List of square real matrices.
#' @param n_perm Nonnegative integer number of permutations per matrix (default 200).
#' @param seed Optional random number generator seed.
#' @return Numeric vector of permuted asymmetry indices.
#' @export
asymmetry_null = function(matrices, n_perm = 200L, seed = NULL) {
  if (n_perm < 0) {
    stop("n_perm must be nonnegative")
  }
  if (!is.null(seed)) {
    set.seed(seed)
  }
  null_vals = numeric(0)
  for (M in matrices) {
    if (!is.matrix(M) || nrow(M) != ncol(M)) {
      stop("each matrix must be square")
    }
    if (any(!is.finite(M))) {
      stop("each matrix must contain only finite values")
    }
    mat = matrix(as.numeric(M), nrow = nrow(M), ncol = ncol(M))
    n = nrow(mat)
    for (p in seq_len(n_perm)) {
      rows = sample.int(n)
      cols = sample.int(n)
      null_vals = c(null_vals, matrix_asymmetry(mat[rows, cols])$A_F)
    }
  }
  null_vals
}

validate_onsager_matrix = function(L, vec_arg, constraint = c("forces", "flows")) {
  constraint = match.arg(constraint)
  if (!is.matrix(L) || nrow(L) != ncol(L)) {
    stop("L must be a square matrix")
  }
  n = length(vec_arg)
  if (nrow(L) != n) {
    stop("L dimensions must match vector dimension")
  }
  if (any(!is.finite(L)) || any(!is.finite(vec_arg))) {
    stop("L and vector must contain only finite values")
  }
  if (all(vec_arg == 0)) {
    stop("driving force or flux vector must be nonzero")
  }
  sym_diff = norm(L - t(L), "F")
  l_norm = norm(L, "F")
  if (sym_diff > MATRIX_SYM_ATOL + MATRIX_SYM_RTOL * l_norm) {
    stop("L must be symmetric (Onsager reciprocity)")
  }
  sym_L = 0.5 * (L + t(L))
  eigs = eigen(sym_L, symmetric = TRUE, only.values = TRUE)$values
  min_eig = min(eigs)
  if (constraint == "forces") {
    tol = PSD_ROUNDOFF_RTOL * max(1.0, norm(sym_L, "2"))
    if (min_eig < -tol) {
      stop("L must be positive semidefinite for fixed forces")
    }
  } else {
    if (min_eig <= 0) {
      stop("L must be positive definite for fixed flows")
    }
  }
  sym_L
}

#' Evaluate the internal entropy production rate in the linear Onsager regime.
#'
#' Computes the entropy production rate \eqn{\sigma}:
#' \deqn{\sigma_X = \mathbf{X}^{\mathsf{T}}\mathbf{L}\mathbf{X} \ge 0 \quad (\text{forces}), \qquad \sigma_J = \mathbf{J}^{\mathsf{T}}\mathbf{L}^{-1}\mathbf{J} > 0 \quad (\text{flows})}
#'
#' @param L Symmetric positive semidefinite (or positive definite) conductivity matrix.
#' @param X_or_J Nonzero thermodynamic force vector or conjugate flux vector.
#' @param constraint Either "forces" or "flows".
#' @return Scalar entropy production rate.
#' @export
entropy_production = function(L, X_or_J, constraint = c("forces", "flows")) {
  constraint = match.arg(constraint)
  sym_L = validate_onsager_matrix(L, X_or_J, constraint)
  v = as.numeric(X_or_J)
  if (constraint == "forces") {
    as.numeric(t(v) %*% (sym_L %*% v))
  } else {
    as.numeric(t(v) %*% solve(sym_L, v))
  }
}

#' Evaluate the second differential of entropy production at stationary transport.
#'
#' Computes \eqn{d^2\sigma} around a state where \eqn{d\mathbf{L} = \mathbf{0}}
#' (Reis 2014), identifying whether the configuration is a maximum or minimum:
#' \deqn{\left.d^2\sigma_X\right|_{d\mathbf{L}=\mathbf{0}} = \mathbf{X}^{\mathsf{T}}(d^2\mathbf{L})\mathbf{X}, \qquad \left.d^2\sigma_J\right|_{d\mathbf{L}=\mathbf{0}} = -\mathbf{J}^{\mathsf{T}}\mathbf{L}^{-1}(d^2\mathbf{L})\mathbf{L}^{-1}\mathbf{J}}
#'
#' @param L Symmetric Onsager conductivity matrix.
#' @param d2L Symmetric second differential matrix \eqn{d^2\mathbf{L}}.
#' @param X_or_J Driving force or conjugate flux vector.
#' @param constraint Either "forces" or "flows".
#' @param rtol Relative numerical tolerance for regime classification (default 1e-12).
#' @return Named list with elements `d2sigma` and `regime` ("maximum", "minimum", or "indeterminate").
#' @export
entropy_production_curvature = function(L, d2L, X_or_J,
                                         constraint = c("forces", "flows"),
                                         rtol = 1e-12) {
  constraint = match.arg(constraint)
  sym_L = validate_onsager_matrix(L, X_or_J, constraint)
  if (!is.matrix(d2L) || nrow(d2L) != ncol(d2L) || nrow(d2L) != nrow(L)) {
    stop("d2L must be square and match L dimensions")
  }
  if (any(!is.finite(d2L))) {
    stop("d2L must contain only finite values")
  }
  d2L_sym = 0.5 * (d2L + t(d2L))
  v = as.numeric(X_or_J)
  val = if (constraint == "forces") {
    as.numeric(t(v) %*% (d2L_sym %*% v))
  } else {
    L_inv_v = solve(sym_L, v)
    -as.numeric(t(L_inv_v) %*% (d2L_sym %*% L_inv_v))
  }
  scale = max(1.0, abs(val))
  regime = if (val < -rtol * scale) {
    "maximum"
  } else if (val > rtol * scale) {
    "minimum"
  } else {
    "indeterminate"
  }
  list(d2sigma = val, regime = regime)
}

#' Compute the Schur complement effective conductivity of an unconstrained subsystem.
#'
#' Evaluates the moderated effective conductivity \eqn{L_{ii,\mathrm{eff}}} under
#' zero-flux stationarity of all remaining degrees of freedom:
#' \deqn{L_{ii,\mathrm{eff}} = L_{ii} - \mathbf{L}_{i,-i}\mathbf{L}_{-i,-i}^{-1}\mathbf{L}_{-i,i}}
#' illustrating Le Chatelier-Braun moderation.
#'
#' @param L Strictly positive definite symmetric Onsager conductivity matrix.
#' @param i Index of the driven coordinate (1-based integer).
#' @return Named list with effective conductivities and clamped/unclamped resistances.
#' @export
schur_effective_conductivity = function(L, i) {
  if (!is.matrix(L) || nrow(L) != ncol(L)) {
    stop("L must be a square matrix")
  }
  n = nrow(L)
  if (i < 1 || i > n) {
    stop("index i is out of bounds")
  }
  sym_diff = norm(L - t(L), "F")
  if (sym_diff > MATRIX_SYM_ATOL + MATRIX_SYM_RTOL * norm(L, "F")) {
    stop("L must be symmetric")
  }
  sym_L = 0.5 * (L + t(L))
  if (min(eigen(sym_L, symmetric = TRUE, only.values = TRUE)$values) <= 0) {
    stop("L must be strictly positive definite")
  }
  rem = setdiff(seq_len(n), i)
  L_ii = sym_L[i, i]
  if (length(rem) == 0) {
    return(list(
      L_ii = L_ii,
      L_ii_eff = L_ii,
      moderation_decrement = 0.0,
      R_ii_unclamped = 1.0 / L_ii,
      R_ii_clamped = 1.0 / L_ii
    ))
  }
  L_ir = sym_L[i, rem, drop = FALSE]
  L_rr = sym_L[rem, rem, drop = FALSE]
  L_ri = sym_L[rem, i, drop = FALSE]
  decrement = as.numeric(L_ir %*% solve(L_rr, L_ri))
  L_ii_eff = L_ii - decrement
  list(
    L_ii = L_ii,
    L_ii_eff = L_ii_eff,
    moderation_decrement = decrement,
    R_ii_unclamped = 1.0 / L_ii,
    R_ii_clamped = 1.0 / L_ii_eff
  )
}

# ==================================================================
# 2. Community Matrix => Onsager Conductivity Bridge (Section 3)
# ==================================================================

#' Map process conductivity to macroscopic community Jacobian via stoichiometry and Hessian.
#'
#' Computes the forward physical mapping:
#' \deqn{\mathbf{L}_x = \mathbf{B}\mathbf{L}\mathbf{B}^{\mathsf{T}}, \qquad \mathbf{A} = -\mathbf{L}_x\mathbf{H}}
#'
#' @param L Symmetric positive semidefinite process conductivity matrix.
#' @param H Symmetric positive definite entropy Hessian matrix.
#' @param B Optional stoichiometric coupling matrix (default identity).
#' @return Named list containing `A`, `L_x`, `eigenvalues_A`, `A_F_A`, and `A_F_Lx`.
#' @export
forward_community_matrix = function(L, H, B = NULL) {
  if (!is.matrix(L) || nrow(L) != ncol(L)) {
    stop("L must be a square matrix")
  }
  if (!is.matrix(H) || nrow(H) != ncol(H)) {
    stop("H must be a square matrix")
  }
  n_pools = nrow(H)
  n_proc = nrow(L)
  if (is.null(B)) {
    if (n_pools != n_proc) {
      stop("L and H dimensions must match when B is omitted")
    }
    B_mat = diag(n_pools)
  } else {
    if (!is.matrix(B) || nrow(B) != n_pools || ncol(B) != n_proc) {
      stop("B must have dimensions matching pools x processes")
    }
    B_mat = matrix(as.numeric(B), nrow = n_pools, ncol = n_proc)
  }
  L_sym = 0.5 * (L + t(L))
  H_sym = 0.5 * (H + t(H))
  L_x = B_mat %*% L_sym %*% t(B_mat)
  A = -L_x %*% H_sym
  eigs = eigen(A, only.values = TRUE)$values
  list(
    A = A,
    L_x = L_x,
    eigenvalues_A = eigs,
    A_F_A = matrix_asymmetry(A)$A_F,
    A_F_Lx = matrix_asymmetry(L_x)$A_F
  )
}

#' Invert community Jacobian to recover physical Onsager conductivities.
#'
#' Inverts \eqn{\mathbf{A} = -\mathbf{B}\mathbf{L}\mathbf{B}^{\mathsf{T}}\mathbf{H}}:
#' \deqn{\mathbf{L}_x = -\mathbf{A}\mathbf{H}^{-1}, \qquad \mathbf{L} = \mathbf{B}^+(\mathbf{L}_x)(\mathbf{B}^+)^{\mathsf{T}}}
#'
#' @param A Square real community matrix.
#' @param H Symmetric positive definite entropy Hessian.
#' @param B Optional stoichiometric coupling matrix.
#' @return Named list with recovered `L`, `L_x`, and inversion `regime`.
#' @export
inverse_onsager_conductivity = function(A, H, B = NULL) {
  if (!is.matrix(A) || nrow(A) != ncol(A)) {
    stop("A must be a square matrix")
  }
  if (!is.matrix(H) || nrow(H) != ncol(H) || nrow(H) != nrow(A)) {
    stop("H must be square and match A dimensions")
  }
  H_sym = 0.5 * (H + t(H))
  L_x = -A %*% solve(H_sym)
  if (is.null(B)) {
    return(list(
      L = L_x,
      L_x = L_x,
      regime = "dense_pool"
    ))
  }
  if (!is.matrix(B) || nrow(B) != nrow(A)) {
    stop("B row dimension must match A dimension")
  }
  n_pools = nrow(B)
  n_proc = ncol(B)
  if (n_pools == n_proc && abs(det(B)) > 1e-12) {
    B_inv = solve(B)
    L = B_inv %*% L_x %*% t(B_inv)
    return(list(
      L = L,
      L_x = L_x,
      regime = "square_invertible"
    ))
  }
  B_pinv = MASS::ginv(B)
  L = B_pinv %*% L_x %*% t(B_pinv)
  list(
    L = L,
    L_x = L_x,
    regime = "rank_deficient_pseudoinverse"
  )
}

# ==================================================================
# 3. Covariance, Drift Decomposition & Canonical Estimator (Section 4)
# ==================================================================

#' Solve the continuous Lyapunov equation for stationary covariance.
#'
#' Solves \eqn{\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} + 2\mathbf{D} = \mathbf{0}}
#' for the stationary state covariance \eqn{\mathbf{C}}.
#'
#' @param A Hurwitz-stable drift matrix (all eigenvalues have negative real parts).
#' @param D Symmetric positive semidefinite diffusion matrix.
#' @return Symmetric stationary covariance matrix \eqn{\mathbf{C}}.
#' @export
solve_lyapunov_covariance = function(A, D) {
  if (!is.matrix(A) || nrow(A) != ncol(A)) {
    stop("A must be a square matrix")
  }
  if (!is.matrix(D) || nrow(D) != ncol(D) || nrow(D) != nrow(A)) {
    stop("D must be square and match A dimensions")
  }
  if (any(!is.finite(A)) || any(!is.finite(D))) {
    stop("A and D must contain only finite values")
  }
  eigs = eigen(A, only.values = TRUE)$values
  if (any(Re(eigs) >= 0)) {
    stop("A must be Hurwitz stable (all eigenvalues with negative real parts)")
  }
  n = nrow(A)
  In = diag(n)
  K = kronecker(In, A) + kronecker(A, In)
  vec_D = as.vector(0.5 * (D + t(D)))
  vec_C = -2.0 * solve(K, vec_D)
  C = matrix(vec_C, nrow = n, ncol = n)
  0.5 * (C + t(C))
}

#' Decompose covariance-weighted drift into symmetric dissipation and skew circulation.
#'
#' Performs the Tomita-Tomita / Graham decomposition:
#' \deqn{\mathbf{K} = -\mathbf{A}\mathbf{C} = \mathbf{D}_{\mathrm{sym}} - \boldsymbol{\Omega}}
#' where \eqn{\mathbf{D}_{\mathrm{sym}} = -\frac{1}{2}(\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}})}
#' and \eqn{\boldsymbol{\Omega} = \frac{1}{2}(\mathbf{A}\mathbf{C} - \mathbf{C}\mathbf{A}^{\mathsf{T}})}.
#'
#' @param A Drift matrix.
#' @param C Stationary covariance matrix.
#' @param D Optional reference diffusion matrix.
#' @param scale Optional physical temperature or noise scale (default 1.0).
#' @return Named list with decomposition matrices and entropy production rate.
#' @export
decompose_covariance_weighted_drift = function(A, C, D = NULL, scale = 1.0) {
  if (!is.matrix(A) || !is.matrix(C) || nrow(A) != ncol(A) || nrow(C) != ncol(C)) {
    stop("A and C must be square matrices")
  }
  n = nrow(A)
  if (nrow(C) != n) {
    stop("A and C must have matching dimensions")
  }
  C_mat = 0.5 * (C + t(C))
  AC = A %*% C_mat
  K_cov = -AC
  D_sym = -0.5 * (AC + t(AC))
  Omega = 0.5 * (AC - t(AC))
  
  D_use = if (is.null(D)) {
    D_sym
  } else {
    0.5 * (D + t(D))
  }
  
  lyap_res = if (is.null(D)) {
    0.0
  } else {
    sym_AC = 0.5 * (AC + t(AC))
    denom = norm(D_use, "F")
    residual = D_use + sym_AC
    if (denom > 0) norm(residual, "F") / denom else norm(residual, "F")
  }
  
  eigs_D = eigen(D_sym, symmetric = TRUE, only.values = TRUE)$values
  min_sym_eig = min(eigs_D)
  
  circ_rate = tryCatch({
    C_inv = solve(C_mat)
    D_inv = solve(D_use)
    sum(diag(t(Omega) %*% C_inv %*% Omega %*% D_inv))
  }, error = function(e) NaN)
  
  sigma = scale * circ_rate
  L_x = K_cov / scale
  H = scale * solve(C_mat)
  A_F_val = matrix_asymmetry(K_cov)$A_F

  list(
    K_cov = K_cov,
    D = D_sym,
    Omega = Omega,
    L_x = L_x,
    H = H,
    A_F = A_F_val,
    min_sym_eig = min_sym_eig,
    circulation_rate = circ_rate,
    lyapunov_residual = lyap_res,
    sigma = sigma
  )
}

diffusion_from_innovation = function(A, Q, dt) {
  if (!is.matrix(A) || !is.matrix(Q) || nrow(A) != ncol(A) || nrow(Q) != ncol(Q)) {
    stop("A and Q must be square matrices")
  }
  n = nrow(A)
  if (nrow(Q) != n) {
    stop("A and Q must have matching dimensions")
  }
  if (!is.finite(dt) || dt <= 0) {
    stop("dt must be finite and positive")
  }
  transport = matrix(0.0, nrow = n^2, ncol = n^2)
  for (i in seq_along(GL5_NODES)) {
    prop = as.matrix(Matrix::expm(A * (dt * GL5_NODES[i])))
    transport = transport + GL5_WEIGHTS[i] * kronecker(prop, prop)
  }
  transport = transport * dt
  Q_sym = 0.5 * (Q + t(Q))
  vec_Q = as.vector(Q_sym)
  vec_D = solve(transport, vec_Q)
  D_raw = 0.5 * matrix(vec_D, nrow = n, ncol = n)
  0.5 * (D_raw + t(D_raw))
}

#' Simulate an exact stationary discrete-time Gaussian Ornstein-Uhlenbeck process.
#'
#' Generates discrete trajectory points \eqn{\mathbf{x}_{t+1} = \mathbf{\Phi}\mathbf{x}_t + \mathbf{Q}^{1/2}\boldsymbol{\xi}_t}.
#'
#' @param A Hurwitz drift matrix.
#' @param D Diffusion matrix.
#' @param dt Sampling interval.
#' @param n_steps Number of time steps.
#' @param C Optional precomputed covariance matrix.
#' @param seed Optional random number generator seed.
#' @return Matrix of dimensions `(n_steps, n_vars)` containing the simulated trajectory.
#' @export
simulate_ou_process = function(A, D, dt, n_steps, C = NULL, seed = NULL) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  n = nrow(A)
  if (is.null(C)) {
    C = solve_lyapunov_covariance(A, D)
  }
  Phi = as.matrix(Matrix::expm(A * dt))
  Q = C - Phi %*% C %*% t(Phi)
  Q = 0.5 * (Q + t(Q))
  e_Q = eigen(Q, symmetric = TRUE)
  pos_vals = pmax(e_Q$values, 0.0)
  Q_half = e_Q$vectors %*% diag(sqrt(pos_vals), nrow = n, ncol = n)
  
  e_C = eigen(C, symmetric = TRUE)
  C_half = e_C$vectors %*% diag(sqrt(pmax(e_C$values, 0.0)), nrow = n, ncol = n)
  
  X_data = matrix(0.0, nrow = n_steps, ncol = n)
  x_cur = as.vector(C_half %*% rnorm(n))
  X_data[1, ] = x_cur
  for (t in 2:n_steps) {
    x_cur = as.vector(Phi %*% x_cur + Q_half %*% rnorm(n))
    X_data[t, ] = x_cur
  }
  X_data
}

matrix_log_principal = function(M) {
  ed = eigen(M)
  vals = ed$values
  V = ed$vectors
  D_mat = diag(log(as.complex(vals)), nrow = length(vals), ncol = length(vals))
  V %*% D_mat %*% solve(V)
}

#' Estimate continuous Onsager transport matrices from discrete state observations.
#'
#' Fits a VAR(1) transition operator, extracts the principal continuous drift
#' via matrix logarithm, inverts innovation covariance to diffusion, and extracts
#' Onsager conductivity and circulation tensors.
#'
#' @param X_data Observed trajectory matrix `(n_obs, n_vars)`.
#' @param dt Sampling time interval.
#' @param scale Physical temperature or noise scaling constant (default 1.0).
#' @return Named list summarizing recovered drift, covariance, diffusion, and conductivities.
#' @export
estimate_ou_onsager = function(X_data, dt = 1.0, scale = 1.0) {
  if (!is.matrix(X_data)) {
    X_data = as.matrix(X_data)
  }
  n_obs = nrow(X_data)
  n_vars = ncol(X_data)
  if (n_obs < 4) {
    stop("at least four time observations are required")
  }
  if (!is.finite(dt) || dt <= 0) {
    stop("dt must be finite and positive")
  }
  centered = scale(X_data, center = TRUE, scale = FALSE)
  C_hat = cov(centered)
  
  lagged = centered[1:(n_obs - 1), , drop = FALSE]
  advanced = centered[2:n_obs, , drop = FALSE]
  gram = t(lagged) %*% lagged
  Phi = t(solve(gram, t(lagged) %*% advanced))
  
  c_log = matrix_log_principal(Phi) / dt
  imag_norm = norm(Im(c_log), "F")
  real_norm = norm(Re(c_log), "F")
  if (imag_norm > MATRIX_LOG_IMAG_RTOL * max(1.0, real_norm)) {
    stop("VAR(1) transition has no real principal matrix logarithm")
  }
  A_hat = Re(c_log)
  
  residuals = advanced - lagged %*% t(Phi)
  Q_hat = (t(residuals) %*% residuals) / (n_obs - 2)
  D_hat = diffusion_from_innovation(A_hat, Q_hat, dt)
  
  decomp = decompose_covariance_weighted_drift(A_hat, C_hat, D = D_hat, scale = scale)
  drift_stable = all(Re(eigen(A_hat, only.values = TRUE)$values) < 0)
  tol = PSD_ROUNDOFF_RTOL * max(1.0, norm(decomp$D, "2"))
  psd_ok = decomp$min_sym_eig >= -tol
  
  H_hat = scale * solve(C_hat)
  L_x_hat = decomp$D / scale
  L_from_D = D_hat / scale
  
  list(
    A = A_hat,
    C = C_hat,
    D = D_hat,
    Q = Q_hat,
    Phi = Phi,
    K_cov = decomp$K_cov,
    K_cov_sym = decomp$D,
    Omega = decomp$Omega,
    L_x = decomp$L_x,
    L_from_D = L_from_D,
    H = decomp$H,
    sigma = decomp$sigma,
    circulation_rate = decomp$circulation_rate,
    A_F = decomp$A_F,
    min_sym_eig = decomp$min_sym_eig,
    lyapunov_residual = decomp$lyapunov_residual,
    drift_stable = drift_stable,
    psd_within_roundoff = psd_ok
  )
}

#' Marginal coarse-grained conductivity of a observed subsystem.
#'
#' @param A Full drift matrix.
#' @param C Full stationary covariance matrix.
#' @param indices Subsystem coordinate indices.
#' @param dt Sampling time step (default 0.0).
#' @param scale Physical noise scale (default 1.0).
#' @return Marginal coarse-grained conductivity matrix.
#' @export
marginal_coarse_grained_conductivity = function(A, C, indices, dt = 0.0, scale = 1.0) {
  if (dt == 0.0) {
    K_full = -A %*% C
    D_full = 0.5 * (K_full + t(K_full))
    return(D_full[indices, indices, drop = FALSE] / scale)
  }
  Phi_full = as.matrix(Matrix::expm(A * dt))
  Phi_sub = Phi_full[indices, indices, drop = FALSE]
  C_sub = C[indices, indices, drop = FALSE]
  A_eff = Re(matrix_log_principal(Phi_sub)) / dt
  K_eff = -A_eff %*% C_sub
  D_eff = 0.5 * (K_eff + t(K_eff))
  D_eff / scale
}

# ==================================================================
# 4. Time Series Vector Autoregressions (VAR)
# ==================================================================

#' Fit a vector autoregressive model of order p.
#'
#' @param X_data Observation matrix `(n_obs, n_vars)`.
#' @param p Autoregressive lag order (default 1).
#' @return Named list with `lags`, `intercept`, `residuals`, and `sigma`.
#' @export
fit_var = function(X_data, p = 1L) {
  if (!is.matrix(X_data)) {
    X_data = as.matrix(X_data)
  }
  n_obs = nrow(X_data)
  k = ncol(X_data)
  if (n_obs <= p * k + 1) {
    stop("sample size is insufficient for VAR order p")
  }
  Y = X_data[(p + 1):n_obs, , drop = FALSE]
  n_eff = nrow(Y)
  Z = matrix(1.0, nrow = n_eff, ncol = 1 + p * k)
  for (i in 1:p) {
    Z[, (1 + (i - 1) * k + 1):(1 + i * k)] = X_data[(p + 1 - i):(n_obs - i), , drop = FALSE]
  }
  B_hat = solve(t(Z) %*% Z, t(Z) %*% Y)
  residuals = Y - Z %*% B_hat
  intercept = B_hat[1, ]
  lags = vector("list", p)
  for (i in 1:p) {
    lags[[i]] = t(B_hat[(1 + (i - 1) * k + 1):(1 + i * k), , drop = FALSE])
  }
  sigma = (t(residuals) %*% residuals) / (n_eff - (1 + p * k))
  list(lags = lags, intercept = intercept, residuals = residuals, sigma = sigma)
}

#' Rolling-window estimation of VAR(1) Frobenius asymmetry.
#'
#' @param X_data Observation matrix.
#' @param window Rolling window size.
#' @param p Autoregressive lag order (default 1).
#' @param step Window stride step.
#' @return Named list with `midpoints` and `A_F` series.
#' @export
rolling_var_asymmetry = function(X_data, window = 100L, p = 1L, step = 100L) {
  if (!is.matrix(X_data)) {
    X_data = as.matrix(X_data)
  }
  n_obs = nrow(X_data)
  starts = seq(1, n_obs - window + 1, by = step)
  A_F_vals = numeric(length(starts))
  midpoints = numeric(length(starts))
  for (i in seq_along(starts)) {
    idx = starts[i]:(starts[i] + window - 1)
    fit = fit_var(X_data[idx, , drop = FALSE], p = p)
    A_F_vals[i] = matrix_asymmetry(fit$lags[[1]])$A_F
    midpoints[i] = mean(idx)
  }
  list(midpoints = midpoints, A_F = A_F_vals)
}

#' Block bootstrap confidence intervals for VAR(1) asymmetry.
#'
#' @param X_data Observation matrix.
#' @param p Lag order.
#' @param n_boot Number of bootstrap replicates.
#' @param block_length Moving block length.
#' @param seed Optional random number generator seed.
#' @return Named list with point estimate and confidence interval.
#' @export
bootstrap_var_asymmetry = function(X_data, p = 1L, n_boot = 10L,
                                    block_length = 10L, seed = NULL) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  if (!is.matrix(X_data)) {
    X_data = as.matrix(X_data)
  }
  fit_orig = fit_var(X_data, p = p)
  orig_asym = matrix_asymmetry(fit_orig$lags[[1]])$A_F
  n_obs = nrow(X_data)
  n_blocks = ceiling(n_obs / block_length)
  max_start = n_obs - block_length + 1
  boot_vals = numeric(n_boot)
  for (b in seq_len(n_boot)) {
    starts = sample.int(max_start, size = n_blocks, replace = TRUE)
    idx = unlist(lapply(starts, function(s) s:(s + block_length - 1)))[1:n_obs]
    fit_b = fit_var(X_data[idx, , drop = FALSE], p = p)
    boot_vals[b] = matrix_asymmetry(fit_b$lags[[1]])$A_F
  }
  q = quantile(boot_vals, probs = c(0.025, 0.975))
  list(
    original = orig_asym,
    interval = list(lower = as.numeric(q[1]), upper = as.numeric(q[2])),
    boot_values = boot_vals
  )
}

# ==================================================================
# 5. Thermal Two-Mode and Four-Mode Models (Section 5.1)
# ==================================================================

#' Construct parameters for a two-mode thermal Brownian network.
#'
#' @param T Ambient temperature in Kelvin (default 300.0).
#' @param C1 Mode 1 heat capacity (default 1.0).
#' @param C2 Mode 2 heat capacity (default 2.0).
#' @param G12 Thermal conductance between modes (default 0.5).
#' @return Named list of model parameters.
#' @export
thermal_two_mode = function(T = 300.0, C_heat = c(1.0, 2.0),
                             G_bath = c(0.5, 0.25), G_m = 0.75) {
  list(T = T, C_heat = C_heat, G_bath = G_bath, G_m = G_m)
}

#' Generate exact analytical matrices for a thermal Brownian network.
#'
#' @param model Two-mode thermal model object.
#' @param kappa Driven non-reciprocal circulation rate (default 0.0).
#' @param noise_scale Non-thermal noise inflation factor (default 1.0).
#' @return Named list of analytical network matrices.
#' @export
thermal_network_matrices = function(model, kappa = 0.0, noise_scale = 1.0) {
  T_val = model$T
  C1 = model$C_heat[1]
  C2 = model$C_heat[2]
  G1 = model$G_bath[1]
  G2 = model$G_bath[2]
  Gm = model$G_m

  A_eq = matrix(c(
    -(G1 + Gm) / C1, Gm / C1,
     Gm / C2,        -(G2 + Gm) / C2
  ), 2, 2)
  A = if (kappa == 0.0) A_eq else A_eq + matrix(c(0.0, -kappa, kappa, 0.0), 2, 2)
  L = (T_val^2) * matrix(c(
    G1 + Gm, -Gm,
   -Gm,       G2 + Gm
  ), 2, 2)
  H = diag(1.0 / (model$C_heat * (T_val^2)), nrow = 2, ncol = 2)
  D = (noise_scale * k_B) * L
  C = if (kappa == 0.0 && noise_scale == 1.0) {
    diag(k_B * (T_val^2) * model$C_heat, nrow = 2, ncol = 2)
  } else {
    solve_lyapunov_covariance(A, D)
  }
  decomp = decompose_covariance_weighted_drift(A, C, D = D, scale = k_B)
  list(
    A = A,
    L = L,
    H = H,
    C = C,
    D = D,
    K_cov = decomp$K_cov,
    Omega = decomp$Omega,
    sigma = decomp$sigma
  )
}

replicate_thermal_study = function(model, n_replicates = 200L, dt = 0.02,
                                    n_steps = 50000L, seed = NULL,
                                    kappa = 0.0, noise_scale = 1.0) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  exact = thermal_network_matrices(model, kappa = kappa, noise_scale = noise_scale)
  A_F_vals = numeric(n_replicates)
  sigmas = numeric(n_replicates)
  L_errors = numeric(n_replicates)
  for (r in seq_len(n_replicates)) {
    X = simulate_ou_process(exact$A, exact$D, dt = dt, n_steps = n_steps, C = exact$C)
    est = estimate_ou_onsager(X, dt = dt, scale = k_B)
    A_F_vals[r] = matrix_asymmetry(est$L_x)$A_F
    sigmas[r] = est$sigma
    L_errors[r] = norm(est$L_x - exact$L, "F") / norm(exact$L, "F")
  }
  list(A_F = A_F_vals, sigma = sigmas, L_errors = L_errors)
}

# ==================================================================
# 6. Reversible Two-Pathway Channel & Trait Evolution (Sections 5.2-5.3)
# ==================================================================

#' Equilibrium channel occupancy fraction from free energy difference.
#'
#' @param Delta_G Standard molar free energy difference in J mol^-1.
#' @param T Temperature in Kelvin (default 298.15).
#' @return Equilibrium probability of channel occupancy.
#' @export
equilibrium_occupancy_fraction = function(Delta_G, T = 298.15) {
  1.0 / (1.0 + exp(Delta_G / (R_GAS * T)))
}

#' Exact two-pathway channel conductivity matrix.
#'
#' @param kappa Vector of channel intrinsic rate coefficients.
#' @param c_s Solute concentration scale.
#' @return 2x2 symmetric conductivity matrix.
#' @export
exact_two_pathway_conductivity = function(kappa, c_s) {
  k1 = kappa[1]
  k2 = kappa[2]
  denom = 4.0 * R_GAS * (k1 + k2)
  c_s * matrix(c(
     k1 * k2 / denom, -k1 * k2 / denom,
    -k1 * k2 / denom,  k1 * k2 / denom
  ), nrow = 2, ncol = 2)
}

#' Simulate channel transport current density via Gillespie jump algorithm.
#'
#' @param X Vector of channel thermodynamic driving forces.
#' @param kappa Vector of channel rate constants.
#' @param N_sites Number of physical channel sites.
#' @param c_s Solute concentration scale.
#' @param burn_in Initial equilibration time.
#' @param T_obs Observation time window.
#' @param Delta_G Energy gap between states.
#' @param T Temperature in Kelvin.
#' @param initial_occupied_sites Optional initial occupied site count.
#' @param seed Optional random number generator seed.
#' @return Named list with current vector `J`, `net_events`, and `final_occupied_sites`.
#' @export
simulate_channel_current_density = function(X, kappa, N_sites = 40L, c_s = 0.2,
                                             burn_in = 0.2, T_obs = 2.0,
                                             Delta_G = 0.0, T = 298.15,
                                             initial_occupied_sites = NULL,
                                             seed = NULL) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  r_count = length(kappa)
  gap_term = Delta_G / (2.0 * R_GAS * T)
  k_plus = kappa * exp(X / (2.0 * R_GAS) - gap_term)
  k_minus = kappa * exp(-X / (2.0 * R_GAS) + gap_term)
  total_horizon = burn_in + T_obs
  p_eq = equilibrium_occupancy_fraction(Delta_G, T)
  occupied = if (is.null(initial_occupied_sites)) {
    rbinom(1, N_sites, p_eq)
  } else {
    as.integer(initial_occupied_sites)
  }
  net_events = integer(r_count)
  sum_plus = sum(k_plus)
  sum_minus = sum(k_minus)
  t = 0.0
  while (t < total_horizon) {
    vacant = N_sites - occupied
    fwd_prop = vacant * sum_plus
    rev_prop = occupied * sum_minus
    tot_prop = fwd_prop + rev_prop
    if (tot_prop <= 0) break
    dt_wait = rexp(1, rate = tot_prop)
    if (t + dt_wait > total_horizon) break
    t = t + dt_wait
    u = runif(1, 0, tot_prop)
    if (u < fwd_prop) {
      thresh = u / vacant
      acc = 0.0
      chosen = 0L
      for (ch in 1:r_count) {
        acc = acc + k_plus[ch]
        if (thresh < acc) {
          chosen = ch
          break
        }
      }
      occupied = occupied + 1L
      if (t >= burn_in) {
        net_events[chosen] = net_events[chosen] + 1L
      }
    } else {
      thresh = (u - fwd_prop) / occupied
      acc = 0.0
      chosen = 0L
      for (ch in 1:r_count) {
        acc = acc + k_minus[ch]
        if (thresh < acc) {
          chosen = ch
          break
        }
      }
      occupied = occupied - 1L
      if (t >= burn_in) {
        net_events[chosen] = net_events[chosen] - 1L
      }
    }
  }
  J = c_s * net_events / (N_sites * T_obs)
  list(J = J, net_events = net_events, final_occupied_sites = occupied)
}

#' Estimate two-pathway process conductivity by finite-difference Gillespie currents.
#'
#' @param kappa Channel rate coefficients.
#' @param N_sites Number of physical sites.
#' @param c_s Solute concentration scale.
#' @param n_replicates Replicates per force condition.
#' @param burn_in Burn-in duration.
#' @param T_obs Observation duration.
#' @param Delta_G Energy gap.
#' @param T Temperature.
#' @param delta_X Finite force perturbation.
#' @param seed Optional random number generator seed.
#' @return Named list with estimated matrix `L` and `standard_errors`.
#' @export
estimate_two_pathway_conductivity = function(kappa, N_sites = 40L, c_s = 0.2,
                                              n_replicates = 2L, burn_in = 0.2,
                                              T_obs = 2.0, Delta_G = 0.0,
                                              T = 298.15, delta_X = 0.5,
                                              seed = NULL) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  L_hat = matrix(0.0, 2, 2)
  se_mat = matrix(0.0, 2, 2)
  for (j in 1:2) {
    X_pos = c(0.0, 0.0)
    X_pos[j] = delta_X
    X_neg = c(0.0, 0.0)
    X_neg[j] = -delta_X
    diff_reps = matrix(0.0, nrow = n_replicates, ncol = 2)
    for (r in seq_len(n_replicates)) {
      sim_p = simulate_channel_current_density(
        X_pos, kappa, N_sites = N_sites, c_s = c_s, burn_in = burn_in,
        T_obs = T_obs, Delta_G = Delta_G, T = T
      )
      sim_m = simulate_channel_current_density(
        X_neg, kappa, N_sites = N_sites, c_s = c_s, burn_in = burn_in,
        T_obs = T_obs, Delta_G = Delta_G, T = T
      )
      diff_reps[r, ] = (sim_p$J - sim_m$J) / (2.0 * delta_X)
    }
    L_hat[, j] = colMeans(diff_reps)
    se_mat[, j] = apply(diff_reps, 2, sd) / sqrt(n_replicates)
  }
  list(L = L_hat, standard_errors = se_mat)
}

#' Simulate conductivity evolution under directional selection on trait theta.
#'
#' @param n_epochs Number of evolutionary epochs.
#' @param epoch_duration Duration of each epoch.
#' @param T_obs Observation duration per epoch.
#' @param N_sites Number of sites.
#' @param c_s Solute concentration scale.
#' @param n_replicates Replicates per evaluation.
#' @param burn_in Burn-in duration.
#' @param theta_0 Initial trait value.
#' @param theta_star Target optimum trait value.
#' @param s Selection strength.
#' @param sigma_theta Trait diffusion noise.
#' @param seed Optional random number generator seed.
#' @return Named list with trajectory of traits and estimated conductivities.
#' @export
simulate_evolving_conductivity = function(
    n_epochs = 12L, epoch_duration = 200.0, T_obs = 40.0, N_sites = 600L,
    c_s = 0.2, n_replicates = 3L, burn_in = 2.0, kappa_0 = 2.5,
    T = 298.15, energy_scale = 1.0, theta_0 = -0.8, theta_star = 0.8,
    s = 0.05, sigma_theta = 0.005, delta_X = 1.0, seed = 20261028) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  theta = theta_0
  occupied_sites = NULL

  theta_hist = numeric(n_epochs)
  p_occ_hist = numeric(n_epochs)
  p_occ_eq_hist = numeric(n_epochs)
  kappa_hist = vector("list", n_epochs)
  L_hat_hist = vector("list", n_epochs)
  L_exact_hist = vector("list", n_epochs)
  se_hist = vector("list", n_epochs)

  for (ep in seq_len(n_epochs)) {
    kappa_vec = kappa_0 * exp(c(theta, -theta))
    Delta_G = R_GAS * T * energy_scale * theta
    p_eq = equilibrium_occupancy_fraction(Delta_G, T)
    if (is.null(occupied_sites)) {
      occupied_sites = rbinom(1, N_sites, p_eq)
    }

    baseline = simulate_channel_current_density(
      c(0.0, 0.0), kappa_vec, N_sites = N_sites, c_s = c_s, burn_in = 0.0,
      T_obs = epoch_duration, Delta_G = Delta_G, T = T,
      initial_occupied_sites = occupied_sites
    )
    occupied_sites = baseline$final_occupied_sites

    ep_seed = if (!is.null(seed)) seed + 1000L * ep else NULL
    est = estimate_two_pathway_conductivity(
      kappa_vec, N_sites = N_sites, c_s = c_s, n_replicates = n_replicates,
      burn_in = burn_in, T_obs = T_obs, Delta_G = Delta_G, T = T,
      delta_X = delta_X, seed = ep_seed
    )

    theta_hist[ep] = theta
    p_occ_hist[ep] = occupied_sites / N_sites
    p_occ_eq_hist[ep] = p_eq
    kappa_hist[[ep]] = kappa_vec
    L_hat_hist[[ep]] = est$L
    se_hist[[ep]] = est$standard_errors
    L_exact_hist[[ep]] = exact_two_pathway_conductivity(kappa_vec, c_s)

    theta = theta + s * (theta_star - theta) + sigma_theta * rnorm(1)
  }

  list(
    epoch = seq_len(n_epochs),
    elapsed_time = (seq_len(n_epochs) - 1L) * epoch_duration,
    theta = theta_hist,
    p_occ = p_occ_hist,
    p_occ_eq = p_occ_eq_hist,
    kappa = kappa_hist,
    L_hat = L_hat_hist,
    L_exact = L_exact_hist,
    standard_errors = se_hist,
    epoch_duration = epoch_duration,
    T_obs = T_obs
  )
}
# ==================================================================
# 7. Allometric Scaling & Demographic Transformations (Section 5.4)
# ==================================================================

#' Normalize raw population biomass vector to unit simplex.
#'
#' @param B Positive biomass vector.
#' @return Named list with normalized fraction vector `b` and scalar `B_tot`.
#' @export
normalize_biomass = function(B) {
  if (any(!is.finite(B)) || any(B < 0) || all(B == 0)) {
    stop("B must contain nonnegative entries with positive total sum")
  }
  B_tot = sum(B)
  list(b = B / B_tot, B_tot = B_tot)
}

#' Weight community interaction matrix by allometric mass scaling and biomass.
#'
#' @param N Abundance vector.
#' @param M Body mass vector.
#' @param A Demographic interaction matrix.
#' @param k Allometric metabolic mass exponent (default 0.25).
#' @return Named list with normalized biomass `b`, weighted matrices `W` and `W_B`, and asymmetry `A_F`.
#' @export
weighted_interaction_matrix = function(N, M, A, k = 0.25) {
  if (!is.matrix(A) || nrow(A) != ncol(A)) {
    stop("A must be a square matrix")
  }
  n = length(N)
  if (length(M) != n || nrow(A) != n) {
    stop("N, M, and A dimensions must match")
  }
  B = N * M
  norm_b = normalize_biomass(B)
  b = norm_b$b
  M_diag = diag(M^(-k), nrow = n, ncol = n)
  b_diag = diag(b, nrow = n, ncol = n)
  W = M_diag %*% A %*% b_diag
  W_B = A %*% b_diag
  list(
    b = b,
    B_tot = norm_b$B_tot,
    W = W,
    W_B = W_B,
    A_F = matrix_asymmetry(W)$A_F
  )
}

#' Evaluate sensitivity of weighted interaction asymmetry across allometric exponents.
#'
#' @param N Abundance vector.
#' @param M Mass vector.
#' @param A Demographic matrix.
#' @param exponents Vector of allometric exponents.
#' @return Named list mapping exponent to Frobenius asymmetry.
#' @export
sensitivity_allometry = function(N, M, A, exponents = c(0.20, 0.30)) {
  res = list()
  for (exp_val in exponents) {
    w = weighted_interaction_matrix(N, M, A, k = exp_val)
    res[[as.character(exp_val)]] = w$A_F
  }
  res
}

#' Mass-scaled multi-species population biomass growth rate function.
#'
#' @param B Biomass vector.
#' @param params Parameter list with `M`, `A`, `K`, and `k`.
#' @return Biomass rate vector \eqn{d\mathbf{B}/dt}.
#' @export
biomass_rate = function(B, params) {
  M = params$M
  A = params$A
  K = params$K
  k = params$k
  growth = M^(-k) * (1.0 - B / K)
  growth * B + B * as.vector(A %*% B)
}

#' Diagnostic Jacobian and allometric scaling from general biomass rate function.
#'
#' Evaluates the demographic Jacobian by central finite differences and applies
#' allometric biomass weighting.
#'
#' @param B Equilibrium biomass vector.
#' @param rate_fn Rate function taking `(B, params)`.
#' @param params Parameter list.
#' @return Named list with evaluated `A`, `W_B`, and `b`.
#' @export
biomass_jacobian_diagnostic = function(B, rate_fn, params) {
  n = length(B)
  h = 1e-7
  A = matrix(0.0, n, n)
  f0 = rate_fn(B, params)
  for (j in 1:n) {
    B_p = B
    B_p[j] = B_p[j] + h
    B_m = B
    B_m[j] = B_m[j] - h
    A[, j] = (rate_fn(B_p, params) - rate_fn(B_m, params)) / (2.0 * h)
  }
  norm_b = normalize_biomass(B)
  b = norm_b$b
  W_B = A %*% diag(b, nrow = n, ncol = n)
  list(A = A, W_B = W_B, b = b, B_tot = norm_b$B_tot)
}

# ==================================================================
# 8. Cone Spring Ecosystem (Section 6, Tilly 1968)
# ==================================================================

#' Assemble the 5-compartment Cone Spring ecosystem budget and living subnetwork.
#'
#' @param s Intraspecific self-damping fraction relative to respiratory turnover (default 0.10).
#' @return Named list of budgetary fluxes, living subnetwork matrices `A` and `D`.
#' @export
cone_spring_network = function(s = 0.10) {
  if (!is.finite(s) || s <= 0) {
    stop("self-damping fraction s must be finite and positive")
  }
  full_budget = list(
    names = c("Plants", "Detritus", "Bacteria", "Detritivores", "Carnivores"),
    B_star = c(285.0, 3580.0, 116.6, 60.0, 17.0),
    z = c(11184.0, 635.0, 0.0, 0.0, 0.0),
    inflow_internal = c(0.0, 10848.0, 5205.0, 2384.0, 370.0),
    outflow_internal = c(8881.0, 7514.0, 1675.0, 570.0, 167.0),
    E = c(300.0, 860.0, 255.0, 0.0, 0.0),
    R = c(2003.0, 3109.0, 3275.0, 1814.0, 203.0),
    T_flow = c(11184.0, 11483.0, 5205.0, 2384.0, 370.0)
  )
  B_star = c(116.6, 60.0, 17.0)
  R = c(3275.0, 1814.0, 203.0)
  T_flow = c(5205.0, 2384.0, 370.0)
  e = (T_flow - R) / T_flow
  F_mat = matrix(0.0, 3, 3)
  F_mat[1, 2] = 75.0
  F_mat[2, 3] = 370.0
  M = c(1.0e-6, 1.0e-2, 1.0)
  N = B_star / M
  norm_b = normalize_biomass(B_star)
  A = matrix(0.0, 3, 3)
  for (i in 1:3) {
    A[i, i] = -s * R[i] / B_star[i]
  }
  A[1, 2] = -F_mat[1, 2] / B_star[2]
  A[2, 1] = e[2] * F_mat[1, 2] / B_star[1]
  A[2, 3] = -F_mat[2, 3] / B_star[3]
  A[3, 2] = e[3] * F_mat[2, 3] / B_star[2]
  D = diag(s * R * B_star, nrow = 3, ncol = 3)
  list(
    full_budget = full_budget,
    B_star = B_star,
    R = R,
    T_flow = T_flow,
    e = e,
    F = F_mat,
    M = M,
    N = N,
    b = norm_b$b,
    B_tot = norm_b$B_tot,
    s = s,
    A = A,
    D = D
  )
}

#' Perform analytical and stochastic Lyapunov decomposition of the Cone Spring network.
#'
#' @param s Intraspecific self-damping fraction.
#' @param dt Simulation time step.
#' @param n_obs Trajectory observations.
#' @param k Allometric exponent.
#' @param seed Optional random number generator seed.
#' @return Named list of analytical spectra, Lyapunov solutions, and trajectory estimates.
#' @export
analyze_cone_spring = function(s = 0.10, dt = 0.01, n_obs = 20000L,
                               k = DEFAULT_ALLOMETRIC_K, seed = 20261026) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  net = cone_spring_network(s = s)
  A = net$A
  D = net$D
  B_star = net$B_star
  eigs_A = eigen(A, only.values = TRUE)$values
  L_naive = -A %*% diag(B_star, nrow = 3, ncol = 3)
  L_sym = 0.5 * (L_naive + t(L_naive))
  L_sym_eigs = eigen(L_sym, symmetric = TRUE, only.values = TRUE)$values
  W_B = A %*% diag(net$b, nrow = 3, ncol = 3)
  W_B_sym = -0.5 * (W_B + t(W_B))
  min_eig_WB = min(eigen(W_B_sym, symmetric = TRUE, only.values = TRUE)$values)
  C = solve_lyapunov_covariance(A, D)
  decomp = decompose_covariance_weighted_drift(A, C, D = D, scale = 1.0)
  X_data = simulate_ou_process(A, D, dt = dt, n_steps = n_obs, C = C)
  est = estimate_ou_onsager(X_data, dt = dt, scale = 1.0)
  rel_err = norm(est$K_cov - decomp$K_cov, "F") / norm(decomp$K_cov, "F")
  w_diag = weighted_interaction_matrix(net$N, net$M, A, k = k)
  allom_sens = sensitivity_allometry(net$N, net$M, A)
  list(
    network = net,
    eigenvalues_A = eigs_A,
    A_F_A = matrix_asymmetry(A)$A_F,
    L_naive = L_naive,
    A_F_naive = matrix_asymmetry(L_naive)$A_F,
    L_naive_sym_eigs = L_sym_eigs,
    W = w_diag$W,
    W_B = w_diag$W_B,
    A_F_W = w_diag$A_F,
    A_F_WB = matrix_asymmetry(w_diag$W_B)$A_F,
    min_eig_neg_sym_WB = min_eig_WB,
    allometric_sensitivity = allom_sens,
    C = C,
    D = D,
    K_cov = decomp$K_cov,
    Omega = decomp$Omega,
    A_F_K_cov = decomp$A_F,
    min_sym_eig_K_cov = decomp$min_sym_eig,
    circulation_rate = decomp$circulation_rate,
    sigma = decomp$sigma,
    rel_error_K_cov = rel_err,
    estimate = est
  )
}

# ==================================================================
# 9. Demographic Jump Process & Stochastic Simulation
# ==================================================================

#' Construct parameters for a stochastic demographic population jump process.
#'
#' @param r Intrinsic per-capita birth rates.
#' @param d Baseline per-capita death rates.
#' @param c Intraspecific quadratic competition rates.
#' @param gamma Inter-species predation encounter rate matrix.
#' @param M Individual body mass vector.
#' @param V System habitat volume.
#' @param epsilon Trophic mass conversion efficiency.
#' @param k Allometric mass scaling exponent.
#' @return Parameter list.
#' @export
population_jump_params = function(r, d, c, gamma, M, V = 100.0,
                                  epsilon = 0.2, k = DEFAULT_ALLOMETRIC_K) {
  n = length(r)
  list(
    n_species = n,
    r = as.numeric(r),
    d = as.numeric(d),
    c = as.numeric(c),
    gamma = matrix(as.numeric(gamma), n, n),
    M = as.numeric(M),
    V = as.numeric(V),
    epsilon = as.numeric(epsilon),
    k = as.numeric(k)
  )
}

#' Compute total population biomass density per unit habitat volume.
#'
#' @param N Vector of species abundances.
#' @param params Population jump parameters.
#' @return Numeric vector of biomass densities.
#' @export
biomass_density = function(N, params) {
  (N * params$M) / params$V
}

#' Calculate event propensities and integer stoichiometric state change vectors.
#'
#' @param N Abundance vector.
#' @param params Population jump parameters.
#' @return Named list with `propensities` and `stoichiometry`.
#' @export
demographic_propensities = function(N, params) {
  n = params$n_species
  props = numeric(0)
  stoich = list()
  for (i in 1:n) {
    props = c(props, params$r[i] * (params$M[i]^(-params$k)) * N[i])
    delta = integer(n)
    delta[i] = 1L
    stoich[[length(stoich) + 1]] = delta
  }
  for (i in 1:n) {
    if (N[i] > 0) {
      ni = as.numeric(N[i])
      prop = params$d[i] * ni + (params$c[i] / params$V) * ni * (ni - 1.0)
      props = c(props, prop)
      delta = integer(n)
      delta[i] = -1L
      stoich[[length(stoich) + 1]] = delta
    }
  }
  for (i in 1:n) {
    for (j in 1:n) {
      g_ij = params$gamma[i, j]
      if (i != j && g_ij > 0 && N[i] > 0 && N[j] > 0) {
        prey_needed = max(1L, as.integer(ceiling(params$M[i] / (params$epsilon * params$M[j]))))
        if (N[j] >= prey_needed) {
          prop = (g_ij / params$V) * (params$M[i]^(-params$k)) * as.numeric(N[i]) * as.numeric(N[j])
          props = c(props, prop)
          delta = integer(n)
          delta[i] = 1L
          delta[j] = -prey_needed
          stoich[[length(stoich) + 1]] = delta
        }
      }
    }
  }
  list(propensities = props, stoichiometry = stoich)
}

#' Run exact stochastic Gillespie simulation of demographic population jumps.
#'
#' @param N_0 Initial integer abundance vector.
#' @param params Population jump parameters.
#' @param t_end Maximum simulation time.
#' @param max_events Maximum allowed event count (default 1000000).
#' @param seed Optional random number generator seed.
#' @return Named list with `time`, `N_history`, `biomass_density`, `event_count`, and `stop_reason`.
#' @export
run_gillespie_population = function(N_0, params, t_end, max_events = 1000000L, seed = NULL) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  t = 0.0
  N = as.integer(N_0)
  t_hist = c(t)
  N_hist = list(N)
  dens_hist = list(biomass_density(N, params))
  ev_count = 0L
  reason = "end_time"
  while (t < t_end) {
    if (ev_count >= max_events) {
      reason = "max_events"
      break
    }
    dp = demographic_propensities(N, params)
    props = dp$propensities
    stoich = dp$stoichiometry
    tot_prop = sum(props)
    if (tot_prop <= 0) {
      reason = "no_active_events"
      break
    }
    dt_wait = rexp(1, rate = tot_prop)
    if (t + dt_wait > t_end) break
    thresh = runif(1, 0, tot_prop)
    acc = 0.0
    chosen = 0L
    for (idx in seq_along(props)) {
      acc = acc + props[idx]
      if (thresh < acc) {
        chosen = idx
        break
      }
    }
    t = t + dt_wait
    N = N + stoich[[chosen]]
    ev_count = ev_count + 1L
    t_hist = c(t_hist, t)
    N_hist[[length(N_hist) + 1]] = N
    dens_hist[[length(dens_hist) + 1]] = biomass_density(N, params)
  }
  list(
    time = t_hist,
    N_history = N_hist,
    biomass_density = dens_hist,
    event_count = ev_count,
    stop_reason = reason
  )
}

# ==================================================================
# 10. Metabolic Size Spectra Models
# ==================================================================

#' Construct parameters for metabolic size spectrum analysis.
#'
#' @param m_min Minimum body mass.
#' @param m_max Maximum body mass.
#' @param abundance_scale Reference abundance normalization.
#' @param abundance_exponent Sheldon scaling exponent lambda.
#' @param metabolic_scale Allometric metabolic normalization.
#' @param metabolic_exponent Kleiber scaling exponent alpha.
#' @param temperature Ambient temperature in Kelvin.
#' @param reference_mass Reference mass unit.
#' @return Parameter list.
#' @export
size_spectrum_params = function(m_min = 1e-12, m_max = 1e1,
                                abundance_scale = 1e3,
                                abundance_exponent = 0.95,
                                metabolic_scale = 0.25,
                                metabolic_exponent = 0.75,
                                temperature = 298.15,
                                reference_mass = 1.0) {
  if (m_min <= 0 || m_max <= m_min) {
    stop("m_min must be positive and m_max must strictly exceed m_min")
  }
  list(
    m_min = m_min,
    m_max = m_max,
    abundance_scale = abundance_scale,
    abundance_exponent = abundance_exponent,
    metabolic_scale = metabolic_scale,
    metabolic_exponent = metabolic_exponent,
    temperature = temperature,
    reference_mass = reference_mass
  )
}

#' Compute macroecological indices and total dissipation across the size spectrum.
#'
#' @param params Size spectrum parameters.
#' @param n_bins Quadrature integration bins (default 1000).
#' @return Named list with integrated biomass, metabolic power, and scaling exponents.
#' @export
compute_size_spectrum_indices = function(params, n_bins = 1000L) {
  if (n_bins < 2) {
    stop("n_bins must be at least 2")
  }
  log_m = seq(log(params$m_min), log(params$m_max), length.out = n_bins)
  m_vals = exp(log_m)
  abundance = params$abundance_scale * (m_vals / params$reference_mass)^(-params$abundance_exponent)
  biomass_dens = abundance * m_vals
  ind_power = params$metabolic_scale * (m_vals / params$reference_mass)^(params$metabolic_exponent)
  power_dens = abundance * ind_power
  
  biomass_per_log_mass = biomass_dens * m_vals
  power_per_log_mass = power_dens * m_vals
  
  d_log_m = diff(log_m)
  biomass_total = sum(d_log_m * (biomass_per_log_mass[-length(biomass_per_log_mass)] + biomass_per_log_mass[-1]) * 0.5)
  power_total = sum(d_log_m * (power_per_log_mass[-length(power_per_log_mass)] + power_per_log_mass[-1]) * 0.5)
  
  beta = params$abundance_exponent - params$metabolic_exponent
  
  list(
    mass = m_vals,
    abundance_density = abundance,
    biomass_density = biomass_dens,
    individual_power = ind_power,
    power_density = power_dens,
    biomass_total = biomass_total,
    power_total = power_total,
    entropy_production_proxy = power_total / params$temperature,
    specific_power_proxy = power_total / biomass_total,
    beta = beta
  )
}

simulate_size_spectrum_filtering = function(params, n_scales = 4L, duration = 1.0,
                                             dt = 0.1, frequencies = c(0.0),
                                             amplitudes = c(1.0), reference_time = 0.5) {
  times = seq(0.0, duration, by = dt)
  n_times = length(times)
  masses = exp(seq(log(params$m_min), log(params$m_max), length.out = n_scales))
  relaxation_rates = params$metabolic_scale * (masses / params$reference_mass)^(-0.25)
  response = matrix(0.0, nrow = n_times, ncol = n_scales)
  for (s in 1:n_scales) {
    gamma_s = relaxation_rates[s]
    for (f_idx in seq_along(frequencies)) {
      omega = frequencies[f_idx]
      amp = amplitudes[f_idx]
      for (t_idx in 1:n_times) {
        t_val = times[t_idx]
        tau = t_val - reference_time
        if (tau >= 0) {
          decay = exp(-gamma_s * tau)
          response[t_idx, s] = response[t_idx, s] + amp * (decay - 1.0) * (omega == 0.0)
        }
      }
    }
  }
  list(response_time = times, response = response, masses = masses, rates = relaxation_rates)
}

#' Simulate dynamic biomass anomaly wave propagation across the size spectrum.
#'
#' @param params Size spectrum parameters.
#' @param n_bins Discrete mass bins.
#' @param duration Total wave propagation duration.
#' @param dt Time step.
#' @param transport_rate Inter-size trophic transfer velocity.
#' @param snapshot_times Vector of evaluation snapshot times.
#' @return Named list with anomaly matrix and effective potential profile.
#' @export
simulate_size_spectrum_wave = function(params, n_bins = 20L, duration = 1.0,
                                        dt = 0.05, transport_rate = 0.15,
                                        snapshot_times = c(0.0, 0.5, 1.0)) {
  for (st in snapshot_times) {
    if (st < 0 || st > duration) {
      stop("snapshot times must lie within [0, duration]")
    }
  }
  log_m = seq(log(params$m_min), log(params$m_max), length.out = n_bins)
  dx = (log(params$m_max) - log(params$m_min)) / (n_bins - 1)
  time_steps = as.integer(round(duration / dt))
  
  u = exp(-((log_m - mean(log_m)) / 0.5)^2)
  anomaly = matrix(0.0, nrow = n_bins, ncol = length(snapshot_times))
  if (0.0 %in% snapshot_times) {
    anomaly[, which(snapshot_times == 0.0)] = u
  }
  
  for (step in 1:time_steps) {
    t = step * dt
    u_new = u
    for (i in 2:n_bins) {
      u_new[i] = u[i] - (transport_rate * dt / dx) * (u[i] - u[i - 1])
    }
    u = u_new
    for (s in seq_along(snapshot_times)) {
      if (abs(t - snapshot_times[s]) < 0.5 * dt) {
        anomaly[, s] = u
      }
    }
  }
  potential = seq(1.0, 0.1, length.out = n_bins + 1L)
  list(relative_anomaly = anomaly, potential = potential)
}

# ==================================================================
# 11. Pelagic Plankton and Fish Ecosystems (NPZD & NPZD-Fish)
# ==================================================================

#' Parameters for a four-pool nutrient-phytoplankton-zooplankton-detritus (NPZD) model.
#'
#' @export
npzd_params = function(v_max = 1.20, k_s = 0.70, m_p = 0.09,
                        a_z = 2.00, eps_z = 1.00, gamma_z = 0.75,
                        c_z = 0.20, mu_p = 0.20, mu_z = 0.20,
                        mu_d = 0.05, w_s = 0.02,
                        nutrient_reference = 0.10,
                        days_per_year = 365.25,
                        noise_fraction = 0.10) {
  if (nutrient_reference <= 0) {
    stop("nutrient_reference must be strictly positive")
  }
  list(
    v_max = v_max, k_s = k_s, m_p = m_p,
    a_z = a_z, eps_z = eps_z, gamma_z = gamma_z,
    c_z = c_z, mu_p = mu_p, mu_z = mu_z,
    mu_d = mu_d, w_s = w_s,
    nutrient_reference = nutrient_reference,
    days_per_year = days_per_year,
    noise_fraction = noise_fraction
  )
}

#' Calibrate reference steady-state concentrations for four-pool NPZD model.
#'
#' @param params NPZD parameter list.
#' @return Named list with `state` vector and `nutrient_input`.
#' @export
npzd_reference_state = function(params) {
  n_star = params$nutrient_reference
  uptake_per_p = params$v_max * n_star / (params$k_s + n_star)
  net_p_rate = uptake_per_p - params$m_p
  if (net_p_rate <= 0) {
    stop("nutrient uptake must exceed phytoplankton loss at reference N")
  }
  zooplankton_at_p = function(p) {
    sqrt(params$gamma_z * net_p_rate * p / params$c_z)
  }
  grazing_ratio = function(p) {
    params$a_z * zooplankton_at_p(p) * params$eps_z * p / (1.0 + params$eps_z * (p^2))
  }
  peak_p = sqrt(3.0 / params$eps_z)
  if (grazing_ratio(peak_p) <= net_p_rate) {
    stop("parameters do not admit a positive NPZD equilibrium")
  }
  low = .Machine$double.eps
  high = peak_p
  for (iter in 1:100) {
    mid = (low + high) / 2.0
    if (grazing_ratio(mid) < net_p_rate) {
      low = mid
    } else {
      high = mid
    }
  }
  p_star = (low + high) / 2.0
  z_star = zooplankton_at_p(p_star)
  grazing = net_p_rate * p_star
  mortality_z = params$c_z * (z_star^2)
  d_star = ((1.0 - params$mu_p) * params$m_p * p_star +
             (1.0 - params$mu_z) * mortality_z) / (params$mu_d + params$w_s)
  uptake = params$v_max * p_star * n_star / (params$k_s + n_star)
  nutrient_input = uptake - (params$mu_p * params$m_p * p_star +
                              params$mu_z * mortality_z +
                              (1.0 - params$gamma_z) * grazing + params$mu_d * d_star)
  if (nutrient_input <= 0) {
    stop("parameters imply a nonpositive external nutrient input")
  }
  list(state = c(n_star, p_star, z_star, d_star), nutrient_input = nutrient_input)
}

.npzd_daily_rhs = function(state, params, nutrient_input) {
  n = state[1]
  p = state[2]
  z = state[3]
  d = state[4]
  uptake = params$v_max * p * n / (params$k_s + n)
  grazing = params$a_z * z * params$eps_z * (p^2) / (1.0 + params$eps_z * (p^2))
  mortality_z = params$c_z * (z^2)
  dn = nutrient_input - uptake + params$mu_p * params$m_p * p +
        params$mu_z * mortality_z + (1.0 - params$gamma_z) * grazing + params$mu_d * d
  dp = uptake - grazing - params$m_p * p
  dz = params$gamma_z * grazing - mortality_z
  dd = (1.0 - params$mu_p) * params$m_p * p + (1.0 - params$mu_z) * mortality_z -
        (params$mu_d + params$w_s) * d
  c(dn, dp, dz, dd)
}

#' Evaluate daily rate of change vector for the NPZD model.
#'
#' @param state Current state vector c(N, P, Z, D).
#' @param params NPZD parameters.
#' @return Rate of change vector.
#' @export
npzd_rhs = function(state, params) {
  if (length(state) != 4) {
    stop("state vector must have length 4")
  }
  ref = npzd_reference_state(params)
  .npzd_daily_rhs(state, params, ref$nutrient_input)
}

#' Compute analytical Jacobian of the daily NPZD system.
#'
#' @param state State vector c(N, P, Z, D).
#' @param params NPZD parameter list.
#' @param nutrient_input External nutrient influx.
#' @return 4x4 Jacobian matrix.
#' @export
npzd_jacobian = function(state, params, nutrient_input) {
  n = state[1]
  p = state[2]
  z = state[3]
  d = state[4]
  
  denom_u = params$k_s + n
  u_n = params$v_max * p * params$k_s / (denom_u^2)
  u_p = params$v_max * n / denom_u
  
  denom_g = 1.0 + params$eps_z * (p^2)
  g_p = params$a_z * z * (2.0 * params$eps_z * p) / (denom_g^2)
  g_z = params$a_z * params$eps_z * (p^2) / denom_g
  
  mz_z = 2.0 * params$c_z * z
  
  J = matrix(0.0, 4, 4)
  J[1, 1] = -u_n
  J[1, 2] = -u_p + params$mu_p * params$m_p + (1.0 - params$gamma_z) * g_p
  J[1, 3] = params$mu_z * mz_z + (1.0 - params$gamma_z) * g_z
  J[1, 4] = params$mu_d
  
  J[2, 1] = u_n
  J[2, 2] = u_p - g_p - params$m_p
  J[2, 3] = -g_z
  J[2, 4] = 0.0
  
  J[3, 1] = 0.0
  J[3, 2] = params$gamma_z * g_p
  J[3, 3] = params$gamma_z * g_z - mz_z
  J[3, 4] = 0.0
  
  J[4, 1] = 0.0
  J[4, 2] = (1.0 - params$mu_p) * params$m_p
  J[4, 3] = (1.0 - params$mu_z) * mz_z
  J[4, 4] = -(params$mu_d + params$w_s)
  
  J
}

#' Complete non-equilibrium thermodynamic and stability diagnostics of the NPZD ecosystem.
#'
#' @param params NPZD parameters.
#' @return Named list with linearized `A`, `D`, `C`, and Tomita-Tomita decomposition.
#' @export
npzd_diagnostics = function(params) {
  ref = npzd_reference_state(params)
  state = ref$state
  A_daily = npzd_jacobian(state, params, ref$nutrient_input)
  A = params$days_per_year * A_daily
  eigs = eigen(A, only.values = TRUE)$values
  if (any(Re(eigs) >= 0)) {
    stop("NPZD reference Jacobian is not Hurwitz stable")
  }
  n = state[1]
  p = state[2]
  z = state[3]
  d = state[4]
  uptake = params$v_max * p * n / (params$k_s + n)
  grazing = params$a_z * z * params$eps_z * (p^2) / (1.0 + params$eps_z * (p^2))
  mortality_z = params$c_z * (z^2)
  turnover_daily = c(
    (ref$nutrient_input + uptake) / n,
    (uptake + grazing) / p,
    (params$gamma_z * grazing + mortality_z) / z,
    params$mu_d + params$w_s
  )
  diff_diag = params$noise_fraction * (state^2) * turnover_daily * params$days_per_year
  D = diag(diff_diag, nrow = 4, ncol = 4)
  C = solve_lyapunov_covariance(A, D)
  decomp = decompose_covariance_weighted_drift(A, C, D = D, scale = 1.0)
  list(
    reference_state = state,
    nutrient_input = ref$nutrient_input,
    A = A,
    D = D,
    C = C,
    decomposition = decomp,
    eigenvalues = eigs,
    lyapunov_residual = decomp$lyapunov_residual
  )
}

#' Parameters for a five-pool nutrient-phytoplankton-zooplankton-detritus-fish model.
#'
#' @export
npzd_fish_params = function(v_max = 1.20, k_s = 0.70, m_p = 0.09,
                             a_z = 2.00, eps_z = 1.00, gamma_z = 0.75,
                             c_z = 0.20, a_f = 0.50, eps_f = 2.00,
                             gamma_f = 0.70, m_f = 0.02,
                             harvest_mortality = 0.0604,
                             mu_p = 0.20, mu_z = 0.20, mu_f = 0.10,
                             mu_d = 0.05, w_s = 0.02,
                             nutrient_reference = 0.10,
                             days_per_year = 365.25,
                             noise_fraction = 0.10) {
  list(
    v_max = v_max, k_s = k_s, m_p = m_p,
    a_z = a_z, eps_z = eps_z, gamma_z = gamma_z,
    c_z = c_z, a_f = a_f, eps_f = eps_f,
    gamma_f = gamma_f, m_f = m_f,
    harvest_mortality = harvest_mortality,
    mu_p = mu_p, mu_z = mu_z, mu_f = mu_f,
    mu_d = mu_d, w_s = w_s,
    nutrient_reference = nutrient_reference,
    days_per_year = days_per_year,
    noise_fraction = noise_fraction
  )
}

#' Calibrate reference steady-state concentrations for five-pool NPZD-fish model.
#'
#' @param params NPZD-fish parameter list.
#' @return Named list with `state` vector and `nutrient_input`.
#' @export
npzd_fish_reference_state = function(params) {
  n_star = params$nutrient_reference
  uptake_per_p = params$v_max * n_star / (params$k_s + n_star)
  p_net_rate = uptake_per_p - params$m_p
  if (p_net_rate <= 0) {
    stop("nutrient uptake must exceed phytoplankton loss at reference nutrient level")
  }
  fish_eq_ratio = (params$m_f + params$harvest_mortality) /
                   (params$gamma_f * params$a_f * params$eps_f)
  if (fish_eq_ratio * params$eps_f >= 1.0) {
    stop("fish mortality is too high for a positive interior fish equilibrium")
  }
  z_star = fish_eq_ratio / (1.0 - fish_eq_ratio * params$eps_f)
  
  quad_a = p_net_rate * params$eps_z
  quad_b = params$a_z * z_star * params$eps_z
  discrim = (quad_b^2) - 4.0 * quad_a * p_net_rate
  if (discrim < 0) {
    stop("parameters do not admit a positive phytoplankton equilibrium")
  }
  p_star = 2.0 * p_net_rate / (quad_b + sqrt(discrim))
  
  grazing_z = params$a_z * z_star * params$eps_z * (p_star^2) /
               (1.0 + params$eps_z * (p_star^2))
  grazing_f_needed = params$gamma_z * grazing_z - params$c_z * (z_star^2)
  if (grazing_f_needed <= 0) {
    stop("parameters do not admit positive fish-supported zooplankton balance")
  }
  fish_grazing_per_fish = params$a_f * params$eps_f * z_star /
                           (1.0 + params$eps_f * z_star)
  f_star = grazing_f_needed / fish_grazing_per_fish
  
  z_mortality = params$c_z * (z_star^2)
  f_mortality = params$m_f * f_star
  d_production = (1.0 - params$mu_p) * params$m_p * p_star +
                  (1.0 - params$mu_z) * z_mortality +
                  (1.0 - params$mu_f) * f_mortality
  d_star = d_production / (params$mu_d + params$w_s)
  
  uptake = params$v_max * p_star * n_star / (params$k_s + n_star)
  fish_grazing = params$a_f * f_star * params$eps_f * z_star /
                 (1.0 + params$eps_f * z_star)
  nutrient_recycling = params$mu_p * params$m_p * p_star +
                        (1.0 - params$gamma_z) * grazing_z +
                        params$mu_z * z_mortality +
                        params$mu_d * d_star + params$mu_f * f_mortality +
                        (1.0 - params$gamma_f) * fish_grazing
  nutrient_input = uptake - nutrient_recycling
  if (nutrient_input <= 0) {
    stop("parameters imply a nonpositive external nutrient input")
  }
  list(state = c(n_star, p_star, z_star, d_star, f_star), nutrient_input = nutrient_input)
}

.npzd_fish_daily_rhs = function(state, params, nutrient_input, harvest_multiplier = 1.0) {
  n = state[1]
  p = state[2]
  z = state[3]
  d = state[4]
  fish = state[5]
  uptake = params$v_max * p * n / (params$k_s + n)
  grazing_z = params$a_z * z * params$eps_z * (p^2) / (1.0 + params$eps_z * (p^2))
  grazing_f = params$a_f * fish * params$eps_f * z / (1.0 + params$eps_f * z)
  mortality_z = params$c_z * (z^2)
  mortality_f = params$m_f * fish
  harvest = params$harvest_mortality * harvest_multiplier * fish
  
  dn = nutrient_input - uptake + params$mu_p * params$m_p * p +
        (1.0 - params$gamma_z) * grazing_z + params$mu_z * mortality_z +
        params$mu_d * d + params$mu_f * mortality_f + (1.0 - params$gamma_f) * grazing_f
  dp = uptake - grazing_z - params$m_p * p
  dz = params$gamma_z * grazing_z - mortality_z - grazing_f
  dd = (1.0 - params$mu_p) * params$m_p * p + (1.0 - params$mu_z) * mortality_z -
        (params$mu_d + params$w_s) * d + (1.0 - params$mu_f) * mortality_f
  dfish = params$gamma_f * grazing_f - mortality_f - harvest
  c(dn, dp, dz, dd, dfish)
}

#' Evaluate daily rate of change vector for the NPZD-fish model.
#'
#' @param state Current state vector c(N, P, Z, D, F).
#' @param params NPZD-fish parameters.
#' @param harvest_multiplier Harvest mortality scaling factor (default 1.0).
#' @return Rate of change vector.
#' @export
npzd_fish_rhs = function(state, params, harvest_multiplier = 1.0) {
  if (length(state) != 5) {
    stop("state vector must have length 5")
  }
  ref = npzd_fish_reference_state(params)
  .npzd_fish_daily_rhs(state, params, ref$nutrient_input, harvest_multiplier)
}

#' Compute analytical Jacobian of the daily NPZD-fish system.
#'
#' @param state State vector c(N, P, Z, D, F).
#' @param params NPZD-fish parameter list.
#' @param nutrient_input External nutrient influx.
#' @param harvest_multiplier Harvest scaling factor.
#' @return 5x5 Jacobian matrix.
#' @export
npzd_fish_jacobian = function(state, params, nutrient_input, harvest_multiplier = 1.0) {
  n = state[1]
  p = state[2]
  z = state[3]
  d = state[4]
  fish = state[5]
  
  denom_u = params$k_s + n
  u_n = params$v_max * p * params$k_s / (denom_u^2)
  u_p = params$v_max * n / denom_u
  
  denom_gz = 1.0 + params$eps_z * (p^2)
  gz_p = params$a_z * z * (2.0 * params$eps_z * p) / (denom_gz^2)
  gz_z = params$a_z * params$eps_z * (p^2) / denom_gz
  
  denom_gf = 1.0 + params$eps_f * z
  gf_z = params$a_f * fish * params$eps_f / (denom_gf^2)
  gf_f = params$a_f * params$eps_f * z / denom_gf
  
  mz_z = 2.0 * params$c_z * z
  mf_f = params$m_f
  h_f = params$harvest_mortality * harvest_multiplier
  
  J = matrix(0.0, 5, 5)
  J[1, 1] = -u_n
  J[1, 2] = -u_p + params$mu_p * params$m_p + (1.0 - params$gamma_z) * gz_p
  J[1, 3] = (1.0 - params$gamma_z) * gz_z + params$mu_z * mz_z + (1.0 - params$gamma_f) * gf_z
  J[1, 4] = params$mu_d
  J[1, 5] = params$mu_f * mf_f + (1.0 - params$gamma_f) * gf_f
  
  J[2, 1] = u_n
  J[2, 2] = u_p - gz_p - params$m_p
  J[2, 3] = -gz_z
  J[2, 4] = 0.0
  J[2, 5] = 0.0
  
  J[3, 1] = 0.0
  J[3, 2] = params$gamma_z * gz_p
  J[3, 3] = params$gamma_z * gz_z - mz_z - gf_z
  J[3, 4] = 0.0
  J[3, 5] = -gf_f
  
  J[4, 1] = 0.0
  J[4, 2] = (1.0 - params$mu_p) * params$m_p
  J[4, 3] = (1.0 - params$mu_z) * mz_z
  J[4, 4] = -(params$mu_d + params$w_s)
  J[4, 5] = (1.0 - params$mu_f) * mf_f
  
  J[5, 1] = 0.0
  J[5, 2] = 0.0
  J[5, 3] = params$gamma_f * gf_z
  J[5, 4] = 0.0
  J[5, 5] = params$gamma_f * gf_f - mf_f - h_f
  
  J
}

#' Complete non-equilibrium thermodynamic and stability diagnostics of the NPZD-fish ecosystem.
#'
#' @param params NPZD-fish parameters.
#' @return Named list with linearized `A`, `D`, `C`, and Tomita-Tomita decomposition.
#' @export
npzd_fish_diagnostics = function(params) {
  ref = npzd_fish_reference_state(params)
  state = ref$state
  A_daily = npzd_fish_jacobian(state, params, ref$nutrient_input)
  A = params$days_per_year * A_daily
  eigs = eigen(A, only.values = TRUE)$values
  if (any(Re(eigs) >= 0)) {
    stop("NPZD-fish reference Jacobian is not Hurwitz stable")
  }
  n = state[1]
  p = state[2]
  z = state[3]
  d = state[4]
  fish = state[5]
  uptake = params$v_max * p * n / (params$k_s + n)
  grazing_z = params$a_z * z * params$eps_z * (p^2) / (1.0 + params$eps_z * (p^2))
  grazing_f = params$a_f * fish * params$eps_f * z / (1.0 + params$eps_f * z)
  mortality_z = params$c_z * (z^2)
  turnover_daily = c(
    (ref$nutrient_input + uptake) / n,
    (params$m_p * p + grazing_z) / p,
    (mortality_z + grazing_f) / z,
    params$mu_d + params$w_s,
    params$m_f + params$harvest_mortality
  )
  diff_diag = params$noise_fraction * (state^2) * turnover_daily * params$days_per_year
  D = diag(diff_diag, nrow = 5, ncol = 5)
  C = solve_lyapunov_covariance(A, D)
  decomp = decompose_covariance_weighted_drift(A, C, D = D, scale = 1.0)
  list(
    reference_state = state,
    nutrient_input = ref$nutrient_input,
    A = A,
    D = D,
    C = C,
    decomposition = decomp,
    eigenvalues = eigs,
    lyapunov_residual = decomp$lyapunov_residual
  )
}

#' Simulate dynamic trajectory of NPZD-fish system under an abrupt step harvest shock.
#'
#' @param params NPZD-fish parameters.
#' @param duration Simulation duration in years.
#' @param dt Time step in years.
#' @param harvest_time Time of harvest shock application.
#' @param harvest_multiplier Multiplier for fish harvest mortality.
#' @param seed Optional random number generator seed.
#' @return Named list with `times`, `states`, and `deviations`.
#' @export
simulate_npzd_fish_harvest = function(params, duration = 0.02, dt = 0.001,
                                       harvest_time = 0.01,
                                       harvest_multiplier = 2.5,
                                       seed = NULL) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  ref = npzd_fish_reference_state(params)
  x_star = ref$state
  diag_base = npzd_fish_diagnostics(params)
  A_base = diag_base$A
  D_base = diag_base$D
  C_base = diag_base$C
  
  A_shock_daily = npzd_fish_jacobian(x_star, params, ref$nutrient_input, harvest_multiplier)
  A_shock = params$days_per_year * A_shock_daily
  
  times = seq(0.0, duration, by = dt)
  n_steps = length(times)
  states = matrix(0.0, nrow = n_steps, ncol = 5)
  deviations = matrix(0.0, nrow = n_steps, ncol = 5)
  
  states[1, ] = x_star
  deviations[1, ] = 0.0
  dx_cur = rep(0.0, 5)
  
  e_D = eigen(2.0 * D_base * dt, symmetric = TRUE)
  D_half = e_D$vectors %*% diag(sqrt(pmax(e_D$values, 0.0)), nrow = 5, ncol = 5)
  
  for (t_idx in 2:n_steps) {
    t_val = times[t_idx]
    A_eff = if (t_val < harvest_time) A_base else A_shock
    noise = as.vector(D_half %*% rnorm(5))
    dx_cur = dx_cur + as.vector(A_eff %*% dx_cur) * dt + noise
    states[t_idx, ] = x_star + dx_cur
    deviations[t_idx, ] = dx_cur
  }
  list(times = times, states = states, deviations = deviations)
}
