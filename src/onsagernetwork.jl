# onsagernetwork.jl
# Consolidated ecological dynamics and matrix diagnostics.
# Biomass fractions are explicit model weights; no biomass-derived entropy
# metric or physical conductivity is computed.

module OnsagerNetwork

using LinearAlgebra
using Statistics
using Random
using Distributions
using ForwardDiff
using DataFrames

const ALLOMETRIC_MASS_EXPONENT = 0.25
const INITIAL_BIOMASS_CAPACITY_FRACTION = 0.5
const MATRIX_LOG_IMAGINARY_RELATIVE_TOLERANCE = 1e-8
const MATRIX_SYMMETRY_ABSOLUTE_TOLERANCE = 1e-10
const MATRIX_SYMMETRY_RELATIVE_TOLERANCE = 1e-8
const PSD_ROUNDOFF_RELATIVE_TOLERANCE = 1e-10

const INTERACTION_MATRIX_DEFAULTS = (
    diagonal_value = 0.1,
    predator_mass_ratio = (1.0, 1000.0),
    predator_probability = 0.1,
    predator_strength = 0.05,
    predator_log_ratio_center = 1.5,
    predator_log_ratio_exponent_scale = 0.5,
    predator_effect_on_counterpart = 0.1,
    small_consumer_mass_ratio = (0.001, 0.1),
    small_consumer_probability = 0.15,
    small_consumer_strength = 0.02,
    small_consumer_effect_on_counterpart = 0.4,
    competition_mass_ratio = (0.5, 2.0),
    competition_probability = 0.17,
    competition_strength = 0.01,
    mutualism_probability = 0.27,
    mutualism_strength = 0.01,
)

const AGENT_MODEL_DEFAULTS = (
    body_mass_coefficient_of_variation = 0.1,
    initial_detritus_biomass = 100.0,
    detritus_remineralization_rate = 0.02,
    producer_count = 5,
    growth_rate = 0.01,
    producer_growth_noise_sd = 0.05,
    ingestion_fraction = 0.01,
    maximum_ingestion_fraction = 0.1,
    assimilation_fraction = 0.5,
    reproduction_scale = 0.8,
)

export normalize_biomass, weighted_interaction_matrix, matrix_asymmetry,
       biomass_jacobian_diagnostic, ibm_biomass_rate, ecosystem_simulation,
       simulation_options, generate_ecosystem_parameters, persistent_asymmetry,
       asymmetry_null, sensitivity_allometry, run_gillespie_population,
       PopulationJumpParams, fit_var, estimate_population_covariance_weighted_drift,
       rolling_var_asymmetry, bootstrap_var_asymmetry,
       simulate_three_state_relaxation

# ------------------------------------------------------------------
# 1. Biomass-fraction normalization
# ------------------------------------------------------------------
"""
    normalize_biomass(biomasses)

Returns `(fractions, total_biomass)`, where each fraction is `Bᵢ / sum(B)`.
Biomasses must be finite, nonnegative, and have a positive total; otherwise an
`ArgumentError` is thrown.
"""
function normalize_biomass(biomasses::AbstractVector{<:Real})
    isempty(biomasses) && throw(ArgumentError("biomasses must not be empty"))
    all(isfinite, biomasses) || throw(ArgumentError("biomasses must be finite"))
    all(>=(0), biomasses) || throw(ArgumentError("biomasses must be nonnegative"))
    total_biomass = sum(biomasses)
    isfinite(total_biomass) && total_biomass > 0 ||
        throw(ArgumentError("total biomass must be finite and positive"))
    return biomasses ./ total_biomass, total_biomass
end

# ------------------------------------------------------------------
# 2. Explicitly weighted interaction diagnostics
# ------------------------------------------------------------------
"""
    weighted_interaction_matrix(abundances, body_masses, interaction_matrix;
                                 mass_exponent=0.25)

Construct the exploratory matrix `W = -Diagonal(body_masses .^ -mass_exponent) *
interaction_matrix * Diagonal(biomass_fractions)`. The mass exponent is
unit-dependent. `W` is not a conductivity, entropy-production matrix, or stability
correction.
"""
function weighted_interaction_matrix(abundances::AbstractVector{<:Real},
                                     body_masses::AbstractVector{<:Real},
                                     interaction_matrix::AbstractMatrix;
                                     mass_exponent::Real=ALLOMETRIC_MASS_EXPONENT)
    species_count = length(abundances)
    length(body_masses) == species_count ||
        throw(DimensionMismatch("abundances and body_masses must have equal lengths"))
    size(interaction_matrix) == (species_count, species_count) ||
        throw(DimensionMismatch("interaction_matrix must be square with one row per species"))
    all(isfinite, abundances) && all(isfinite, body_masses) &&
        all(isfinite, interaction_matrix) && isfinite(mass_exponent) ||
        throw(ArgumentError("inputs and mass_exponent must be finite"))
    all(>=(0), abundances) || throw(ArgumentError("abundances must be nonnegative"))
    all(>(0), body_masses) || throw(ArgumentError("body_masses must be positive"))
    biomass_fractions, total_biomass =
        normalize_biomass(body_masses .* abundances)
    weighted_matrix = -Diagonal(body_masses .^ (-mass_exponent)) *
                      interaction_matrix * Diagonal(biomass_fractions)
    all(isfinite, weighted_matrix) ||
        throw(ArgumentError("weighted matrix contains nonfinite values; check mass_exponent and input scales"))
    return (biomass_fractions = biomass_fractions,
            total_biomass = total_biomass,
            mass_exponent = Float64(mass_exponent),
            weighted_matrix = weighted_matrix,
            asymmetry = matrix_asymmetry(weighted_matrix).index)
end

"""Return matrix scale and asymmetry for each supplied mass exponent."""
function sensitivity_allometry(abundances, body_masses, interaction_matrix;
                               exponents=0.2:0.01:0.33)
    results = Dict{Float64, NamedTuple}()
    for mass_exponent in exponents
        diagnostic = weighted_interaction_matrix(
            abundances, body_masses, interaction_matrix;
            mass_exponent=mass_exponent)
        results[Float64(mass_exponent)] =
            (asymmetry = diagnostic.asymmetry,
             matrix_norm = norm(diagnostic.weighted_matrix))
    end
    return results
end

# ------------------------------------------------------------------
# 3. Matrix asymmetry summaries
# ------------------------------------------------------------------
"""Frobenius asymmetry and symmetric/skew decomposition of a square matrix."""
function matrix_asymmetry(input_matrix::AbstractMatrix)
    size(input_matrix, 1) == size(input_matrix, 2) ||
        throw(DimensionMismatch("matrix must be square"))
    all(isfinite, input_matrix) ||
        throw(ArgumentError("matrix must contain only finite values"))
    matrix = Matrix{Float64}(input_matrix)
    all(isfinite, matrix) ||
        throw(ArgumentError("matrix entries must be representable as finite Float64 values"))
    difference = matrix .- transpose(matrix)
    denominator = norm(matrix)
    index = denominator > 0 ? norm(difference) / denominator : 0.0
    symmetric = 0.5 .* (matrix .+ transpose(matrix))
    skew = 0.5 .* (matrix .- transpose(matrix))
    pairwise = zeros(size(matrix))
    for i in axes(matrix, 1), j in axes(matrix, 2)
        scale = abs(matrix[i, j]) + abs(matrix[j, i])
        pairwise[i, j] = scale > 0 ? (matrix[i, j] - matrix[j, i]) / scale : 0.0
    end
    return (index = index, symmetric = symmetric, skew = skew, pairwise = pairwise)
end


# Threshold-run helper for descriptive matrix-asymmetry series.
"""
    persistent_asymmetry(asymmetry_series; threshold=0.2, min_run=3)

Returns true if `asymmetry_series` contains a run of at least `min_run` consecutive
values above `threshold`. This utility only detects a threshold run; it is not a
regime-shift or tipping-point detector.
"""
function persistent_asymmetry(asymmetry_series::AbstractVector{<:Real};
                              threshold::Real=0.2, min_run::Int=3)
    min_run > 0 || throw(ArgumentError("min_run must be positive"))
    isfinite(threshold) || throw(ArgumentError("threshold must be finite"))
    all(isfinite, asymmetry_series) ||
        throw(ArgumentError("asymmetry_series must contain only finite values"))
    run = 0
    for value in asymmetry_series
        run = value > threshold ? run + 1 : 0
        if run >= min_run
            return true
        end
    end
    return false
end

"""
    asymmetry_null(matrices; n_perm=200, rng=Random.default_rng())

Empirical null distribution of A_F under independent row and column
permutations of each square matrix. Using the same permutation on both axes merely
renames variables and leaves A_F unchanged, so the permutations are independent.
This is a simple exchangeability null, not a time-series-aware inferential test.
Returns `length(matrices) * n_perm` null values. Supply `rng` for reproducibility.
"""
function asymmetry_null(matrices::AbstractVector{<:AbstractMatrix};
                        n_perm::Int=200,
                        rng::AbstractRNG=Random.default_rng())
    n_perm >= 0 || throw(ArgumentError("n_perm must be nonnegative"))
    out = Float64[]
    for matrix in matrices
        size(matrix, 1) == size(matrix, 2) ||
            throw(DimensionMismatch("each matrix must be square"))
        all(isfinite, matrix) ||
            throw(ArgumentError("each matrix must contain only finite values"))
        matrix = Matrix{Float64}(matrix)
        n = size(matrix, 1)
        for _ in 1:n_perm
            rows, cols = randperm(rng, n), randperm(rng, n)
            push!(out, matrix_asymmetry(matrix[rows, cols]).index)
        end
    end
    return out
end

# ------------------------------------------------------------------
# 4. Time-series inference: reduced-form VAR diagnostics
# ------------------------------------------------------------------
"""
    fit_var(data; p=1)

Fit a VAR(`p`) with an intercept by ordinary least squares. Rows of `data` are
successive observations and columns are variables. Returns the intercept, lag
matrices, residuals, residual covariance, fitted values, and coefficient standard
errors. The standard-error matrix has one row per design coefficient (intercept,
then lagged variables) and one column per modeled variable. This reduced-form model
does not identify thermodynamic conductivities or causal effects.
"""
function fit_var(data::AbstractMatrix{<:Real}; p::Int=1)
    p >= 1 || throw(ArgumentError("p must be at least 1"))
    number_of_observations, number_of_variables = size(data)
    number_of_variables > 0 || throw(ArgumentError("data must contain at least one variable"))
    all(isfinite, data) || throw(ArgumentError("data must contain only finite values"))
    number_of_coefficients = 1 + number_of_variables * p
    number_of_regression_rows = number_of_observations - p
    number_of_regression_rows > number_of_coefficients ||
        throw(ArgumentError("not enough observations for VAR($p) with $number_of_variables variables"))

    response = Matrix{Float64}(data[(p + 1):number_of_observations, :])
    design_matrix = Matrix{Float64}(undef, number_of_regression_rows,
                                    number_of_coefficients)
    design_matrix[:, 1] .= 1.0
    for lag in 1:p
        lag_columns = (2 + (lag - 1) * number_of_variables):(1 + lag * number_of_variables)
        design_matrix[:, lag_columns] .=
            data[(p + 1 - lag):(number_of_observations - lag), :]
    end
    rank(design_matrix) == number_of_coefficients ||
        throw(ArgumentError("VAR design matrix is rank deficient"))

    coefficients = design_matrix \ response
    fitted_values = design_matrix * coefficients
    residuals = response - fitted_values
    residual_degrees_of_freedom = number_of_regression_rows - number_of_coefficients
    residual_covariance = (residuals' * residuals) / residual_degrees_of_freedom
    inverse_gram = inv(Symmetric(design_matrix' * design_matrix))
    coefficient_variances = max.(
        diag(inverse_gram) * transpose(diag(residual_covariance)), 0.0)
    standard_errors = sqrt.(coefficient_variances)
    lag_matrices = Matrix{Float64}[]
    for lag in 1:p
        lag_columns = (2 + (lag - 1) * number_of_variables):(1 + lag * number_of_variables)
        push!(lag_matrices, Matrix(transpose(coefficients[lag_columns, :])))
    end

    return (intercept = vec(coefficients[1, :]), lags = lag_matrices,
            residuals = residuals, residual_covariance = Matrix(residual_covariance),
            standard_errors = standard_errors, fitted_values = fitted_values,
            n_observations = number_of_observations, lag_order = p)
end

"""
    estimate_population_covariance_weighted_drift(data; dt=1.0)

Estimate `-A*C` under a stationary Gaussian Ornstein-Uhlenbeck approximation.
Rows are equally spaced observations; columns are nonredundant state coordinates.
Coordinates may be correlated, but their sample covariance must be positive definite.
The sample covariance `C` and continuous-time drift `A` are estimated from the data,
with `A` obtained from the VAR(1) transition matrix logarithm. The returned matrix
depends on the selected coordinates and model. It is not a thermodynamic force,
physical entropy production, or Onsager conductivity. Diagnostics describe drift
stability, matrix asymmetry, and the symmetric part; they are not physical
thermodynamic diagnostics. An unsupported or complex matrix logarithm is rejected.
"""
function estimate_population_covariance_weighted_drift(data::AbstractMatrix{<:Real}; dt::Real=1.0)
    size(data, 1) >= 4 || throw(ArgumentError("at least four time observations are required"))
    size(data, 2) > 0 || throw(ArgumentError("data must contain at least one state coordinate"))
    all(isfinite, data) || throw(ArgumentError("data must contain only finite values"))
    isfinite(dt) && dt > 0 || throw(ArgumentError("dt must be finite and positive"))

    centered_data = Matrix{Float64}(data)
    centered_data .-= mean(centered_data; dims=1)
    state_covariance = cov(centered_data)
    isposdef(Symmetric(state_covariance)) ||
        throw(ArgumentError("state covariance must be positive definite; use nonredundant coordinates"))
    transition_matrix = fit_var(centered_data; p=1).lags[1]
    complex_drift = log(complex.(transition_matrix)) / Float64(dt)
    imaginary_norm = norm(imag.(complex_drift))
    real_norm = norm(real.(complex_drift))
    imaginary_norm <= MATRIX_LOG_IMAGINARY_RELATIVE_TOLERANCE * max(1.0, real_norm) ||
        throw(ArgumentError("VAR transition has no numerically real principal matrix logarithm"))
    drift_matrix = real.(complex_drift)
    covariance_weighted_drift = -drift_matrix * state_covariance
    symmetric_part = 0.5 .* (covariance_weighted_drift .+ transpose(covariance_weighted_drift))
    asymmetry = matrix_asymmetry(covariance_weighted_drift).index
    minimum_symmetric_eigenvalue = minimum(eigvals(Symmetric(symmetric_part)))
    drift_stable = maximum(real.(eigvals(drift_matrix))) < 0
    roundoff_tolerance = PSD_ROUNDOFF_RELATIVE_TOLERANCE *
                         max(1.0, opnorm(symmetric_part))

    return (drift = drift_matrix, covariance = state_covariance,
            covariance_weighted_drift = covariance_weighted_drift,
            symmetric_part = symmetric_part, asymmetry = asymmetry,
            minimum_symmetric_eigenvalue = minimum_symmetric_eigenvalue,
            drift_stable = drift_stable,
            symmetric_part_psd_within_roundoff =
                minimum_symmetric_eigenvalue >= -roundoff_tolerance)
end

"""
    rolling_var_asymmetry(data; window, p=1, step=1)

Fit a VAR in each rolling window and report the Frobenius asymmetry of its
first-lag coefficient matrix. This is a reduced-form propagator diagnostic,
not an Onsager reciprocity test.
"""
function rolling_var_asymmetry(data::AbstractMatrix{<:Real}; window::Int, p::Int=1, step::Int=1)
    window > 0 || throw(ArgumentError("window must be positive"))
    step > 0 || throw(ArgumentError("step must be positive"))
    window <= size(data, 1) || throw(ArgumentError("window cannot exceed the number of observations"))
    starts = collect(1:step:(size(data, 1) - window + 1))
    asymmetry = Float64[]
    coefficients = Matrix{Float64}[]
    for first in starts
        model = fit_var(view(data, first:(first + window - 1), :); p=p)
        push!(coefficients, model.lags[1])
        push!(asymmetry, matrix_asymmetry(model.lags[1]).index)
    end
    return (end_indices = starts .+ window .- 1, asymmetry = asymmetry,
            lag1_coefficients = coefficients)
end

"""
    bootstrap_var_asymmetry(data; p=1, n_boot=500, confidence=0.95,
                            block_length=nothing, rng=Random.default_rng())

Estimate a percentile interval for the asymmetry of a VAR first-lag coefficient
using a moving-block bootstrap of the observed multivariate series. The interval
is an approximate time-series uncertainty summary and depends on stationarity
and block-length assumptions; it is not a tipping-point test.
"""
function bootstrap_var_asymmetry(data::AbstractMatrix{<:Real}; p::Int=1,
                                 n_boot::Int=500, confidence::Real=0.95,
                                 block_length::Union{Nothing,Int}=nothing,
                                 rng::AbstractRNG=Random.default_rng())
    n_boot > 0 || throw(ArgumentError("n_boot must be positive"))
    0 < confidence < 1 || throw(ArgumentError("confidence must be between zero and one"))
    T, n = size(data)
    point_estimate = matrix_asymmetry(fit_var(data; p=p).lags[1]).index
    block = isnothing(block_length) ? max(p + 1, ceil(Int, T^(1 / 3))) : block_length
    1 <= block <= T || throw(ArgumentError("block_length must be between 1 and the number of observations"))

    samples = Vector{Float64}(undef, n_boot)
    for b in 1:n_boot
        resampled = Matrix{Float64}(undef, T, n)
        next_row = 1
        while next_row <= T
            first = rand(rng, 1:(T - block + 1))
            count = min(block, T - next_row + 1)
            resampled[next_row:(next_row + count - 1), :] .= data[first:(first + count - 1), :]
            next_row += count
        end
        samples[b] = matrix_asymmetry(fit_var(resampled; p=p).lags[1]).index
    end
    tail = (1 - confidence) / 2
    interval = (lower = quantile(samples, tail), upper = quantile(samples, 1 - tail))
    return (estimate = point_estimate, interval = interval, bootstrap_samples = samples,
            confidence = Float64(confidence), block_length = block)
end

# ------------------------------------------------------------------
# 5. Linear three-state relaxation simulator
# ------------------------------------------------------------------
"""
    simulate_three_state_relaxation(K, x0; dt=0.1, t_end=10.0)

Simulate the linear system `dx/dt = -K*x` for three state coordinates using the
symmetric eigendecomposition solution. `K` must be symmetric and positive
semidefinite within floating-point tolerance; accepted tiny negative modes are
preserved, not clipped. The returned quadratic values are raw diagnostics, not
physical entropy production.
"""
function simulate_three_state_relaxation(K::AbstractMatrix{<:Real}, x0::AbstractVector{<:Real};
                                          dt::Real=0.1, t_end::Real=10.0)
    size(K) == (3, 3) || throw(DimensionMismatch("K must be 3 by 3"))
    length(x0) == 3 || throw(DimensionMismatch("x0 must have three entries"))
    all(isfinite, K) && all(isfinite, x0) || throw(ArgumentError("K and x0 must be finite"))
    isfinite(dt) && dt > 0 || throw(ArgumentError("dt must be finite and positive"))
    isfinite(t_end) && t_end >= 0 || throw(ArgumentError("t_end must be finite and nonnegative"))
    matrix = Matrix{Float64}(K)
    isapprox(matrix, matrix'; atol=MATRIX_SYMMETRY_ABSOLUTE_TOLERANCE,
             rtol=MATRIX_SYMMETRY_RELATIVE_TOLERANCE) ||
        throw(ArgumentError("K must be symmetric"))
    decomposition = eigen(Symmetric(matrix))
    psd_tolerance = PSD_ROUNDOFF_RELATIVE_TOLERANCE * max(1.0, opnorm(matrix))
    minimum(decomposition.values) >= -psd_tolerance ||
        throw(ArgumentError("K must be positive semidefinite"))
    eigenvalues = decomposition.values
    n_steps = ceil(Int, Float64(t_end) / Float64(dt))
    times = min.(collect(0:n_steps) .* Float64(dt), Float64(t_end))
    states = Matrix{Float64}(undef, length(times), 3)
    initial_coordinates = decomposition.vectors' * Float64.(x0)
    for (i, time) in enumerate(times)
        states[i, :] .= decomposition.vectors * (exp.(-eigenvalues .* time) .* initial_coordinates)
    end
    rates = -states * matrix
    quadratic = [dot(view(states, i, :), matrix * view(states, i, :))
                 for i in axes(states, 1)]
    return (time = times, deviation = states, rate = rates, quadratic_diagnostic = quadratic)
end

# ------------------------------------------------------------------
# 6. Biomass-weighted Jacobian diagnostics
# ------------------------------------------------------------------
function validate_ecosystem_parameters(reference_masses, carrying_capacities,
                                        interaction_matrix, species_count::Int)
    length(reference_masses) == species_count &&
        length(carrying_capacities) == species_count ||
        throw(DimensionMismatch("reference masses and carrying capacities must match species_count"))
    size(interaction_matrix) == (species_count, species_count) ||
        throw(DimensionMismatch("interaction_matrix must be square with one row per species"))
    all(isfinite, reference_masses) && all(>(0), reference_masses) ||
        throw(ArgumentError("reference_masses must be finite and positive"))
    all(isfinite, interaction_matrix) ||
        throw(ArgumentError("interaction_matrix must be finite"))
    all(value -> value > 0 || value == Inf, carrying_capacities) ||
        throw(ArgumentError("carrying_capacities must be positive or Inf"))
    return nothing
end

"""Evaluate the heuristic deterministic biomass-rate function."""
function ibm_biomass_rate(biomasses::AbstractVector{<:Real}, parameters::AbstractDict)
    species_count = length(biomasses)
    all(isfinite, biomasses) && all(>=(0), biomasses) ||
        throw(ArgumentError("biomasses must be finite and nonnegative"))
    reference_masses = get(parameters, :reference_masses, ones(species_count))
    interaction_matrix = get(parameters, :interaction_matrix,
                              Matrix{Float64}(I, species_count, species_count))
    carrying_capacities = get(parameters, :carrying_capacities, fill(Inf, species_count))
    validate_ecosystem_parameters(reference_masses, carrying_capacities,
                                  interaction_matrix, species_count)

    growth_rates = reference_masses .^ (-ALLOMETRIC_MASS_EXPONENT)
    carrying_capacity_factor = 1.0 .- (biomasses ./ carrying_capacities)
    biomass_rates = (growth_rates .* biomasses .* carrying_capacity_factor) .-
                    (growth_rates .* (interaction_matrix * biomasses))
    all(isfinite, biomass_rates) ||
        throw(ArgumentError("biomass-rate calculation overflowed or returned nonfinite values"))
    return biomass_rates
end

"""
    biomass_jacobian_diagnostic(biomasses, rate_function, parameters)

Compute a ForwardDiff Jacobian of a supplied biomass-rate function and the
explicitly weighted matrix `-A * Diagonal(biomass_fractions)`. Returns the raw
Jacobian and weighted matrix without symmetrization, eigenvalue clipping, or
thermodynamic interpretation.
"""
function biomass_jacobian_diagnostic(biomasses::AbstractVector{<:Real},
                                      rate_function, parameters::AbstractDict)
    biomass_fractions, total_biomass = normalize_biomass(biomasses)
    jacobian = ForwardDiff.jacobian(B -> rate_function(B, parameters), biomasses)
    size(jacobian) == (length(biomasses), length(biomasses)) ||
        throw(DimensionMismatch("rate_function must return one rate per biomass state"))
    weighted_matrix = -jacobian * Diagonal(biomass_fractions)
    return (jacobian = jacobian, weighted_matrix = weighted_matrix,
            biomass_fractions = biomass_fractions, total_biomass = total_biomass,
            asymmetry = matrix_asymmetry(weighted_matrix).index)
end

# ------------------------------------------------------------------
# 7. Heuristic agent-based ecosystem simulation
# ------------------------------------------------------------------
struct BiomassAgent
    species_index::Int
    mass::Float64
end

function initialize_agents(biomasses, reference_masses; rng::AbstractRNG=Random.default_rng())
    length(biomasses) == length(reference_masses) ||
        throw(DimensionMismatch("biomasses and reference masses must have equal lengths"))
    all(isfinite, biomasses) && all(>=(0), biomasses) ||
        throw(ArgumentError("biomasses must be finite and nonnegative"))
    all(isfinite, reference_masses) && all(>(0), reference_masses) ||
        throw(ArgumentError("reference masses must be finite and positive"))

    agents = BiomassAgent[]
    mass_cv = AGENT_MODEL_DEFAULTS.body_mass_coefficient_of_variation
    for (species_index, biomass) in enumerate(biomasses)
        individual_count = round(Int, biomass / reference_masses[species_index])
        mass_distribution = truncated(
            Normal(reference_masses[species_index], mass_cv * reference_masses[species_index]),
            0.0, Inf)
        for _ in 1:individual_count
            push!(agents, BiomassAgent(species_index,
                                       rand(rng, mass_distribution)))
        end
    end
    return agents
end

"""Run the heuristic biomass-agent model from a `simulation_options` result."""
function ecosystem_simulation(options::NamedTuple)
    parameters = options.parameters
    initial_biomasses = options.initial_biomasses
    simulation_duration = options.simulation_duration
    time_step = options.time_step
    output_interval = options.output_interval
    rng = options.rng
    species_count = length(initial_biomasses)

    species_count > 0 || throw(ArgumentError("at least one species is required"))
    isfinite(simulation_duration) && simulation_duration >= 0 ||
        throw(ArgumentError("simulation_duration must be finite and nonnegative"))
    isfinite(time_step) && time_step > 0 ||
        throw(ArgumentError("time_step must be finite and positive"))
    isfinite(output_interval) && output_interval > 0 ||
        throw(ArgumentError("output_interval must be finite and positive"))
    haskey(parameters, :reference_masses) &&
        haskey(parameters, :carrying_capacities) &&
        haskey(parameters, :interaction_matrix) ||
        throw(ArgumentError("parameters must include reference masses, carrying capacities, and interactions"))

    reference_masses = Float64.(parameters[:reference_masses])
    carrying_capacities = Float64.(parameters[:carrying_capacities])
    interaction_matrix = Float64.(parameters[:interaction_matrix])
    validate_ecosystem_parameters(reference_masses, carrying_capacities,
                                  interaction_matrix, species_count)

    agents = initialize_agents(initial_biomasses, reference_masses; rng=rng)
    detritus_biomass = AGENT_MODEL_DEFAULTS.initial_detritus_biomass
    biomass_history = Vector{Float64}[]
    time_history = Float64[]
    metrics_history = Dict{String,Any}[]
    dynamic_carrying_capacities = copy(carrying_capacities)
    producer_indices = sortperm(reference_masses)[1:min(AGENT_MODEL_DEFAULTS.producer_count,
                                                         species_count)]
    smallest_species = argmin(reference_masses)
    number_of_steps = ceil(Int, simulation_duration / time_step)
    steps_per_output = max(1, round(Int, output_interval / time_step))

    for step_index in 0:number_of_steps
        time = min(step_index * time_step, simulation_duration)
        current_biomass = zeros(species_count)
        for agent in agents
            current_biomass[agent.species_index] += agent.mass
        end

        if step_index % steps_per_output == 0 || step_index == number_of_steps
            push!(biomass_history, copy(current_biomass))
            push!(time_history, time)
            asymmetry = missing
            if sum(current_biomass) > 0
                diagnostic = biomass_jacobian_diagnostic(
                    current_biomass, ibm_biomass_rate, parameters)
                asymmetry = diagnostic.asymmetry
            end
            push!(metrics_history, Dict{String,Any}(
                "time" => time,
                "detritus_biomass" => detritus_biomass,
                "weighted_jacobian_asymmetry" => asymmetry,
            ))
        end

        step_duration = min(time_step, simulation_duration - time)
        step_duration == 0 && break

        remineralized_biomass = detritus_biomass * min(
            AGENT_MODEL_DEFAULTS.detritus_remineralization_rate * step_duration, 1.0)
        detritus_biomass -= remineralized_biomass
        dynamic_carrying_capacities[producer_indices] .+=
            remineralized_biomass / length(producer_indices)
        producer_growth_noise = randn(rng) * AGENT_MODEL_DEFAULTS.producer_growth_noise_sd
        updated_agents = BiomassAgent[]
        interaction_effects = interaction_matrix * current_biomass

        for agent in agents
            allometric_step = agent.mass^(-ALLOMETRIC_MASS_EXPONENT) * step_duration
            growth_rate = agent.species_index in producer_indices ?
                AGENT_MODEL_DEFAULTS.growth_rate + producer_growth_noise :
                AGENT_MODEL_DEFAULTS.growth_rate

            if agent.species_index == smallest_species
                ingested_biomass = min(
                    detritus_biomass * AGENT_MODEL_DEFAULTS.ingestion_fraction,
                    agent.mass * AGENT_MODEL_DEFAULTS.maximum_ingestion_fraction) * step_duration
                ingested_biomass = min(ingested_biomass, detritus_biomass)
                detritus_biomass -= ingested_biomass
                updated_mass = agent.mass + ingested_biomass *
                    AGENT_MODEL_DEFAULTS.assimilation_fraction
            else
                updated_mass = agent.mass +
                    agent.mass^(1 - ALLOMETRIC_MASS_EXPONENT) * growth_rate * step_duration
            end

            mortality_pressure = current_biomass[agent.species_index] /
                dynamic_carrying_capacities[agent.species_index] +
                interaction_effects[agent.species_index] /
                max(current_biomass[agent.species_index], eps(Float64))
            mortality_probability = clamp(allometric_step * mortality_pressure, 0.0, 1.0)
            if rand(rng) > mortality_probability
                push!(updated_agents, BiomassAgent(agent.species_index, updated_mass))
                if rand(rng) < clamp(allometric_step * AGENT_MODEL_DEFAULTS.reproduction_scale,
                                     0.0, 1.0)
                    push!(updated_agents, BiomassAgent(
                        agent.species_index, reference_masses[agent.species_index]))
                end
            else
                detritus_biomass += agent.mass
            end
        end
        agents = updated_agents
    end

    biomass_matrix = hcat(biomass_history...)'
    biomass_dataframe = DataFrame(
        biomass_matrix,
        [Symbol("species_", species_index) for species_index in 1:species_count])
    biomass_dataframe[!, :time] = time_history
    metrics_dataframe = DataFrame(metrics_history)
    return (biomass = biomass_dataframe, metrics = metrics_dataframe,
            parameters = parameters)
end

"""
    simulation_options(; n_species=10, ecosystem_type="temperate",
                       initial_biomasses=nothing, reference_masses=nothing,
                       carrying_capacities=nothing, interaction_matrix=nothing,
                       simulation_duration=365.0, time_step=0.1,
                       output_interval=10.0, rng=Random.default_rng())

Generate and validate the inputs for `ecosystem_simulation`. Supplying the four
optional state/parameter arrays overrides the generated defaults. The returned
named tuple includes the same RNG, so parameter generation and simulation form one
reproducible random sequence.
"""
function simulation_options(; n_species::Integer=10,
                            ecosystem_type::AbstractString="temperate",
                            initial_biomasses::Union{Nothing,AbstractVector{<:Real}}=nothing,
                            reference_masses::Union{Nothing,AbstractVector{<:Real}}=nothing,
                            carrying_capacities::Union{Nothing,AbstractVector{<:Real}}=nothing,
                            interaction_matrix::Union{Nothing,AbstractMatrix{<:Real}}=nothing,
                            simulation_duration::Real=365.0,
                            time_step::Real=0.1,
                            output_interval::Real=10.0,
                            rng::AbstractRNG=Random.default_rng())
    n_species > 0 || throw(ArgumentError("n_species must be positive"))
    isfinite(simulation_duration) && simulation_duration >= 0 ||
        throw(ArgumentError("simulation_duration must be finite and nonnegative"))
    isfinite(time_step) && time_step > 0 ||
        throw(ArgumentError("time_step must be finite and positive"))
    isfinite(output_interval) && output_interval > 0 ||
        throw(ArgumentError("output_interval must be finite and positive"))

    parameters = generate_ecosystem_parameters(
        ecosystem_type; n_species=n_species, rng=rng)
    if !isnothing(reference_masses)
        parameters[:reference_masses] = Float64.(reference_masses)
    end
    if !isnothing(carrying_capacities)
        parameters[:carrying_capacities] = Float64.(carrying_capacities)
    end
    if !isnothing(interaction_matrix)
        parameters[:interaction_matrix] = Float64.(interaction_matrix)
    end
    initial_biomass_values = isnothing(initial_biomasses) ?
        rand(rng, n_species) .* parameters[:carrying_capacities] *
            INITIAL_BIOMASS_CAPACITY_FRACTION :
        Float64.(initial_biomasses)
    length(initial_biomass_values) == n_species ||
        throw(DimensionMismatch("initial_biomasses must contain n_species values"))
    all(isfinite, initial_biomass_values) && all(>=(0), initial_biomass_values) ||
        throw(ArgumentError("initial_biomasses must be finite and nonnegative"))
    validate_ecosystem_parameters(parameters[:reference_masses],
                                  parameters[:carrying_capacities],
                                  parameters[:interaction_matrix], n_species)
    return (parameters=parameters, initial_biomasses=initial_biomass_values,
            simulation_duration=Float64(simulation_duration),
            time_step=Float64(time_step), output_interval=Float64(output_interval),
            rng=rng)
end

"""
    generate_ecosystem_parameters(ecosystem_type; n_species=10, rng=Random.default_rng())

Generate uncalibrated reference masses, interactions, and carrying capacities for
one of the supported ecosystem categories. The RNG controls all generated values.
"""
function generate_ecosystem_parameters(ecosystem_type::AbstractString;
                                       n_species::Integer=10,
                                       rng::AbstractRNG=Random.default_rng())
    n_species > 0 || throw(ArgumentError("n_species must be positive"))
    supported_types = ("boreal", "tropical", "temperate",
                       "high trophic level", "low trophic level")
    ecosystem_type in supported_types ||
        throw(ArgumentError("ecosystem_type must be one of $(join(supported_types, ", "))"))

    log_capacity_mean = ecosystem_type == "boreal" ? 10.0 :
                        ecosystem_type == "tropical" ? 12.0 : 11.0
    capacity_distribution = LogNormal(log_capacity_mean, 1.5)
    log_mass_bounds = ecosystem_type == "high trophic level" ? (5.0, 15.0) :
                      ecosystem_type == "low trophic level" ? (1.0, 5.0) :
                      (0.0, 10.0)
    log_mass_width = last(log_mass_bounds) - first(log_mass_bounds)
    reference_masses = exp.(rand(rng, n_species) .* log_mass_width .+
                            first(log_mass_bounds))
    return Dict(:reference_masses => reference_masses,
                :interaction_matrix => construct_biological_matrix(
                    reference_masses; rng=rng),
                :carrying_capacities => rand(rng, capacity_distribution, n_species),
                :ecosystem_type => ecosystem_type)
end

"""Construct the model's heuristic interaction matrix for species body masses."""
function construct_biological_matrix(reference_masses::AbstractVector{<:Real};
                                     rng::AbstractRNG=Random.default_rng())
    all(isfinite, reference_masses) && all(>(0), reference_masses) ||
        throw(ArgumentError("reference_masses must be finite and positive"))
    species_count = length(reference_masses)
    interaction_matrix = zeros(species_count, species_count)
    for i in 1:species_count, j in 1:species_count
        if i == j
            interaction_matrix[i, i] = INTERACTION_MATRIX_DEFAULTS.diagonal_value
            continue
        end
        mass_ratio = reference_masses[i] / reference_masses[j]
        draw = rand(rng)
        if first(INTERACTION_MATRIX_DEFAULTS.predator_mass_ratio) < mass_ratio <
           last(INTERACTION_MATRIX_DEFAULTS.predator_mass_ratio) &&
           draw < INTERACTION_MATRIX_DEFAULTS.predator_probability
            strength = INTERACTION_MATRIX_DEFAULTS.predator_strength *
                exp(-INTERACTION_MATRIX_DEFAULTS.predator_log_ratio_exponent_scale *
                    (log10(mass_ratio) -
                     INTERACTION_MATRIX_DEFAULTS.predator_log_ratio_center)^2)
            interaction_matrix[j, i] += strength
            interaction_matrix[i, j] -=
                INTERACTION_MATRIX_DEFAULTS.predator_effect_on_counterpart * strength
        elseif first(INTERACTION_MATRIX_DEFAULTS.small_consumer_mass_ratio) < mass_ratio <
               last(INTERACTION_MATRIX_DEFAULTS.small_consumer_mass_ratio) &&
               draw < INTERACTION_MATRIX_DEFAULTS.small_consumer_probability
            strength = INTERACTION_MATRIX_DEFAULTS.small_consumer_strength * rand(rng)
            interaction_matrix[j, i] += strength
            interaction_matrix[i, j] -=
                INTERACTION_MATRIX_DEFAULTS.small_consumer_effect_on_counterpart * strength
        elseif first(INTERACTION_MATRIX_DEFAULTS.competition_mass_ratio) < mass_ratio <
               last(INTERACTION_MATRIX_DEFAULTS.competition_mass_ratio) &&
               draw < INTERACTION_MATRIX_DEFAULTS.competition_probability
            strength = INTERACTION_MATRIX_DEFAULTS.competition_strength * rand(rng)
            interaction_matrix[i, j] -= strength
            interaction_matrix[j, i] -= strength
        elseif first(INTERACTION_MATRIX_DEFAULTS.competition_mass_ratio) < mass_ratio <
               last(INTERACTION_MATRIX_DEFAULTS.competition_mass_ratio) &&
               draw < INTERACTION_MATRIX_DEFAULTS.mutualism_probability
            strength = INTERACTION_MATRIX_DEFAULTS.mutualism_strength /
                (1.0 + abs(log(mass_ratio)))
            interaction_matrix[i, j] += strength
            interaction_matrix[j, i] += strength
        end
    end
    return interaction_matrix
end

# ------------------------------------------------------------------
# 8. Gillespie population jump model
# ------------------------------------------------------------------
"""
    PopulationJumpParams(; birth_rates, death_rates, competition_coefficients,
                           predation_coefficients, body_masses, volume,
                           conversion_efficiency)

Parameters for the demographic jump model. `predation_coefficients[i, j]` describes
predation by species `i` on species `j`; diagonal values are ignored. Event rates
use `body_masses^(-ALLOMETRIC_MASS_EXPONENT)`, so coefficient units must match the
chosen mass, time, and physical-volume units. `conversion_efficiency` is a
dimensionless fraction in `(0, 1]`. The species count is inferred from `birth_rates`.
"""
struct PopulationJumpParams
    species_count::Int
    birth_rates::Vector{Float64}
    death_rates::Vector{Float64}
    competition_coefficients::Vector{Float64}
    predation_coefficients::Matrix{Float64}
    body_masses::Vector{Float64}
    volume::Float64
    conversion_efficiency::Float64

    function PopulationJumpParams(; birth_rates::AbstractVector{<:Real},
                                  death_rates::AbstractVector{<:Real},
                                  competition_coefficients::AbstractVector{<:Real},
                                  predation_coefficients::AbstractMatrix{<:Real},
                                  body_masses::AbstractVector{<:Real},
                                  volume::Real,
                                  conversion_efficiency::Real)
        species_count = length(birth_rates)
        species_count > 0 || throw(ArgumentError("at least one species is required"))
        length(death_rates) == length(competition_coefficients) ==
            length(body_masses) == species_count ||
            throw(DimensionMismatch("all species vectors must have species_count entries"))
        size(predation_coefficients) == (species_count, species_count) ||
            throw(DimensionMismatch("predation_coefficients must be species_count by species_count"))

        birth_rates_f = Float64.(birth_rates)
        death_rates_f = Float64.(death_rates)
        competition_coefficients_f = Float64.(competition_coefficients)
        predation_coefficients_f = Matrix{Float64}(predation_coefficients)
        body_masses_f = Float64.(body_masses)
        volume_f = Float64(volume)
        conversion_efficiency_f = Float64(conversion_efficiency)
        all(isfinite, birth_rates_f) && all(isfinite, death_rates_f) &&
            all(isfinite, competition_coefficients_f) &&
            all(isfinite, predation_coefficients_f) && all(isfinite, body_masses_f) &&
            isfinite(volume_f) && isfinite(conversion_efficiency_f) ||
            throw(ArgumentError("all jump-model parameters must be representable as finite Float64 values"))
        all(>=(0), birth_rates_f) && all(>=(0), death_rates_f) &&
            all(>=(0), competition_coefficients_f) &&
            all(>=(0), predation_coefficients_f) ||
            throw(ArgumentError("rates and interaction coefficients must be nonnegative"))
        all(>(0), body_masses_f) && volume_f > 0 &&
            0 < conversion_efficiency_f <= 1 ||
            throw(ArgumentError("body_masses and volume must be positive; conversion_efficiency must be in (0, 1]"))
        for predator in 1:species_count, prey in 1:species_count
            mass_ratio = body_masses_f[predator] /
                (conversion_efficiency_f * body_masses_f[prey])
            isfinite(mass_ratio) && mass_ratio <= typemax(Int) ||
                throw(ArgumentError("predation mass ratio must be finite and fit in Int"))
        end

        new(species_count, birth_rates_f, death_rates_f,
            competition_coefficients_f, predation_coefficients_f,
            body_masses_f, volume_f, conversion_efficiency_f)
    end
end

"""Return species biomass per physical volume for an integer count vector."""
function biomass_density(counts::AbstractVector{<:Integer},
                          parameters::PopulationJumpParams)
    density = (parameters.body_masses .* Float64.(counts)) ./ parameters.volume
    all(isfinite, density) || throw(ArgumentError("biomass-density calculation overflowed"))
    return density
end

function evaluate_propensities_and_stoichiometry(
    counts::AbstractVector{<:Integer}, parameters::PopulationJumpParams)
    length(counts) == parameters.species_count ||
        throw(DimensionMismatch("counts must have species_count entries"))
    all(>=(0), counts) || throw(ArgumentError("counts must be nonnegative"))

    propensities = Float64[]
    stoichiometry = Vector{Vector{Int}}()
    for species in 1:parameters.species_count
        push!(propensities, parameters.birth_rates[species] *
            parameters.body_masses[species]^(-ALLOMETRIC_MASS_EXPONENT) * Float64(counts[species]))
        birth_change = zeros(Int, parameters.species_count)
        birth_change[species] = 1
        push!(stoichiometry, birth_change)
    end
    for species in 1:parameters.species_count
        if counts[species] > 0
            species_count = Float64(counts[species])
            propensity = parameters.death_rates[species] * species_count +
                (parameters.competition_coefficients[species] / parameters.volume) *
                species_count * (species_count - 1)
            push!(propensities, propensity)
            death_change = zeros(Int, parameters.species_count)
            death_change[species] = -1
            push!(stoichiometry, death_change)
        end
    end
    for predator in 1:parameters.species_count, prey in 1:parameters.species_count
        predation_coefficient = parameters.predation_coefficients[predator, prey]
        if predator != prey && predation_coefficient > 0 &&
           counts[predator] > 0 && counts[prey] > 0
            prey_to_predator_ratio = parameters.body_masses[predator] /
                (parameters.conversion_efficiency * parameters.body_masses[prey])
            prey_per_event = max(1, ceil(Int, prey_to_predator_ratio))
            if counts[prey] >= prey_per_event
                count_product = Float64(counts[predator]) * Float64(counts[prey])
                propensity = (predation_coefficient / parameters.volume) *
                    parameters.body_masses[predator]^(-ALLOMETRIC_MASS_EXPONENT) * count_product
                push!(propensities, propensity)
                predation_change = zeros(Int, parameters.species_count)
                predation_change[predator] = 1
                predation_change[prey] = -prey_per_event
                push!(stoichiometry, predation_change)
            end
        end
    end
    return propensities, stoichiometry
end

"""
    run_gillespie_population(initial_counts, parameters, end_time;
                             max_events=1_000_000, rng=Random.default_rng())

Simulate the jump process and return event times, counts, biomass densities, event
count, and a stop reason (`:end_time`, `:no_active_events`, or `:max_events`).
"""
function run_gillespie_population(initial_counts::AbstractVector{<:Integer},
                                  parameters::PopulationJumpParams, end_time::Real;
                                  max_events::Int=1_000_000,
                                  rng::AbstractRNG=Random.default_rng())
    isfinite(end_time) && end_time >= 0 ||
        throw(ArgumentError("end_time must be finite and nonnegative"))
    max_events >= 0 || throw(ArgumentError("max_events must be nonnegative"))
    length(initial_counts) == parameters.species_count ||
        throw(DimensionMismatch("initial_counts must have species_count entries"))
    all(>=(0), initial_counts) ||
        throw(ArgumentError("initial_counts must be nonnegative"))

    time = 0.0
    counts = Int.(initial_counts)
    time_history = Float64[time]
    count_history = [copy(counts)]
    density_history = [biomass_density(counts, parameters)]
    event_count = 0
    stop_reason = :end_time

    while time < end_time
        if event_count >= max_events
            stop_reason = :max_events
            break
        end
        propensities, stoichiometry =
            evaluate_propensities_and_stoichiometry(counts, parameters)
        all(value -> isfinite(value) && value >= 0, propensities) ||
            throw(ArgumentError("event propensities must be finite and nonnegative"))
        total_propensity = sum(propensities)
        isfinite(total_propensity) ||
            throw(ArgumentError("total event propensity overflowed"))
        if total_propensity == 0
            stop_reason = :no_active_events
            break
        end

        waiting_time = -log(max(rand(rng), floatmin(Float64))) / total_propensity
        time + waiting_time <= end_time || break
        event_threshold = rand(rng) * total_propensity
        cumulative_propensity = 0.0
        selected_event = 0
        for event_index in eachindex(propensities)
            cumulative_propensity += propensities[event_index]
            if event_threshold < cumulative_propensity
                selected_event = event_index
                break
            end
        end
        selected_event > 0 || error("failed to select an event from positive propensities")

        time += waiting_time
        counts .+= stoichiometry[selected_event]
        all(>=(0), counts) || error("reaction stoichiometry produced a negative count")
        event_count += 1
        push!(time_history, time)
        push!(count_history, copy(counts))
        push!(density_history, biomass_density(counts, parameters))
    end

    return (time=time_history, counts=count_history,
            biomass_density=density_history, event_count=event_count,
            stop_reason=stop_reason)
end

end # module OnsagerNetwork
