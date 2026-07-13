import LinearAlgebra: Diagonal, I, eigvals, dot
import Distributions: Normal, LogNormal
import FiniteDiff
using StatsBase
import Statistics

struct Agent
    id::Int
    species::Int
    mass::Float64
end

const allometric_exponent = 0.25
const volume_element = 1.0

function manual_linreg(x::Vector{Float64}, y::Vector{Float64})
    n = length(x)
    if n < 2; return (0.0, 0.0); end
    mean_x, mean_y = Statistics.mean(x), Statistics.mean(y)
    num = sum((x[i] - mean_x) * (y[i] - mean_y) for i in 1:n)
    den = sum((x[i] - mean_x)^2 for i in 1:n)
    return den == 0 ? (0.0, 0.0) : (num / den, mean_y - (num / den) * manual_linreg(x,y)[1] * mean_x)
end

function initialize_agents(biomasses, ref_masses)
    agents = Agent[]
    id_cnt = 1
    for (s, b) in enumerate(biomasses)
        n_ind = max(1, round(Int, b / max(ref_masses[s], 1e-9)))
        for _ in 1:n_ind
            m = rand(Normal(ref_masses[s], 0.1 * ref_masses[s]))
            push!(agents, Agent(id_cnt, s, max(m, 0.001)))
            id_cnt += 1
        end
    end
    return agents
end

function run_ibm_step(biomass_densities::Vector{Float64}, params::Dict)
    biomass_densities = max.(biomass_densities, 1e-9)
    num_species_local = length(biomass_densities)
    species_means = get(params, :species_ref_masses, ones(num_species_local))
    interaction_matrix = get(params, :interaction_matrix, I(num_species_local))
    carrying_capacities = get(params, :carrying_capacities, fill(Inf, num_species_local))
    growth_rates = species_means .^ -allometric_exponent
    limiter = 1.0 .- (biomass_densities ./ carrying_capacities)
    return (growth_rates .* biomass_densities .* limiter) .- (growth_rates .* (interaction_matrix * biomass_densities))
end

function calculate_thermodynamic_matrices(biomasses, step_func, params)
    A = FiniteDiff.finite_difference_jacobian(N -> step_func(N, params), biomasses)
    g = Diagonal(1.0 ./ max.(biomasses, 1e-6))
    L_raw = A * inv(g)
    L = 0.5 * (L_raw + L_raw')
    return A, g, L
end

function compute_system_metrics(A, g, L, agents=nothing)
    ev_A, ev_L = eigvals(A), eigvals(L)
    force = g * rand(Normal(0, 0.1), size(A, 1))
    sigma = dot(L * force, force)
    metrics = Dict{String, Any}("Local Specific Dissipation (sigma)" => round(sigma, sigdigits=4),
                   "System Resilience (Max Re(λ) of Community Matrix)" => round(maximum(real(ev_A)), sigdigits=4),
                   "Thermodynamic Admittance (Max λ of Conductivity Matrix)" => round(maximum(real(ev_L)), sigdigits=4))
    if agents !== nothing
        metrics["Aggregated Leslie Matrix"] = round.(I(size(A, 1)) + A, digits=4)
        masses = [a.mass for a in agents]
        h = fit(Histogram, log.(masses), nbins=max(2, round(Int, sqrt(length(agents)))))
        v = h.weights .> 0
        metrics["Size-Abundance Relationship (Slope)"] = sum(v) > 1 ? round(manual_linreg((h.edges[1][1:end-1]+h.edges[1][2:end])[v]./2, log.(h.weights[v]+1e-9))[1], sigdigits=4) : 0.0
        cts = [count(a->a.species==i, agents) for i in 1:size(A,1)]
        ps = filter(>(0), cts ./ length(agents))
        metrics["Shannon Diversity Index"] = round(-sum(p*log(p) for p in ps), sigdigits=4)
    end
    return metrics
end

function lechatons_options(; n_species=10, type="temperate", initial_biomass=nothing, duration=365.0, dt=0.1, aggregation=10.0, kwargs...)
    @assert n_species > 1 "Species count must be > 1"
    @assert duration > 0 && dt > 0 "Time parameters must be positive"
    params = generate_ecosystem_parameters(type; num_species_override=n_species)
    for (k, v) in kwargs; params[k] = v; end
    b0 = initial_biomass === nothing ? rand(n_species) .* params[:carrying_capacities] .* 0.5 : initial_biomass
    return (params=params, initial_biomass=b0, duration=duration, dt=dt, aggregation=aggregation)
end

function lechatons(opts)
    params, biomasses, duration, dt, agg = opts.params, opts.initial_biomass, opts.duration, opts.dt, opts.aggregation
    num_s = length(biomasses)
    agents = initialize_agents(biomasses, params[:species_ref_masses])
    detritus, remin_rate = 100.0, 0.02
    b_hist, m_hist, t_hist = Vector{Float64}[], Dict[], Float64[]
    k_caps = copy(params[:carrying_capacities])
    producers = sortperm(params[:species_ref_masses])[1:min(5, num_s)]
    for i in 0:round(Int, duration/dt)
        t = i*dt
        curr_b = zeros(num_s)
        for a in agents; curr_b[a.species] += a.mass; end
        if i % round(Int, agg/dt) == 0
            push!(b_hist, copy(curr_b)); push!(t_hist, t)
            A, g, L = calculate_thermodynamic_matrices(curr_b, run_ibm_step, params)
            m = compute_system_metrics(A, g, L, agents); m["Time"], m["Detritus_Pool"] = t, detritus
            push!(m_hist, m)
        end
        remin = detritus * remin_rate * dt
        detritus -= remin; k_caps[producers] .+= (remin / length(producers))
        noise, new_a = randn()*0.05, Agent[]
        for a in agents
            sc = (a.mass^-allometric_exponent)*dt
            gr = a.species in producers ? 0.01+noise : 0.01
            if a.species == argmin(params[:species_ref_masses])
                ing = min(detritus*0.01, a.mass*0.1)*dt; detritus -= ing; um = a.mass + ing*0.5
            else; um = a.mass + (a.mass^0.75*gr)*dt; end
            if rand() > (clamp(sc*(curr_b[a.species]/k_caps[a.species]), 0, 1) + clamp(sc*((params[:interaction_matrix]*curr_b)[a.species]/max(curr_b[a.species],1e-6)), 0, 1))
                push!(new_a, Agent(a.id, a.species, um))
                if rand() < clamp(sc*0.8, 0, 1); push!(new_a, Agent(length(new_a)+10^7, a.species, params[:species_ref_masses][a.species])); end
            else; detritus += a.mass; end
        end
        agents = isempty(new_a) ? initialize_agents(biomasses.*0.1, params[:species_ref_masses]) : new_a
    end
    biomass_df = DataFrame(vcat(transpose.(b_hist)...), [Symbol("Species_", j) for j in 1:num_s]) |> df -> (df[!,:Time]=t_hist; df)
    return (biomass=biomass_df, metrics=DataFrame(m_hist), params=params)
end

function lechatons_plot(res; title="Ecosystem Dashboard")
    b_df, m_df, params = res.biomass, res.metrics, res.params
    num_s = size(b_df, 2) - 1
    masses = params[:species_ref_masses]
    metabolic_rates = masses .^ 0.75
    p1 = plot(b_df.Time, Matrix(b_df[:, 1:num_s]), title="Biomass Dynamics", xlabel="Time", ylabel="Biomass", legend=false, alpha=0.6)
    p2 = plot(m_df.Time, m_df[!, "Local Specific Dissipation (sigma)"], title="Specific Dissipation (σ)", xlabel="Time", ylabel="σ", color=:purple, lw=2)
    p3 = plot(m_df.Time, m_df[!, "System Resilience (Max Re(λ) of Community Matrix)"], title="Resilience (Max Re(λ))", xlabel="Time", ylabel="Rate", color=:red, lw=2)
    p4 = plot(m_df.Time, m_df[!, "Shannon Diversity Index"], title="Shannon Diversity (H')", xlabel="Time", ylabel="Index", color=:green, lw=2)
    p5 = plot(m_df.Time, m_df.Detritus_Pool, title="Detritus Pool", xlabel="Time", ylabel="Mass", color=:brown, lw=2)
    p6 = plot(m_df.Time, m_df[!, "Size-Abundance Relationship (Slope)"], title="Size-Abundance Slope", xlabel="Time", ylabel="Slope", color=:orange, lw=2)
    p7 = plot(title="Size-Abundance Spectrum", xlabel="log10(M)", ylabel="log10(N)", legend=:bottomleft)
    for idx in [1, div(nrow(b_df), 2), nrow(b_df)]
        b_vals = Vector(b_df[idx, 1:num_s])
        abund = b_vals ./ masses
        scatter!(p7, log10.(masses), log10.(abund .+ 1e-9), label="Day $(round(b_df.Time[idx]))", alpha=0.5)
    end
    p8 = plot(title="Metabolic Density", xlabel="log10(Metabolic Rate)", ylabel="Density")
    for idx in [1, nrow(b_df)]
        b_vals = Vector(b_df[idx, 1:num_s])
        data = Float64[]
        for s in 1:num_s
            n_pseudo = max(1, round(Int, b_vals[s]))
            append!(data, fill(log10(metabolic_rates[s]), n_pseudo))
        end
        if !isempty(data); density!(p8, data, label="Day $(round(b_df.Time[idx]))", lw=2); end
    end
    return plot(p1, p2, p3, p4, p5, p6, p7, p8, layout=(4,2), size=(1100, 1200), plot_title=title)
end

function generate_ecosystem_parameters(st; num_species_override=nothing)
    n = something(num_species_override, 10)
    mu = st=="boreal" ? 10.0 : (st=="tropical" ? 12.0 : 11.0)
    k_dist = LogNormal(mu, 1.5)
    m_range = st=="high trophic level" ? (5.0, 15.0) : (st=="low trophic level" ? (1.0, 5.0) : (0.0, 10.0))
    masses = exp.(rand(n) .* (m_range[2]-m_range[1]) .+ m_range[1])
    return Dict(:species_ref_masses => masses, :interaction_matrix => construct_biological_matrix(n, masses), :carrying_capacities => rand(k_dist, n), :system_type => st)
end

function construct_biological_matrix(n, masses; kwargs...)
    A = zeros(n, n)
    for i in 1:n, j in 1:n
        if i == j; A[i,i] = 0.1; continue; end
        rat, r = masses[i]/masses[j], rand()
        if 1.0 < rat < 1000.0 && r < 0.1; s = 0.05*exp(-0.5*(log10(rat)-1.5)^2); A[j,i]+=s; A[i,j]-=0.1*s;
        elseif 0.001 < rat < 0.1 && r < 0.15; s = 0.02*rand(); A[j,i]+=s; A[i,j]-=0.4*s;
        elseif 0.5 < rat < 2.0 && r < 0.17; s = 0.01*rand(); A[i,j]-=s; A[j,i]-=s;
        elseif 0.5 < rat < 2.0 && r < 0.27; s = 0.01/(1.0+abs(log(rat))); A[i,j]+=s; A[j,i]+=s; end
    end
    return A
end

something(x, y) = x === nothing ? y : x

function run_extended_stochastic_ibm(initial_biomass, params, duration, dt, agg)
    opts = (params=params, initial_biomass=initial_biomass, duration=duration, dt=dt, aggregation=agg)
    res = lechatons(opts)
    return res.biomass, res.metrics
end

function analyze_leslie_stability(df)
    sr, dr = Float64[], Float64[]
    for i in 1:nrow(df)
        evs = sort(abs.(eigvals(df[i, "Aggregated Leslie Matrix"])), rev=true)
        push!(sr, evs[1]); push!(dr, length(evs)>1 && evs[2]>1e-9 ? evs[1]/evs[2] : 1.0)
    end
    return plot(plot(df.Time, sr, title="Spectral Radius", lw=2, color=:orange), plot(df.Time, dr, title="Damping Ratio", lw=2, color=:darkcyan), layout=(2,1))
end




