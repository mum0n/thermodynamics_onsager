# onsagernetwork.jl
# Consolidated ecological thermodynamics model (Onsager network).
# Self-consistent implementation: biomass is normalized by total biovolume V
# (intensive biovolume concentration b_i = B_i / V) in the entropy metric g.

module OnsagerNetwork

using LinearAlgebra
using Statistics
using Random
using Distributions
using ForwardDiff
using DataFrames

export biovolume_concentration, intensive_thermodynamics, onsager_asymmetry,
       calculate_thermodynamic_matrices, run_ibm_step, ecosystem_simulation, simulation_options,
       generate_ecosystem_parameters, estimate_conductivity_matrix, compute_matrix_asymmetry,
       persistent_asymmetry, asymmetry_null, sensitivity_allometry,
       run_gillespie_eco_thermo, run_tau_leaping_eco_thermo, EcoThermodynamicParams

# ------------------------------------------------------------------
# 1. Biovolume normalization (intensive concentration)
# ------------------------------------------------------------------
"""
    biovolume_concentration(biomasses)

Returns (b, V) where b_i = B_i / V (intensive biovolume concentration)
and V = sum(B_i) (total biovolume). Concentrations sum to 1.
"""
function biovolume_concentration(biomasses::AbstractVector)
    V = sum(biomasses)
    V = V <= 0 ? 1.0 : V
    b = biomasses ./ V
    return b, V
end

# ------------------------------------------------------------------
# 2. Intensive thermodynamics (corrected with biomass normalization)
# ------------------------------------------------------------------
"""
    intensive_thermodynamics(N, masses, A_raw, N_star)

Computes intensive thermodynamic quantities for abundance vector N:
- biovolume_conc b_i = M_i N_i / V
- entropic_stiffness g = Diagonal(1 ./ b)
- A_intensive = Diagonal(M_i^-0.25) * A_raw
- L = A_intensive * Diagonal(b)   (L_ij = M_i^-0.25 * A_raw_ij * b_j)
- X = (N - N_star) ./ N_star
- sigma = X' L X
"""
# NOTE: parameterization-only route (not the canonical empirical estimator).
# The canonical L is the Jacobian-based one in calculate_thermodynamic_matrices.
function intensive_thermodynamics(N::AbstractVector, masses::AbstractVector,
                                 A_raw::AbstractMatrix, N_star::AbstractVector)
    V = sum(masses .* N)
    V = V <= 0 ? 1.0 : V
    b = (masses .* N) ./ V
    g = Diagonal(1.0 ./ max.(b, 1e-12))  # Hessian of mixing entropy S=-sum b ln b (fraction coords); see paper Sec. 3.2
    metabolic = Diagonal(masses .^ (-0.25))
    A_int = metabolic * A_raw
    # Ecological-unit conductivity (asymmetric in general): L_ij = -M_i^-0.25 * A_ij * b_j.
    # Sign-flipped so self-terms are positive; off-diagonal signs follow -A_raw.
    # NOTE: strict Onsager reciprocity (L_ij=L_ji) is only expected after
    # nondimensionalisation to entropy units; in raw ecological units L is
    # generally only approximately symmetric. See L_raw / L_matrix fields.
    L_raw = -A_int * Diagonal(b)
    # Positive-definite symmetric part used for sigma and dynamics.
    S = 0.5 .* (L_raw .+ transpose(L_raw))
    F = eigen(Symmetric(S))
    lam = max.(F.values, 1e-9)
    L_pd = F.vectors * Diagonal(lam) * F.vectors'
    L_pd = 0.5 .* (L_pd .+ transpose(L_pd))
    # Thermodynamic force is the (positive) deviation; dynamics are dN/dt = -L*X.
    X = (N .- N_star) ./ max.(abs.(N_star), 1e-9)
    sigma = real(dot(X, L_pd * X))
    return (biovolume_conc = b, V = V, entropic_stiffness = g,
            A_intensive = A_int, L_raw = L_raw, L_matrix = L_pd, forces = X,
            sigma_dagger = sigma)
end

# ------------------------------------------------------------------
# 3. Onsager asymmetry metrics
# ------------------------------------------------------------------
function onsager_asymmetry(L::AbstractMatrix)
    L = Matrix{Float64}(L)
    diff = L .- transpose(L)
    nL = norm(L)
    AF = nL > 0 ? norm(diff) / nL : 0.0
    L_sym = 0.5 .* (L .+ transpose(L))
    L_skew = 0.5 .* (L .- transpose(L))
    a_pair = zeros(size(L))
    for i in axes(L,1), j in axes(L,2)
        den = abs(L[i,j]) + abs(L[j,i])
        a_pair[i,j] = den > 1e-12 ? (L[i,j]-L[j,i])/den : 0.0
    end
    return (AF = AF, L_sym = L_sym, L_skew = L_skew, a_pairwise = a_pair)
end
compute_matrix_asymmetry(L::AbstractMatrix) = onsager_asymmetry(L).AF

# Sensitivity analysis for the allometric exponent k.
"""
    sensitivity_allometry(N, masses, A_raw, N_star; ks=0.2:0.01:0.33)

Returns a Dict mapping each k to the minimum eigenvalue of L (positive-definite
part) and the asymmetry of L_raw, for sensitivity reporting.
"""
function sensitivity_allometry(N, masses, A_raw, N_star; ks=0.2:0.01:0.33)
    out = Dict{Float64, NamedTuple}()
    for k in ks
        # temporarily scale masses exponent by recomputing L via intensive_thermodynamics
        # with a modified mass vector exponent: build A_int with M^-k
        V = sum(masses .* N); V = V <= 0 ? 1.0 : V
        b = (masses .* N) ./ V
        A_int = Diagonal(masses .^ (-k)) * A_raw
        L_raw = -A_int * Diagonal(b)
        S = 0.5 .* (L_raw .+ transpose(L_raw))
        F = eigen(Symmetric(S))
        lam = max.(F.values, 1e-9)
        L_pd = F.vectors * Diagonal(lam) * F.vectors'
        L_pd = 0.5 .* (L_pd .+ transpose(L_pd))
        X = (N .- N_star) ./ max.(abs.(N_star), 1e-9)
        out[Float64(k)] = (min_eig = minimum(real(eigvals(L_pd))),
                           asymmetry = compute_matrix_asymmetry(L_raw),
                           sigma = real(dot(X, L_pd * X)))
    end
    return out
end

# Tau-leaping hybrid (approximate) for high-abundance regimes.
"""
    run_tau_leaping_eco_thermo(N_init, params, t_max; tau=0.1, max_steps=10^6)

Approximate (tau-leaping) integrator for high-abundance regimes where exact SSA
is too slow. Uses Poisson leaps for each reaction channel. Prefer exact SSA for
low-abundance (apex) classes.
"""
function run_tau_leaping_eco_thermo(N_init::Vector{Int}, params, t_max::Float64;
                                    tau::Float64=0.1, max_steps::Int=10^6)
    t = 0.0
    N = copy(N_init)
    t_history = Float64[t]
    N_history = [copy(N)]
    n = 0
    while t < t_max && n < max_steps
        n += 1
        a, nu = evaluate_propensities_and_stoichiometry(N, params)
        a0 = sum(a)
        a0 <= 0 && break
        dt = min(tau, (t_max - t))
        t += dt
        for k in eachindex(a)
            nk = rand(Poisson(a[k] * dt))
            N .+= nk .* nu[k]
        end
        N .= max.(N, 0)
        push!(t_history, t)
        push!(N_history, copy(N))
    end
    return t_history, N_history
end

# Persistence / uncertainty helpers for the asymmetry index.
# A_F spikes can arise from regime shifts, sampling noise, time-lag mismatch or
# non-stationarity. Require persistence across windows and compare to a null.
"""
    persistent_asymmetry(AF_series; threshold=0.2, min_run=3)

Returns true if `AF_series` contains a run of at least `min_run` consecutive
values above `threshold`. A single spike is not treated as a tipping signal.
"""
function persistent_asymmetry(AF_series::AbstractVector{<:Real};
                              threshold::Real=0.2, min_run::Int=3)
    run = 0
    for v in AF_series
        run = v > threshold ? run + 1 : 0
        if run >= min_run
            return true
        end
    end
    return false
end

"""
    asymmetry_null(L_series; n_perm=200)

Empirical null distribution of A_F under row/column permutations of each L.
Returns a vector of null A_F values for comparison with the observed index.
"""
function asymmetry_null(L_series::AbstractVector{<:AbstractMatrix}; n_perm::Int=200)
    out = Float64[]
    for L in L_series
        L = Matrix{Float64}(L)
        n = size(L, 1)
        for _ in 1:n_perm
            P = randperm(n)
            Lp = L[P, P]
            push!(out, compute_matrix_asymmetry(Lp))
        end
    end
    return out
end

# ------------------------------------------------------------------
# 4. Corrected thermodynamic matrices (biomass normalized)
# ------------------------------------------------------------------
function run_ibm_step(biomass_densities::AbstractVector{<:Real}, params::Dict)
    biomass_densities = max.(biomass_densities, 1e-9)
    num_species_local = length(biomass_densities)
    species_means = get(params, :species_ref_masses, ones(num_species_local))
    interaction_matrix = get(params, :interaction_matrix, Matrix{Float64}(I, num_species_local, num_species_local))
    carrying_capacities = get(params, :carrying_capacities, fill(Inf, num_species_local))
    growth_rates = species_means .^ (-0.25)
    limiter = 1.0 .- (biomass_densities ./ carrying_capacities)
    return (growth_rates .* biomass_densities .* limiter) .-
           (growth_rates .* (interaction_matrix * biomass_densities))
end

"""
    calculate_thermodynamic_matrices(biomasses, step_func, params)

Canonical empirical estimator of L (Jacobian route): L = -A*g^{-1}.
Corrected version: g uses intensive biovolume concentration b_i = B_i / V
(total biomass normalized), not raw biomass.
"""
function calculate_thermodynamic_matrices(biomasses::AbstractVector{<:Real},
                                          step_func, params::Dict)
    biomasses = max.(biomasses, 1e-9)
    A = ForwardDiff.jacobian(N -> step_func(N, params), biomasses)
    # Corrected normalizing factor: total biovolume V
    b, V = biovolume_concentration(biomasses)
    g = Diagonal(1.0 ./ max.(b, 1e-12))  # Hessian of mixing entropy S=-sum b ln b (fraction coords); see paper Sec. 3.2
    L_raw = A * inv(g)          # = A * Diagonal(b)  (A is negative-stable Jacobian near equilibrium)
    # Sign-flipped ecological-unit conductivity (asymmetric in general).
    # NOTE: strict Onsager symmetry is only expected after nondimensionalisation to
    # entropy units; in raw ecological units L_raw is generally only approximately
    # symmetric. Use onsager_asymmetry(L_raw) to quantify the departure.
    L_eco = -L_raw
    # Positive-definite symmetric part used for sigma and dynamics.
    S = 0.5 .* (L_eco .+ transpose(L_eco))
    F = eigen(Symmetric(S))
    lam = max.(F.values, 1e-9)
    L_pd = F.vectors * Diagonal(lam) * F.vectors'
    L_pd = 0.5 .* (L_pd .+ transpose(L_pd))
    return (A = A, g = g, L = L_pd, L_raw = L_eco)
end

# ------------------------------------------------------------------
# 5. Ecosystem simulation (corrected biomass normalization)
# ------------------------------------------------------------------
function initialize_agents(biomasses, ref_masses)
    agents = NamedTuple[]
    id_cnt = 1
    for (s, b) in enumerate(biomasses)
        n_ind = max(1, round(Int, b / max(ref_masses[s], 1e-9)))
        for _ in 1:n_ind
            m = rand(Normal(ref_masses[s], 0.1 * ref_masses[s]))
            push!(agents, (id = id_cnt, species = s, mass = max(m, 0.001)))
            id_cnt += 1
        end
    end
    return agents
end

function ecosystem_simulation(opts::NamedTuple)
    params = opts.params
    biomasses = opts.initial_biomass
    duration = opts.duration
    dt = opts.dt
    agg = opts.aggregation
    num_s = length(biomasses)
    agents = initialize_agents(biomasses, params[:species_ref_masses])
    detritus = 100.0
    remin_rate = 0.02
    b_hist = Vector{Float64}[]
    m_hist = Dict{String,Any}[]
    t_hist = Float64[]
    k_caps = copy(params[:carrying_capacities])
    producers = sortperm(params[:species_ref_masses])[1:min(5, num_s)]
    for i in 0:round(Int, duration/dt)
        t = i*dt
        curr_b = zeros(num_s)
        for a in agents; curr_b[a.species] += a.mass; end
        if i % max(1, round(Int, agg/dt)) == 0
            push!(b_hist, copy(curr_b)); push!(t_hist, t)
            res = calculate_thermodynamic_matrices(curr_b, run_ibm_step, params)
            A, g, L = res.A, res.g, res.L
            L_raw = res.L_raw
            m = Dict{String,Any}(
                "Time" => t,
                "Detritus_Pool" => detritus,
            )
            # metrics
            ev_A, ev_L = eigvals(A), eigvals(L)
            force = g * rand(Normal(0, 0.1), num_s)
            sigma = dot(L * force, force)
            m["Onsager asymmetry (raw)"] = round(compute_matrix_asymmetry(L_raw), sigdigits=4)
            m["Local Specific Dissipation (sigma)"] = round(sigma, sigdigits=4)
            m["System Resilience (Max Re)"] = round(maximum(real(ev_A)), sigdigits=4)
            m["Thermodynamic Admittance (Max)"] = round(maximum(real(ev_L)), sigdigits=4)
            push!(m_hist, m)
        end
        remin = detritus * remin_rate * dt
        detritus -= remin
        k_caps[producers] .+= (remin / length(producers))
        noise = randn()*0.05
        new_a = NamedTuple[]
        for a in agents
            sc = (a.mass^-0.25)*dt
            gr = a.species in producers ? 0.01+noise : 0.01
            if a.species == argmin(params[:species_ref_masses])
                ing = min(detritus*0.01, a.mass*0.1)*dt; detritus -= ing; um = a.mass + ing*0.5
            else; um = a.mass + (a.mass^0.75*gr)*dt; end
            if rand() > (clamp(sc*(curr_b[a.species]/k_caps[a.species]), 0, 1) +
                         clamp(sc*((params[:interaction_matrix]*curr_b)[a.species]/max(curr_b[a.species],1e-6)), 0, 1))
                push!(new_a, (id=a.id, species=a.species, mass=um))
                if rand() < clamp(sc*0.8, 0, 1)
                    push!(new_a, (id=length(new_a)+10^7, species=a.species, mass=params[:species_ref_masses][a.species]))
                end
            else
                detritus += a.mass
            end
        end
        agents = isempty(new_a) ? initialize_agents(biomasses.*0.1, params[:species_ref_masses]) : new_a
    end
    if isempty(b_hist)
        push!(b_hist, zeros(num_s)); push!(t_hist, 0.0)
    end
    if isempty(m_hist)
        push!(m_hist, Dict{String,Any}("Time" => 0.0, "Detritus_Pool" => detritus))
    end
    b_mat = hcat([b for b in b_hist]...)'
    biomass_df = DataFrame(b_mat, [Symbol("Species_", j) for j in 1:num_s])
    biomass_df[!, :Time] = t_hist
    metrics_df = DataFrame(m_hist)
    return (biomass = biomass_df, metrics = metrics_df, params = params)
end

function simulation_options(; n_species=10, type="temperate", initial_biomass=nothing,
                            duration=365.0, dt=0.1, aggregation=10.0, kwargs...)
    params = generate_ecosystem_parameters(type; num_species_override=n_species)
    for (k, v) in kwargs; params[k] = v; end
    b0 = initial_biomass === nothing ? rand(n_species) .* params[:carrying_capacities] .* 0.5 : initial_biomass
    return (params=params, initial_biomass=b0, duration=duration, dt=dt, aggregation=aggregation)
end

function generate_ecosystem_parameters(st; num_species_override=nothing)
    n = something(num_species_override, 10)
    mu = st=="boreal" ? 10.0 : (st=="tropical" ? 12.0 : 11.0)
    k_dist = LogNormal(mu, 1.5)
    m_range = st=="high trophic level" ? (5.0, 15.0) :
              (st=="low trophic level" ? (1.0, 5.0) : (0.0, 10.0))
    masses = exp.(rand(n) .* (m_range[2]-m_range[1]) .+ m_range[1])
    return Dict(:species_ref_masses => masses,
                :interaction_matrix => construct_biological_matrix(n, masses),
                :carrying_capacities => rand(k_dist, n),
                :system_type => st)
end

function construct_biological_matrix(n, masses)
    A = zeros(n, n)
    for i in 1:n, j in 1:n
        if i == j; A[i,i] = 0.1; continue; end
        rat = masses[i]/masses[j]; r = rand()
        if 1.0 < rat < 1000.0 && r < 0.1
            s = 0.05*exp(-0.5*(log10(rat)-1.5)^2); A[j,i]+=s; A[i,j]-=0.1*s
        elseif 0.001 < rat < 0.1 && r < 0.15
            s = 0.02*rand(); A[j,i]+=s; A[i,j]-=0.4*s
        elseif 0.5 < rat < 2.0 && r < 0.17
            s = 0.01*rand(); A[i,j]-=s; A[j,i]-=s
        elseif 0.5 < rat < 2.0 && r < 0.27
            s = 0.01/(1.0+abs(log(rat))); A[i,j]+=s; A[j,i]+=s
        end
    end
    return A
end

something(x, y) = x === nothing ? y : x

# ------------------------------------------------------------------
# 6. Gillespie SSA (from ideas_ssa.md), corrected biomass normalization
# ------------------------------------------------------------------
struct EcoThermodynamicParams
    S::Int
    r::Vector{Float64}
    d::Vector{Float64}
    c::Vector{Float64}
    gamma::Matrix{Float64}
    M::Vector{Float64}
    V::Float64
    epsilon::Float64
    kB::Float64
end

function compute_biovolume_fractions(N::Vector{Int}, p::EcoThermodynamicParams)
    return (p.M .* Float64.(N)) ./ p.V
end

function evaluate_propensities_and_stoichiometry(N::Vector{Int}, p::EcoThermodynamicParams)
    propensities = Float64[]
    stoichiometry = Vector{Vector{Int}}()
    for i in 1:p.S
        a_birth = p.r[i] * (p.M[i]^(-0.25)) * Float64(N[i])
        push!(propensities, a_birth)
        nu = zeros(Int, p.S); nu[i] = 1; push!(stoichiometry, nu)
    end
    for i in 1:p.S
        if N[i] > 0
            a_death = p.d[i] * Float64(N[i]) + (p.c[i] / p.V) * Float64(N[i] * (N[i] - 1))
            push!(propensities, a_death)
            nu = zeros(Int, p.S); nu[i] = -1; push!(stoichiometry, nu)
        end
    end
    for i in 1:p.S, j in 1:p.S
        if i != j && p.gamma[i,j] > 0.0 && N[i] > 0 && N[j] > 0
            k_prey = Int(ceil(p.M[i] / (p.epsilon * p.M[j])))
            if N[j] >= k_prey
                a_pred = (p.gamma[i,j] / p.V) * (p.M[i]^(-0.25)) * Float64(N[i] * N[j])
                push!(propensities, a_pred)
                nu = zeros(Int, p.S); nu[i] = 1; nu[j] = -k_prey; push!(stoichiometry, nu)
            end
        end
    end
    return propensities, stoichiometry
end

function estimate_conductivity_matrix(N::Vector{Int}, N_ref::Vector{Float64}, p::EcoThermodynamicParams)
    S = p.S
    L = zeros(Float64, S, S)
    for i in 1:S
        L[i,i] = (p.d[i] + 2.0 * (p.c[i] / p.V) * Float64(N[i])) * (p.M[i]^(-0.25))
        for j in 1:S
            if i != j
                interaction_ij = (p.gamma[i,j] + p.gamma[j,i]) / 2.0
                mean_density = sqrt(max(1.0, Float64(N[i]) * Float64(N[j])))
                L[i,j] = (interaction_ij / p.V) * mean_density * ((p.M[i] * p.M[j])^(-0.125))
            end
        end
    end
    return L
end

function run_gillespie_eco_thermo(N_init::Vector{Int}, params::EcoThermodynamicParams, t_max::Float64;
                                  max_steps::Int=10^6)
    t = 0.0
    N = copy(N_init)
    N_ref = Float64.(N_init)
    t_history = Float64[t]
    N_history = [copy(N)]
    b_history = [compute_biovolume_fractions(N, params)]
    AF_history = Float64[0.0]
    n_steps = 0
    while t < t_max && n_steps < max_steps
        n_steps += 1
        a, nu_matrix = evaluate_propensities_and_stoichiometry(N, params)
        a0 = sum(a)
        if a0 <= 0.0; break; end
        r1, r2 = rand(), rand()
        dt = -log(r1) / a0
        threshold = r2 * a0
        a_cum = 0.0
        selected_k = 1
        for k in 1:length(a)
            a_cum += a[k]
            if a_cum >= threshold
                selected_k = k; break
            end
        end
        t += dt
        N .+= nu_matrix[selected_k]
        N .= max.(N, 0)
        N_ref .= 0.95 .* N_ref .+ 0.05 .* Float64.(N)
        L_t = estimate_conductivity_matrix(N, N_ref, params)
        AF_t = compute_matrix_asymmetry(L_t)
        push!(t_history, t)
        push!(N_history, copy(N))
        push!(b_history, compute_biovolume_fractions(N, params))
        push!(AF_history, AF_t)
    end
    return t_history, N_history, b_history, AF_history
end

end # module OnsagerNetwork
nothing
