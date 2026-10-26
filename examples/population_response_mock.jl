using LinearAlgebra
using Random

include(joinpath(@__DIR__, "..", "src", "onsagernetwork.jl"))
using .OnsagerNetwork

function main()
    rng = MersenneTwister(20261026)
    dt = 0.2
    n_observations = 20_000

    covariance = [1.0 0.35 0.10;
                  0.35 1.40 0.20;
                  0.10 0.20 0.80]
    true_covariance_weighted_drift = [0.80 -0.10 0.05;
                                      -0.10 0.60 -0.08;
                                      0.05 -0.08 0.50]
    drift = -true_covariance_weighted_drift / covariance
    transition = exp(drift * dt)
    innovation_covariance = covariance - transition * covariance * transition'
    innovation_factor = cholesky(Symmetric(innovation_covariance)).L
    stationary_factor = cholesky(Symmetric(covariance)).L

    log_abundance = Matrix{Float64}(undef, n_observations, 3)
    log_abundance[1, :] .= stationary_factor * randn(rng, 3)
    for t in 2:n_observations
        log_abundance[t, :] .= transition * log_abundance[t - 1, :] .+
                               innovation_factor * randn(rng, 3)
    end

    reference_abundance = [100.0, 50.0, 20.0]
    abundance = exp.(log_abundance) .* reshape(reference_abundance, 1, :)
    recovered_log_abundance = log.(abundance ./ reshape(reference_abundance, 1, :))
    estimate = estimate_population_covariance_weighted_drift(
        recovered_log_abundance; dt=dt)

    println("Seed: 20261026; observations: $n_observations; dt: $dt")
    println("True covariance-weighted drift matrix K_cov = -A*C:")
    display(true_covariance_weighted_drift)
    println("Estimated covariance-weighted drift matrix:")
    display(estimate.covariance_weighted_drift)
    println("Estimated symmetric part:")
    display(estimate.symmetric_part)
    println("Stable drift: $(estimate.drift_stable)")
    println("Asymmetry: $(estimate.asymmetry)")
    println("Minimum symmetric eigenvalue: $(estimate.minimum_symmetric_eigenvalue)")
    println("Symmetric part PSD within roundoff: $(estimate.symmetric_part_psd_within_roundoff)")
    println("Frobenius estimation error: $(norm(estimate.covariance_weighted_drift -
                                            true_covariance_weighted_drift))")
end

main()
