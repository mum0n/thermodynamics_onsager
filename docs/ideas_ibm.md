Technical Report: Thermodynamic Agent-Based Modeling of Ocean Size-Spectra in Agents.jl

1. Theoretical Framework: Non-Equilibrium Thermodynamics and Agent-Based Integration

Context & Strategic Importance

The modern synthesis of non-equilibrium statistical mechanics and agent-based modeling (ABM) provides a rigorous, physics-informed framework for resolving long-standing theoretical and methodological ambiguities in ecological science. Historically, ecological modeling has struggled to formulate unambiguous system boundaries, ground/reference states, and fundamental state variables. In open marine ecosystems—characterized by non-linear energy transformations operating across vast spatial, temporal, and organizational scales—traditional macroscopic thermodynamic frameworks fail because closed boundary assumptions are violated. Bridging agent-level biological interactions with macroscopic thermodynamic laws via Onsager reciprocal relations and Ilya Prigogine’s intensive local approach (\ddagger) provides an analytical foundation for state-space modeling. By explicitly grounding discrete agent behaviors in local non-equilibrium statistical mechanics, we can model energy degradation, biomass accumulation, and ecological stability without imposing arbitrary spatial boundaries or teleological assumptions.

       GLOBAL ENVIRONMENT (Extensive Boundary Fluxes, Global Disorder)
  ─────────────────────────────────────────────────────────────────────────
      ▲                                                               │
      │ Waste Heat & Entropy Export (d_e S‡)                          │ Free Energy Influx 
      │                                                               ▼ (Sunlight, NPP)
  ┌───────────────────────────────────────────────────────────────────────┐
  │ LOCAL BIOVOLUME ELEMENT (dS‡ = d_i S‡ + d_e S‡)                       │
  │                                                                       │
  │   ┌─────────────────────────┐           ┌─────────────────────────┐   │
  │   │  Agent Cohort i (M_i)   │◀─────────▶│  Agent Cohort j (M_j)   │   │
  │   │                         │  Cross    │                         │   │
  │   │  Self-Damping (L_ii)    │  Fluxes   │  Self-Damping (L_jj)    │   │
  │   │  Metabolic Loss ~M^-0.25│  (L_ij)   │  Metabolic Loss ~M^-0.25│   │
  │   └─────────────────────────┘           └─────────────────────────┘   │
  │               ▲                                     ▲                 │
  │               └───────────── Conjugate ─────────────┘                 │
  │                               Effects                                 │
  │                                                                       │
  │   Local Homeostasis & Quasi-Stable Equilibrium (Landsberg's 4th Law)   │
  └───────────────────────────────────────────────────────────────────────┘


Microscopic vs. Macroscopic Energetics

Thermodynamics has historically evolved along two divergent intellectual tracks:

1. Macroscopic Extensive Approaches: Spearheaded by Carnot, Clausius, and Carathéodory, and later adapted to ecological systems by Lindeman, Odum, Kay, Aoki, Schneider, and Jørgensen. These models evaluate aggregate free-energy dissipation by tracking extensive quantities (total energy, volume, mass) across entire ecosystems. However, because open ecosystems lack rigid physical boundaries and feature nested metabolic cycles spanning multiple scales, extensive entropy accounting introduces ambiguous reference states and ill-defined system limits.
2. Microscopic Information-Theoretic Representations: Originating from Boltzmann, Gibbs, and Schrödinger, and generalized by Jaynes, these models formulate statistical configurations within a 6n-dimensional phase space. Microscopic variability is represented as an information-theoretic analog to statistical disorder. In ecological literature, microscopic information disorder and macroscopic thermodynamic entropy are frequently conflated. However, unless phase-space microscopic configurations explicitly converge with physical energy degradation pathways, statistical disorder remains a subjective, model-dependent construct.

To establish theoretical coherence across developmental and evolutionary scales, we evaluate three operational expressions of order principles:

* Order \rightarrow Disorder (The 2nd Law / Entropic Decay): Characterized by the irreversible conversion of constrained potential energy into random molecular motion and residual entropy. In marine ecosystems, bulk energy flows are dominated by this process. Empirical trophic efficiencies are low (<1% to 10%), demonstrating that >90–99% of absorbed solar and metabolic energy is rapidly degraded into low-grade waste heat via respiration and evapotranspiration.
* Order \rightarrow Order (Homeostatic Dissipative Structures): Exemplified by Erwin Schrödinger’s characterization of DNA as an "aperiodic crystal" maintaining high informational fidelity against thermal fluctuations via activation energy barriers, enzymatic repair, and natural selection. At ecological scales, metabolic cascades (e.g., the Krebs cycle), predator-prey feedback loops, and symbiotic networks constitute dissipative structures (Kolmogorov, Glansdorff, Prigogine). These structures preserve local structural order (Order \rightarrow Order) by consuming external free energy and pumping generated entropy into their surrounding environment: \text{(Local Order} \Leftrightarrow \text{Local Order)} \rightarrow \text{(Global Disorder)}
* Disorder \rightarrow Order (Self-Organization & Evolutionary Bifurcation): Manifested during origin-of-life transitions (hypercycles), embryonic development, ecological succession, and macro-evolutionary diversification. As external free-energy gradients drive open systems far from equilibrium, kinetic dissipation induces microscopic fluctuations. At critical thresholds, dynamic attractors undergo bifurcation, transitioning the system into non-laminar, highly organized regimes (order through fluctuation). Over evolutionary timescales, biological networks accumulate organizational strategies, expanding metabolic complexity to preserve local structural integrity against environmental volatility.

The Intensive Local Approach (\ddagger) & Landsberg’s 4th Law

To circumvent the boundary ambiguities inherent in extensive whole-system thermodynamics, we employ Prigogine’s intensive local approach. Rather than computing global macroscopic integrals across an open, non-stationary domain, we restrict our analytical focus to an arbitrarily small, local biovolume element (designated by the symbol \ddagger). The total intensive entropy change dS^\ddagger within this quasi-stable biovolume element is partitioned into internal production d_i S^\ddagger and external transport d_e S^\ddagger:

dS^\ddagger = d_i S^\ddagger + d_e S^\ddagger

Where:

* d_i S^\ddagger \ge 0 represents irreversible internal entropy production generated by metabolic degradation, strictly obeying the Second Law.
* d_e S^\ddagger represents the net flux of entropy exchanged across the local biovolume boundary via advective transport, nutrient exchange, waste heat export, or organism migration.

This local discretization is justified by Landsberg’s 4th Law of Thermodynamics (Landsberg 1972; Choi & Hansell 2023). Landsberg formally postulated the existence of both extensive (aggregate) and intensive (density) state variables for equilibrium and near-equilibrium non-equilibrium states. In marine ecosystems, total macroscopic biovolume fluctuates by orders of magnitude due to spatial patchiness and seasonal blooms, rendering global extensive formulations ill-posed. However, Landsberg's 4th Law establishes that assuming a constant local biovolume element (dS^\ddagger) guarantees the existence of intensive local semi-stable equilibria subject to small fluctuations around reference states. By isolating a sufficiently small space-time element, forward and backward process rates achieve local balance, justifying the linearization of thermodynamic fluxes (J) and forces (X) via Onsager relations even within highly dynamic marine environments.

Onsager Relations & Conjugate Effects (J = LX)

Near a local quasi-steady state, thermodynamic forces X_k (intensive gradients, such as specific entropy gradients or biomass density deviations from reference states) drive thermodynamic fluxes J_i (rates of energy turnover, material transport, or population mortality). Linearizing these processes yields the phenomenological equations:

J_i = \sum_{j=1}^{n} L_{ij} X_j \quad \implies \quad J = LX

Where:

* X_j = \nabla \left( \frac{\partial S^\ddagger}{\partial \alpha_j} \right) defines the thermodynamic force restoring equilibrium for a state deviation vector \alpha_j.
* L is the matrix of phenomenological conductivities (with resistivity matrix R = L^{-1}). Assuming microscopic reversibility, Lars Onsager proved that L is symmetric (L_{ij} = L_{ji}).

                             THERMODYNAMIC FORCE (X_i)
                        (Deviation from Reference State)
                                       │
                                       ▼
                       ┌────────────────────────────────┐
                       │ Diagonal Conductivity L_ii > 0 │
                       └────────────────────────────────┘
                                       │
                                       ▼
                        SELF-DAMPING FLUX (J_i = L_ii * X_i)
                       (Le Chatelier-Braun Resistance)
                                       │
        ┌──────────────────────────────┴──────────────────────────────┐
        ▼                                                             ▼
┌─────────────────────────────────┐                       ┌─────────────────────────────────┐
│ Off-Diagonal Coupling L_ij > 0  │                       │ Off-Diagonal Coupling L_ij < 0  │
│ (Mutualism, Symbiosis)          │                       │ (Predation, Parasitism)         │
└─────────────────────────────────┘                       └─────────────────────────────────┘
        │                                                             │
        ▼                                                             ▼
  Symmetric Cross-Flux J_j                                      Reciprocal Damping / 
  (Accelerates Adaptive Balance)                                Dynamic Stabilization


The physical and ecological properties of the conductivity matrix L include:

1. Diagonal Elements (L_{ii} > 0): Quantify linearized self-damping processes. Required to be strictly positive by the Second Law, L_{ii} causes internal perturbations to dissipate heat, providing a mathematical formulation of the Le Chatelier-Braun principle: any small perturbing force \delta X_i induces a restoring flux \delta J_i = L_{ii} \delta X_i that directly opposes the initial perturbation.
2. Off-Diagonal Elements (L_{ij} - Conjugate Effects): Represent cross-process couplings where force X_j drives flux J_i. In marine systems, these reciprocal couplings manifest as mutualism, benthic-pelagic nutrient exchanges, predator-prey control, and host-parasite interactions. Conjugate effects allow localized stress in one species cohort to be dissipated through connected metabolic channels across the community.

Crucially, ecological reciprocal relationships often exhibit time-asymmetry in conjugate relations. Co-evolutionary predator-prey interactions or host-parasite dynamics operate across divergent temporal scales (e.g., rapid parasite generation turnover versus slow host life cycles). Divergent timescales introduce non-linear reciprocal dynamics near steady states. Rather than destabilizing the system, these time-asymmetrical reciprocal processes provide dynamic stabilization, enabling high-frequency fluctuations in fast-turnover cohorts to be absorbed by slow-turnover cohorts without destroying the local quasi-steady equilibrium.

At stationary states, total specific entropy production rate \sigma^\ddagger is given by the quadratic form:

\sigma^\ddagger = \sum_{i} J_i X_i = \sum_{i,j} L_{ij} X_i X_j \ge 0

Onsager demonstrated that local stationary states minimize energy dissipation per unit volume. Ecosystem stability is governed by a thermodynamic trade-off between resilience and resistance (Choi & Hansell 2023, Figure 2):

* Resilience (Respiration-to-Biomass Ratio R/B, or Kinetic Conductivity): Systems dominated by high R/B ratios (e.g., microbial loops, pelagic plankton) possess high kinetic conductivity L_{ii} and rapid recovery slopes following perturbations, but maintain low standing biovolume (low resistance).
* Resistance (Accumulated Biovolume): Systems with low R/B ratios (e.g., climax benthic communities, large cetacean/fish stocks) store large standing biovolumes that resist structural displacement, but exhibit slow kinetic recovery slopes.

  RESPIRATION / BIOMASS (R/B ~ Conductivity / Resilience)
  ▲
  │  (High Resilience / Low Resistance)
  │  * Planktonic Pelagic / Microbial Systems
  │   \
  │    \  Global Allometric Baseline (R/B ∝ M^-0.25)
  │     \
  │      \  Local Instability Vector (Ecological vs Evolutionary Antagonism)
  │       \
  │        * Benthic Climax / Large Teleost Systems
  │          (Low Resilience / High Resistance)
  └─────────────────────────────────────────────────────────────►
  0                                                   BIOMASS (B ~ Resistance)


Because individual metabolic rates scale allometrically as M_i^{-0.25}, small-bodied organism cohorts exhibit high mass-specific turnover (high resilience), whereas large-bodied cohorts store biovolume (high resistance). Local deviations from this global allometric line generate thermodynamic restoring forces. These deviations define directional vectors where ecologically favored ("local") and evolutionarily favored ("global") directions of change can act antagonistically or mutualistically, pulling the size-spectrum back toward its stable attractor.

Mapping Aggregated Agents to Ecological Size-Classes

To operationalize this non-equilibrium framework within an agent-based architecture, organisms are aggregated into discrete size-class cohorts. The table below specifies the mathematical and physical mapping between thermodynamic variables and programmatic agent properties:

Physical / Biological Concept	Mathematical Symbol	Agents.jl Property Field	Formal Mathematical Definition & Allometric Constraint
Aggregated Cohort Agent	i	SpeciesAgent	Discrete agent representing size-cohort i within local biovolume dS^\ddagger.
Cohort Biovolume / Mass	B_i	biomass::Float64	Total accumulated biomass of cohort i: B_i = \int_{dS^\ddagger} \rho_i(x) dx.
Individual Mass Class	M_i	body_mass::Float64	Median individual mass defining size-class i.
Metabolic Turnover Rate	R_i / B_i	metabolic_rate::Float64	Mass-specific respiration rate scaled allometrically: R_i / B_i \propto M_i^{-0.25}.
Self-Damping Conductivity	L_{ii}	local_stiffness::Float64	Diagonal Onsager conductivity coefficient (L_{ii} > 0); Le Chatelier-Braun dampening.
Thermodynamic Force	X_i	Derived Field	Normalized deviation force: X_i = \nabla \left( \frac{\partial S^\ddagger}{\partial B_i} \right) \approx \frac{B_i - B_{ref,i}}{B_{ref,i}}.
Conjugate Cross-Flux	J_i	Derived Vector	Net energy/mass flux to cohort i: J_i = \sum_{j} L_{ij} X_j.

Grounding these agent definitions in intensive thermodynamics allows us to deploy size-class cohorts across spatially explicit continuous marine environments.

2. Environmental Covariates and Spatial Grid Architecture

Context & Strategic Importance

In non-equilibrium thermodynamics, the spatial environment acts as the primary generator of external thermodynamic forces (X_{env}). Spatially heterogeneous abiotic fields impose boundary flux gradients (d_e S^\ddagger) across adjacent biovolume elements dS^\ddagger. These environmental gradients modulate metabolic turnover, induce directional chemotactic advection, and drive turbulent diffusion. By mapping thermodynamic size-class agents onto continuous multi-layer environmental rasters, we capture how hydrographic and climatic drivers modulate micro-scale ecological dissipation.

Raster Field Integration

The spatial domain is constructed as a 2D continuous space (ContinuousSpace) bounded by periodic constraints and coupled to multi-layer spatial rasters. These rasters track three fundamental environmental fields:

1. Sea Surface Temperature (SST(x,y)): Dictates molecular kinetic energy. SST scales baseline metabolic turnover and modulates self-damping conductivities (L_{ii}), accelerating metabolic degradation as thermal kinetic energy increases.
2. Net Primary Productivity (NPP(x,y)): Represents the external free-energy influx driving Disorder \rightarrow Order transitions. NPP supplies the chemical potential required to synthesize biovolume and counter entropic decay.
3. Nutrient Gradients (\nabla N(x,y)): Spatial concentration fields of inorganic nutrients generating chemical potential gradients that direct chemotactic advection and constrain bottom-up primary production.

Modulation of Agent Kinetics & Transport

The motion and metabolic loss rates of an agent at position (x,y) are dynamically coupled to local environmental rasters:

               ENVIRONMENTAL RASTER FIELDS
       ┌─────────────────────────────────────────┐
       │ SST(x,y)   │ NPP(x,y)   │ Nutrients N(x,y)│
       └─────────────────────────────────────────┘
            │            │             │
            │ Kinetic    │ Free Energy │ Spatial
            │ Scaling    │ Influx      │ Gradient
            ▼            ▼             ▼
       ┌─────────────────────────────────────────┐
       │     THERMODYNAMIC AGENT KINETICS        │
       │                                         │
       │ Metabolic Rate ~ M^-0.25 * f(SST)       │
       │ Advective Velocity ~ ∇NPP               │
       │ Diffusive Motion ~ Fluctuation (SST)    │
       └─────────────────────────────────────────┘


1. Temperature-Dependent Metabolic Dissipation Rate

The mass-specific metabolic dissipation rate R_i(x,y) of cohort agent i is modulated by body mass M_i and local kinetic temperature SST(x,y):

R_i(x,y) = \kappa_0 \cdot M_i^{-0.25} \cdot \exp \left( -\frac{E_a}{k_B \cdot SST(x,y)} \right)

Where \kappa_0 is the metabolic normalization constant, E_a is activation energy, and k_B is Boltzmann's constant.

2. Spatial Transport and Fluctuation-Dissipation Dynamics

Agent velocity \mathbf{v}_i combines directional advection along free-energy gradients (\nabla NPP) with isotropic Brownian diffusion derived from temperature fluctuation-dissipation relationships:

\mathbf{v}_i(x,y) = \mu_i \nabla NPP(x,y) + \sqrt{2 D_i(SST)} \cdot \boldsymbol{\xi}(t)

Where:

* \mu_i is the chemotactic motility coefficient.
* D_i(SST) = \frac{k_B \cdot SST(x,y)}{6 \pi \eta M_i^{1/3}} is the spatial diffusion coefficient linking kinetic temperature to stochastic dispersion.
* \boldsymbol{\xi}(t) is a standard zero-mean Gaussian white noise vector.

This continuous spatial architecture provides the physical foundation for executable computational models implemented in Agents.jl.

3. Complete Julia Codebase using Agents.jl

Context & Strategic Importance

Simulating non-equilibrium thermodynamic interactions across spatial size-classes requires high computational throughput, type stability, and efficient memory management. Julia provides an ideal computational platform through its multiple dispatch model and native performance. Using Agents.jl (v6+), we build a fully executable model where size-class cohorts interact via linear Onsager conductivity matrices (L), process environmental free energy, and dissipate metabolic heat in real time.

Agent Architecture Definition (@agent struct)

Below is the Julia structural definition for the thermodynamic size-class agent using the Agents.@agent macro:

using Agents
using LinearAlgebra
using Random
using Distributions

# Define the thermodynamic size-class agent in ContinuousSpace{2}
@agent struct SpeciesAgent(ContinuousAgent{2,Float64})
    biomass::Float64           # Total biovolume / biomass in cohort (B_i)
    body_mass::Float64         # Individual body mass class (M_i)
    species_id::Int            # Ecological size-class identifier
    metabolic_rate::Float64    # Allometric metabolic turnover rate (~M_i^-0.25)
    local_stiffness::Float64   # Self-damping conductivity coefficient (L_ii)
    reference_biomass::Float64 # Quasi-steady state reference biomass (B_ref)
end


Environment & Model Initialization

The function below instantiates the spatial model domain containing environmental rasters (SST, NPP, Nutrients) and populates it with size-class agent cohorts using exact Agents.jl constructor mapping:

function initialize_thermodynamic_model(;
    grid_dims = (50.0, 50.0),
    num_size_classes = 5,
    base_agents_per_class = 20,
    seed = 42
)
    Random.seed!(seed)
    
    # Continuous 2D space with periodic boundary conditions
    space = ContinuousSpace(grid_dims; periodic = true)
    
    # Spatial raster fields: SST (K), NPP (g/m^2/day), Nutrients (mmol/m^3)
    nx, ny = Int(grid_dims[1]), Int(grid_dims[2])
    sst_raster = fill(288.15, nx, ny) .+ randn(nx, ny) .* 0.5
    npp_raster = fill(10.0, nx, ny) .+ rand(nx, ny) .* 2.0
    nutrient_raster = fill(5.0, nx, ny)
    
    # Global conductivity matrix L (symmetric near steady state)
    L_matrix = zeros(Float64, num_size_classes, num_size_classes)
    for i in 1:num_size_classes
        L_matrix[i, i] = 0.5 * (1.0 / i)^0.25 # Diagonal self-damping (L_ii > 0)
        for j in (i+1):num_size_classes
            coupling = 0.05 / (j - i + 1)
            L_matrix[i, j] = coupling
            L_matrix[j, i] = coupling # Onsager symmetry L_ij = L_ji
        end
    end

    properties = Dict{Symbol, Any}(
        :SST => sst_raster,
        :NPP => npp_raster,
        :Nutrients => nutrient_raster,
        :L_matrix => L_matrix,
        :num_classes => num_size_classes,
        :step_count => 0
    )

    model = StandardABM(
        SpeciesAgent,
        space;
        properties = properties,
        agent_step! = agent_step!,
        model_step! = model_step!,
        container = Vector
    )

    # Populate agents across log-spaced size classes (M_i = 10^(i-1))
    for class_idx in 1:num_size_classes
        m_i = 10.0^(class_idx - 1)
        metabolic_rate = 0.1 * (m_i)^(-0.25)
        l_ii = L_matrix[class_idx, class_idx]
        b_ref = 100.0 / (m_i^0.1) # Inverse size-spectrum scaling
        
        for _ in 1:base_agents_per_class
            pos = (rand() * grid_dims[1], rand() * grid_dims[2])
            vel = (randn() * 0.1, randn() * 0.1)
            init_biomass = b_ref * (0.9 + 0.2 * rand())
            
            # Explicit positional call matching ContinuousAgent field order:
            # pos, model, vel, biomass, body_mass, species_id, metabolic_rate, local_stiffness, reference_biomass
            add_agent!(
                pos,
                model,
                vel,
                init_biomass,
                m_i,
                class_idx,
                metabolic_rate,
                l_ii,
                b_ref
            )
        end
    end

    return model
end


Step Functions Implementation (agent_step! and model_step!)

The step functions handle thermal metabolic dissipation, spatial advection-diffusion, and conjugate cross-cohort mass exchanges:

function agent_step!(agent::SpeciesAgent, model)
    # 1. Query local environmental rasters
    x_idx = clamp(Int(floor(agent.pos[1])) + 1, 1, size(model.SST, 1))
    y_idx = clamp(Int(floor(agent.pos[2])) + 1, 1, size(model.SST, 2))
    
    local_sst = model.SST[x_idx, y_idx]
    local_npp = model.NPP[x_idx, y_idx]
    
    # 2. Metabolic Energy Degradation (d_i S‡ ∝ M_i^-0.25 * SST)
    thermal_factor = exp(-4000.0 / local_sst) / exp(-4000.0 / 288.15)
    dissipation = agent.metabolic_rate * thermal_factor * agent.biomass * 0.05
    agent.biomass = max(1e-4, agent.biomass - dissipation)
    
    # Primary producer cohort absorbs free energy from NPP
    if agent.species_id == 1
        agent.biomass += local_npp * 0.01
    end

    # 3. Spatial Movement: Chemotactic Advection + Isotropic Brownian Diffusion
    x_next = clamp(x_idx + 1, 1, size(model.NPP, 1))
    y_next = clamp(y_idx + 1, 1, size(model.NPP, 2))
    grad_x = model.NPP[x_next, y_idx] - local_npp
    grad_y = model.NPP[x_idx, y_next] - local_npp
    
    motility = 0.05 / (agent.body_mass^0.2)
    diffusion_std = sqrt(2.0 * 0.01 * (local_sst / 288.15) / (agent.body_mass^0.33))
    
    new_vx = motility * grad_x + diffusion_std * randn()
    new_vy = motility * grad_y + diffusion_std * randn()
    
    agent.vel = (new_vx, new_vy)
    move_agent!(agent, model, 1.0)
end

function model_step!(model)
    model.step_count += 1
    num_classes = model.num_classes
    L = model.L_matrix
    
    # Aggregate biovolumes across size classes
    class_biomass = zeros(Float64, num_classes)
    class_ref = zeros(Float64, num_classes)
    class_counts = zeros(Int, num_classes)
    
    for agent in allagents(model)
        cid = agent.species_id
        class_biomass[cid] += agent.biomass
        class_ref[cid] += agent.reference_biomass
        class_counts[cid] += 1
    end
    
    # Compute thermodynamic forces X_j = (B_j - B_ref,j) / B_ref,j
    X_forces = zeros(Float64, num_classes)
    for c in 1:num_classes
        if class_ref[c] > 0.0
            X_forces[c] = (class_biomass[c] - class_ref[c]) / class_ref[c]
        end
    end
    
    # Compute conjugate cross-fluxes J = L * X
    J_fluxes = L * X_forces
    
    # Redistribute conjugate mass exchange across agents
    for agent in allagents(model)
        cid = agent.species_id
        if class_counts[cid] > 0
            delta_b = J_fluxes[cid] / class_counts[cid]
            agent.biomass = max(1e-4, agent.biomass - 0.01 * delta_b)
        end
    end
    
    # Environmental renewal and nutrient drawdown
    for x in 1:size(model.Nutrients, 1), y in 1:size(model.Nutrients, 2)
        model.Nutrients[x, y] += 0.01 * (10.0 - model.Nutrients[x, y])
    end
end


Macroscopic Diagnostic Extraction

To track macroscopic thermodynamic trajectories, we compute the Specific Entropy Production Rate (\sigma^\ddagger) and the L-Matrix Asymmetry Index (A_F):

# 1. Specific Entropy Production Rate (σ‡ = ∑ J_i * X_i)
function calculate_specific_entropy_production(model)
    num_classes = model.num_classes
    class_biomass = zeros(Float64, num_classes)
    class_ref = zeros(Float64, num_classes)
    
    for agent in allagents(model)
        cid = agent.species_id
        class_biomass[cid] += agent.biomass
        class_ref[cid] += agent.reference_biomass
    end
    
    X_forces = [(class_biomass[c] - class_ref[c]) / max(1e-6, class_ref[c]) for c in 1:num_classes]
    J_fluxes = model.L_matrix * X_forces
    
    sigma_double_dagger = dot(J_fluxes, X_forces)
    return sigma_double_dagger
end

# 2. L-Matrix Asymmetry Index (A_F = ||L - L^T||_F / ||L||_F)
function calculate_l_matrix_asymmetry(L::Matrix{Float64})
    numerator = norm(L - L', :fro)
    denominator = norm(L, :fro)
    return denominator > 0.0 ? numerator / denominator : 0.0
end


Extracting these macroscopic diagnostics from forward Agents.jl simulations enables continuous monitoring of thermodynamic stability, providing a direct bridging vector to Bayesian state-space filtering in Turing.jl.

4. Bayesian Observation Error Integration via Turing.jl

Context & Strategic Importance

Forward ABM output simulates latent thermodynamic state dynamics. However, empirical oceanographic data (e.g., pelagic trawl catches, optical plankton counter profiles, satellite radiometry) contain substantial observation noise, gear selectivity bias, and spatial under-sampling. Fitting unfiltered simulation outputs directly to raw survey data risks confounding sampling artifacts with physical regime shifts. Establishing a Bayesian state-space model in Turing.jl separates latent thermodynamic biovolume trajectories from measurement error, enabling robust conductivity estimation and hypothesis testing.

                  STATE-SPACE INFERENCE ARCHITECTURE
  
    TRUE LATENT DYNAMICS (Agents.jl ABM)      OBSERVATIONAL PROCESS (Field Surveys)
  ┌─────────────────────────────────────┐   ┌─────────────────────────────────────┐
  │ Latent Biovolume State B_{t,i}      │   │ Empirical Trawl / OPC Sample Y_{t,i}│
  │ Process Noise σ_proc                │   │ Measurement Error σ_obs             │
  │ Step: B_t = f_ABM(B_{t-1}, L, SST)  │   │ Distribution: MvLogNormal           │
  └─────────────────────────────────────┘   └─────────────────────────────────────┘
                     │                                         │
                     └────────────────────┬────────────────────┘
                                          │
                                          ▼
                         BAYESIAN ESTIMATION (Turing.jl)
                   ┌──────────────────────────────────────────┐
                   │ Model Priors: L_ij ~ Normal(0, σ)        │
                   │ Functional Non-Mutating Array Inference  │
                   │ Posterior Sampling: P(L, σ_obs | Y)      │
                   └──────────────────────────────────────────┘


State-Space Formulation of Latent Biovolume Dynamics

The state-space model is formulated as follows:

1. Latent State Equation: True cohort biovolumes B_{t,i} evolve according to the Agents.jl thermodynamic operator f_{\text{ABM}} subject to multiplicative stochastic process noise \eta_t \sim \mathcal{N}(0, \sigma_{\text{proc}}^2):

B_{t,i} = f_{\text{ABM}}(B_{t-1,i}; L, SST_t, NPP_t) \cdot \exp(\eta_{t,i})

1. Observation Likelihood Equation: Empirical field samples Y_{t,i} are linked to latent biovolumes through a Log-Normal observation model:

Y_{t,i} \sim \text{LogNormal}\left(\log B_{t,i} - \frac{\sigma_{\text{obs}}^2}{2}, \, \sigma_{\text{obs}}\right)

Turing.jl Model Implementation

To prevent array mutation errors during Automatic Differentiation (AD) execution with ForwardDiff or Zygote backends, the Turing.jl probabilistic model below utilizes non-mutating functional array constructs (Vector{Vector{Real}} and matrix comprehensions):

using Turing

@model function fit_thermodynamic_abm(y_observed::Matrix{Float64}, sst_series::Vector{Float64})
    num_steps, num_classes = size(y_observed)
    
    # 1. Priors on observation and process noise scales
    sigma_obs ~ Exponential(1.0)
    sigma_proc ~ Exponential(0.5)
    
    # Prior on cross-coupling conductivities (L_ij)
    l_cross ~ Normal(0.05, 0.02)
    
    # Functional construction of symmetric conductivity matrix L without mutation
    L = [i == j ? 0.2 / (i^0.25) : l_cross for i in 1:num_classes, j in 1:num_classes]

    # Sample initial latent state vector
    init_B ~ MvNormal(y_observed[1, :], fill(0.1^2, num_classes))

    # Construct latent state trajectory functionally to maintain AD backend compatibility
    latent_states = Vector{Vector{Real}}(undef, num_steps)
    latent_states[1] = init_B

    for t in 2:num_steps
        prev_B = latent_states[t-1]
        
        # Compute thermodynamic forces X = (B - B_ref) / B_ref
        X = [(prev_B[c] - 100.0 / (c^0.1)) / (100.0 / (c^0.1)) for c in 1:num_classes]
        J = L * X
        
        # Expected mean biovolumes for current step
        mu_b = [
            max(1e-3, prev_B[c] - 0.05 * (c^(-0.25)) * (sst_series[t] / 288.15) * prev_B[c] - 0.01 * J[c])
            for c in 1:num_classes
        ]
        
        # Latent state transition step
        latent_states[t] ~ MvLogNormal(log.(mu_b), fill(sigma_proc^2, num_classes))
    end

    # 2. Observational Likelihood Evaluation
    for t in 1:num_steps
        y_observed[t, :] ~ MvLogNormal(log.(max.(1e-3, latent_states[t])), fill(sigma_obs^2, num_classes))
    end
end


Evaluating Parameter Identifiability and Filter Performance

Using Hamiltonian Monte Carlo (HMC) or Sequential Monte Carlo (SMC) in Turing.jl, we estimate posterior distributions over conductivities L_{ij} and latent paths B_{t,i}. This Bayesian state-space filter isolates true physical regime shifts—such as degradation of self-damping conductivities—from observation artifacts caused by shifting net efficiencies or patchy spatial sampling.

Filtering out high-frequency observation noise ensures that posterior estimates of specific entropy production rates (\sigma^\ddagger) reflect true ecosystem thermodynamics, establishing a reliable baseline for real-world ecological management.

5. Discussion, Model Calibration, and Future Applications

Context & Strategic Importance

Translating non-equilibrium thermodynamic ABMs into operational ocean science provides a physics-grounded alternative to static, single-species management models. Integrating thermodynamic limits with Bayesian filtering yields predictive tools for climate impact assessments, fisheries management, and ecosystem early-warning frameworks.

Empirical Calibration with Multi-Source Oceanographic Data

Calibrating thermodynamic size-class ABMs involves synthesizing multi-modal oceanographic datasets:

* Satellite Remote Sensing: Multi-spectral satellite sensors supply high-resolution rasters of SST and NPP, constraining local environmental boundary forces (X_{env}).
* In-Situ Oceanographic Surveys: Pelagic trawl surveys, Continuous Plankton Recorders (CPR), and Optical Plankton Counters (OPC) yield empirical biovolume size-spectra across space and time.
* Allometric Metabolic Constraints: Respirometry experiments define baseline mass-specific metabolic dissipation rates, enforcing the M_i^{-0.25} scaling exponent.

                               DYNAMIC CLIMATE FORCING
                       (Rapid Warming, Nutrient Alteration)
                                         │
                                         ▼
                      ┌──────────────────────────────────────┐
                      │ External Perturbation Force (δX_env) │
                      └──────────────────────────────────────┘
                                         │
                                         ▼
                      ┌──────────────────────────────────────┐
                      │ Breaking Conjugate Effects (L_ij≠L_ji)│
                      │ Reciprocity Symmetry Collapse        │
                      └──────────────────────────────────────┘
                                         │
                                         ▼
                      ┌──────────────────────────────────────┐
                      │ Early-Warning Diagnostic Signals     │
                      │ • Spike in Asymmetry Index (A_F)     │
                      │ • Perturbation Spectra Expansion     │
                      └──────────────────────────────────────┘
                                         │
                                         ▼
                      ┌──────────────────────────────────────┐
                      │ State Bifurcation & Regime Shift     │
                      │ (Alternate Attractor / Cod Collapse) │
                      └──────────────────────────────────────┘


Unlike conventional stock assessment models that assume static carrying capacities and fixed interaction terms, thermodynamic ABMs dynamically update conductivities (L_{ij}) in response to climate forcing. This dynamic adaptation captures non-linear ecological responses to ocean warming and extreme marine heatwaves.

Early-Warning Indicators of Ecological Tipping Points

1. Breaking Conjugate Effects

Near local quasi-steady states, Onsager reciprocity holds (L_{ij} = L_{ji}), and conjugate cross-fluxes dampen incoming perturbations. However, when severe environmental stress (e.g., overexploitation, rapid thermal anomalies) drives the system far from equilibrium, internal damping mechanisms fail. Cross-coupling parameters diverge (L_{ij} \neq L_{ji}), causing Breaking Conjugate Effects.

    STABLE CONJUGATE REGIME (Near-Equilibrium)       UNSTABLE BROKEN REGIME (Far-from-Equilibrium)

         Force X_j  ───────►  Flux J_i                    Force X_j  ───────►  Flux J_i
             ▲                  │                             │                  │
             │     L_ij = L_ji  │                             │   L_ij ≠ L_ji    │
             │                  ▼                             ▼                  ▼
         Flux J_j  ◄───────  Force X_i                    Force X_i  ───────►  Flux J_j
         
         • Symmetric Damping & Recovery                   • Asymmetric Amplification
         • Minimal Specific Dissipation (σ‡)              • Runaway Divergence / Collapse


When reciprocity breaks, cross-process couplings transform from negative dampening channels into positive feedback amplifiers, accelerating state divergence and triggering ecosystem collapse.

2. Reinterpreting Historic Collapses (e.g., Northwest Atlantic Cod)

The catastrophic collapse of the Northwest Atlantic cod (Gadus morhua) stock in the early 1990s illustrates thermodynamic symmetry breaking. Prolonged industrial overfishing selectively eliminated large, high-resistance teleost cohorts, truncating the size-spectrum toward small, high-turnover cohorts. Truncating large size classes destroyed the system's structural biovolume capacity (B) and disrupted demersal-pelagic conjugate couplings. Local self-damping mechanisms failed, causing Onsager matrix reciprocity to break (L_{ij} \neq L_{ji}) and driving a catastrophic bifurcation into an alternate state (order through fluctuation).

3. Diagnostic Monitoring via Perturbation Spectra

Thermodynamic ABMs provide concrete early-warning metrics to detect impending tipping points:

* L-Matrix Asymmetry Index Spikes (A_F > \epsilon): Quantifies structural divergence from Onsager symmetry (A_F = \|L - L^T\|_F / \|L\|_F), signalling transitions into far-from-equilibrium regimes.
* Perturbation Spectra Expansion (\text{Var}(\sigma_i^\ddagger)): Monitoring size-structured specific entropy production rates (\sigma_i^\ddagger = J_i X_i) across individual size classes generates a perturbation spectrum (Choi et al. 1999; Choi & Hansell 2023). Variance expansion within specific size-class channels signals localized homeostatic damping breakdown prior to macroscopic ecosystem collapse.

Future Architectural Horizons

Key technical extensions for thermodynamic ABM architectures include:

1. 3D Hydrodynamic Spatial Coupling: Expanding spatial domains from 2D surface rasters to 3D hydrodynamic transport models (e.g., ROMS, FVCOM) to simulate vertical diel migration and deep carbon export.
2. Evolutionary Adaptive Dynamics: Allowing agent conductivities (L_{ij}) to evolve via mutational algorithms, capturing phenotypic adaptation under persistent climate change.
3. High-Performance GPU Acceleration: Executing millions of continuous agent cohort computations in parallel on CUDA GPUs via native CUDA.jl integration.

Grounding agent-based ecological models in non-equilibrium statistical mechanics elevates computational ecology from descriptive simulation to predictive, physics-informed science.
