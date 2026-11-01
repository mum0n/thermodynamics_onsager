# onsagernetwork.jl
# Unified non-equilibrium thermodynamic operators, community-to-Onsager
# transformations, canonical covariance estimators, physical transport models,
# and ecological network diagnostics.

module OnsagerNetwork

using LinearAlgebra
using Statistics
using Random
using Distributions
using ForwardDiff

# ------------------------------------------------------------------
# Physical and numerical constants
# ------------------------------------------------------------------
const k_B = 1.380649e-23            # Boltzmann constant (J K^-1)
const R_GAS = 8.31446261815324      # Molar gas constant (J mol^-1 K^-1)
const DEFAULT_ALLOMETRIC_K = 0.25   # Kleiber allometric mass exponent

const MATRIX_LOG_IMAG_RTOL = 1e-8
const MATRIX_SYM_ATOL = 1e-10
const MATRIX_SYM_RTOL = 1e-8
const PSD_ROUNDOFF_RTOL = 1e-10

# Five-point Gauss-Legendre quadrature nodes and weights on [0, 1]
const GL5_NODES = (
    0.046910077030668,
    0.230765344947158,
    0.500000000000000,
    0.769234655052841,
    0.953089922969332,
)
const GL5_WEIGHTS = (
    0.118463442528095,
    0.239314335249683,
    0.284444444444444,
    0.239314335249683,
    0.118463442528095,
)

export k_B, R_GAS, DEFAULT_ALLOMETRIC_K,
       matrix_asymmetry, persistent_asymmetry, asymmetry_null,
       entropy_production, entropy_production_curvature,
       schur_effective_conductivity,
       forward_community_matrix, inverse_onsager_conductivity,
       solve_lyapunov_covariance, decompose_covariance_weighted_drift,
       diffusion_from_innovation, simulate_ou_process, estimate_ou_onsager,
       marginal_coarse_grained_conductivity,
       fit_var, rolling_var_asymmetry, bootstrap_var_asymmetry,
       ThermalTwoMode, thermal_network_matrices, replicate_thermal_study,
       equilibrium_occupancy_fraction, exact_two_pathway_conductivity,
       simulate_channel_current_density, estimate_two_pathway_conductivity,
       simulate_evolving_conductivity,
       normalize_biomass, weighted_interaction_matrix, sensitivity_allometry,
       biomass_rate, biomass_jacobian_diagnostic,
       cone_spring_network, analyze_cone_spring,
       PopulationJumpParams, biomass_density, run_gillespie_population,
       SizeSpectrumParams, compute_size_spectrum_indices,
       simulate_size_spectrum_filtering, simulate_size_spectrum_wave,
       NPZDParams, npzd_reference_state, npzd_rhs, npzd_diagnostics,
       NPZDFishParams, npzd_fish_reference_state, npzd_fish_rhs,
       npzd_fish_diagnostics, simulate_npzd_fish_harvest

# ==================================================================
# 1. Matrix Asymmetry and Thermodynamic Primitives (Paper Section 2)
# ==================================================================

"""
    matrix_asymmetry(M)

Compute the Frobenius asymmetry index and symmetric/skew-symmetric
decomposition of a square matrix ``\\mathbf{M}``:

```math
\\mathcal{A}_F(\\mathbf{M}) = \\frac{\\|\\mathbf{M} - \\mathbf{M}^{\\mathsf{T}}\\|_F}{\\|\\mathbf{M}\\|_F} \\in [0, 2],
\\qquad
\\mathbf{M}_s = \\frac{1}{2}(\\mathbf{M} + \\mathbf{M}^{\\mathsf{T}}),
\\qquad
\\mathbf{M}_a = \\frac{1}{2}(\\mathbf{M} - \\mathbf{M}^{\\mathsf{T}}).
```

Inputs:
- `M`: Square real matrix with finite entries.

Outputs:
A named tuple `(A_F, symmetric, skew, pairwise)` where `A_F` is the
dimensionless Frobenius asymmetry ``\\mathcal{A}_F(\\mathbf{M})``, `symmetric`
is ``\\mathbf{M}_s``, `skew` is ``\\mathbf{M}_a``, and `pairwise` contains
``(M_{ij} - M_{ji}) / (|M_{ij}| + |M_{ji}|)``.
"""
function matrix_asymmetry(M::AbstractMatrix{<:Real})
    size(M, 1) == size(M, 2) ||
        throw(DimensionMismatch("M must be a square matrix"))
    all(isfinite, M) ||
        throw(ArgumentError("M must contain only finite values"))
    mat = Matrix{Float64}(M)
    all(isfinite, mat) ||
        throw(ArgumentError("M entries must be representable as finite Float64"))
    diff_mat = mat .- transpose(mat)
    denom = norm(mat)
    A_F = denom > 0 ? norm(diff_mat) / denom : 0.0
    symmetric = 0.5 .* (mat .+ transpose(mat))
    skew = 0.5 .* diff_mat
    pairwise = zeros(size(mat))
    for i in axes(mat, 1), j in axes(mat, 2)
        scale = abs(mat[i, j]) + abs(mat[j, i])
        pairwise[i, j] = scale > 0 ? (mat[i, j] - mat[j, i]) / scale : 0.0
    end
    return (A_F = A_F, symmetric = symmetric, skew = skew, pairwise = pairwise)
end

"""
    persistent_asymmetry(A_F_series; threshold=0.2, min_run=3)

Evaluate whether a time series of Frobenius asymmetry values `A_F_series`
contains at least `min_run` consecutive observations strictly exceeding
`threshold`.

Inputs:
- `A_F_series`: Vector of finite real asymmetry indices.
- `threshold`: Finite real threshold (default `0.2`).
- `min_run`: Positive integer run length (default `3`).

Outputs:
Boolean indicating whether the run criterion is satisfied.
"""
function persistent_asymmetry(A_F_series::AbstractVector{<:Real};
                              threshold::Real=0.2,
                              min_run::Int=3)
    min_run > 0 || throw(ArgumentError("min_run must be positive"))
    isfinite(threshold) || throw(ArgumentError("threshold must be finite"))
    all(isfinite, A_F_series) ||
        throw(ArgumentError("A_F_series must contain only finite values"))
    run_count = 0
    for val in A_F_series
        run_count = val > threshold ? run_count + 1 : 0
        if run_count >= min_run
            return true
        end
    end
    return false
end

"""
    asymmetry_null(matrices; n_perm=200, rng=Random.default_rng())

Construct an empirical exchangeability null distribution of the Frobenius
asymmetry index ``\\mathcal{A}_F`` by applying independent random row and
column permutations to each square matrix in `matrices`.

Inputs:
- `matrices`: Vector of square real matrices with finite entries.
- `n_perm`: Nonnegative integer number of permutations per matrix (default `200`).
- `rng`: Random number generator.

Outputs:
Vector of `length(matrices) * n_perm` permuted ``\\mathcal{A}_F`` values.
"""
function asymmetry_null(matrices::AbstractVector{<:AbstractMatrix};
                        n_perm::Int=200,
                        rng::AbstractRNG=Random.default_rng())
    n_perm >= 0 || throw(ArgumentError("n_perm must be nonnegative"))
    null_vals = Float64[]
    for M in matrices
        size(M, 1) == size(M, 2) ||
            throw(DimensionMismatch("each matrix must be square"))
        all(isfinite, M) ||
            throw(ArgumentError("each matrix must contain only finite values"))
        mat = Matrix{Float64}(M)
        n = size(mat, 1)
        for _ in 1:n_perm
            rows = randperm(rng, n)
            cols = randperm(rng, n)
            push!(null_vals, matrix_asymmetry(mat[rows, cols]).A_F)
        end
    end
    return null_vals
end

function validate_onsager_matrix(L::AbstractMatrix{<:Real},
                                 vec_arg::AbstractVector{<:Real},
                                 constraint::Symbol)
    constraint in (:forces, :flows) ||
        throw(ArgumentError("constraint must be :forces or :flows"))
    n = length(vec_arg)
    size(L) == (n, n) ||
        throw(DimensionMismatch("L must be square and match vector dimension"))
    all(isfinite, L) && all(isfinite, vec_arg) ||
        throw(ArgumentError("L and vector must contain only finite values"))
    any(!iszero, vec_arg) ||
        throw(ArgumentError("driving force or flux vector must be nonzero"))
    isapprox(L, L'; atol=MATRIX_SYM_ATOL, rtol=MATRIX_SYM_RTOL) ||
        throw(ArgumentError("L must be symmetric (Onsager reciprocity)"))
    sym_L = Symmetric(0.5 .* (Matrix{Float64}(L) .+ Matrix{Float64}(L)'))
    min_eig = minimum(eigvals(sym_L))
    if constraint == :forces
        tol = PSD_ROUNDOFF_RTOL * max(1.0, opnorm(sym_L))
        min_eig >= -tol ||
            throw(ArgumentError("L must be positive semidefinite for fixed forces"))
    else
        min_eig > 0 ||
            throw(ArgumentError("L must be positive definite for fixed flows"))
    end
    return sym_L
end

"""
    entropy_production(L, X_or_J; constraint=:forces)

Evaluate the linear-regime internal entropy production rate ``\\sigma`` for
``\\mathbf{J} = \\mathbf{L}\\mathbf{X}`` (Onsager 1931a, 1931b; Reis 2014):

```math
\\sigma_X = \\mathbf{X}^{\\mathsf{T}}\\mathbf{L}\\mathbf{X} \\ge 0
\\quad (\\text{constraint = :forces}),
\\qquad
\\sigma_J = \\mathbf{J}^{\\mathsf{T}}\\mathbf{L}^{-1}\\mathbf{J} > 0
\\quad (\\text{constraint = :flows}).
```

Inputs:
- `L`: Symmetric Onsager conductivity matrix (positive semidefinite for
  `:forces`, strictly positive definite for `:flows`).
- `X_or_J`: Nonzero thermodynamic force vector ``\\mathbf{X}`` (when
  `constraint == :forces`) or conjugate flux vector ``\\mathbf{J}`` (when
  `constraint == :flows`).
- `constraint`: Either `:forces` or `:flows`.

Outputs:
Scalar entropy production rate ``\\sigma``.
"""
function entropy_production(L::AbstractMatrix{<:Real},
                            X_or_J::AbstractVector{<:Real};
                            constraint::Symbol=:forces)
    sym_L = validate_onsager_matrix(L, X_or_J, constraint)
    v = Float64.(X_or_J)
    return constraint == :forces ? dot(v, sym_L * v) : dot(v, sym_L \ v)
end

"""
    entropy_production_curvature(L, d2L, X_or_J; constraint=:forces, rtol=1e-12)

Evaluate the second differential of the entropy production rate around a
stationary transport configuration where ``d\\mathbf{L} = \\mathbf{0}``
(Reis 2014):

```math
\\left.d^2\\sigma_X\\right|_{d\\mathbf{L}=\\mathbf{0}} =
\\mathbf{X}^{\\mathsf{T}}(d^2\\mathbf{L})\\mathbf{X},
\\qquad
\\left.d^2\\sigma_J\\right|_{d\\mathbf{L}=\\mathbf{0}} =
-\\left(\\mathbf{L}^{-1}\\mathbf{J}\\right)^{\\mathsf{T}}(d^2\\mathbf{L})
\\left(\\mathbf{L}^{-1}\\mathbf{J}\\right).
```

When ``-d^2\\mathbf{L} \\succ 0``, fixed forces yield ``d^2\\sigma_X < 0``
(`:maximum`, MaxEP) and fixed flows yield ``d^2\\sigma_J > 0`` (`:minimum`,
MinEP; Prigogine 1955).

Inputs:
- `L`: Symmetric Onsager conductivity matrix.
- `d2L`: Symmetric second-differential matrix ``d^2\\mathbf{L}``.
- `X_or_J`: Nonzero force vector ``\\mathbf{X}`` or flux vector ``\\mathbf{J}``.
- `constraint`: `:forces` or `:flows`.
- `rtol`: Relative tolerance for classifying near-zero curvature as
  `:indeterminate`.

Outputs:
Named tuple `(d2sigma, regime)` where `regime` is `:maximum`, `:minimum`, or
`:indeterminate`.
"""
function entropy_production_curvature(L::AbstractMatrix{<:Real},
                                      d2L::AbstractMatrix{<:Real},
                                      X_or_J::AbstractVector{<:Real};
                                      constraint::Symbol=:forces,
                                      rtol::Real=1e-12)
    sym_L = validate_onsager_matrix(L, X_or_J, constraint)
    size(d2L) == size(L) ||
        throw(DimensionMismatch("d2L must have the same dimensions as L"))
    all(isfinite, d2L) ||
        throw(ArgumentError("d2L must contain only finite values"))
    isapprox(d2L, d2L'; atol=MATRIX_SYM_ATOL, rtol=MATRIX_SYM_RTOL) ||
        throw(ArgumentError("d2L must be symmetric"))
    v = Float64.(X_or_J)
    d2L_mat = Matrix{Float64}(d2L)
    d2sigma = if constraint == :forces
        dot(v, d2L_mat * v)
    else
        resp = sym_L \ v
        -dot(resp, d2L_mat * resp)
    end
    scale = Float64(rtol) * sum(abs2, v) * norm(d2L_mat)
    if constraint == :flows
        scale *= opnorm(inv(Matrix(sym_L)))^2
    end
    regime = abs(d2sigma) <= scale ? :indeterminate :
             d2sigma < 0 ? :maximum : :minimum
    return (d2sigma = d2sigma, regime = regime)
end

"""
    schur_effective_conductivity(L, i)

Compute the Le Chatelier-Braun Schur-complement effective conductivity
``L_{ii,\\mathrm{eff}}`` for primary process `i` when all secondary fluxes
``\\delta\\mathbf{J}_{-i} = \\mathbf{0}`` are clamped (Bertalanffy 1950;
Gündüz and Gündüz 2014):

```math
L_{ii,\\mathrm{eff}} = L_{ii} -
\\mathbf{L}_{i,-i}\\mathbf{L}_{-i,-i}^{-1}\\mathbf{L}_{-i,i} \\le L_{ii}.
```

Inputs:
- `L`: Symmetric positive-definite conductivity matrix ``\\mathbf{L} \\succ 0``.
- `i`: Integer index of the primary coordinate (`1 <= i <= size(L, 1)`).

Outputs:
Named tuple `(L_ii, L_ii_eff, moderation_decrement, R_ii_unclamped, R_ii_clamped)`
satisfying ``L_{ii,\\mathrm{eff}} \\le L_{ii}`` and
``R_{ii,\\mathrm{unclamped}} = L_{ii}^{-1} \\le R_{ii,\\mathrm{clamped}} = L_{ii,\\mathrm{eff}}^{-1}``.
"""
function schur_effective_conductivity(L::AbstractMatrix{<:Real}, i::Integer)
    n = size(L, 1)
    size(L) == (n, n) && n >= 2 ||
        throw(DimensionMismatch("L must be square with dimension at least 2"))
    1 <= i <= n ||
        throw(ArgumentError("index i must be between 1 and $n"))
    all(isfinite, L) ||
        throw(ArgumentError("L must contain only finite values"))
    isapprox(L, L'; atol=MATRIX_SYM_ATOL, rtol=MATRIX_SYM_RTOL) ||
        throw(ArgumentError("L must be symmetric"))
    sym_L = Symmetric(0.5 .* (Matrix{Float64}(L) .+ Matrix{Float64}(L)'))
    isposdef(sym_L) ||
        throw(ArgumentError("L must be strictly positive definite"))
    other = [idx for idx in 1:n if idx != i]
    L_ii = sym_L[i, i]
    L_i_other = Vector{Float64}(sym_L[i, other])
    L_other_other = Symmetric(Matrix{Float64}(sym_L[other, other]))
    decrement = dot(L_i_other, L_other_other \ L_i_other)
    L_ii_eff = L_ii - decrement
    return (
        L_ii = L_ii,
        L_ii_eff = L_ii_eff,
        moderation_decrement = decrement,
        R_ii_unclamped = inv(L_ii),
        R_ii_clamped = inv(L_ii_eff),
    )
end

# ==================================================================
# 2. Community Matrix <-> Onsager Conductivity Bridge (Section 3)
# ==================================================================

"""
    forward_community_matrix(L, H; B=I)

Construct the projected pool-space conductivity ``\\mathbf{L}_x`` and the
linearized community Jacobian ``\\mathbf{A}`` from a process conductivity
matrix ``\\mathbf{L}``, entropy Hessian ``\\mathbf{H} = \\mathbf{H}_G / T``,
and stoichiometric projection ``\\mathbf{B}``:

```math
\\mathbf{L}_x = \\mathbf{B}\\mathbf{L}\\mathbf{B}^{\\mathsf{T}},
\\qquad
\\mathbf{A} = -\\mathbf{B}\\mathbf{L}\\mathbf{B}^{\\mathsf{T}}\\mathbf{H} =
-\\mathbf{L}_x\\mathbf{H}.
```

Inputs:
- `L`: Process conductivity matrix (``r \\times r``).
- `H`: Symmetric positive-definite entropy Hessian (``n \\times n``).
- `B`: Stoichiometric matrix (``n \\times r``) or `UniformScaling` `I`.

Outputs:
Named tuple `(A, L_x, A_F_A, A_F_Lx, eigenvalues_A)`.
"""
function forward_community_matrix(L::AbstractMatrix{<:Real},
                                  H::AbstractMatrix{<:Real};
                                  B::Union{AbstractMatrix{<:Real},UniformScaling}=I)
    n = size(H, 1)
    size(H) == (n, n) ||
        throw(DimensionMismatch("H must be square"))
    r = size(L, 1)
    size(L) == (r, r) ||
        throw(DimensionMismatch("L must be square"))
    all(isfinite, L) && all(isfinite, H) ||
        throw(ArgumentError("L and H must contain only finite values"))
    isapprox(H, H'; atol=MATRIX_SYM_ATOL, rtol=MATRIX_SYM_RTOL) ||
        throw(ArgumentError("H must be symmetric"))
    sym_H = Symmetric(0.5 .* (Matrix{Float64}(H) .+ Matrix{Float64}(H)'))
    isposdef(sym_H) ||
        throw(ArgumentError("H must be strictly positive definite"))

    B_mat = B isa UniformScaling ? Matrix{Float64}(B, n, r) : Matrix{Float64}(B)
    size(B_mat) == (n, r) ||
        throw(DimensionMismatch("B must have size ($n, $r)"))
    all(isfinite, B_mat) ||
        throw(ArgumentError("B must contain only finite values"))

    L_mat = Matrix{Float64}(L)
    L_x = B_mat * L_mat * transpose(B_mat)
    A = -L_x * Matrix(sym_H)
    return (
        A = A,
        L_x = L_x,
        A_F_A = matrix_asymmetry(A).A_F,
        A_F_Lx = matrix_asymmetry(L_x).A_F,
        eigenvalues_A = eigvals(A),
    )
end

"""
    inverse_onsager_conductivity(A, H; B=nothing)

Recover the pool-space conductivity ``\\mathbf{L}_x = -\\mathbf{A}\\mathbf{H}^{-1}``
and, when a stoichiometric matrix ``\\mathbf{B}`` is supplied, the process-space
conductivity ``\\mathbf{L}`` across the three inversion regimes:

- Dense pool coordinates (`B === nothing` or `B == I`):
  ``\\mathbf{L} = \\mathbf{L}_x = -\\mathbf{A}\\mathbf{H}^{-1}``.
- Square invertible stoichiometry (``r = n``, ``\\det\\mathbf{B} \\neq 0``):
  ``\\mathbf{L} = \\mathbf{B}^{-1}\\mathbf{L}_x\\mathbf{B}^{-\\mathsf{T}}``.
- Rectangular or rank-deficient stoichiometry (``\\operatorname{rank}(\\mathbf{B}) < r``):
  minimum-norm Moore-Penrose pseudoinverse projection
  ``\\mathbf{L}_{\\mathrm{pinv}} = \\mathbf{B}^{+}\\mathbf{L}_x\\mathbf{B}^{+\\mathsf{T}}``.

Inputs:
- `A`: Community or drift matrix (``n \\times n``).
- `H`: Symmetric positive-definite entropy Hessian (``n \\times n``).
- `B`: Optional stoichiometric matrix (``n \\times r``).

Outputs:
Named tuple `(L_x, L, regime, A_F_Lx, min_sym_eig_Lx)`.
"""
function inverse_onsager_conductivity(
    A::AbstractMatrix{<:Real},
    H::AbstractMatrix{<:Real};
    B::Union{Nothing,AbstractMatrix{<:Real},UniformScaling}=nothing,
)
    n = size(A, 1)
    size(A) == (n, n) && size(H) == (n, n) ||
        throw(DimensionMismatch("A and H must be square matrices of equal size"))
    all(isfinite, A) && all(isfinite, H) ||
        throw(ArgumentError("A and H must contain only finite values"))
    isapprox(H, H'; atol=MATRIX_SYM_ATOL, rtol=MATRIX_SYM_RTOL) ||
        throw(ArgumentError("H must be symmetric"))
    sym_H = Symmetric(0.5 .* (Matrix{Float64}(H) .+ Matrix{Float64}(H)'))
    isposdef(sym_H) ||
        throw(ArgumentError("H must be strictly positive definite"))

    A_mat = Matrix{Float64}(A)
    L_x = -A_mat / sym_H
    asym_Lx = matrix_asymmetry(L_x)
    min_eig_Lx = minimum(eigvals(Symmetric(asym_Lx.symmetric)))

    if isnothing(B) || B isa UniformScaling
        scale_val = B isa UniformScaling ? Float64(B.λ) : 1.0
        scale_val != 0 || throw(ArgumentError("UniformScaling B must be nonzero"))
        L_rec = L_x ./ (scale_val^2)
        return (
            L_x = L_x,
            L = L_rec,
            regime = :dense_pool,
            A_F_Lx = asym_Lx.A_F,
            min_sym_eig_Lx = min_eig_Lx,
        )
    end

    B_mat = Matrix{Float64}(B)
    size(B_mat, 1) == n ||
        throw(DimensionMismatch("B must have $n rows to match A and H"))
    all(isfinite, B_mat) ||
        throw(ArgumentError("B must contain only finite values"))
    r = size(B_mat, 2)
    rk = rank(B_mat)
    if r == n && rk == n
        B_inv = inv(B_mat)
        L_rec = B_inv * L_x * transpose(B_inv)
        regime = :square_invertible
    else
        B_pinv = pinv(B_mat)
        L_rec = B_pinv * L_x * transpose(B_pinv)
        regime = :rank_deficient_pseudoinverse
    end
    return (
        L_x = L_x,
        L = L_rec,
        regime = regime,
        A_F_Lx = asym_Lx.A_F,
        min_sym_eig_Lx = min_eig_Lx,
    )
end

# ==================================================================
# 3. Canonical Covariance Estimator & Lyapunov Decomposition (Sec 4)
# ==================================================================

"""
    solve_lyapunov_covariance(A, D)

Solve the continuous stationary Lyapunov (Aleksandrov) balance equation for the
stationary state covariance ``\\mathbf{C}``:

```math
\\mathbf{A}\\mathbf{C} + \\mathbf{C}\\mathbf{A}^{\\mathsf{T}} + 2\\mathbf{D} = \\mathbf{0}.
```

Inputs:
- `A`: Hurwitz-stable drift matrix (``n \\times n``).
- `D`: Symmetric positive-semidefinite diffusion matrix (``n \\times n``).

Outputs:
Symmetric matrix ``\\mathbf{C}`` (``n \\times n``).
"""
function solve_lyapunov_covariance(A::AbstractMatrix{<:Real},
                                   D::AbstractMatrix{<:Real})
    n = size(A, 1)
    size(A) == (n, n) && size(D) == (n, n) ||
        throw(DimensionMismatch("A and D must be square matrices of equal size"))
    all(isfinite, A) && all(isfinite, D) ||
        throw(ArgumentError("A and D must contain only finite values"))
    A_mat = Matrix{Float64}(A)
    D_mat = Matrix{Float64}(D)
    maximum(real.(eigvals(A_mat))) < 0 ||
        throw(ArgumentError("A must be Hurwitz stable (all eigenvalues Re(λ) < 0)"))
    K_op = kron(Matrix{Float64}(I, n, n), A_mat) +
           kron(A_mat, Matrix{Float64}(I, n, n))
    C_vec = -(K_op \ vec(2.0 .* D_mat))
    C_raw = reshape(C_vec, n, n)
    return Symmetric(0.5 .* (C_raw .+ transpose(C_raw)))
end

"""
    decompose_covariance_weighted_drift(A, C; D=nothing, scale=k_B)

Decompose the covariance-weighted drift ``\\mathbf{K}_{\\mathrm{cov}} = -\\mathbf{A}\\mathbf{C}``
into its symmetric dissipative diffusion matrix ``\\mathbf{D}`` and its
antisymmetric steady-state circulation tensor ``\\boldsymbol{\\Omega}``:

```math
\\mathbf{K}_{\\mathrm{cov}} = -\\mathbf{A}\\mathbf{C} = \\mathbf{D} - \\boldsymbol{\\Omega},
\\qquad
\\mathbf{D} = -\\operatorname{sym}(\\mathbf{A}\\mathbf{C}),
\\qquad
\\boldsymbol{\\Omega} = \\operatorname{asym}(\\mathbf{A}\\mathbf{C}),
```
and evaluate the steady-state entropy production rate
``\\sigma = \\text{scale}\\cdot\\operatorname{tr}[\\boldsymbol{\\Omega}^{\\mathsf{T}}\\mathbf{C}^{-1}\\boldsymbol{\\Omega}\\mathbf{D}^{-1}]``.

Inputs:
- `A`: Drift or community matrix (``n \\times n``).
- `C`: Symmetric positive-definite state covariance matrix (``n \\times n``).
- `D`: Optional independently estimated diffusion matrix ``\\mathbf{D}`` used
  to compute the Lyapunov residual ``\\|\\mathbf{D} + \\operatorname{sym}(\\mathbf{A}\\mathbf{C})\\|_F / \\|\\mathbf{D}\\|_F``.
  When `D === nothing`, ``\\mathbf{D} = -\\operatorname{sym}(\\mathbf{A}\\mathbf{C})`` is used.
- `scale`: Physical scale factor (default `k_B` for SI thermal units; set
  `scale = 1.0` for unscaled demographic diagnostics).

Outputs:
Named tuple `(K_cov, D, Omega, L_x, H, sigma, circulation_rate, A_F,
min_sym_eig, lyapunov_residual)`.
"""
function decompose_covariance_weighted_drift(
    A::AbstractMatrix{<:Real},
    C::AbstractMatrix{<:Real};
    D::Union{Nothing,AbstractMatrix{<:Real}}=nothing,
    scale::Real=k_B,
)
    n = size(A, 1)
    size(A) == (n, n) && size(C) == (n, n) ||
        throw(DimensionMismatch("A and C must be square matrices of equal size"))
    all(isfinite, A) && all(isfinite, C) ||
        throw(ArgumentError("A and C must contain only finite values"))
    isfinite(scale) && scale > 0 ||
        throw(ArgumentError("scale must be finite and positive"))

    A_mat = Matrix{Float64}(A)
    C_mat = 0.5 .* (Matrix{Float64}(C) .+ Matrix{Float64}(C)')
    isposdef(Symmetric(C_mat)) ||
        throw(ArgumentError("C must be strictly positive definite"))

    AC = A_mat * C_mat
    K_cov = -AC
    D_sym = -0.5 .* (AC .+ transpose(AC))
    Omega = 0.5 .* (AC .- transpose(AC))

    D_use = if isnothing(D)
        D_sym
    else
        size(D) == (n, n) && all(isfinite, D) ||
            throw(ArgumentError("D must be a finite $n by $n matrix"))
        0.5 .* (Matrix{Float64}(D) .+ Matrix{Float64}(D)')
    end

    lyapunov_residual = if isnothing(D)
        0.0
    else
        sym_AC = 0.5 .* (AC .+ transpose(AC))
        denom = norm(D_use)
        residual = D_use .+ sym_AC
        denom > 0 ? norm(residual) / denom : norm(residual)
    end

    min_sym_eig = minimum(eigvals(Symmetric(D_sym)))
    psd_tolerance = PSD_ROUNDOFF_RTOL * max(opnorm(D_sym), eps(Float64))
    dissipation_psd = min_sym_eig >= -psd_tolerance
    circulation_rate = if dissipation_psd && isposdef(Symmetric(D_use))
        tr(transpose(Omega) * (C_mat \ Omega) / D_use)
    else
        NaN
    end
    sigma = Float64(scale) * circulation_rate
    L_x = K_cov ./ Float64(scale)
    H = Float64(scale) .* inv(C_mat)
    A_F = matrix_asymmetry(K_cov).A_F

    return (
        K_cov = K_cov,
        D = D_sym,
        Omega = Omega,
        L_x = L_x,
        H = H,
        sigma = sigma,
        circulation_rate = circulation_rate,
        A_F = A_F,
        min_sym_eig = min_sym_eig,
        lyapunov_residual = lyapunov_residual,
    )
end

"""
    diffusion_from_innovation(A, Q, dt)

Invert the exact discrete-time innovation covariance integral

```math
\\mathbf{Q} = \\int_0^{\\Delta t} e^{\\mathbf{A}s}(2\\mathbf{D})e^{\\mathbf{A}^{\\mathsf{T}}s}\\,ds
```

for the continuous-time diffusion matrix ``\\mathbf{D}`` using five-point
Gauss-Legendre quadrature on ``[0, 1]``.

Inputs:
- `A`: Drift matrix (``n \\times n``).
- `Q`: Discrete-time innovation covariance matrix (``n \\times n``).
- `dt`: Positive sampling interval ``\\Delta t``.

Outputs:
Symmetric matrix ``\\mathbf{D}`` free of first-order ``O(\\mathbf{A}\\Delta t)``
Euler discretization bias.
"""
function diffusion_from_innovation(A::AbstractMatrix{<:Real},
                                   Q::AbstractMatrix{<:Real},
                                   dt::Real)
    n = size(A, 1)
    size(A) == (n, n) && size(Q) == (n, n) ||
        throw(DimensionMismatch("A and Q must be square matrices of equal size"))
    all(isfinite, A) && all(isfinite, Q) ||
        throw(ArgumentError("A and Q must contain only finite values"))
    isfinite(dt) && dt > 0 ||
        throw(ArgumentError("dt must be finite and positive"))

    A_mat = Matrix{Float64}(A)
    Q_mat = Matrix{Float64}(Q)
    transport = zeros(n^2, n^2)
    for (node, weight) in zip(GL5_NODES, GL5_WEIGHTS)
        prop = exp(A_mat .* (Float64(dt) * node))
        transport .+= weight .* kron(prop, prop)
    end
    transport .*= Float64(dt)
    D_raw = 0.5 .* reshape(transport \ vec(Q_mat), n, n)
    return Symmetric(0.5 .* (D_raw .+ transpose(D_raw)))
end

"""
    simulate_ou_process(A, D; dt, n_steps, C=nothing, rng=Random.default_rng())

Simulate an exact discrete-time stationary Gaussian Ornstein-Uhlenbeck
trajectory governed by ``d\\mathbf{x} = \\mathbf{A}\\mathbf{x}\\,dt + \\sqrt{2\\mathbf{D}}\\,d\\mathbf{W}``:

```math
\\mathbf{x}_{t+1} = \\mathbf{\\Phi}\\mathbf{x}_t + \\mathbf{Q}^{1/2}\\boldsymbol{\\xi}_t,
\\qquad
\\mathbf{\\Phi} = e^{\\mathbf{A}\\Delta t},
\\qquad
\\mathbf{Q} = \\mathbf{C} - \\mathbf{\\Phi}\\mathbf{C}\\mathbf{\\Phi}^{\\mathsf{T}}.
```

The initial state ``\\mathbf{x}_1 \\sim \\mathcal{N}(\\mathbf{0}, \\mathbf{C})`` is
drawn directly from the stationary distribution so that no burn-in truncation
is needed.

Inputs:
- `A`: Hurwitz-stable drift matrix (``n \\times n``).
- `D`: Symmetric positive-definite diffusion matrix (``n \\times n``).
- `dt`: Positive sampling step ``\\Delta t``.
- `n_steps`: Positive integer number of transitions (returns `n_steps + 1` rows).
- `C`: Optional precomputed stationary covariance ``\\mathbf{C}``.
- `rng`: Random number generator.

Outputs:
Trajectory matrix of size `(n_steps + 1, n)` where each row is an observation
``\\mathbf{x}(t_k)^{\\mathsf{T}}``.
"""
function simulate_ou_process(
    A::AbstractMatrix{<:Real},
    D::AbstractMatrix{<:Real};
    dt::Real,
    n_steps::Integer,
    C::Union{Nothing,AbstractMatrix{<:Real}}=nothing,
    rng::AbstractRNG=Random.default_rng(),
)
    isfinite(dt) && dt > 0 ||
        throw(ArgumentError("dt must be finite and positive"))
    n_steps > 0 ||
        throw(ArgumentError("n_steps must be positive"))
    n = size(A, 1)
    C_sym = isnothing(C) ? solve_lyapunov_covariance(A, D) :
            Symmetric(0.5 .* (Matrix{Float64}(C) .+ Matrix{Float64}(C)'))
    isposdef(C_sym) ||
        throw(ArgumentError("stationary covariance C must be positive definite"))
    Phi = exp(Matrix{Float64}(A) .* Float64(dt))
    Q_raw = Matrix(C_sym) - Phi * Matrix(C_sym) * transpose(Phi)
    Q_sym = Symmetric(0.5 .* (Q_raw .+ transpose(Q_raw)))
    isposdef(Q_sym) ||
        throw(ArgumentError("discrete innovation covariance Q is not positive definite"))

    L_C = cholesky(C_sym).L
    L_Q = cholesky(Q_sym).L
    X_data = Matrix{Float64}(undef, n_steps + 1, n)
    X_data[1, :] .= L_C * randn(rng, n)
    for step in 1:n_steps
        X_data[step + 1, :] .= Phi * view(X_data, step, :) .+ L_Q * randn(rng, n)
    end
    return X_data
end

"""
    estimate_ou_onsager(X_data; dt=1.0, scale=1.0)

Estimate the continuous-time drift ``\\widehat{\\mathbf{A}}``, stationary
covariance ``\\widehat{\\mathbf{C}}``, quadrature-inverted diffusion
``\\widehat{\\mathbf{D}}``, covariance-weighted drift
``\\widehat{\\mathbf{K}}_{\\mathrm{cov}} = -\\widehat{\\mathbf{A}}\\widehat{\\mathbf{C}}``,
dissipative conductivity ``\\widehat{\\mathbf{L}}_x``, entropy Hessian
``\\widehat{\\mathbf{H}}``, circulation ``\\widehat{\\boldsymbol{\\Omega}}``,
and steady-state entropy production rate ``\\widehat{\\sigma}`` from a
multivariate stationary trajectory `X_data`.

Inputs:
- `X_data`: Observation matrix of size `(n_obs, n)` with rows as equally spaced
  time points and columns as state coordinates.
- `dt`: Positive sampling interval ``\\Delta t`` (default `1.0`).
- `scale`: Physical scale constant (use `scale = k_B` for conjugate physical
  coordinates in SI units, or `scale = 1.0` for demographic coordinates).

Outputs:
Named tuple `(A, C, D, Q, Phi, K_cov, K_cov_sym, Omega, L_x, L_from_D, H, sigma,
circulation_rate, A_F, min_sym_eig, lyapunov_residual, drift_stable,
psd_within_roundoff)`.
"""
function estimate_ou_onsager(X_data::AbstractMatrix{<:Real};
                             dt::Real=1.0,
                             scale::Real=1.0)
    n_obs, n_vars = size(X_data)
    n_obs >= 4 ||
        throw(ArgumentError("at least four time observations are required"))
    n_vars >= 1 ||
        throw(ArgumentError("X_data must contain at least one state variable"))
    all(isfinite, X_data) ||
        throw(ArgumentError("X_data must contain only finite values"))
    isfinite(dt) && dt > 0 ||
        throw(ArgumentError("dt must be finite and positive"))
    isfinite(scale) && scale > 0 ||
        throw(ArgumentError("scale must be finite and positive"))

    centered = Matrix{Float64}(X_data)
    centered .-= mean(centered; dims=1)
    C_hat = cov(centered)
    isposdef(Symmetric(C_hat)) ||
        throw(ArgumentError("sample covariance C must be positive definite"))

    lagged = view(centered, 1:(n_obs - 1), :)
    advanced = view(centered, 2:n_obs, :)
    gram = Symmetric(transpose(lagged) * lagged)
    isposdef(gram) ||
        throw(ArgumentError("lagged design matrix is rank deficient"))
    Phi = (transpose(advanced) * lagged) / gram

    complex_A = log(complex.(Phi)) ./ Float64(dt)
    imag_norm = norm(imag.(complex_A))
    real_norm = norm(real.(complex_A))
    imag_norm <= MATRIX_LOG_IMAG_RTOL * max(1.0, real_norm) ||
        throw(ArgumentError("VAR(1) transition has no real principal matrix logarithm"))
    A_hat = real.(complex_A)

    residuals = advanced .- lagged * transpose(Phi)
    Q_hat = Symmetric((transpose(residuals) * residuals) ./ (n_obs - 2))
    D_hat = Matrix(diffusion_from_innovation(A_hat, Q_hat, dt))

    decomp = decompose_covariance_weighted_drift(
        A_hat, C_hat; D=D_hat, scale=scale)
    drift_stable = maximum(real.(eigvals(A_hat))) < 0
    tol = PSD_ROUNDOFF_RTOL * max(1.0, opnorm(decomp.D))
    psd_ok = decomp.min_sym_eig >= -tol

    return (
        A = A_hat,
        C = C_hat,
        D = D_hat,
        Q = Matrix(Q_hat),
        Phi = Phi,
        K_cov = decomp.K_cov,
        K_cov_sym = decomp.D,
        Omega = decomp.Omega,
        L_x = decomp.L_x,
        L_from_D = D_hat ./ Float64(scale),
        H = decomp.H,
        sigma = decomp.sigma,
        circulation_rate = decomp.circulation_rate,
        A_F = decomp.A_F,
        min_sym_eig = decomp.min_sym_eig,
        lyapunov_residual = decomp.lyapunov_residual,
        drift_stable = drift_stable,
        psd_within_roundoff = psd_ok,
    )
end

"""
    marginal_coarse_grained_conductivity(A, C, obs_indices; dt=0.0, scale=k_B)

Compute the effective marginal conductivity ``\\widehat{\\mathbf{L}}_{11,\\mathrm{eff}}``
when observing a coordinate subset `obs_indices` of a larger linear Gaussian
system:

```math
\\widehat{\\mathbf{L}}_{11,\\mathrm{eff}} =
-\\frac{\\mathbf{A}_{11,\\mathrm{eff}}\\mathbf{C}_{11}}{k_{\\mathrm{B}}},
\\qquad
\\mathbf{A}_{11,\\mathrm{eff}} =
\\begin{cases}
(\\mathbf{A}\\mathbf{C})_{11}\\mathbf{C}_{11}^{-1}, & \\Delta t = 0, \\\\
\\frac{1}{\\Delta t}\\ln\\!\\left[(e^{\\mathbf{A}\\Delta t}\\mathbf{C})_{11}\\mathbf{C}_{11}^{-1}\\right], & \\Delta t > 0.
\\end{cases}
```

Inputs:
- `A`: Full drift matrix (``n \\times n``).
- `C`: Full stationary covariance matrix (``n \\times n``).
- `obs_indices`: Vector or range of observed coordinate indices.
- `dt`: Sampling interval ``\\Delta t \\ge 0`` (`0.0` evaluates the exact
  continuous-time limit).
- `scale`: Physical scale constant (default `k_B`).

Outputs:
Marginal conductivity matrix ``\\widehat{\\mathbf{L}}_{11,\\mathrm{eff}}``.
"""
function marginal_coarse_grained_conductivity(
    A::AbstractMatrix{<:Real},
    C::AbstractMatrix{<:Real},
    obs_indices::AbstractVector{<:Integer};
    dt::Real=0.0,
    scale::Real=k_B,
)
    n = size(A, 1)
    size(A) == (n, n) && size(C) == (n, n) ||
        throw(DimensionMismatch("A and C must be square matrices of equal size"))
    !isempty(obs_indices) && all(idx -> 1 <= idx <= n, obs_indices) ||
        throw(ArgumentError("obs_indices must be valid indices in 1:$n"))
    isfinite(dt) && dt >= 0 ||
        throw(ArgumentError("dt must be finite and nonnegative"))
    isfinite(scale) && scale > 0 ||
        throw(ArgumentError("scale must be finite and positive"))

    A_mat = Matrix{Float64}(A)
    C_mat = Matrix{Float64}(C)
    C_11 = C_mat[obs_indices, obs_indices]
    if dt == 0
        AC_11 = (A_mat * C_mat)[obs_indices, obs_indices]
        A_11_eff = AC_11 / C_11
        return -(A_11_eff * C_11) ./ Float64(scale)
    else
        Phi_11 = (exp(A_mat .* Float64(dt)) * C_mat)[obs_indices, obs_indices] / C_11
        A_11_eff = real.(log(complex.(Phi_11))) ./ Float64(dt)
        return -(A_11_eff * C_11) ./ Float64(scale)
    end
end

# ==================================================================
# 4. Reduced-Form VAR(p) and Time-Series Uncertainty Helpers
# ==================================================================

"""
    fit_var(X_data; p=1)

Fit a reduced-form vector autoregression of order `p` with intercept by ordinary
least squares.

Inputs:
- `X_data`: Matrix of size `(n_obs, n_vars)` with observations in rows.
- `p`: Positive integer lag order (default `1`).

Outputs:
Named tuple `(intercept, lags, residuals, residual_covariance, standard_errors,
fitted_values, n_observations, lag_order)`.
"""
function fit_var(X_data::AbstractMatrix{<:Real}; p::Int=1)
    p >= 1 || throw(ArgumentError("p must be at least 1"))
    n_obs, n_vars = size(X_data)
    n_vars > 0 || throw(ArgumentError("X_data must contain at least one variable"))
    all(isfinite, X_data) ||
        throw(ArgumentError("X_data must contain only finite values"))
    n_coeffs = 1 + n_vars * p
    n_rows = n_obs - p
    n_rows > n_coeffs ||
        throw(ArgumentError("insufficient observations for VAR($p) with $n_vars variables"))

    Y = Matrix{Float64}(X_data[(p + 1):n_obs, :])
    Z = Matrix{Float64}(undef, n_rows, n_coeffs)
    Z[:, 1] .= 1.0
    for lag in 1:p
        cols = (2 + (lag - 1) * n_vars):(1 + lag * n_vars)
        Z[:, cols] .= X_data[(p + 1 - lag):(n_obs - lag), :]
    end
    rank(Z) == n_coeffs ||
        throw(ArgumentError("VAR design matrix is rank deficient"))

    B_hat = Z \ Y
    fitted = Z * B_hat
    residuals = Y - fitted
    dof = n_rows - n_coeffs
    res_cov = (transpose(residuals) * residuals) / dof
    inv_gram = inv(Symmetric(transpose(Z) * Z))
    coeff_var = diag(inv_gram) * transpose(diag(res_cov))
    all(>=(-PSD_ROUNDOFF_RTOL), coeff_var) ||
        throw(ArgumentError("negative coefficient variance encountered"))
    std_errors = sqrt.(max.(coeff_var, 0.0))

    lags = Matrix{Float64}[]
    for lag in 1:p
        cols = (2 + (lag - 1) * n_vars):(1 + lag * n_vars)
        push!(lags, Matrix(transpose(B_hat[cols, :])))
    end

    return (
        intercept = vec(B_hat[1, :]),
        lags = lags,
        residuals = residuals,
        residual_covariance = Matrix(res_cov),
        standard_errors = std_errors,
        fitted_values = fitted,
        n_observations = n_obs,
        lag_order = p,
    )
end

"""
    rolling_var_asymmetry(X_data; window, p=1, step=1)

Evaluate the Frobenius asymmetry ``\\mathcal{A}_F`` of the first-lag coefficient
matrix across rolling windows of length `window`.

Inputs:
- `X_data`: Observation matrix `(n_obs, n_vars)`.
- `window`: Positive integer window length (`window <= n_obs`).
- `p`: VAR lag order (default `1`).
- `step`: Positive integer stride between windows (default `1`).

Outputs:
Named tuple `(end_indices, A_F, lag1_matrices)`.
"""
function rolling_var_asymmetry(X_data::AbstractMatrix{<:Real};
                               window::Int,
                               p::Int=1,
                               step::Int=1)
    window > 0 || throw(ArgumentError("window must be positive"))
    step > 0 || throw(ArgumentError("step must be positive"))
    window <= size(X_data, 1) ||
        throw(ArgumentError("window cannot exceed the number of observations"))
    starts = collect(1:step:(size(X_data, 1) - window + 1))
    A_F_vec = Float64[]
    lag1_mats = Matrix{Float64}[]
    for s_idx in starts
        fit = fit_var(view(X_data, s_idx:(s_idx + window - 1), :); p=p)
        push!(lag1_mats, fit.lags[1])
        push!(A_F_vec, matrix_asymmetry(fit.lags[1]).A_F)
    end
    return (
        end_indices = starts .+ window .- 1,
        A_F = A_F_vec,
        lag1_matrices = lag1_mats,
    )
end

"""
    bootstrap_var_asymmetry(X_data; p=1, n_boot=500, confidence=0.95,
                            block_length=nothing, rng=Random.default_rng())

Compute a moving-block bootstrap percentile interval for the Frobenius
asymmetry ``\\mathcal{A}_F`` of the first-lag VAR(`p`) matrix.

Inputs:
- `X_data`: Observation matrix `(n_obs, n_vars)`.
- `p`: VAR lag order (default `1`).
- `n_boot`: Positive integer number of bootstrap resamples (default `500`).
- `confidence`: Confidence level in `(0, 1)` (default `0.95`).
- `block_length`: Optional integer block length (defaults to
  `max(p + 1, ceil(Int, n_obs^(1/3)))`).
- `rng`: Random number generator.

Outputs:
Named tuple `(estimate, interval, bootstrap_samples, confidence, block_length,
n_failed_resamples)`.
"""
function bootstrap_var_asymmetry(X_data::AbstractMatrix{<:Real};
                                 p::Int=1,
                                 n_boot::Int=500,
                                 confidence::Real=0.95,
                                 block_length::Union{Nothing,Int}=nothing,
                                 rng::AbstractRNG=Random.default_rng())
    n_boot > 0 || throw(ArgumentError("n_boot must be positive"))
    0 < confidence < 1 ||
        throw(ArgumentError("confidence must lie strictly between 0 and 1"))
    n_obs, n_vars = size(X_data)
    point_est = matrix_asymmetry(fit_var(X_data; p=p).lags[1]).A_F
    blk = isnothing(block_length) ? max(p + 1, ceil(Int, n_obs^(1 / 3))) : block_length
    1 <= blk <= n_obs ||
        throw(ArgumentError("block_length must be between 1 and n_obs"))

    samples = Float64[]
    failed = 0
    for _ in 1:n_boot
        resampled = Matrix{Float64}(undef, n_obs, n_vars)
        row_cursor = 1
        while row_cursor <= n_obs
            start_idx = rand(rng, 1:(n_obs - blk + 1))
            len = min(blk, n_obs - row_cursor + 1)
            resampled[row_cursor:(row_cursor + len - 1), :] .=
                X_data[start_idx:(start_idx + len - 1), :]
            row_cursor += len
        end
        try
            push!(samples, matrix_asymmetry(fit_var(resampled; p=p).lags[1]).A_F)
        catch err
            err isa ArgumentError || rethrow()
            failed += 1
        end
    end
    length(samples) >= 2 ||
        throw(ArgumentError("fewer than two full-rank bootstrap resamples succeeded"))
    tail = (1.0 - Float64(confidence)) / 2.0
    interval = (lower = quantile(samples, tail), upper = quantile(samples, 1.0 - tail))
    return (
        estimate = point_est,
        interval = interval,
        bootstrap_samples = samples,
        confidence = Float64(confidence),
        block_length = blk,
        n_failed_resamples = failed,
    )
end

# ==================================================================
# 5. Physical Thermal & Reversible Reaction Models (Sections 5.1-5.3)
# ==================================================================

"""
    ThermalTwoMode(; T=300.0, C_heat=[1.0, 2.0], G_bath=[0.5, 0.25], G_m=0.75)

Parameter structure for the closed-form physical two-mode thermal network
(Paper Section 5.1, eqs. 32a-32b). Two compartments with heat capacities
``C_1, C_2`` (``\\mathrm{J\\,K^{-1}}``) at bath temperature ``T`` (``\\mathrm{K}``)
exchange heat with a bath through conductances ``G_1, G_2`` (``\\mathrm{W\\,K^{-1}}``)
and with each other through mutual conductance ``G_m`` (``\\mathrm{W\\,K^{-1}}``).
"""
struct ThermalTwoMode
    T::Float64
    C_heat::Vector{Float64}
    G_bath::Vector{Float64}
    G_m::Float64

    function ThermalTwoMode(; T::Real=300.0,
                            C_heat::AbstractVector{<:Real}=[1.0, 2.0],
                            G_bath::AbstractVector{<:Real}=[0.5, 0.25],
                            G_m::Real=0.75)
        cap = Float64.(C_heat)
        cond = Float64.(G_bath)
        length(cap) == 2 ||
            throw(ArgumentError("C_heat must have exactly two entries"))
        length(cond) == 2 ||
            throw(ArgumentError("G_bath must have exactly two entries"))
        isfinite(T) && T > 0 ||
            throw(ArgumentError("bath temperature T must be finite and positive"))
        all(isfinite, cap) && all(>(0), cap) ||
            throw(ArgumentError("C_heat entries must be finite and positive"))
        all(isfinite, cond) && all(>(0), cond) ||
            throw(ArgumentError("G_bath entries must be finite and positive"))
        isfinite(G_m) && G_m > 0 ||
            throw(ArgumentError("mutual conductance G_m must be finite and positive"))
        new(Float64(T), cap, cond, Float64(G_m))
    end
end

"""
    thermal_network_matrices(model; kappa=0.0, noise_scale=1.0)

Return the exact analytical matrices of the `ThermalTwoMode` network in energy
deviation coordinates ``\\mathbf{x} = (\\delta E_1, \\delta E_2)^{\\mathsf{T}}``:

```math
\\mathbf{A} = \\begin{bmatrix} -(G_1 + G_m)/C_1 & G_m/C_2 + \\kappa \\\\ G_m/C_1 - \\kappa & -(G_2 + G_m)/C_2 \\end{bmatrix},
\\qquad
\\mathbf{L} = T^2 \\begin{bmatrix} G_1 + G_m & -G_m \\\\ -G_m & G_2 + G_m \\end{bmatrix}.
```

Inputs:
- `model`: `ThermalTwoMode` instance.
- `kappa`: Optional skew-symmetric driving frequency ``\\kappa`` (``\\mathrm{s^{-1}}``).
- `noise_scale`: Dimensionless multiplier ``\\alpha > 0`` applied to the thermal
  diffusion matrix ``\\mathbf{D} = \\alpha k_{\\mathrm{B}}\\mathbf{L}``.

Outputs:
Named tuple `(A, L, H, C, D, K_cov, Omega, sigma)`.
"""
function thermal_network_matrices(model::ThermalTwoMode;
                                  kappa::Real=0.0,
                                  noise_scale::Real=1.0)
    isfinite(kappa) || throw(ArgumentError("kappa must be finite"))
    isfinite(noise_scale) && noise_scale > 0 ||
        throw(ArgumentError("noise_scale must be finite and positive"))

    T = model.T
    C1, C2 = model.C_heat
    G1, G2 = model.G_bath
    Gm = model.G_m

    A_eq = [-(G1 + Gm) / C1    Gm / C2;
             Gm / C1          -(G2 + Gm) / C2]
    A = iszero(kappa) ? A_eq : A_eq + [0.0 Float64(kappa); -Float64(kappa) 0.0]
    L = (T^2) .* [G1 + Gm  -Gm;
                  -Gm       G2 + Gm]
    H = Matrix(Diagonal(1.0 ./ (model.C_heat .* (T^2))))
    D = Float64(noise_scale) * k_B .* L
    C = iszero(kappa) && noise_scale == 1.0 ?
        Matrix(k_B * (T^2) .* Diagonal(model.C_heat)) :
        Matrix(solve_lyapunov_covariance(A, D))
    decomp = decompose_covariance_weighted_drift(A, C; D=D, scale=k_B)

    return (
        A = A,
        L = L,
        H = H,
        C = C,
        D = D,
        K_cov = decomp.K_cov,
        Omega = decomp.Omega,
        sigma = decomp.sigma,
    )
end

"""
    replicate_thermal_study(model; n_replicates=200, dt=0.02, n_steps=50_000,
                            seed=20261027, kappa=0.0, noise_scale=1.0)

Run `n_replicates` independent stationary Ornstein-Uhlenbeck trajectories of
`model` and summarize the reciprocity difference ``\\widehat{L}_{12} - \\widehat{L}_{21}``,
its standard error, reciprocity ``z``-score, mean estimated entropy production
``\\widehat{\\sigma}``, and mean Lyapunov residual.
"""
function replicate_thermal_study(model::ThermalTwoMode;
                                 n_replicates::Integer=200,
                                 dt::Real=0.02,
                                 n_steps::Integer=50_000,
                                 seed::Integer=20261027,
                                 kappa::Real=0.0,
                                 noise_scale::Real=1.0)
    n_replicates >= 2 ||
        throw(ArgumentError("n_replicates must be at least 2"))
    mats = thermal_network_matrices(model; kappa=kappa, noise_scale=noise_scale)
    L12_vec = Float64[]
    L21_vec = Float64[]
    sigma_vec = Float64[]
    res_vec = Float64[]
    for rep in 1:n_replicates
        rng = MersenneTwister(seed + 2 * rep)
        X_data = simulate_ou_process(
            mats.A, mats.D; dt=dt, n_steps=n_steps, C=mats.C, rng=rng)
        est = estimate_ou_onsager(X_data; dt=dt, scale=k_B)
        push!(L12_vec, est.L_x[1, 2])
        push!(L21_vec, est.L_x[2, 1])
        push!(sigma_vec, est.sigma)
        push!(res_vec, est.lyapunov_residual)
    end
    diffs = L12_vec .- L21_vec
    se = std(diffs) / sqrt(length(diffs))
    return (
        mean_L12 = mean(L12_vec),
        mean_L21 = mean(L21_vec),
        mean_diff = mean(diffs),
        se_diff = se,
        reciprocity_z = mean(diffs) / se,
        mean_sigma = mean(sigma_vec),
        mean_lyapunov_residual = mean(res_vec),
        n_replicates = Int(n_replicates),
    )
end

"""
    equilibrium_occupancy_fraction(Delta_G, T=298.15)

Compute the equilibrium occupied site fraction for molar free-energy gap
``\\Delta G`` (``\\mathrm{J\\,mol^{-1}}``) at absolute temperature ``T`` (``\\mathrm{K}``):

```math
p_{\\mathrm{occ}} = \\frac{1}{1 + \\exp(\\Delta G / (RT))}.
```
"""
function equilibrium_occupancy_fraction(Delta_G::Real, T::Real=298.15)
    isfinite(Delta_G) || throw(ArgumentError("Delta_G must be finite"))
    isfinite(T) && T > 0 || throw(ArgumentError("T must be finite and positive"))
    x = Float64(Delta_G) / (R_GAS * Float64(T))
    return x >= 0 ? exp(-x) / (1.0 + exp(-x)) : inv(1.0 + exp(x))
end

"""
    exact_two_pathway_conductivity(kappa, c_s; Delta_G=0.0, T=298.15)

Evaluate the exact near-equilibrium process conductivity matrix ``\\mathbf{L}``
(eq. 35) for a two-pathway reversible site model with per-site baseline rate
constants ``\\boldsymbol{\\kappa} = (\\kappa_1, \\kappa_2)^{\\mathsf{T}}`` (``\\mathrm{s^{-1}}``)
and molar site concentration ``c_s`` (``\\mathrm{mol\\,m^{-3}}``):

```math
\\mathbf{L} = \\frac{c_s}{2R}\\operatorname{sech}\\!\\left(\\frac{\\Delta G}{2RT}\\right)
\\left[\\operatorname{Diag}(\\boldsymbol{\\kappa}) -
\\frac{\\boldsymbol{\\kappa}\\boldsymbol{\\kappa}^{\\mathsf{T}}}{\\kappa_1 + \\kappa_2}\\right].
```
"""
function exact_two_pathway_conductivity(kappa::AbstractVector{<:Real},
                                        c_s::Real;
                                        Delta_G::Real=0.0,
                                        T::Real=298.15)
    length(kappa) == 2 ||
        throw(DimensionMismatch("kappa must contain exactly two channel rate constants"))
    all(isfinite, kappa) && all(>(0), kappa) ||
        throw(ArgumentError("kappa entries must be finite and positive"))
    isfinite(c_s) && c_s > 0 ||
        throw(ArgumentError("c_s must be finite and positive"))
    isfinite(Delta_G) ||
        throw(ArgumentError("Delta_G must be finite"))
    isfinite(T) && T > 0 ||
        throw(ArgumentError("T must be finite and positive"))

    rates = Float64.(kappa)
    scaled_gap = Float64(Delta_G) / (2.0 * R_GAS * Float64(T))
    isfinite(scaled_gap) && isfinite(cosh(scaled_gap)) ||
        throw(ArgumentError("Delta_G / (2RT) is outside finite numerical range"))
    prefactor = Float64(c_s) / (2.0 * R_GAS * cosh(scaled_gap))
    return prefactor .* (Diagonal(rates) - (rates * transpose(rates)) / sum(rates))
end

"""
    simulate_channel_current_density(X, kappa; N_sites, c_s, burn_in, T_obs,
                                     Delta_G=0.0, T=298.15,
                                     initial_occupied_sites=nothing,
                                     rng=Random.default_rng())

Simulate a continuous-time reversible Markov jump process on `N_sites`
independent two-state binding sites with transition rates obeying local
detailed balance (eq. 34):

```math
k_r^+ = \\kappa_r \\exp\\!\\left(\\frac{X_r}{2R} - \\frac{\\Delta G}{2RT}\\right),
\\qquad
k_r^- = \\kappa_r \\exp\\!\\left(-\\frac{X_r}{2R} + \\frac{\\Delta G}{2RT}\\right).
```

Inputs:
- `X`: Molar thermodynamic force vector ``\\mathbf{X}`` (``\\mathrm{J\\,mol^{-1}\\,K^{-1}}``).
- `kappa`: Per-site channel rate constants ``\\boldsymbol{\\kappa}`` (``\\mathrm{s^{-1}}``).
- `N_sites`: Positive integer number of binding sites.
- `c_s`: Molar site concentration (``\\mathrm{mol\\,m^{-3}}``).
- `burn_in`: Nonnegative burn-in duration (``\\mathrm{s}``).
- `T_obs`: Positive measurement window duration (``\\mathrm{s}``).
- `Delta_G`: Occupied-minus-vacant molar free-energy gap (``\\mathrm{J\\,mol^{-1}}``).
- `T`: Absolute temperature (``\\mathrm{K}``).
- `initial_occupied_sites`: Optional starting occupied-site count in `0:N_sites`.
- `rng`: Random number generator.

Outputs:
Named tuple `(J, net_events, final_occupied_sites)` where `J` is the molar
flux density vector (``\\mathrm{mol\\,m^{-3}\\,s^{-1}}``).
"""
function simulate_channel_current_density(
    X::AbstractVector{<:Real},
    kappa::AbstractVector{<:Real};
    N_sites::Integer,
    c_s::Real,
    burn_in::Real,
    T_obs::Real,
    Delta_G::Real=0.0,
    T::Real=298.15,
    initial_occupied_sites::Union{Nothing,Integer}=nothing,
    rng::AbstractRNG=Random.default_rng(),
)
    r_count = length(kappa)
    r_count > 0 || throw(ArgumentError("at least one channel is required"))
    length(X) == r_count ||
        throw(DimensionMismatch("X and kappa must have equal lengths"))
    N_sites > 0 || throw(ArgumentError("N_sites must be positive"))
    all(isfinite, X) && all(isfinite, kappa) && all(>(0), kappa) ||
        throw(ArgumentError("X must be finite and kappa must be finite and positive"))
    isfinite(c_s) && c_s > 0 ||
        throw(ArgumentError("c_s must be finite and positive"))
    isfinite(burn_in) && burn_in >= 0 ||
        throw(ArgumentError("burn_in must be finite and nonnegative"))
    isfinite(T_obs) && T_obs > 0 ||
        throw(ArgumentError("T_obs must be finite and positive"))
    isfinite(Delta_G) || throw(ArgumentError("Delta_G must be finite"))
    isfinite(T) && T > 0 || throw(ArgumentError("T must be finite and positive"))
    isnothing(initial_occupied_sites) ||
        0 <= initial_occupied_sites <= N_sites ||
        throw(ArgumentError("initial_occupied_sites must lie in 0:N_sites"))

    gap_term = Float64(Delta_G) / (2.0 * R_GAS * Float64(T))
    k_plus = Float64.(kappa) .* exp.(Float64.(X) ./ (2.0 * R_GAS) .- gap_term)
    k_minus = Float64.(kappa) .* exp.(-Float64.(X) ./ (2.0 * R_GAS) .+ gap_term)
    all(isfinite, k_plus) && all(isfinite, k_minus) &&
        all(>(0), k_plus) && all(>(0), k_minus) ||
        throw(ArgumentError("channel transition rates overflowed or underflowed"))

    total_horizon = Float64(burn_in + T_obs)
    isfinite(total_horizon) || throw(ArgumentError("total simulation time overflowed"))

    p_eq = equilibrium_occupancy_fraction(Delta_G, T)
    occupied = isnothing(initial_occupied_sites) ?
        count(_ -> rand(rng) < p_eq, 1:N_sites) :
        Int(initial_occupied_sites)

    net_events = zeros(Int, r_count)
    sum_plus = sum(k_plus)
    sum_minus = sum(k_minus)
    t = 0.0

    while t < total_horizon
        vacant = N_sites - occupied
        fwd_prop = vacant * sum_plus
        rev_prop = occupied * sum_minus
        tot_prop = fwd_prop + rev_prop
        tot_prop > 0 || break
        isfinite(tot_prop) || throw(ArgumentError("total propensity overflowed"))

        dt_wait = randexp(rng) / tot_prop
        t + dt_wait <= total_horizon || break
        t += dt_wait
        u = rand(rng) * tot_prop

        if u < fwd_prop
            thresh = u / vacant
            acc = 0.0
            chosen = 0
            for ch in 1:r_count
                acc += k_plus[ch]
                if thresh < acc
                    chosen = ch
                    break
                end
            end
            chosen > 0 || error("failed to select forward reaction channel")
            occupied += 1
            if t >= burn_in
                net_events[chosen] += 1
            end
        else
            thresh = (u - fwd_prop) / occupied
            acc = 0.0
            chosen = 0
            for ch in 1:r_count
                acc += k_minus[ch]
                if thresh < acc
                    chosen = ch
                    break
                end
            end
            chosen > 0 || error("failed to select reverse reaction channel")
            occupied -= 1
            if t >= burn_in
                net_events[chosen] -= 1
            end
        end
    end

    J = Float64(c_s) .* net_events ./ (N_sites * Float64(T_obs))
    return (J = J, net_events = net_events, final_occupied_sites = occupied)
end

"""
    estimate_two_pathway_conductivity(kappa; N_sites=1000, c_s=0.2, n_replicates=4,
                                      burn_in=2.0, T_obs=400.0, Delta_G=0.0,
                                      T=298.15, delta_X=1.0, seed=20261027)

Estimate the ``2 \\times 2`` process conductivity matrix ``\\widehat{\\mathbf{L}}``
by central finite differences of Gillespie-simulated stationary currents (eq. 36):

```math
\\widehat{L}_{rs} = \\frac{\\widehat{J}_r(+\\delta X_s) - \\widehat{J}_r(-\\delta X_s)}{2\\delta X_s}.
```

Outputs:
Named tuple `(L, standard_errors, delta_X, n_replicates, Delta_G, T)`.
"""
function estimate_two_pathway_conductivity(
    kappa::AbstractVector{<:Real};
    N_sites::Integer=1000,
    c_s::Real=0.2,
    n_replicates::Integer=4,
    burn_in::Real=2.0,
    T_obs::Real=400.0,
    Delta_G::Real=0.0,
    T::Real=298.15,
    delta_X::Real=1.0,
    seed::Integer=20261027,
)
    length(kappa) == 2 ||
        throw(DimensionMismatch("two-pathway model requires exactly two channels"))
    n_replicates >= 2 ||
        throw(ArgumentError("n_replicates must be at least 2"))
    isfinite(delta_X) && delta_X > 0 ||
        throw(ArgumentError("delta_X must be finite and positive"))

    L_est = Matrix{Float64}(undef, 2, 2)
    SE_est = Matrix{Float64}(undef, 2, 2)

    for s_idx in 1:2
        J_pos = Matrix{Float64}(undef, n_replicates, 2)
        J_neg = Matrix{Float64}(undef, n_replicates, 2)
        for rep in 1:n_replicates
            X_pos = zeros(2)
            X_neg = zeros(2)
            X_pos[s_idx] = Float64(delta_X)
            X_neg[s_idx] = -Float64(delta_X)
            seed_pos = seed + 2 * ((s_idx - 1) * n_replicates + rep - 1)
            seed_neg = seed_pos + 1
            res_pos = simulate_channel_current_density(
                X_pos, kappa; N_sites=N_sites, c_s=c_s, burn_in=burn_in,
                T_obs=T_obs, Delta_G=Delta_G, T=T, rng=MersenneTwister(seed_pos))
            res_neg = simulate_channel_current_density(
                X_neg, kappa; N_sites=N_sites, c_s=c_s, burn_in=burn_in,
                T_obs=T_obs, Delta_G=Delta_G, T=T, rng=MersenneTwister(seed_neg))
            J_pos[rep, :] .= res_pos.J
            J_neg[rep, :] .= res_neg.J
        end
        mean_pos = vec(mean(J_pos; dims=1))
        mean_neg = vec(mean(J_neg; dims=1))
        var_pos = vec(var(J_pos; dims=1))
        var_neg = vec(var(J_neg; dims=1))
        L_est[:, s_idx] .= (mean_pos .- mean_neg) ./ (2.0 * Float64(delta_X))
        SE_est[:, s_idx] .= sqrt.((var_pos .+ var_neg) ./ n_replicates) ./
                            (2.0 * Float64(delta_X))
    end

    return (
        L = L_est,
        standard_errors = SE_est,
        delta_X = Float64(delta_X),
        n_replicates = Int(n_replicates),
        Delta_G = Float64(Delta_G),
        T = Float64(T),
    )
end

"""
    simulate_evolving_conductivity(; n_epochs=12, epoch_duration=200.0, T_obs=40.0,
                                   N_sites=600, c_s=0.2, n_replicates=3, burn_in=2.0,
                                   kappa_0=2.5, T=298.15, energy_scale=1.0,
                                   theta_0=-0.8, theta_star=0.8, s=0.05,
                                   sigma_theta=0.005, delta_X=1.0, seed=20261028)

Simulate a fast-slow evolutionary hierarchy (Paper Section 5.3, eq. 38) where
fast reversible site switching (mixing time ``\\tau_{\\mathrm{mix}}``) is nested
within slow Ornstein-Uhlenbeck evolution of a trait ``\\theta_k`` across
epochs:

```math
\\theta_{k+1} = \\theta_k + s(\\theta_* - \\theta_k) + \\sigma_\\theta \\xi_k,
\\qquad
\\boldsymbol{\\kappa}(\\theta_k) = \\kappa_0 (e^{\\theta_k}, e^{-\\theta_k})^{\\mathsf{T}},
\\qquad
\\Delta G(\\theta_k) = RT \\cdot \\text{energy\\_scale} \\cdot \\theta_k.
```

Outputs:
Named tuple `(epoch, elapsed_time, theta, p_occ, p_occ_eq, kappa, L_hat,
L_exact, standard_errors, epoch_duration, T_obs)`.
"""
function simulate_evolving_conductivity(
    ; n_epochs::Integer=12,
    epoch_duration::Real=200.0,
    T_obs::Real=40.0,
    N_sites::Integer=600,
    c_s::Real=0.2,
    n_replicates::Integer=3,
    burn_in::Real=2.0,
    kappa_0::Real=2.5,
    T::Real=298.15,
    energy_scale::Real=1.0,
    theta_0::Real=-0.8,
    theta_star::Real=0.8,
    s::Real=0.05,
    sigma_theta::Real=0.005,
    delta_X::Real=1.0,
    seed::Integer=20261028,
)
    n_epochs > 0 || throw(ArgumentError("n_epochs must be positive"))
    isfinite(epoch_duration) && epoch_duration > 0 ||
        throw(ArgumentError("epoch_duration must be finite and positive"))
    isfinite(T_obs) && T_obs > 0 && T_obs < epoch_duration ||
        throw(ArgumentError("T_obs must be positive and shorter than epoch_duration"))
    isfinite(kappa_0) && kappa_0 > 0 ||
        throw(ArgumentError("kappa_0 must be finite and positive"))
    isfinite(T) && T > 0 ||
        throw(ArgumentError("T must be finite and positive"))
    isfinite(energy_scale) ||
        throw(ArgumentError("energy_scale must be finite"))
    isfinite(theta_0) && isfinite(theta_star) ||
        throw(ArgumentError("theta_0 and theta_star must be finite"))
    0 <= s <= 1 ||
        throw(ArgumentError("selection strength s must lie in [0, 1]"))
    isfinite(sigma_theta) && sigma_theta >= 0 ||
        throw(ArgumentError("sigma_theta must be finite and nonnegative"))

    fast_rng = MersenneTwister(seed)
    trait_rng = MersenneTwister(seed + 1)
    theta = Float64(theta_0)
    occupied_sites = nothing

    theta_hist = Float64[]
    p_occ_hist = Float64[]
    p_occ_eq_hist = Float64[]
    kappa_hist = Vector{Float64}[]
    L_hat_hist = Matrix{Float64}[]
    L_exact_hist = Matrix{Float64}[]
    se_hist = Matrix{Float64}[]

    for ep in 1:n_epochs
        kappa_vec = Float64(kappa_0) .* exp.([theta, -theta])
        all(isfinite, kappa_vec) && all(>(0), kappa_vec) ||
            throw(ArgumentError("trait theta produced nonfinite or nonpositive rates"))
        Delta_G = R_GAS * Float64(T) * Float64(energy_scale) * theta
        p_eq = equilibrium_occupancy_fraction(Delta_G, T)
        if isnothing(occupied_sites)
            occupied_sites = count(_ -> rand(fast_rng) < p_eq, 1:N_sites)
        end

        baseline = simulate_channel_current_density(
            zeros(2), kappa_vec; N_sites=N_sites, c_s=c_s, burn_in=0.0,
            T_obs=epoch_duration, Delta_G=Delta_G, T=T,
            initial_occupied_sites=occupied_sites, rng=fast_rng)
        occupied_sites = baseline.final_occupied_sites

        ep_seed = seed + 1000 * ep
        est = estimate_two_pathway_conductivity(
            kappa_vec; N_sites=N_sites, c_s=c_s, n_replicates=n_replicates,
            burn_in=burn_in, T_obs=T_obs, Delta_G=Delta_G, T=T,
            delta_X=delta_X, seed=ep_seed)

        push!(theta_hist, theta)
        push!(p_occ_hist, occupied_sites / N_sites)
        push!(p_occ_eq_hist, p_eq)
        push!(kappa_hist, kappa_vec)
        push!(L_hat_hist, est.L)
        push!(se_hist, est.standard_errors)
        push!(L_exact_hist, exact_two_pathway_conductivity(
            kappa_vec, c_s; Delta_G=Delta_G, T=T))

        theta += Float64(s) * (Float64(theta_star) - theta) +
                 Float64(sigma_theta) * randn(trait_rng)
    end

    return (
        epoch = collect(1:n_epochs),
        elapsed_time = collect(0:(n_epochs - 1)) .* Float64(epoch_duration),
        theta = theta_hist,
        p_occ = p_occ_hist,
        p_occ_eq = p_occ_eq_hist,
        kappa = kappa_hist,
        L_hat = L_hat_hist,
        L_exact = L_exact_hist,
        standard_errors = se_hist,
        epoch_duration = Float64(epoch_duration),
        T_obs = Float64(T_obs),
    )
end

# ==================================================================
# 6. Ecological Network Models & Cone Spring Analysis (Sec 3.3, 5.4)
# ==================================================================

"""
    normalize_biomass(B)

Compute relative biomass fractions ``b_i = B_i / B_{\\mathrm{tot}}`` and total
standing stock ``B_{\\mathrm{tot}} = \\sum_i B_i``.

Inputs:
- `B`: Vector of finite, nonnegative compartment standing stocks with positive
  sum.

Outputs:
Tuple `(b, B_tot)`.
"""
function normalize_biomass(B::AbstractVector{<:Real})
    isempty(B) && throw(ArgumentError("B must not be empty"))
    all(isfinite, B) || throw(ArgumentError("B must contain only finite values"))
    all(>=(0), B) || throw(ArgumentError("B must be nonnegative"))
    B_tot = Float64(sum(B))
    isfinite(B_tot) && B_tot > 0 ||
        throw(ArgumentError("total biomass B_tot must be finite and positive"))
    return Float64.(B) ./ B_tot, B_tot
end

"""
    weighted_interaction_matrix(N, M, A; k=DEFAULT_ALLOMETRIC_K)

Construct the allometrically and biomass-fraction weighted ecological
diagnostic matrices (eq. 40):

```math
\\mathbf{W} = \\operatorname{Diag}(M_i^{-k})\\,\\mathbf{A}\\,\\operatorname{Diag}(b_i),
\\qquad
\\mathbf{W}_B = \\mathbf{A}\\,\\operatorname{Diag}(b_i),
\\qquad
b_i = \\frac{M_i N_i}{\\sum_{j=1}^n M_j N_j}.
```

Inputs:
- `N`: Species abundance vector ``\\mathbf{N}`` (nonnegative).
- `M`: Representative individual body mass vector ``\\mathbf{M}`` (positive).
- `A`: Community interaction matrix ``\\mathbf{A}`` with convention
  ``A_{ij} = \\partial \\dot{B}_i / \\partial B_j``.
- `k`: Allometric mass exponent (default `0.25`).

Outputs:
Named tuple `(W, W_B, b, B_tot, k, A_F, A_F_B)`.
"""
function weighted_interaction_matrix(N::AbstractVector{<:Real},
                                     M::AbstractVector{<:Real},
                                     A::AbstractMatrix{<:Real};
                                     k::Real=DEFAULT_ALLOMETRIC_K)
    n = length(N)
    length(M) == n ||
        throw(DimensionMismatch("N and M must have equal lengths"))
    size(A) == (n, n) ||
        throw(DimensionMismatch("A must be square with size ($n, $n)"))
    all(isfinite, N) && all(isfinite, M) && all(isfinite, A) && isfinite(k) ||
        throw(ArgumentError("N, M, A, and k must be finite"))
    all(>=(0), N) || throw(ArgumentError("abundances N must be nonnegative"))
    all(>(0), M) || throw(ArgumentError("body masses M must be positive"))

    b, B_tot = normalize_biomass(Float64.(M) .* Float64.(N))
    A_mat = Matrix{Float64}(A)
    W_B = A_mat * Diagonal(b)
    W = Diagonal(Float64.(M) .^ (-Float64(k))) * W_B
    all(isfinite, W) ||
        throw(ArgumentError("weighted matrix W overflowed; check M and k scales"))

    return (
        W = W,
        W_B = W_B,
        b = b,
        B_tot = B_tot,
        k = Float64(k),
        A_F = matrix_asymmetry(W).A_F,
        A_F_B = matrix_asymmetry(W_B).A_F,
    )
end

"""
    sensitivity_allometry(N, M, A; exponents=0.20:0.01:0.33)

Evaluate the Frobenius norm ``\\|\\mathbf{W}\\|_F`` and asymmetry
``\\mathcal{A}_F(\\mathbf{W})`` across a range of allometric mass exponents `k`.
"""
function sensitivity_allometry(N::AbstractVector{<:Real},
                               M::AbstractVector{<:Real},
                               A::AbstractMatrix{<:Real};
                               exponents=0.20:0.01:0.33)
    results = Dict{Float64,NamedTuple}()
    for k_val in exponents
        diag_res = weighted_interaction_matrix(N, M, A; k=k_val)
        results[Float64(k_val)] = (
            A_F = diag_res.A_F,
            norm_W = norm(diag_res.W),
        )
    end
    return results
end

"""
    biomass_rate(B, params)

Evaluate the deterministic allometric Lotka-Volterra biomass rate:

```math
\\dot{B}_i = M_i^{-k} B_i \\left(1 - \\frac{B_i}{K_i}\\right) + M_i^{-k} (\\mathbf{A}\\mathbf{B})_i.
```

Inputs:
- `B`: Standing biomass vector ``\\mathbf{B}``.
- `params`: NamedTuple or Dict supplying `:M` (body masses), `:A` (interaction
  matrix), `:K` (carrying capacities, default `fill(Inf, n)`), and `:k`
  (allometric exponent, default `0.25`).
"""
function biomass_rate(B::AbstractVector{<:Real},
                      params::Union{AbstractDict,NamedTuple})
    n = length(B)
    all(isfinite, B) && all(>=(0), B) ||
        throw(ArgumentError("B must be finite and nonnegative"))
    M = haskey(params, :M) ? params[:M] : ones(n)
    A = haskey(params, :A) ? params[:A] : Matrix{Float64}(I, n, n)
    K = haskey(params, :K) ? params[:K] : fill(Inf, n)
    k = haskey(params, :k) ? params[:k] : DEFAULT_ALLOMETRIC_K

    length(M) == n && length(K) == n && size(A) == (n, n) ||
        throw(DimensionMismatch("M, K, and A dimensions must match B"))
    all(isfinite, M) && all(>(0), M) ||
        throw(ArgumentError("M must be finite and positive"))
    all(isfinite, A) && isfinite(k) ||
        throw(ArgumentError("A and k must be finite"))
    all(val -> val > 0 || val == Inf, K) ||
        throw(ArgumentError("carrying capacities K must be positive or Inf"))

    g = M .^ (-k)
    logistic_term = 1.0 .- (B ./ K)
    rates = (g .* B .* logistic_term) .+ (g .* (A * B))
    all(isfinite, rates) ||
        throw(ArgumentError("biomass_rate calculation produced nonfinite values"))
    return rates
end

"""
    biomass_jacobian_diagnostic(B, rate_fn, params)

Compute the exact ForwardDiff Jacobian ``\\mathbf{A} = \\partial \\dot{\\mathbf{B}} / \\partial \\mathbf{B}``
and fraction-weighted matrix ``\\mathbf{W}_B = \\mathbf{A}\\operatorname{Diag}(\\mathbf{b})``
at standing stock vector `B`.
"""
function biomass_jacobian_diagnostic(B::AbstractVector{<:Real},
                                     rate_fn,
                                     params::Union{AbstractDict,NamedTuple})
    b, B_tot = normalize_biomass(B)
    A = ForwardDiff.jacobian(x -> rate_fn(x, params), B)
    size(A) == (length(B), length(B)) ||
        throw(DimensionMismatch("rate_fn must return one rate per state variable"))
    W_B = A * Diagonal(b)
    return (
        A = A,
        W_B = W_B,
        b = b,
        B_tot = B_tot,
        A_F = matrix_asymmetry(W_B).A_F,
    )
end

"""
    cone_spring_network(; s=0.10)

Return the published steady-state energy budget and parameterized community
matrix ``\\mathbf{A}_{\\mathrm{CS}}`` (in ``\\mathrm{yr^{-1}}``) for the Cone
Spring ecosystem (Tilly 1968; Patten 1978; Ulanowicz 1986; de Ruiter et al.
1995; Neutel et al. 2002), corresponding to Table 2 and eq. (22a) of Paper II.

In the three-compartment living heterotrophic food chain (1: Bacteria,
2: Detritivores, 3: Carnivores):
- ``A_{ji} = -F_{ji} / B_i^*`` (direct predator suppression of prey),
- ``A_{ij} = +e_i F_{ji} / B_j^*`` (assimilated prey enhancement of predator),
- ``A_{ii} = -s R_i / B_i^*`` (intraspecific self-damping, default ``s = 0.10``),
- ``\\mathbf{D} = \\operatorname{Diag}(s R_i B_i^*)`` (metabolic fluctuation
  diffusion matrix in ``(\\mathrm{kcal\\,m^{-2}})^2\\,\\mathrm{yr^{-1}}``).

Outputs:
Named tuple `(full_budget, B_star, R, T_flow, e, F, M, N, b, B_tot, s, A, D)`.
"""
function cone_spring_network(; s::Real=0.10)
    isfinite(s) && s > 0 ||
        throw(ArgumentError("self-damping fraction s must be finite and positive"))
    s_val = Float64(s)

    # Full 5-compartment published budget (Table 2: Plants, Detritus, Bacteria,
    # Detritivores, Carnivores)
    full_budget = (
        names = ["Plants", "Detritus", "Bacteria", "Detritivores", "Carnivores"],
        B_star = [285.0, 3580.0, 116.6, 60.0, 17.0],
        z = [11184.0, 635.0, 0.0, 0.0, 0.0],
        inflow_internal = [0.0, 10848.0, 5205.0, 2384.0, 370.0],
        outflow_internal = [8881.0, 7514.0, 1675.0, 570.0, 167.0],
        E = [300.0, 860.0, 255.0, 0.0, 0.0],
        R = [2003.0, 3109.0, 3275.0, 1814.0, 203.0],
        T_flow = [11184.0, 11483.0, 5205.0, 2384.0, 370.0],
    )

    # 3-compartment living heterotrophic food chain (Bacteria, Detritivores,
    # Carnivores)
    B_star = [116.6, 60.0, 17.0]
    R = [3275.0, 1814.0, 203.0]
    T_flow = [5205.0, 2384.0, 370.0]
    e = (T_flow .- R) ./ T_flow

    F = zeros(3, 3)
    F[1, 2] = 75.0
    F[2, 3] = 370.0

    M = [1.0e-6, 1.0e-2, 1.0]
    N = B_star ./ M
    b, B_tot = normalize_biomass(B_star)

    A = zeros(3, 3)
    for i in 1:3
        A[i, i] = -s_val * R[i] / B_star[i]
    end
    A[1, 2] = -F[1, 2] / B_star[2]
    A[2, 1] = e[2] * F[1, 2] / B_star[1]
    A[2, 3] = -F[2, 3] / B_star[3]
    A[3, 2] = e[3] * F[2, 3] / B_star[2]

    D = Matrix(Diagonal(s_val .* R .* B_star))

    return (
        full_budget = full_budget,
        B_star = B_star,
        R = R,
        T_flow = T_flow,
        e = e,
        F = F,
        M = M,
        N = N,
        b = b,
        B_tot = B_tot,
        s = s_val,
        A = A,
        D = D,
    )
end

"""
    analyze_cone_spring(; s=0.10, dt=0.01, n_obs=20_000, k=DEFAULT_ALLOMETRIC_K,
                        seed=20261026)

Perform the complete analytical and stochastic Lyapunov decomposition of the
published Cone Spring community matrix (Sections 3.3 and 5.4, Table 5):
- Evaluates the naive equilibrium capacity-weighted matrix
  ``-\\mathbf{A}_{\\mathrm{CS}}\\operatorname{Diag}(\\mathbf{B}^*)`` and its
  indefinite symmetric eigenvalue spectrum (eqs. 22b-22c).
- Solves the continuous Lyapunov equation ``\\mathbf{A}_{\\mathrm{CS}}\\mathbf{C}_{\\mathrm{CS}} + \\mathbf{C}_{\\mathrm{CS}}\\mathbf{A}_{\\mathrm{CS}}^{\\mathsf{T}} + 2\\mathbf{D}_{\\mathrm{CS}} = \\mathbf{0}``
  for the stationary covariance ``\\mathbf{C}_{\\mathrm{CS}}`` (eq. 39b).
- Decomposes ``\\mathbf{K}_{\\mathrm{cov,CS}} = -\\mathbf{A}_{\\mathrm{CS}}\\mathbf{C}_{\\mathrm{CS}} = \\mathbf{D}_{\\mathrm{CS}} - \\boldsymbol{\\Omega}_{\\mathrm{CS}}``
  into strictly positive-definite metabolic dissipation ``\\mathbf{D}_{\\mathrm{CS}}``
  and skew-symmetric trophic circulation ``-\\boldsymbol{\\Omega}_{\\mathrm{CS}}`` (eq. 39c).
- Evaluates allometric weighting ``\\mathbf{W}`` and sensitivity across
  ``k \\in [0.20, 0.33]``.
- Simulates a stationary trajectory of length `n_obs` at sampling interval `dt`
  and recovers ``\\widehat{\\mathbf{K}}_{\\mathrm{cov,CS}}`` via `estimate_ou_onsager`.
"""
function analyze_cone_spring(
    ; s::Real=0.10,
    dt::Real=0.01,
    n_obs::Integer=20_000,
    k::Real=DEFAULT_ALLOMETRIC_K,
    seed::Integer=20261026,
)
    net = cone_spring_network(; s=s)
    A = net.A
    D = net.D
    B_star = net.B_star

    # Ideal capacity weighting -A * Diag(B^*)
    L_naive = -A * Diagonal(B_star)
    L_naive_sym_eigs = eigvals(Symmetric(0.5 .* (L_naive .+ transpose(L_naive))))

    # Allometric and biomass-fraction diagnostics
    w_diag = weighted_interaction_matrix(net.N, net.M, A; k=k)
    W_B_sym_eigs = eigvals(Symmetric(-0.5 .* (w_diag.W_B .+ transpose(w_diag.W_B))))
    allom_sens = sensitivity_allometry(net.N, net.M, A)

    # Exact Lyapunov covariance and decomposition
    C = Matrix(solve_lyapunov_covariance(A, D))
    exact_decomp = decompose_covariance_weighted_drift(A, C; D=D, scale=1.0)

    # Time-series simulation and estimation
    rng = MersenneTwister(seed)
    X_data = simulate_ou_process(A, D; dt=dt, n_steps=n_obs - 1, C=C, rng=rng)
    est = estimate_ou_onsager(X_data; dt=dt, scale=1.0)
    rel_error_K = norm(est.K_cov - exact_decomp.K_cov) / norm(exact_decomp.K_cov)

    return (
        network = net,
        eigenvalues_A = eigvals(A),
        A_F_A = matrix_asymmetry(A).A_F,
        L_naive = L_naive,
        A_F_naive = matrix_asymmetry(L_naive).A_F,
        L_naive_sym_eigs = L_naive_sym_eigs,
        W = w_diag.W,
        W_B = w_diag.W_B,
        A_F_W = w_diag.A_F,
        A_F_WB = w_diag.A_F_B,
        min_eig_neg_sym_WB = minimum(W_B_sym_eigs),
        allometric_sensitivity = allom_sens,
        C = C,
        D = D,
        K_cov = exact_decomp.K_cov,
        Omega = exact_decomp.Omega,
        A_F_K_cov = exact_decomp.A_F,
        min_sym_eig_K_cov = exact_decomp.min_sym_eig,
        circulation_rate = exact_decomp.circulation_rate,
        estimate = est,
        rel_error_K_cov = rel_error_K,
    )
end

# ==================================================================
# 7. Stochastic Demographic Gillespie Jump Model (Equation 41)
# ==================================================================

"""
    PopulationJumpParams(; r, d, c, gamma, M, V, epsilon, k=DEFAULT_ALLOMETRIC_K)

Parameter structure for the exact continuous-time demographic birth-death-
competition-predation Markov jump process in physical volume ``\\mathcal{V}``
(eq. 41):

```math
\\lambda_i^{\\mathrm{birth}} = r_i M_i^{-k} N_i,
\\qquad
\\lambda_i^{\\mathrm{death}} = d_i N_i + \\frac{c_i}{\\mathcal{V}} N_i (N_i - 1),
\\qquad
\\lambda_{ij}^{\\mathrm{pred}} = \\frac{\\gamma_{ij}}{\\mathcal{V}} M_i^{-k} N_i N_j.
```

A predation event by predator `i` on prey `j` adds ``+1`` individual of species
`i` and removes ``\\max(1, \\lceil M_i / (\\epsilon M_j) \\rceil)`` individuals of
species `j`.
"""
struct PopulationJumpParams
    n_species::Int
    r::Vector{Float64}
    d::Vector{Float64}
    c::Vector{Float64}
    gamma::Matrix{Float64}
    M::Vector{Float64}
    V::Float64
    epsilon::Float64
    k::Float64

    function PopulationJumpParams(; r::AbstractVector{<:Real},
                                  d::AbstractVector{<:Real},
                                  c::AbstractVector{<:Real},
                                  gamma::AbstractMatrix{<:Real},
                                  M::AbstractVector{<:Real},
                                  V::Real,
                                  epsilon::Real,
                                  k::Real=DEFAULT_ALLOMETRIC_K)
        n = length(r)
        n > 0 || throw(ArgumentError("at least one species is required"))
        length(d) == n && length(c) == n && length(M) == n ||
            throw(DimensionMismatch("r, d, c, and M must have equal length"))
        size(gamma) == (n, n) ||
            throw(DimensionMismatch("gamma must be an $n by $n matrix"))

        r_f = Float64.(r)
        d_f = Float64.(d)
        c_f = Float64.(c)
        gamma_f = Matrix{Float64}(gamma)
        M_f = Float64.(M)
        V_f = Float64(V)
        eps_f = Float64(epsilon)
        k_f = Float64(k)

        all(isfinite, r_f) && all(isfinite, d_f) && all(isfinite, c_f) &&
            all(isfinite, gamma_f) && all(isfinite, M_f) &&
            isfinite(V_f) && isfinite(eps_f) && isfinite(k_f) ||
            throw(ArgumentError("all parameters must be finite"))
        all(>=(0), r_f) && all(>=(0), d_f) && all(>=(0), c_f) &&
            all(>=(0), gamma_f) && k_f >= 0 ||
            throw(ArgumentError("rates r, d, c, gamma and exponent k must be nonnegative"))
        all(>(0), M_f) && V_f > 0 && 0 < eps_f <= 1 ||
            throw(ArgumentError("M and V must be positive and epsilon must lie in (0, 1]"))

        for i in 1:n, j in 1:n
            ratio = M_f[i] / (eps_f * M_f[j])
            isfinite(ratio) && ratio <= typemax(Int) ||
                throw(ArgumentError("predation mass ratio exceeds integer capacity"))
        end
        new(n, r_f, d_f, c_f, gamma_f, M_f, V_f, eps_f, k_f)
    end
end

"""
    biomass_density(N, params)

Return the standing biomass density ``B_i / \\mathcal{V} = M_i N_i / \\mathcal{V}``
for integer abundance vector `N`.
"""
function biomass_density(N::AbstractVector{<:Integer},
                         params::PopulationJumpParams)
    dens = (params.M .* Float64.(N)) ./ params.V
    all(isfinite, dens) || throw(ArgumentError("biomass density overflowed"))
    return dens
end

function demographic_propensities(N::AbstractVector{<:Integer},
                                  params::PopulationJumpParams)
    length(N) == params.n_species ||
        throw(DimensionMismatch("N must have n_species entries"))
    all(>=(0), N) || throw(ArgumentError("abundances N must be nonnegative"))

    props = Float64[]
    stoich = Vector{Vector{Int}}()
    n = params.n_species

    for i in 1:n
        push!(props, params.r[i] * params.M[i]^(-params.k) * Float64(N[i]))
        delta = zeros(Int, n)
        delta[i] = 1
        push!(stoich, delta)
    end
    for i in 1:n
        if N[i] > 0
            ni = Float64(N[i])
            prop = params.d[i] * ni + (params.c[i] / params.V) * ni * (ni - 1.0)
            push!(props, prop)
            delta = zeros(Int, n)
            delta[i] = -1
            push!(stoich, delta)
        end
    end
    for i in 1:n, j in 1:n
        g_ij = params.gamma[i, j]
        if i != j && g_ij > 0 && N[i] > 0 && N[j] > 0
            prey_needed = max(1, ceil(Int, params.M[i] / (params.epsilon * params.M[j])))
            if N[j] >= prey_needed
                prop = (g_ij / params.V) * params.M[i]^(-params.k) *
                       Float64(N[i]) * Float64(N[j])
                push!(props, prop)
                delta = zeros(Int, n)
                delta[i] = 1
                delta[j] = -prey_needed
                push!(stoich, delta)
            end
        end
    end
    return props, stoich
end

"""
    run_gillespie_population(N_0, params, t_end; max_events=1_000_000,
                             rng=Random.default_rng())

Simulate the exact demographic jump process from initial count vector `N_0` up
to horizon `t_end`, preserving exact integer stoichiometry without negative
counts or range truncation.

Outputs:
Named tuple `(time, N_history, biomass_density, event_count, stop_reason)`.
"""
function run_gillespie_population(N_0::AbstractVector{<:Integer},
                                  params::PopulationJumpParams,
                                  t_end::Real;
                                  max_events::Int=1_000_000,
                                  rng::AbstractRNG=Random.default_rng())
    isfinite(t_end) && t_end >= 0 ||
        throw(ArgumentError("t_end must be finite and nonnegative"))
    max_events >= 0 || throw(ArgumentError("max_events must be nonnegative"))
    length(N_0) == params.n_species ||
        throw(DimensionMismatch("N_0 must have n_species entries"))
    all(>=(0), N_0) || throw(ArgumentError("N_0 must be nonnegative"))

    t = 0.0
    N = Int.(N_0)
    t_hist = Float64[t]
    N_hist = [copy(N)]
    dens_hist = [biomass_density(N, params)]
    ev_count = 0
    reason = :end_time

    while t < t_end
        if ev_count >= max_events
            reason = :max_events
            break
        end
        props, stoich = demographic_propensities(N, params)
        all(val -> isfinite(val) && val >= 0, props) ||
            throw(ArgumentError("event propensities must be finite and nonnegative"))
        tot_prop = sum(props)
        isfinite(tot_prop) || throw(ArgumentError("total propensity overflowed"))
        if tot_prop == 0
            reason = :no_active_events
            break
        end

        dt_wait = randexp(rng) / tot_prop
        t + dt_wait <= t_end || break
        thresh = rand(rng) * tot_prop
        acc = 0.0
        chosen = 0
        for idx in eachindex(props)
            acc += props[idx]
            if thresh < acc
                chosen = idx
                break
            end
        end
        chosen > 0 || error("failed to select jump event from positive propensities")

        t += dt_wait
        N .+= stoich[chosen]
        all(>=(0), N) || error("stoichiometric jump produced a negative count")
        ev_count += 1
        push!(t_hist, t)
        push!(N_hist, copy(N))
        push!(dens_hist, biomass_density(N, params))
    end

    return (
        time = t_hist,
        N_history = N_hist,
        biomass_density = dens_hist,
        event_count = ev_count,
        stop_reason = reason,
    )
end

# ------------------------------------------------------------------
# Metabolic size spectra and size-dependent response models
# ------------------------------------------------------------------

"""
    SizeSpectrumParams(; m_min=1e-12, m_max=1e1, abundance_scale=1e3,
                       abundance_exponent=0.95, metabolic_scale=0.25,
                       metabolic_exponent=0.75, temperature=298.15,
                       reference_mass=1.0)

Parameters for a power-law abundance density and allometric individual
metabolic rate. Mass units must be consistent across `m_min`, `m_max`, and
`reference_mass`; `abundance_scale` and `metabolic_scale` carry the
corresponding units. The default mass unit is kg, but the model does not
convert units automatically.
"""
struct SizeSpectrumParams
    m_min::Float64
    m_max::Float64
    abundance_scale::Float64
    abundance_exponent::Float64
    metabolic_scale::Float64
    metabolic_exponent::Float64
    temperature::Float64
    reference_mass::Float64

    function SizeSpectrumParams(; m_min::Real=1e-12,
                                m_max::Real=1e1,
                                abundance_scale::Real=1e3,
                                abundance_exponent::Real=0.95,
                                metabolic_scale::Real=0.25,
                                metabolic_exponent::Real=0.75,
                                temperature::Real=298.15,
                                reference_mass::Real=1.0)
        vals = Float64.((m_min, m_max, abundance_scale, abundance_exponent,
                         metabolic_scale, metabolic_exponent, temperature,
                         reference_mass))
        all(isfinite, vals) || throw(ArgumentError("size-spectrum parameters must be finite"))
        m_min_f, m_max_f, abundance_scale_f, abundance_exponent_f,
            metabolic_scale_f, metabolic_exponent_f, temperature_f,
            reference_mass_f = vals
        0 < m_min_f < m_max_f ||
            throw(ArgumentError("require 0 < m_min < m_max"))
        abundance_scale_f > 0 || throw(ArgumentError("abundance_scale must be positive"))
        metabolic_scale_f > 0 || throw(ArgumentError("metabolic_scale must be positive"))
        temperature_f > 0 || throw(ArgumentError("temperature must be positive"))
        reference_mass_f > 0 || throw(ArgumentError("reference_mass must be positive"))
        new(m_min_f, m_max_f, abundance_scale_f, abundance_exponent_f,
            metabolic_scale_f, metabolic_exponent_f, temperature_f,
            reference_mass_f)
    end
end

"""
    compute_size_spectrum_indices(params; n_bins=1000)

Integrate the power-law abundance density `N(m) = N₀(m/m₀)^(-λ)` and the
individual metabolic rate `q(m) = q₀(m/m₀)^α` across a logarithmic mass grid.
The returned biomass and power integrals are macro-ecological summaries, not
Onsager matrices; `power_total / temperature` is an entropy-production proxy
only when the measured metabolic power is dissipated as heat at the stated
ambient temperature.

Returns a named tuple containing the grid, spectral densities, integral
indices, and the metabolic-spectrum exponent `β = λ - α`.
"""
function compute_size_spectrum_indices(params::SizeSpectrumParams; n_bins::Int=1000)
    n_bins >= 2 || throw(ArgumentError("n_bins must be at least 2"))
    log_mass = range(log(params.m_min), log(params.m_max); length=n_bins)
    mass = exp.(log_mass)
    abundance = params.abundance_scale .*
                (mass ./ params.reference_mass) .^ (-params.abundance_exponent)
    biomass_density = abundance .* mass
    individual_power = params.metabolic_scale .*
                       (mass ./ params.reference_mass) .^ params.metabolic_exponent
    power_density = abundance .* individual_power

    # Since d(log m) = dm / m, these are the corresponding integrands in log mass.
    biomass_per_log_mass = biomass_density .* mass
    power_per_log_mass = power_density .* mass
    biomass_total = sum(diff(log_mass) .*
                        (biomass_per_log_mass[1:end-1] .+
                         biomass_per_log_mass[2:end]) ./ 2)
    power_total = sum(diff(log_mass) .*
                      (power_per_log_mass[1:end-1] .+
                       power_per_log_mass[2:end]) ./ 2)
    beta = params.abundance_exponent - params.metabolic_exponent

    return (
        mass = collect(mass),
        abundance_density = abundance,
        biomass_density = biomass_density,
        individual_power = individual_power,
        power_density = power_density,
        biomass_total = biomass_total,
        power_total = power_total,
        entropy_production_proxy = power_total / params.temperature,
        specific_power_proxy = power_total / biomass_total,
        beta = beta,
    )
end

"""
    simulate_size_spectrum_filtering(params; n_scales=5, duration=50.0,
                                     dt=0.01, frequencies=(10.0, 1.0, 0.1),
                                     amplitudes=(1.0, 0.8, 0.5),
                                     reference_time=0.5)

Simulate independent first-order responses of size classes to a shared,
multifrequency forcing signal. Each size class has response time
`τ(m) = reference_time * (m/reference_mass)^(1-α)`. The exact exponential
update for piecewise-constant forcing avoids an Euler stability restriction.
This is a phenomenological low-pass-filter model, not an FFT or a claim that
size classes physically separate environmental frequencies.
"""
function simulate_size_spectrum_filtering(params::SizeSpectrumParams;
                                          n_scales::Int=5,
                                          duration::Real=50.0,
                                          dt::Real=0.01,
                                          frequencies::AbstractVector{<:Real}=[10.0, 1.0, 0.1],
                                          amplitudes::AbstractVector{<:Real}=[1.0, 0.8, 0.5],
                                          reference_time::Real=0.5)
    n_scales >= 1 || throw(ArgumentError("n_scales must be positive"))
    isfinite(duration) && duration > 0 || throw(ArgumentError("duration must be positive and finite"))
    isfinite(dt) && dt > 0 || throw(ArgumentError("dt must be positive and finite"))
    isfinite(reference_time) && reference_time > 0 ||
        throw(ArgumentError("reference_time must be positive and finite"))
    length(frequencies) == length(amplitudes) ||
        throw(DimensionMismatch("frequencies and amplitudes must have equal lengths"))
    all(isfinite, frequencies) && all(>=(0), frequencies) ||
        throw(ArgumentError("frequencies must be finite and nonnegative"))
    all(isfinite, amplitudes) || throw(ArgumentError("amplitudes must be finite"))

    log_mass = range(log(params.m_min), log(params.m_max); length=n_scales)
    mass = exp.(log_mass)
    response_time = Float64(reference_time) .*
                    (mass ./ params.reference_mass) .^ (1 - params.metabolic_exponent)
    n_steps = ceil(Int, Float64(duration) / Float64(dt))
    time = min.(collect(0:n_steps) .* Float64(dt), Float64(duration))
    forcing = zeros(length(time))
    for (frequency, amplitude) in zip(frequencies, amplitudes)
        forcing .+= Float64(amplitude) .* sin.(Float64(frequency) .* time)
    end

    response = zeros(length(time), n_scales)
    for step in 2:length(time)
        step_dt = time[step] - time[step - 1]
        for scale in 1:n_scales
            decay = exp(-step_dt / response_time[scale])
            response[step, scale] = decay * response[step - 1, scale] +
                                    (1 - decay) * forcing[step - 1]
        end
    end

    return (time = time, forcing = forcing, mass = collect(mass),
            response_time = response_time, response = response)
end

"""
    simulate_size_spectrum_wave(params; n_bins=200, duration=50.0, dt=0.01,
                                transport_rate=0.15, reference_decay_rate=1.0,
                                anomaly_center=0.0, anomaly_width=0.4,
                                anomaly_amplitude=1.5,
                                snapshot_times=[0.0, 5.0, 15.0, 30.0, 50.0])

Evolve a localized perturbation across log-mass classes with a nearest-neighbor
skew-symmetric coupling and positive size-dependent damping. The skew coupling
redistributes perturbation without changing its quadratic norm; damping makes
that norm decrease. An implicit Euler step preserves this contraction for any
positive `dt`. The model is an illustrative linear network, not a derived
continuum food-web law or a validated prediction of ecosystem recovery.

The state is a normalized perturbation, and may be signed. Do not interpret it
as abundance or clip it to enforce positivity.
"""
function simulate_size_spectrum_wave(params::SizeSpectrumParams;
                                      n_bins::Int=200,
                                      duration::Real=50.0,
                                      dt::Real=0.01,
                                      transport_rate::Real=0.15,
                                      reference_decay_rate::Real=1.0,
                                      anomaly_center::Real=0.0,
                                      anomaly_width::Real=0.4,
                                      anomaly_amplitude::Real=1.5,
                                      snapshot_times::AbstractVector{<:Real}=[0.0, 5.0, 15.0, 30.0, 50.0])
    n_bins >= 3 || throw(ArgumentError("n_bins must be at least 3"))
    isfinite(duration) && duration > 0 || throw(ArgumentError("duration must be positive and finite"))
    isfinite(dt) && dt > 0 || throw(ArgumentError("dt must be positive and finite"))
    isfinite(transport_rate) && transport_rate >= 0 ||
        throw(ArgumentError("transport_rate must be finite and nonnegative"))
    isfinite(reference_decay_rate) && reference_decay_rate > 0 ||
        throw(ArgumentError("reference_decay_rate must be positive and finite"))
    isfinite(anomaly_center) || throw(ArgumentError("anomaly_center must be finite"))
    isfinite(anomaly_width) && anomaly_width > 0 ||
        throw(ArgumentError("anomaly_width must be positive and finite"))
    isfinite(anomaly_amplitude) || throw(ArgumentError("anomaly_amplitude must be finite"))
    isempty(snapshot_times) && throw(ArgumentError("snapshot_times cannot be empty"))
    all(isfinite, snapshot_times) && all(t -> 0 <= t <= duration, snapshot_times) ||
        throw(ArgumentError("snapshot times must be finite and lie within the simulation"))
    issorted(snapshot_times) || throw(ArgumentError("snapshot_times must be sorted"))

    log_mass = collect(range(log10(params.m_min), log10(params.m_max); length=n_bins))
    mass = 10 .^ log_mass
    dlog_mass = log_mass[2] - log_mass[1]
    abundance = params.abundance_scale .*
                (mass ./ params.reference_mass) .^ (-params.abundance_exponent)
    relaxation_rate = Float64(reference_decay_rate) .*
                      (mass ./ params.reference_mass) .^ (params.metabolic_exponent - 1)

    # y_i = sqrt(Δlog m) times the relative abundance deviation; thus V = |y|²/2.
    initial_relative = Float64(anomaly_amplitude) .*
                       exp.(-((log_mass .- Float64(anomaly_center)).^2) ./
                            (2 * Float64(anomaly_width)^2))
    state = sqrt(dlog_mass) .* initial_relative
    diagonal = -relaxation_rate
    upper = fill(-Float64(transport_rate), n_bins - 1)
    lower = fill(Float64(transport_rate), n_bins - 1)
    n_steps = ceil(Int, Float64(duration) / Float64(dt))
    target_steps = [round(Int, t / dt) for t in snapshot_times]
    any(diff(target_steps) .<= 0) && length(target_steps) > 1 &&
        throw(ArgumentError("snapshot_times must map to distinct time steps"))
    target_steps[end] <= n_steps || throw(ArgumentError("snapshot time exceeds simulation duration"))

    snapshot_state = zeros(n_bins, length(snapshot_times))
    potential = zeros(n_steps + 1)
    potential[1] = dot(state, state) / 2
    snapshot_index = 1
    if target_steps[1] == 0
        snapshot_state[:, 1] = state
        snapshot_index += 1
    end

    for step in 1:n_steps
        step_dt = min(Float64(dt), Float64(duration) - (step - 1) * Float64(dt))
        lhs = Tridiagonal(-step_dt .* lower,
                          1 .- step_dt .* diagonal,
                          -step_dt .* upper)
        state = lhs \ state
        potential[step + 1] = dot(state, state) / 2
        if snapshot_index <= length(target_steps) && step >= target_steps[snapshot_index]
            snapshot_state[:, snapshot_index] = state
            snapshot_index += 1
        end
    end

    relative_history = snapshot_state ./ sqrt(dlog_mass)
    abundance_history = abundance .* (1 .+ relative_history)
    effective_snapshot_times = min.(target_steps .* Float64(dt), Float64(duration))
    time = min.(collect(0:n_steps) .* Float64(dt), Float64(duration))
    return (time = time,
            mass = mass,
            reference_abundance = abundance,
            relative_anomaly = relative_history,
            abundance = abundance_history,
            snapshot_times = effective_snapshot_times,
            potential = potential,
            relaxation_rate = relaxation_rate)
end

"""
    NPZDParams(; kwargs...)

Parameters for a four-pool nitrogen-currency NPZD model. Rate constants are
per day; state concentrations are in a consistent nitrogen-per-volume unit.
The reference nutrient input is derived to close the nutrient balance at the
positive equilibrium returned by `npzd_reference_state`. Defaults define an
illustrative model, not a fit to BATS observations.
"""
struct NPZDParams
    v_max::Float64
    k_s::Float64
    m_p::Float64
    a_z::Float64
    eps_z::Float64
    gamma_z::Float64
    c_z::Float64
    mu_p::Float64
    mu_z::Float64
    mu_d::Float64
    w_s::Float64
    nutrient_reference::Float64
    days_per_year::Float64
    noise_fraction::Float64

    function NPZDParams(; v_max::Real=1.20,
                        k_s::Real=0.70,
                        m_p::Real=0.09,
                        a_z::Real=2.00,
                        eps_z::Real=1.00,
                        gamma_z::Real=0.75,
                        c_z::Real=0.20,
                        mu_p::Real=0.20,
                        mu_z::Real=0.20,
                        mu_d::Real=0.05,
                        w_s::Real=0.02,
                        nutrient_reference::Real=0.10,
                        days_per_year::Real=365.25,
                        noise_fraction::Real=0.10)
        values = Float64[v_max, k_s, m_p, a_z, eps_z, gamma_z, c_z,
                         mu_p, mu_z, mu_d, w_s, nutrient_reference,
                         days_per_year, noise_fraction]
        all(isfinite, values) || throw(ArgumentError("NPZD parameters must be finite"))
        all(>(0), values[[1, 2, 3, 4, 5, 7, 10, 11, 12, 13, 14]]) ||
            throw(ArgumentError("rate, scale, and reference parameters must be positive"))
        0 < values[6] <= 1 || throw(ArgumentError("gamma_z must lie in (0, 1]"))
        all(v -> 0 <= v <= 1, values[8:9]) ||
            throw(ArgumentError("recycling fractions must lie in [0, 1]"))
        new(values...)
    end
end

"""
    npzd_reference_state(params)

Construct a positive steady state for the four-pool NPZD model. The nutrient
concentration is fixed at `params.nutrient_reference`; phytoplankton and
zooplankton balances determine the grazing equilibrium, detritus follows from
its balance, and a positive dissolved-nutrient input closes the nitrogen
balance. Returns `(state, nutrient_input)` in `(N, P, Z, D)` order.
"""
function npzd_reference_state(params::NPZDParams)
    n_star = params.nutrient_reference
    uptake_per_phytoplankton = params.v_max * n_star / (params.k_s + n_star)
    net_phytoplankton_rate = uptake_per_phytoplankton - params.m_p
    net_phytoplankton_rate > 0 ||
        throw(ArgumentError("nutrient uptake must exceed phytoplankton loss at reference N"))

    zooplankton_at_p(p) = sqrt(params.gamma_z * net_phytoplankton_rate * p / params.c_z)
    grazing_ratio(p) = params.a_z * zooplankton_at_p(p) * params.eps_z * p /
                       (1 + params.eps_z * p^2)
    peak_p = sqrt(3 / params.eps_z)
    grazing_ratio(peak_p) > net_phytoplankton_rate ||
        throw(ArgumentError("parameters do not admit a positive NPZD equilibrium"))

    low = eps(Float64)
    high = peak_p
    for _ in 1:100
        mid = (low + high) / 2
        if grazing_ratio(mid) < net_phytoplankton_rate
            low = mid
        else
            high = mid
        end
    end
    p_star = (low + high) / 2
    z_star = zooplankton_at_p(p_star)
    grazing = net_phytoplankton_rate * p_star
    mortality_z = params.c_z * z_star^2
    d_star = ((1 - params.mu_p) * params.m_p * p_star +
              (1 - params.mu_z) * mortality_z) / (params.mu_d + params.w_s)
    uptake = params.v_max * p_star * n_star / (params.k_s + n_star)
    nutrient_input = uptake - (params.mu_p * params.m_p * p_star +
                      params.mu_z * mortality_z +
                      (1 - params.gamma_z) * grazing + params.mu_d * d_star)
    nutrient_input > 0 ||
        throw(ArgumentError("parameters imply a nonpositive external nutrient input"))
    return (state = [n_star, p_star, z_star, d_star],
            nutrient_input = nutrient_input)
end

function _npzd_daily_rhs(state::AbstractVector, params::NPZDParams,
                         nutrient_input::Real)
    n, p, z, d = state
    uptake = params.v_max * p * n / (params.k_s + n)
    grazing = params.a_z * z * params.eps_z * p^2 /
              (1 + params.eps_z * p^2)
    mortality_z = params.c_z * z^2
    return [nutrient_input - uptake + params.mu_p * params.m_p * p +
            params.mu_z * mortality_z + (1 - params.gamma_z) * grazing +
            params.mu_d * d,
            uptake - grazing - params.m_p * p,
            params.gamma_z * grazing - mortality_z,
            (1 - params.mu_p) * params.m_p * p +
            (1 - params.mu_z) * mortality_z - (params.mu_d + params.w_s) * d]
end

"""
    npzd_rhs(state, params)

Evaluate the four-pool NPZD nitrogen balance in concentration units per day.
The input is calibrated to the positive reference equilibrium.
"""
function npzd_rhs(state::AbstractVector{<:Real}, params::NPZDParams)
    length(state) == 4 || throw(DimensionMismatch("state must contain N, P, Z, and D"))
    all(isfinite, state) || throw(ArgumentError("state values must be finite"))
    reference = npzd_reference_state(params)
    return _npzd_daily_rhs(state, params, reference.nutrient_input)
end

"""
    npzd_diagnostics(params)

Return the positive NPZD reference state, annualized ForwardDiff community
Jacobian, a heuristic diagonal diffusion matrix, Lyapunov covariance, and
canonical covariance-weighted drift decomposition. The diffusion scale is a
model assumption, not observed or thermal noise.
"""
function npzd_diagnostics(params::NPZDParams)
    reference = npzd_reference_state(params)
    state = reference.state
    A_daily = ForwardDiff.jacobian(
        x -> _npzd_daily_rhs(x, params, reference.nutrient_input), state)
    A = params.days_per_year .* A_daily
    all(real.(eigvals(A)) .< 0) ||
        throw(ArgumentError("NPZD reference Jacobian is not Hurwitz stable"))

    n, p, z, d = state
    uptake = params.v_max * p * n / (params.k_s + n)
    grazing = params.a_z * z * params.eps_z * p^2 /
              (1 + params.eps_z * p^2)
    mortality_z = params.c_z * z^2
    turnover_daily = [(reference.nutrient_input + uptake) / n,
                      (uptake + grazing) / p,
                      (params.gamma_z * grazing + mortality_z) / z,
                      params.mu_d + params.w_s]
    diffusion_diagonal = params.noise_fraction .* state.^2 .* turnover_daily .*
                         params.days_per_year
    D = Matrix(Diagonal(diffusion_diagonal))
    C = Matrix(solve_lyapunov_covariance(A, D))
    decomposition = decompose_covariance_weighted_drift(A, C; D=D, scale=1.0)
    return (reference_state = state,
            nutrient_input = reference.nutrient_input,
            A = A,
            D = D,
            C = C,
            decomposition = decomposition,
            eigenvalues = eigvals(A),
            lyapunov_residual = decomposition.lyapunov_residual)
end

"""
    NPZDFishParams(; kwargs...)

Parameters for a five-pool nitrogen-currency NPZD–fish model. Rates are
specified per day and converted to per year by `days_per_year`. The model
uses a nutrient input chosen to support its reference equilibrium; the
reference nutrient concentration is configurable. Defaults are an illustrative
scenario, not a fit to BATS or fishery observations.
"""
struct NPZDFishParams
    v_max::Float64
    k_s::Float64
    m_p::Float64
    a_z::Float64
    eps_z::Float64
    gamma_z::Float64
    c_z::Float64
    a_f::Float64
    eps_f::Float64
    gamma_f::Float64
    m_f::Float64
    harvest_mortality::Float64
    mu_p::Float64
    mu_z::Float64
    mu_f::Float64
    mu_d::Float64
    w_s::Float64
    nutrient_reference::Float64
    days_per_year::Float64
    noise_fraction::Float64

    function NPZDFishParams(; v_max::Real=1.20,
                            k_s::Real=0.70,
                            m_p::Real=0.09,
                            a_z::Real=2.00,
                            eps_z::Real=1.00,
                            gamma_z::Real=0.75,
                            c_z::Real=0.20,
                            a_f::Real=0.50,
                            eps_f::Real=2.00,
                            gamma_f::Real=0.70,
                            m_f::Real=0.02,
                            harvest_mortality::Real=0.0604,
                            mu_p::Real=0.20,
                            mu_z::Real=0.20,
                            mu_f::Real=0.10,
                            mu_d::Real=0.05,
                            w_s::Real=0.02,
                            nutrient_reference::Real=0.10,
                            days_per_year::Real=365.25,
                            noise_fraction::Real=0.10)
        values = Float64[v_max, k_s, m_p, a_z, eps_z, gamma_z, c_z,
                         a_f, eps_f, gamma_f, m_f, harvest_mortality,
                         mu_p, mu_z, mu_f, mu_d, w_s, nutrient_reference,
                         days_per_year, noise_fraction]
        all(isfinite, values) || throw(ArgumentError("NPZD-fish parameters must be finite"))
        positive = values[[1, 2, 3, 4, 5, 7, 8, 9, 11, 12, 18, 19, 20]]
        all(>(0), positive) || throw(ArgumentError("rate, scale, and reference parameters must be positive"))
        0 < values[6] <= 1 && 0 < values[10] <= 1 ||
            throw(ArgumentError("assimilation efficiencies must lie in (0, 1]"))
        all(v -> 0 <= v <= 1, values[13:17]) ||
            throw(ArgumentError("recycling fractions must lie in [0, 1]"))
        new(values...)
    end
end

"""
    npzd_fish_reference_state(params)

Construct a positive interior reference state for the NPZD–fish equations by
solving the phytoplankton, zooplankton, fish, and detritus balance relations
in sequence. The dissolved-nutrient input is then chosen to close the nutrient
balance. Throws if the parameter values do not admit the required positive
reference state.

Returns `(state, nutrient_input)` in compartment order `(N, P, Z, D, F)`.
"""
function npzd_fish_reference_state(params::NPZDFishParams)
    n_star = params.nutrient_reference
    uptake_per_phytoplankton = params.v_max * n_star / (params.k_s + n_star)
    phytoplankton_net_rate = uptake_per_phytoplankton - params.m_p
    phytoplankton_net_rate > 0 ||
        throw(ArgumentError("nutrient uptake must exceed phytoplankton loss at the reference nutrient level"))

    fish_equilibrium_ratio = (params.m_f + params.harvest_mortality) /
                             (params.gamma_f * params.a_f * params.eps_f)
    fish_equilibrium_ratio * params.eps_f < 1 ||
        throw(ArgumentError("fish mortality is too high for a positive interior fish equilibrium"))
    z_star = fish_equilibrium_ratio /
             (1 - fish_equilibrium_ratio * params.eps_f)

    quadratic_a = phytoplankton_net_rate * params.eps_z
    quadratic_b = params.a_z * z_star * params.eps_z
    discriminant = quadratic_b^2 - 4 * quadratic_a * phytoplankton_net_rate
    discriminant >= 0 ||
        throw(ArgumentError("parameters do not admit a positive phytoplankton equilibrium"))
    p_star = 2 * phytoplankton_net_rate /
             (quadratic_b + sqrt(discriminant))

    grazing_z = params.a_z * z_star * params.eps_z * p_star^2 /
                (1 + params.eps_z * p_star^2)
    grazing_f_needed = params.gamma_z * grazing_z - params.c_z * z_star^2
    grazing_f_needed > 0 ||
        throw(ArgumentError("parameters do not admit positive fish-supported zooplankton balance"))
    fish_grazing_per_fish = params.a_f * params.eps_f * z_star /
                            (1 + params.eps_f * z_star)
    f_star = grazing_f_needed / fish_grazing_per_fish

    zooplankton_mortality = params.c_z * z_star^2
    fish_mortality = params.m_f * f_star
    detritus_production = (1 - params.mu_p) * params.m_p * p_star +
                          (1 - params.mu_z) * zooplankton_mortality +
                          (1 - params.mu_f) * fish_mortality
    d_star = detritus_production / (params.mu_d + params.w_s)

    uptake = params.v_max * p_star * n_star / (params.k_s + n_star)
    fish_grazing = params.a_f * f_star * params.eps_f * z_star /
                   (1 + params.eps_f * z_star)
    nutrient_recycling = params.mu_p * params.m_p * p_star +
                         (1 - params.gamma_z) * grazing_z +
                         params.mu_z * zooplankton_mortality +
                         params.mu_d * d_star + params.mu_f * fish_mortality +
                         (1 - params.gamma_f) * fish_grazing
    nutrient_input = uptake - nutrient_recycling
    nutrient_input > 0 ||
        throw(ArgumentError("parameters imply a nonpositive external nutrient input"))

    state = [n_star, p_star, z_star, d_star, f_star]
    return (state = state, nutrient_input = nutrient_input)
end

function _npzd_fish_daily_rhs(state::AbstractVector, params::NPZDFishParams,
                              nutrient_input::Real,
                              harvest_multiplier::Real=1.0)
    n, p, z, d, fish = state
    uptake = params.v_max * p * n / (params.k_s + n)
    grazing_z = params.a_z * z * params.eps_z * p^2 /
                (1 + params.eps_z * p^2)
    grazing_f = params.a_f * fish * params.eps_f * z /
                (1 + params.eps_f * z)
    mortality_z = params.c_z * z^2
    mortality_f = params.m_f * fish
    harvest = params.harvest_mortality * harvest_multiplier * fish

    return [nutrient_input - uptake + params.mu_p * params.m_p * p +
            (1 - params.gamma_z) * grazing_z + params.mu_z * mortality_z +
            params.mu_d * d + params.mu_f * mortality_f +
            (1 - params.gamma_f) * grazing_f,
            uptake - grazing_z - params.m_p * p,
            params.gamma_z * grazing_z - mortality_z - grazing_f,
            (1 - params.mu_p) * params.m_p * p +
            (1 - params.mu_z) * mortality_z - (params.mu_d + params.w_s) * d +
            (1 - params.mu_f) * mortality_f,
            params.gamma_f * grazing_f - mortality_f - harvest]
end

"""
    npzd_fish_rhs(state, params; harvest_multiplier=1.0)

Evaluate the deterministic five-pool nitrogen balance in concentration units
per day. Pool order is dissolved inorganic nitrogen, phytoplankton,
zooplankton, detritus, and fish. The nutrient supply is calibrated to the
reference state returned by `npzd_fish_reference_state`.
"""
function npzd_fish_rhs(state::AbstractVector{<:Real}, params::NPZDFishParams;
                       harvest_multiplier::Real=1.0)
    length(state) == 5 || throw(DimensionMismatch("state must contain N, P, Z, D, and fish"))
    all(isfinite, state) || throw(ArgumentError("state values must be finite"))
    isfinite(harvest_multiplier) && harvest_multiplier >= 0 ||
        throw(ArgumentError("harvest_multiplier must be finite and nonnegative"))
    ref = npzd_fish_reference_state(params)
    return _npzd_fish_daily_rhs(state, params, ref.nutrient_input,
                                harvest_multiplier)
end

"""
    npzd_fish_diagnostics(params)

Compute the reference equilibrium, annualized ForwardDiff Jacobian, heuristic
diagonal diffusion, stationary covariance, and canonical covariance-weighted
drift decomposition for the NPZD–fish model. The diffusion is specified as a
fraction of each pool's squared reference concentration times its absolute
self-relaxation rate; it is a modeling choice, not a measured or thermal noise
calibration.
"""
function npzd_fish_diagnostics(params::NPZDFishParams)
    reference = npzd_fish_reference_state(params)
    state = reference.state
    A_daily = ForwardDiff.jacobian(
        x -> _npzd_fish_daily_rhs(x, params, reference.nutrient_input), state)
    A = params.days_per_year .* A_daily
    all(real.(eigvals(A)) .< 0) ||
        throw(ArgumentError("NPZD-fish reference Jacobian is not Hurwitz stable"))

    n, p, z, d, fish = state
    uptake = params.v_max * p * n / (params.k_s + n)
    grazing_z = params.a_z * z * params.eps_z * p^2 /
                (1 + params.eps_z * p^2)
    grazing_f = params.a_f * fish * params.eps_f * z /
                (1 + params.eps_f * z)
    mortality_z = params.c_z * z^2
    turnover_daily = [(reference.nutrient_input + uptake) / n,
                      (params.m_p * p + grazing_z) / p,
                      (mortality_z + grazing_f) / z,
                      params.mu_d + params.w_s,
                      params.m_f + params.harvest_mortality]
    diffusion_diagonal = params.noise_fraction .* state.^2 .* turnover_daily .*
                         params.days_per_year
    D = Matrix(Diagonal(diffusion_diagonal))
    C = Matrix(solve_lyapunov_covariance(A, D))
    decomposition = decompose_covariance_weighted_drift(A, C; D=D, scale=1.0)
    return (reference_state = state,
            nutrient_input = reference.nutrient_input,
            A = A,
            D = D,
            C = C,
            decomposition = decomposition,
            eigenvalues = eigvals(A),
            lyapunov_residual = decomposition.lyapunov_residual)
end

"""
    simulate_npzd_fish_harvest(params; duration=10.0, dt=1e-4,
                               harvest_time=5.0, harvest_multiplier=2.5,
                               rng=Random.default_rng())

Simulate a linearized Ornstein–Uhlenbeck perturbation about the calibrated
NPZD–fish reference state, with a step increase in fish-harvest mortality.
Returns model states and deviations; states are not clipped, since clipping
would change the linear stochastic dynamics. The simulation is illustrative,
and its noise scale is not an empirical or thermal calibration.
"""
function simulate_npzd_fish_harvest(params::NPZDFishParams;
                                    duration::Real=10.0,
                                    dt::Real=1e-4,
                                    harvest_time::Real=5.0,
                                    harvest_multiplier::Real=2.5,
                                    rng::AbstractRNG=Random.default_rng())
    isfinite(duration) && duration > 0 || throw(ArgumentError("duration must be positive and finite"))
    isfinite(dt) && dt > 0 || throw(ArgumentError("dt must be positive and finite"))
    isfinite(harvest_time) && 0 <= harvest_time <= duration ||
        throw(ArgumentError("harvest_time must lie within the simulation interval"))
    isfinite(harvest_multiplier) && harvest_multiplier >= 1 ||
        throw(ArgumentError("harvest_multiplier must be finite and at least one"))

    diagnostics = npzd_fish_diagnostics(params)
    n_steps = ceil(Int, Float64(duration) / Float64(dt))
    time = min.(collect(0:n_steps) .* Float64(dt), Float64(duration))
    deviations = zeros(n_steps + 1, 5)
    states = zeros(n_steps + 1, 5)
    states[1, :] = diagnostics.reference_state
    noise_factor = cholesky(Symmetric(2 .* diagnostics.D)).L
    extra_harvest_rate = (harvest_multiplier - 1) *
                         params.harvest_mortality * params.days_per_year

    for step in 1:n_steps
        step_dt = time[step + 1] - time[step]
        drift = diagnostics.A * deviations[step, :]
        if time[step] >= harvest_time
            drift[5] -= extra_harvest_rate *
                        (diagnostics.reference_state[5] + deviations[step, 5])
        end
        deviations[step + 1, :] = deviations[step, :] .+ drift .* step_dt .+
                                  sqrt(step_dt) .* (noise_factor * randn(rng, 5))
        states[step + 1, :] = diagnostics.reference_state .+ deviations[step + 1, :]
    end

    return (time = time,
            states = states,
            deviations = deviations,
            diagnostics = diagnostics,
            harvest_time = Float64(harvest_time),
            harvest_multiplier = Float64(harvest_multiplier))
end

end # module OnsagerNetwork
