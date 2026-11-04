---
title: "Reconciling Ecological Population Dynamics with Non-Equilibrium Thermodynamics: II. Empirical Validation, Allometric Cascades, and Non-Linear Regime Shifts"
header: "Choi (2026): Ecological Cascades"
date: '\today'
journal: 'biorxiv'
author:
- name: Jae S. Choi
  footnote: 1
  corresponding: true
  email: choi.jae.seok@gmail.com
  orcid: 0000-0003-3632-5723
affiliation:
- number: 1
  name: Bedford Institute of Oceanography, Fisheries and Oceans Canada, Dartmouth, Nova Scotia, Canada
keyword: |
  Keywords: Onsager Reciprocal Relations, Community Matrix, Phenomenological Conductivity, Fluctuation-Dissipation, Probability Circulation, Detailed Balance, Biomass Capacitance, Resistance, Resilience, Energy Dissipation Cascade, Biomass Size Spectrum, Spatiotemporal Hierarchy, Quasi-Potential Landscape, Early Warning Signals
abstract: |
  Theoretical ecology describes living communities through demographic interaction matrices that are fundamentally asymmetric due to directional trophic predation and body-size disparities. In the companion paper (Choi and Hansell 2026), the relationship between demographic models and physical thermodynamics was clarified by demonstrating that the demographic community matrix conflates underlying physical transport conductivities with heterogeneous biomass storage capacities. Through continuous Lyapunov covariance factorization, the demographic matrix resolves into a symmetric Onsager dissipative conductivity that drives monotonic downhill thermodynamic relaxation, and an antisymmetric probability circulation tensor that quantifies non-dissipative cyclic flows in state space. Here, this framework is tested empirically across contrasting biomes, extended to continuous allometric size spectra, and connected to multi-scale energy cascades and non-linear regime shifts. The empirical decomposition is evaluated on two canonical aquatic ecosystems: the detritus-buffered benthic cold-spring food web at Cone Spring and the solar-driven open-ocean plankton community at the Bermuda Atlantic Time-series Study (BATS) site in the Sargasso Sea. In Cone Spring, detrital biomass capacitance provides high entropic Resistance (shock absorption) and slow relaxation (oscillation period of 296 days) at a low stationary entropy production rate density (90.35 per year). In contrast, the upper mixed layer at BATS prioritizes kinetic Resilience (recovery turnover, oscillation period of approximately 40 to 42 days) over standing storage, operating at nearly triple the entropy production rate density (257.65 per year). Simulating industrial exploitation in an extended pelagic food web (NPZD-Fish) demonstrates that harvesting long-lived predatory fish strips slow biomass capacitance, increasing probability circulation volatility and driving entropy production to 425.03 per year, which flattens the stationary potential basin and preconditions the ecosystem for regime collapse. Extending the framework to continuous allometric size spectra via the Sheldon distribution and Kleiber scaling links organismal body mass to multi-scale impedance filtering analogous to the Kolmogorov turbulence cascade: macroscopic organisms act as structural capacitors that absorb bulk environmental forcing, cross-scale trophic and mechanical couplings circulate energy across size octaves, and microscopic organisms act as high-turnover dissipative sinks. Formal coordinate-invariance proofs, non-linear Helmholtz-Hodge and Fokker-Planck derivations, compositional coordinate breakdowns, stochastic master-equation algorithms, and electrical network dualities are provided in Appendices A to D, accompanied by an open-source Julia software implementation.

unnumberedsections: false
citeproc: true
citeproc-method: biblatex
biblatex: true
biblio-style: authoryear
biblatexoptions: |
 \usepackage[authordate, maxcitenames=1, uniquename=mininit, backend=biber, natbib]{biblatex-chicago}
csl: media/chicago-author-date.csl
bibliography: references.bib
documentclass: paper
papersize: letterpaper
fontsize: 11pt
output:
    pdf_document:
    html_document:
        css: media/default.css
        self_contained: no
---

# Introduction: Reconciling Ecological Dynamics Across Scales

Theoretical ecology and non-equilibrium physics share a common goal: understanding how complex, open systems maintain stability and persist under environmental variability. Historically, however, these disciplines developed along divergent paths. Theoretical ecology, tracing its origins to the Lotka-Volterra equations (Lotka 1925, Volterra 1926) and May's (1972, 1973) complexity-stability paradox, formalizes living communities through demographic community interaction matrices (Jacobians). These matrices are fundamentally asymmetric: directional predation, asymmetrical interference competition, and body size disparities mean that species effects on one another are rarely mutual or reciprocal ($A_{ij} \ne A_{ji}$).

In contrast, non-equilibrium physical thermodynamics, pioneered by Onsager (1931a,b) and extended by Prigogine (1947, 1955) and de Groot and Mazur (1962), characterizes irreversible transport processes through phenomenological conductivity matrices ($\mathbf{L}$). Grounded in the microscopic time-reversal invariance of thermal fluctuations (detailed balance), Onsager reciprocity dictates that phenomenological cross-conductivities are strictly symmetric ($L_{ij} = L_{ji}$; Casimir 1945).

When theoretical ecologists and physicists first attempted to map ecological communities onto thermodynamic networks, they encountered an apparent contradiction. Evaluating demographic interaction matrices directly, researchers found that predation inherently broke reciprocal symmetry. This led to the widespread conclusion that non-equilibrium thermodynamics is inapplicable to living communities (MacArthur 1970, Ulanowicz and Hannon 1987, Michaelian 2005, Chakrabarti and Ghosh 2009, Meysman and Bruers 2010).

In the companion paper (Choi and Hansell 2026), this theoretical tension was shown to stem from a conceptual conflation: the demographic community matrix $\mathbf{A}$ is not the physical Onsager conductivity $\mathbf{L}$. The demographic matrix describes the rate of change of population abundances ($\delta\dot{\mathbf{x}} = \mathbf{A}\delta\mathbf{x}$), whereas Onsager conductivities relate thermodynamic fluxes to intensive driving forces ($\mathbf{J} = \mathbf{L}\mathbf{X}$). The community matrix is a composite dynamical operator that conflates underlying physical transport conductivities with the heterogeneous biomass storage capacities of biological compartments. Through continuous Lyapunov covariance factorization ($\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} = -2\mathbf{D}_{\mathrm{sym}}$), the demographic matrix resolves into a symmetric Onsager dissipative conductivity $\mathbf{D}_{\mathrm{sym}}$ that satisfies the Second Law, and an antisymmetric probability circulation tensor $\boldsymbol{\Omega}$ that quantifies non-dissipative cyclic flows in state space sustained by continuous external energy throughput (Choi and Hansell 2026).

Building upon that theoretical foundation, the present work develops the empirical, multi-scale, and non-linear dimensions of this synthesis. First, the framework is evaluated empirically across contrasting aquatic biomes, comparing a benthic detritus-buffered cold spring (Cone Spring) with an open-ocean planktonic food web at the Bermuda Atlantic Time-series Study (BATS) site and an exploited marine pelagic fishery (NPZD-Fish). Second, the stability analysis is extended to continuous allometric size spectra by linking biomass capacitance and metabolic turnover to organismal body mass through Kleiber scaling and the Sheldon size spectrum. Third, a multi-scale energy cascade model analogous to Kolmogorov fluid turbulence is formulated to explain how macroscopic structural capacitors absorb bulk environmental forcing, cross-scale probability circulation transfers energy across size octaves, and microscopic organisms dissipate it into heat. Fourth, the linear theory is extended to non-linear Fokker-Planck quasi-potential landscapes, yielding physical early-warning diagnostics for catastrophic regime shifts. Formal coordinate-invariance proofs, non-linear phase-space derivations, compositional coordinate breakdowns, stochastic chemical master equations, and electrical circuit dualities are presented in Appendices A to D.


# The Dual Nature of Ecological Matrices: Conceptual Bridge

To understand why ecological communities exhibit asymmetric interaction matrices while remaining compliant with physical thermodynamics, two distinct mechanisms must be distinguished. The first mechanism is directional trophic feeding with incomplete assimilation: biomass flows unidirectionally from prey to predator with imperfect metabolic conversion ($\epsilon < 1$), producing opposing demographic signs that are negative for the prey and positive for the predator. The second mechanism is unequal biomass storage capacity: the shift in intensive thermodynamic potential induced by adding mass depends inversely on the physical storage capacity of the receiving compartment. Adding a unit of carbon to a large detrital reservoir induces a negligible change in chemical potential, whereas adding that same mass to a small predator population produces a large potential shift. The demographic community matrix conflates physical transport conductivities with these unequal storage capacities.

When this conflation is resolved using the stationary fluctuation covariance matrix $\mathbf{C} = \langle \delta\mathbf{x}\delta\mathbf{x}^{\mathsf{T}}\rangle = k_{\mathrm{B}}\mathbf{H}^{-1}$ as the inverse metric tensor of state space, the covariance-weighted drift operator $-\mathbf{A}\mathbf{C}$ splits uniquely into two distinct physical operators (Choi and Hansell 2026, Appendix A):

$$-\mathbf{A}\mathbf{C} = \mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega}, \qquad \mathbf{A} = -(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}$$

The symmetric component $\mathbf{D}_{\mathrm{sym}} = -\frac{1}{2}(\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}})$ represents the irreversible dissipation of free energy through metabolic respiration, physiological maintenance, and heat loss; as required by the Second Law of Thermodynamics, $\mathbf{D}_{\mathrm{sym}}$ is strictly positive definite ($\mathbf{D}_{\mathrm{sym}} \succ 0$), driving perturbations monotonically downhill toward the stationary state. In contrast, the skew-symmetric component $\boldsymbol{\Omega} = \frac{1}{2}(\mathbf{C}\mathbf{A}^{\mathsf{T}} - \mathbf{A}\mathbf{C}) = -\boldsymbol{\Omega}^{\mathsf{T}}$ represents non-dissipative cyclic motion in state space, such as predator-prey oscillations, seasonal plankton cycles, and microbial recycling loops. Because $\boldsymbol{\Omega}$ is skew-symmetric, it performs no net thermodynamic work against the potential gradient ($\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}\delta\mathbf{x} = 0$), functioning as a conservative energy and nutrient shuttler across compartments.

These physical operators map directly to ecological mechanisms. Biological standing stocks function as entropic capacitors ($\mathbf{C}$): detrital beds and forest boles store reserves of carbon and nutrients, providing physical inertia that buffers the community against seasonal droughts and resource lean periods. Metabolic dissipation ($\mathbf{D}_{\mathrm{sym}}$) represents the irreversible metabolic expenditure required to maintain living structure against thermal decay, pulling perturbations monotonically back toward stationary balance. Probability circulation ($\boldsymbol{\Omega}$) represents conservative transport within internal trophic loops, where feeding cycles and microbial recycling pathways shuttle matter and energy across species boundaries without degrading the local free-energy gradient.

The dimensionless non-equilibrium circulation ratio

$$\chi = \frac{\|\boldsymbol{\Omega}\|_F}{\|\mathbf{D}_{\mathrm{sym}}\|_F}$$

where $\|\mathbf{M}\|_F = \sqrt{\operatorname{tr}(\mathbf{M}^{\mathsf{T}}\mathbf{M})} = \sqrt{\sum_{i,j} M_{ij}^2}$ denotes the Frobenius matrix norm, quantifies the network-wide magnitude of cyclic trophic transport relative to irreversible dissipative damping and thus measures the departure from microscopic detailed balance. Because symmetric and skew-symmetric matrices are mutually orthogonal under the Frobenius inner product ($\operatorname{tr}(\mathbf{D}_{\mathrm{sym}}^{\mathsf{T}}\boldsymbol{\Omega}) = 0$), the total squared norm of the covariance-weighted drift decomposes via the Pythagorean identity $\|-\mathbf{A}\mathbf{C}\|_F^2 = \|\mathbf{D}_{\mathrm{sym}}\|_F^2 + \|\boldsymbol{\Omega}\|_F^2 = \|\mathbf{D}_{\mathrm{sym}}\|_F^2(1 + \chi^2)$, where $\chi = \tan\theta$ is the tangent of the angle between the composite dynamical operator and the purely dissipative Onsager subspace. In an isolated system at thermodynamic equilibrium (or in a purely symmetric competitive community), detailed balance holds, circulation vanishes ($\boldsymbol{\Omega} = \mathbf{0}$, $\chi = 0$), and perturbations relax monotonically without rotation. In open ecosystems driven by solar irradiance and nutrient inflows, continuous boundary throughput sustains persistent cyclic currents ($\chi > 0$), indexing a continuum of dynamical regimes from capacitance-buffered overdamped relaxation ($\chi < 1$, as in detritus-dominated benthic streams) and active planktonic recycling ($\chi \sim 1\text{ to }1.5$, as in the open-ocean mixed layer) to volatile, unbuffered oscillatory spiraling when slow apex capacitors are stripped ($\chi \gg 1$, approaching a Hopf bifurcation). Coordinate-invariance proofs, geometric properties of the Frobenius ratio, and the canonical two-species prototype decomposition are presented in Appendices A.2 and D.1.

# Biomass Capacitance and the Resistance-Resilience Trade-Off

## The Artifact of Spatial Coordinates

A recurring source of ambiguity in ecological thermodynamics is the convention of normalizing ecosystem state variables solely by geographic area ($\mathrm{m}^2$) or water volume ($\mathrm{m}^3$). Although convenient for field sampling, treating fixed spatial areas or volumes as thermodynamic containers introduces dimensional artifacts when total standing biovolume varies across orders of magnitude (Choi and Hansell 2026). An open-water plankton column, a benthic detrital bed, and a forest stand of equal ground area contain vastly different quantities of active biological matter. In biological communities, the physical vessel storing chemical energy and configurational entropy is the standing biomass ($B$) within a local control volume.

Let an ecological compartment $i$ contain stationary standing biomass $B_i^*$ (measured in extensive units such as $\mathrm{g\,C}$, $\mathrm{kcal}$, or $\mathrm{mmol\,N}$). Near a local non-equilibrium steady state where elemental stoichiometry and specific chemical energy are maintained homeostatically, the diagonal entries of the symmetric, positive-definite entropy Hessian $\mathbf{H} = -\partial^2 \Delta S_{\mathrm{tot}} / \partial\mathbf{x}^2\big|_{\mathbf{x}^*}$ scale inversely with compartment standing stock ($H_{ii} \propto 1/B_i^*$, analogous to the ideal chemical curvature $H_{ii} = \frac{1}{T}\frac{\partial \mu_i}{\partial x_i} = \frac{R_{\mathrm{gas}}}{x_i^*}$). By the Einstein-Onsager fluctuation relation ($\mathbf{C} = \langle \delta\mathbf{x}\delta\mathbf{x}^{\mathsf{T}}\rangle = k_{\mathrm{B}}\mathbf{H}^{-1}$), the entropic storage capacitance of compartment $i$ is proportional to its standing biomass:

$$C_i \propto \frac{B_i^*}{k_{\mathrm{B}}}$$

Consequently, the conjugate thermodynamic driving force $\delta\mathbf{X} = -\mathbf{H}\delta\mathbf{x} = -k_{\mathrm{B}}\mathbf{C}^{-1}\delta\mathbf{x}$ induced by an extensive mass or energy perturbation $\delta\mathbf{x} = \delta\mathbf{B}$ is:

$$\delta\mathbf{X} = -k_{\mathrm{B}}\mathbf{C}^{-1}\delta\mathbf{B}, \qquad \delta B_i = -\frac{1}{k_{\mathrm{B}}}C_i\,\delta X_i$$

This constitutive capacitance relation clarifies how biomass governs entropic Resistance. For a given extensive mass or energy shock $\delta B_i$, both the induced shift in intensive thermodynamic potential ($|\delta X_i| = k_{\mathrm{B}}|\delta B_i| / C_i \propto |\delta B_i| / B_i^*$) and the relative fractional state displacement ($|\delta\tilde{x}_i| = |\delta B_i| / B_i^*$) scale inversely with standing biomass $B_i^*$. Equivalently, for a given shift in intensive boundary force $|\delta X_i|$, a compartment with large capacitance $C_i$ absorbs a correspondingly large extensive mass transfer $|\delta B_i| \propto B_i^*|\delta X_i|$ before its intensive potential is displaced. Large standing biomass $B_{\text{tot}} = \sum_i B_i^*$ therefore provides high entropic Resistance by buffering intensive potentials and relative community structure against external shocks.

Conversely, ecosystem Resilience is governed by the mass-specific dissipative turnover rate:

$$\mathcal{R} = \frac{\sum_i R_i}{\sum_i B_i^*} \quad (\mathrm{yr}^{-1})$$

which characterizes the trace of the kinetic relaxation operator $\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}$ and sets the characteristic return rate of perturbations to the stationary attractor. Normalizing extensive departures by reference standing biomass ($\delta\tilde{x}_i = \delta B_i / B_i^*$) renders the state coordinates dimensionless strain variables while preserving the positive definiteness of $\mathbf{D}_{\mathrm{sym}}$ under linear congruence transformations (Appendix A.2), whereas projecting onto closed compositional simplex fractions ($\sum_i b_i = 1$) introduces a null-space singularity ($\det\mathbf{C}_b = 0$; Appendix B).

## Biomass Capacitance and Kinetic Turnover: Resistance vs. Resilience

Grounding stability in biomass capacitance resolves the classical tension between ecological Resistance and ecological Resilience (Webster et al. 1975, Pimm 1984, Holling 1996, Gunderson 2000). Within this non-equilibrium thermodynamic framework, the two properties correspond to complementary physical operators. Entropic Resistance is governed by the stationary covariance capacitance $\mathbf{C}$ and measures the ability of an ecosystem to absorb extensive mass or energy disturbances without undergoing large shifts in intensive thermodynamic forces or fractional species composition. Ecosystems with large biomass reservoirs, such as old-growth forests, peatlands, and detritus-buffered streams, exhibit high Resistance. Kinetic Resilience is governed by the mass-specific turnover operator $\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}$ and measures the rate at which perturbations decay back to steady state. Ecosystems with small standing biomass but high mass-specific metabolic rates, such as open-ocean surface plankton, microbial biofilms, and ephemeral pools, exhibit high Resilience; although sensitive to initial displacement, their rapid specific turnover drives fast recovery.

Because biological tissue allocation faces allometric and resource-supply constraints, ecosystems organize along a hyperbolic Resistance-Resilience trade-off continuum (Fig. \ref{fig_ecosystem_comparison}; Choi and Hansell 2026, Fig. 2):

$$B_{\text{tot}} \times \mathcal{R} \approx \text{constant}$$

where $B_{\text{tot}}$ is total standing biomass capacitance and $\mathcal{R}$ is mass-specific metabolic turnover. Under a bounded area- or volume-specific primary energetic supply $P_{\mathrm{in}}$ balanced at stationarity by total community respiration $R_{\mathrm{tot}} = \sum_i R_i \approx P_{\mathrm{in}}$, the product $B_{\text{tot}} \times \mathcal{R} = B_{\text{tot}} \times (R_{\mathrm{tot}} / B_{\text{tot}}) = R_{\mathrm{tot}}$ is constrained by the environmental energy budget (and reinforced in frequency space by the Bode sensitivity integral; Appendix D.3). Dense benthic detrital beds and mature forests occupy the high-Resistance, low-Resilience region of this frontier, whereas open pelagic waters and microbial communities occupy the low-Resistance, high-Resilience region.

The capacity of an ecosystem to partition its life-history and metabolic investments along this hyperbolic frontier defines its adaptive capacity on the thermodynamic landscape. When a stationary homeostatic operating point along this frontier is established for a given environmental regime, the community maintains a **Le Chatelier-Braun balance**. In this state, primary perturbations are moderated by coupled secondary pathways via the matrix Schur complement (both through direct symmetric dissipative cross-couplings where $0 < L_{ii,\mathrm{eff}} \le L_{ii}$ and through cyclic indirect trophic feedbacks where stationary compliance $0 < L_{ii,\mathrm{eff}}^{-1} \le L_{ii}^{-1}$ is reduced; Choi and Hansell 2026, Appendix B) and decay monotonically along the quadratic Lyapunov availability functional ($\dot{V} < 0$; Appendix A.4). This stationary regime reflects a boundary-versus-interior variational duality (Appendix A.3): under fixed external driving forces $X_0$ (incident solar irradiance, ambient temperature, or chemical affinities), boundary transport maximizes dissipation ($P_{\mathrm{boundary}} = L_{\mathrm{boundary}} X_0^2$), whereas under fixed nutrient throughflows $J_0$, unconstrained internal forces relax toward minimum internal dissipation per unit squared biomass ($\sigma / B_{\mathrm{tot}} \propto B_{\mathrm{tot}}^{-2}$).

However, when an acute shock or sustained regime shift perturbs the ecosystem, this Le Chatelier-Braun balance is broken. To persist, the system must dynamically re-establish balance under the altered conditions, governed by the modified **external gradients** (boundary thermodynamic forces such as solar flux, temperature, or nutrient inputs) and the **internal mechanisms that remain available** (surviving biomass capacitance reserves $\mathbf{C}$, allometric size-spectrum diversity, and intact non-dissipative circulation pathways $\boldsymbol{\Omega}$). This re-equilibration unfolds across a temporal hierarchy: immediate kinetic resilience ($\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}$) dampens acute shocks within days via high-turnover guilds; seasonal reorganization recruits standing capacitance ($\mathbf{C}$) and reconfigures trophic circulation loops ($\boldsymbol{\Omega}$); and multi-decadal allometric succession reconstructs slow macroscopic order parameters ($C(M) \propto M^{1-b}$, $\lambda(M) \propto M^{b-1}$). Because the community matrix $\mathbf{A} = -(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}$ is non-normal ($\mathbf{A}\mathbf{A}^{\mathsf{T}} \ne \mathbf{A}^{\mathsf{T}}\mathbf{A}$), transient reactive amplification can temporarily heighten variance or population fluctuations before asymptotic Lyapunov relaxation restores the stationary balance. If surviving internal mechanisms provide sufficient Adaptive Capacity to match the altered external gradient, the community re-equilibrates to a new Le Chatelier-Braun balance; if internal capacitors are degraded beyond recovery, the balance collapses into instability.

![Thermodynamic phase space of ecosystems: The Resistance-Resilience Trade-Off Continuum and non-equilibrium circulation. (A) The Resistance-Resilience trade-off continuum: plotting total biomass capacitance $\log_{10} B_{\text{tot}}$ (Resistance) against mass-specific metabolic turnover $\log_{10}\mathcal{R}$ (Resilience) reveals an overarching trade-off across world biomes, from dense benthic detrital beds and ancient forests to pelagic oceans. (B) Detailed balance violation: the non-equilibrium circulation ratio $\chi = \|\boldsymbol{\Omega}\|_{F} / \|\mathbf{D}_{\mathrm{sym}}\|_{F}$ quantifies driven cyclic currents in living food webs. (C) Phase space relaxation: state departures spiral inward under a negative-definite Lyapunov potential while driven currents maintain non-equilibrium circulation. (D) Characteristic relaxation timescales: complex eigenvalue distributions distinguish rapid kinetic recovery in pelagic plankton (period of approximately 42 days) from slow, massive detrital damping in benthic streams (period of approximately 296 days).](media/fig_ecosystem_comparison.png){#fig_ecosystem_comparison width=85%}


# Empirical Applications: Benthic Cold Springs vs. Open-Ocean Plankton Ecosystems

To demonstrate the empirical utility of this non-equilibrium thermodynamic framework, the methodology is applied to two contrasting aquatic ecosystems with published empirical flow budgets: the classic benthic, detritus-buffered Cone Spring food web (Tilly 1968, Patten 1978, Ulanowicz 1986) and the open-ocean plankton network at the Bermuda Atlantic Time-series Study (BATS) site in the Sargasso Sea (Fasham et al. 1990, Spitz et al. 2001, Steinberg et al. 2001, Zheng et al. 2024). In addition, an exploited marine fishery model (NPZD-Fish) is evaluated to examine how harvesting pressure alters thermodynamic attractor stability.

## The Benthic Cold-Spring Ecosystem: High-Resistance Detrital Storage (Cone Spring)

Cone Spring is a cold limnocrene freshwater spring in Iowa characterized by steady subterranean discharge, a stenothermal temperature regime (approximately 10 degrees Celsius year-round), and heavy reliance on allochthonous organic matter inputs (Tilly 1968, Patten 1978, Ulanowicz 1986). The biological community is organized into five functional guilds (Table \ref{tbl:app_cone_full}): primary producers ($x_1$), organic detritus ($x_2$), decomposer microbes ($x_3$), benthic shredders and grazers ($x_4$), and benthic predators ($x_5$). Primary producers are dominated by rooted macrophyte beds of freshwater watercress (*Nasturtium officinale*) and epiphytic benthic microalgae that carpet the spring substrate, fixing solar irradiance during spring and summer. The organic detritus pool constitutes a large non-living organic matter reservoir comprising decaying deciduous tree litter, predominantly oak, elm, and hickory foliage from the surrounding riparian forest canopy, intermixed with submerged particulate organic muck. Decomposer microbes consist of benthic heterotrophic bacteria and microbial biofilms adhering to decaying leaves, secreting extracellular enzymes to digest cellulose and refractory structural lignin. Benthic shredders and grazers are dominated by cold-adapted amphipod crustacea (*Gammarus pseudolimnaeus*) and aquatic isopods (*Asellus militaris*), which shred coarse leaf litter while assimilating bacterial biofilms coating leaf surfaces. Finally, benthic predators comprise secondary and tertiary consumers including freshwater planarians (*Phagocata morgani*), leeches, and predatory larval salamanders (*Eurycea bislineata*) that feed upon amphipods and detritivores.

| Compartment ($i$) | $B_i^*$ | Inflow $z_i$ | To $x_1$ | To $x_2$ | To $x_3$ | To $x_4$ | To $x_5$ | Exports $E_i$ | Resp. $R_i$ | Flow $T_i$ |
|:-------------------------|:------:|:---------:|:-------:|:-------:|:-------:|:-------:|:-------:|:-----------:|:---------:|:--------:|
| **1. Plants** | $285.0$ | $11\,184$ | $0$ | $0$ | $0$ | $0$ | $0$ | $300$ | $2\,003$ | $11\,184$ |
| **2. Detritus** | $3\,580.0$ | $635$ | $8\,881$ | $0$ | $1\,600$ | $200$ | $167$ | $860$ | $3\,109$ | $11\,483$ |
| **3. Bacteria** | $116.6$ | $0$ | $0$ | $5\,205$ | $0$ | $0$ | $0$ | $255$ | $3\,275$ | $5\,205$ |
| **4. Detritivores** | $60.0$ | $0$ | $0$ | $2\,309$ | $75$ | $0$ | $0$ | $0$ | $1\,814$ | $2\,384$ |
| **5. Carnivores** | $17.0$ | $0$ | $0$ | $0$ | $0$ | $370$ | $0$ | $0$ | $203$ | $370$ |

Table: Complete steady-state energy flow matrix for Cone Spring ($\mathrm{kcal\,m^{-2}\,yr^{-1}}$; Tilly 1968, Patten 1978, Ulanowicz 1986). Column headers denote standing biomass $B_i^*$ ($\mathrm{kcal\,m^{-2}}$), external inflow $z_i$, internal trophic transfers $T_{j\to i}$ from source row $j$ to recipient column $i$ ($x_1$: Plants, $x_2$: Detritus, $x_3$: Bacteria, $x_4$: Detritivores, $x_5$: Carnivores), net exports $E_i$, respiration dissipation $R_i$, and total throughflow $T_i$. {#tbl:app_cone_full}

Following the energetic interaction parameterization of de Ruiter et al. (1995), the steady-state energy flows $F_{ji}$ from prey $j$ to consumer $i$, compartment throughflows $T_i$, and respirations $R_i$ define the linearized community matrix $\mathbf{A}_{\mathrm{CS}}$ for the three-compartment living heterotrophic food chain (1: Bacteria, 2: Detritivores, 3: Carnivores): direct consumer suppression of prey is $A_{ji} = -F_{ji} / B_i^*$, assimilated prey enhancement of consumer growth is $A_{ij} = +e_i F_{ji} / B_j^*$ with production efficiency $e_i = (T_i - R_i) / T_i$, and intraspecific self-damping is $A_{ii} = -s R_i / B_i^*$ ($s = 0.10$):

$$\mathbf{A}_{\mathrm{CS}} = \begin{bmatrix} -2.8087 & -1.2500 & 0 \\ 0.1538 & -3.0233 & -21.7647 \\ 0 & 2.7833 & -1.1941 \end{bmatrix}\ \mathrm{yr^{-1}}$$

Spectral decomposition of $\mathbf{A}_{\mathrm{CS}}$ yields a real eigenvalue $\lambda_1 = -2.8036\ \mathrm{yr^{-1}}$ and a complex conjugate pair $\lambda_{2,3} = -2.1113 \pm 7.7414i\ \mathrm{yr^{-1}}$, corresponding to an internal oscillation period of $T = 2\pi / |\operatorname{Im}(\lambda_{2,3})| = 296\ \mathrm{days}$. Naive attempts to construct a conductivity matrix by multiplying $-\mathbf{A}_{\mathrm{CS}}$ directly by diagonal standing biomass $\operatorname{Diag}(\mathbf{B}^*)$ produce an indefinite symmetric part with a negative eigenvalue ($\lambda_{\min} = -29.16\ \mathrm{kcal\,m^{-2}\,yr^{-1}}$; Fig. \ref{fig_app3_cone_spring}A), which would falsely suggest a violation of the Second Law. In contrast, solving the continuous Lyapunov equation $\mathbf{A}_{\mathrm{CS}}\mathbf{C}_{\mathrm{CS}} + \mathbf{C}_{\mathrm{CS}}\mathbf{A}_{\mathrm{CS}}^{\mathsf{T}} + 2\mathbf{D}_{\mathrm{CS}} = \mathbf{0}$ with metabolic fluctuation diffusion $\mathbf{D}_{\mathrm{CS}} = \operatorname{Diag}(s R_i B_i^*)$ yields the positive-definite stationary covariance matrix:

$$\mathbf{C}_{\mathrm{CS}} = \begin{bmatrix} 13\,629.90 & -77.16 & -69.10 \\ -77.16 & 3\,240.05 & 49.46 \\ -69.10 & 49.46 & 404.28 \end{bmatrix}\ (\mathrm{kcal\,m^{-2}})^2$$

and the skew-symmetric non-equilibrium probability circulation tensor $\boldsymbol{\Omega}_{\mathrm{CS}} = \frac{1}{2}(\mathbf{C}_{\mathrm{CS}}\mathbf{A}_{\mathrm{CS}}^{\mathsf{T}} - \mathbf{A}_{\mathrm{CS}}\mathbf{C}_{\mathrm{CS}})$:

$$\boldsymbol{\Omega}_{\mathrm{CS}} = \begin{bmatrix} 0 & 3\,833.33 & -132.26 \\ -3\,833.33 & 0 & 8\,959.08 \\ 132.26 & -8\,959.08 & 0 \end{bmatrix}\ (\mathrm{kcal\,m^{-2}})^2\,\mathrm{yr}^{-1}$$

Evaluating these operators across the Cone Spring guilds highlights three structural properties of cold-spring stability (Fig. \ref{fig_app3_cone_spring}). First, detrital storage capacitance dominates the network: the detrital reservoir ($B_2^* = 3\,580\ \mathrm{kcal\,m^{-2}}$, or approximately $358.3\ \mathrm{g\,C\,m^{-2}}$) accounts for over 88% of total standing stock, acting as an entropic shock absorber (Resistance) that buffers seasonal pulses of autumnal leaf fall and prevents boom-and-bust starvation cycles in detritivores. Second, the community operates at a low stationary entropy production rate density ($\sigma = 90.35\ \mathrm{yr^{-1}}$) with a slow relaxation period of 296 days. Third, the non-zero entries of $\boldsymbol{\Omega}_{\mathrm{CS}}$ quantify persistent cyclic trophic flow across the benthic food chain (detritivores grazing bacteria and carnivores preying upon detritivores, with mortality returning organic matter to detritus), maintaining moderate probability circulation ($\chi = 0.85$ across the five-compartment network; $\chi = 0.245$ within the three-guild heterotrophic chain) while $\mathbf{D}_{\mathrm{sym}} = \mathbf{D}_{\mathrm{CS}} \succ 0$ guarantees monotonic Lyapunov decay (Fig. \ref{fig_app3_cone_spring}B).

![Thermodynamic flow network decomposition of the Cone Spring benthic ecosystem (Tilly 1968). (A) Resolution of the indefinite symmetric part paradox: while the raw community matrix sum $\mathbf{A} + \mathbf{A}^{\mathsf{T}}$ contains spurious negative eigenvalues, the continuous Lyapunov transformation $-\mathbf{A}\mathbf{C} - \mathbf{C}\mathbf{A}^{\mathsf{T}} = 2\mathbf{D}_{\mathrm{sym}}$ is strictly positive-definite. (B) Monotonic Lyapunov decay: relaxation trajectories follow negative-definite quadratic potentials $V(\delta\mathbf{x}) = \delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\delta\mathbf{x}$, demonstrating global asymptotic stability. (C) Stationary covariance structure: cross-compartment correlations across the five trophic pools (Plants, Detritus, Herbivores, Carnivores, Deposit Feeders). (D) Resistance vs. Resilience across compartments: detritus dominates biomass capacitance ($B_2^* = 358.3\ \mathrm{g\,C\,m^{-2}}$, high Resistance), while active carnivores and herbivores govern kinetic turnover (high Resilience).](media/fig_app3_cone_spring.png){#fig_app3_cone_spring width=85%}


## The Open-Ocean Plankton Ecosystem: High-Resilience Kinetic Turnover (BATS Site)

In contrast to the benthic detrital spring, open-ocean planktonic ecosystems operate in an unattached, three-dimensional fluid environment driven by high-frequency solar irradiance and rapid nutrient cycling. A four-compartment Nutrient-Phytoplankton-Zooplankton-Detritus (NPZD) network is parameterized using observations from the Bermuda Atlantic Time-series Study (BATS) in the oligotrophic Sargasso Sea (Fasham et al. 1990, Spitz et al. 2001, Steinberg et al. 2001, Zheng et al. 2024).

The epipelagic euphotic zone comprises four coupled pools. Dissolved inorganic nitrogen ($N$) consists of bioavailable nitrate, nitrite, and ammonium drawn down to near-depletion in surface waters ($N^* = 0.10\ \mathrm{mmol\,N\,m^{-3}}$). The phytoplankton assemblage ($P$) is dominated by picoplanktonic cyanobacteria (*Prochlorococcus marinus* and *Synechococcus*) and small eukaryotic flagellates (prasinophytes and prymnesiophytes), supplemented by diatom blooms during winter convective mixing. Heterotrophic zooplankton grazers ($Z$) comprise microzooplankton (ciliates and dinoflagellates) and mesozooplankton dominated by calanoid and cyclopoid copepods (*Calanus*, *Oithona*, and *Pleuromamma*), chaetognaths, and salps. Particulate organic detritus ($D$) forms a sinking marine snow pool of planktonic detritus, fecal pellets, and transparent exopolymer particles.

### BATS Upper Mixed Layer NPZD Model and Fluctuation Dynamics

The nitrogen-currency mass balance for $(N, P, Z, D)$ (in $\mathrm{mmol\,N\,m^{-3}}$) is governed by Michaelis-Menten phytoplankton nutrient uptake $U(N, P) = \frac{V_{\max} N}{k_s + N}P$ and Holling Type-III zooplankton grazing $G(P, Z) = \frac{a_z \epsilon_z P^2 Z}{1 + \epsilon_z P^2}$:

$$\frac{dN}{dt} = I - U(N, P) + \mu_p m_p P + (1 - \gamma_z)G(P, Z) + \mu_z c_z Z^2 + \mu_d D$$

$$\frac{dP}{dt} = U(N, P) - G(P, Z) - m_p P$$

$$\frac{dZ}{dt} = \gamma_z G(P, Z) - c_z Z^2$$

$$\frac{dD}{dt} = (1 - \mu_p)m_p P + (1 - \mu_z)c_z Z^2 - (\mu_d + w_s)D$$

With rate parameters $V_{\max} = 1.20\ \mathrm{d^{-1}}$, $k_s = 0.70\ \mathrm{mmol\,N\,m^{-3}}$, $m_p = 0.09\ \mathrm{d^{-1}}$, $a_z = 2.00\ (\mathrm{mmol\,N\,m^{-3}})^{-1}\mathrm{d^{-1}}$, $\epsilon_z = 1.00\ (\mathrm{mmol\,N\,m^{-3}})^{-2}$, assimilation efficiency $\gamma_z = 0.75$, quadratic zooplankton loss $c_z = 0.20\ (\mathrm{mmol\,N\,m^{-3}})^{-1}\mathrm{d}^{-1}$, soluble recycling fractions $\mu_p = 0.20$ and $\mu_z = 0.20$, detrital remineralization $\mu_d = 0.05\ \mathrm{d}^{-1}$, sinking loss $w_s = 0.02\ \mathrm{d}^{-1}$, and external nutrient supply $I = 0.0050\ \mathrm{mmol\,N\,m^{-3}\,d^{-1}}$, the interior stationary state is $(N^*, P^*, Z^*, D^*) = (0.1000, 0.1615, 0.1906, 0.2492)\ \mathrm{mmol\,N\,m^{-3}}$. Converting living planktonic nitrogen ($P^* + Z^*$) to carbon via the Redfield ratio ($106\,\mathrm{C}:16\,\mathrm{N}$) gives a standing plankton biomass capacitance of $B_{\text{tot}} = 0.02802\ \mathrm{g\,C\,m^{-3}}$.

In the upper mixed layer (0 to 52 m), standing biomass capacitance is more than four orders of magnitude smaller than in Cone Spring, but mass-specific primary production and grazing rates are rapid. Linearizing the pelagic flux network around stationarity yields fast oscillatory grazing modes with a characteristic oscillation period of approximately 40 to 42 days ($\lambda_{1,2} = -50.82 \pm 54.66i\ \mathrm{yr}^{-1}$ in the reduced pelagic representation of Fig. \ref{fig_ecosystem_comparison}C,D; $\lambda_{3,4} = -62.95 \pm 57.73i\ \mathrm{yr}^{-1}$, $T = 39.8\ \mathrm{days}$ in the full mixed-layer budget of Table \ref{tbl:aquatic_comparison}), which is more than seven times faster in period and over twenty-four times faster in damping rate than Cone Spring:

$$\mathbf{A}_{\mathrm{NPZD}} = \begin{bmatrix} -73.05 & -36.52 & 0 & 18.26 \\ 73.05 & -18.26 & -91.31 & 0 \\ 0 & 36.52 & -36.52 & 0 \\ 0 & 18.26 & 36.52 & -27.39 \end{bmatrix}\ \mathrm{yr^{-1}}$$

Driven by continuous solar photon throughput and winter convective nitrate entrainment, the BATS upper mixed layer operates at a stationary entropy production rate density of $\sigma = 257.65\ \mathrm{yr^{-1}}$, nearly three times that of Cone Spring, and stabilizes perturbations through rapid kinetic turnover rather than static mass storage. Vertically across the water column, stratification establishes a Resistance-Resilience gradient: whereas the illuminated surface mixed layer (0 to 52 m) occupies the low-Resistance, high-Resilience regime, the subsurface Deep Chlorophyll Maximum (52 to 250 m) maintains a larger dissolved inorganic nitrogen reservoir ($N^* \approx 1.73\ \mathrm{mmol\,N\,m^{-3}}$) that buffers the euphotic zone against seasonal convective mixing.

To examine how anthropogenic harvesting alters this thermodynamic balance, the four-pool BATS plankton model is extended to a five-pool food web (NPZD-Fish) by coupling planktivorous and predatory fish ($F$) to zooplankton via Holling Type-II predation $G_F(Z, F) = \frac{a_f \epsilon_f Z F}{1 + \epsilon_f Z}$, with assimilation $\gamma_f = 0.70$, basal mortality $m_f = 0.02\ \mathrm{d}^{-1}$, and harvest mortality $H = q E F$. Under lightly exploited baseline conditions, adding the fish tier shifts the pelagic community along the Resistance-Resilience trade-off continuum toward higher Resistance: total standing biomass expands ($B_{\text{tot}} \approx 0.15\ \mathrm{g\,C\,m^{-3}}$), mass-specific turnover decreases ($\mathcal{R} \approx 18.7\ \mathrm{yr^{-1}}$), and the dominant relaxation period lengthens to approximately 254 days. The fish compartment acts as a multi-year entropic storage capacitor ($C_{55}$) that damps high-frequency planktonic bloom-and-bust oscillations.

When heavy industrial fishing mortality is imposed ($H = q E F$), the thermodynamic trajectory parallels documented marine groundfish collapses, such as the collapse of Northwest Atlantic cod (*Gadus morhua*) on the eastern Scotian Shelf and Grand Banks (Choi et al. 2004, Frank et al. 2005, Choi 2023). Selective harvesting of long-lived predatory fish drains the slow apex capacitor ($C_{55} \to 0$, reducing total standing stock to $B_{\text{tot}} \approx 0.035\ \mathrm{g\,C\,m^{-3}}$), removing the top-down buffer that regulated lower trophic tiers. Deprived of predatory damping, the food web truncates into a volatile community dominated by fast-turnover plankton, small pelagic forage fish, and macroinvertebrates. Probability circulation between phytoplankton and zooplankton surges ($\chi = 2.68$), the characteristic response timescale shortens to 18.5 days, and internal entropy production rate density rises to $\sigma = 425.03\ \mathrm{yr^{-1}}$ (4.7 times that of Cone Spring). Stripping the slow biomass capacitor flattens the local entropic potential well ($\mathbf{H} \to 0$), so that modest temperature or wind anomalies induce large-amplitude plankton swings and precondition the ecosystem for transition into an alternative degraded Le Chatelier-Braun regime.

\newpage

## Cross-System Fluctuation Thermodynamics: Comparative Analysis Across Aquatic Regimes

Comparing the three aquatic regimes highlights how environmental geometry, primary energy sources, and biological architectures dictate non-equilibrium thermodynamic state variables (Table \ref{tbl:aquatic_comparison}).

| Thermodynamic Metric | Benthic Cold Spring (Cone Spring) | Open-Ocean Mixed Layer (BATS NPZD) | Exploited Marine Fishery (NPZD-Fish) | Physical Significance |
|:-------------------|:-------------------|:-------------------|:-------------------|:----------------------------------------|
| **System Boundary** | Fixed benthic channel; localized spring | Upper mixed layer (0 to 52 m); fluid volume | Upper ocean with industrial harvesting | Controls transport constraints and external boundary inputs |
| **Primary Energy Driver** | Allochthonous organic detrital inflow | High solar photon irradiance | Solar flux coupled to external biomass export | Dictates the magnitude of non-equilibrium thermodynamic driving |
| **Standing Biomass ($B_{\text{tot}}$)** | $358.3\ \mathrm{g\ C\ m^{-2}}$ (high capacitance) | $0.028\ \mathrm{g\ C\ m^{-3}}$ (low capacitance) | $0.035\ \mathrm{g\ C\ m^{-3}}$ (stripped capacitance) | Determines entropic storage capacity and static Resistance |
| **Dominant Timescale ($\tau$)** | $296\ \mathrm{days}$ (slow, low frequency) | $39.8\ \mathrm{days}$ (fast, high frequency) | $18.5\ \mathrm{days}$ (volatile, erratic) | Reflects characteristic system response time to external shocks |
| **Circulation Ratio ($\chi$)** | $0.85$ (balanced cycling) | $1.42$ (strong planktonic loops) | $2.68$ (severe unbuffered circulation) | Quantifies departure from detailed balance and cyclic flux intensity |
| **Entropy Density ($\sigma$)** | $90.35\ \mathrm{yr^{-1}}$ (low dissipation) | $257.65\ \mathrm{yr^{-1}}$ (moderate dissipation) | $425.03\ \mathrm{yr^{-1}}$ (high dissipation) | Measures the rate of free-energy dissipation per unit volume |
| **Stability Regime** | High Resistance / Low Resilience | Low Resistance / High Resilience | Depleted Resistance / Fragile Turnover | Defines position along the overarching Resistance and Resilience trade-off continuum |

Table: Cross-system comparative analysis of non-equilibrium thermodynamic properties across three canonical aquatic ecosystems. {#tbl:aquatic_comparison}

These empirical findings demonstrate that ecosystems adapt to their physical environment by tuning the ratio of storage capacitance (Resistance) to kinetic turnover (Resilience). Whether an ecosystem organizes around massive detrital buffers or rapid planktonic recycling loops, its dynamics conform to the continuous Lyapunov balance equation, verifying the universality of the non-equilibrium thermodynamic framework.

# Extension to Allometric Size Spectra and Multi-Scale Energy Cascades

## Allometric Partitioning of Capacitance and Turnover Across the Size Spectrum

Living communities are not unstructured mixtures of species. Rather, they are organized across continuous spectra of organismal body size spanning more than twenty-two orders of magnitude, from marine picoplankton and soil bacteria ($10^{-14}\ \mathrm{g}$) to pelagic blue whales and giant forest trees ($10^8\ \mathrm{g}$). This physical size structuring governs how energy, mass, and thermodynamic entropy flow through the biosphere.

Empirical marine and terrestrial surveys reveal that total biomass tends to distribute evenly across logarithmic body-mass octaves, a macroecological regularity known as the biomass size spectrum (Sheldon et al. 1972, Kerr 1974, Platt and Denman 1977, 1978, Rodriguez and Mullin 1986, Boudreau and Dickie 1992, Choi et al. 1999, Kerr and Dickie 2001, Andersen 2019):

$$\frac{dB(m)}{d\ln m} \approx \text{constant}$$

When taken as a whole, the observation of biomass size spectra in aquatic and terrestrial systems (Sheldon et al. 1972, Kerr 1974, Platt and Denman 1977, 1978, Rodriguez and Mullin 1986, Boudreau and Dickie 1992, Choi et al. 1999) can be seen as energy cascades across hierarchies of spatiotemporal scales. While biomass density remains approximately invariant across mass octaves, metabolic rates scale non-linearly with individual organismal mass according to Kleiber's law (Kleiber 1932, 1947, West et al. 1997, Brown et al. 2004): individual metabolic rate scales as $B_{\text{ind}} \propto m^{3/4}$, which implies that mass-specific metabolic dissipation scales as:

$$\rho(m) \propto m^{-1/4}$$

This quarter-power allometric scaling creates a systematic functional partitioning across the size spectrum (Fig. \ref{fig_energy_cascade}A). At microscopic scales ($m \to 0$), high mass-specific turnover ($\rho(m) \propto m^{-0.25}$) combines with small individual storage capacitance ($C_{\text{ind}} \propto m^1$), such that small organisms, including bacteria, flagellates, and phytoplankton, function primarily as high-frequency kinetic dissipators conferring Resilience. At macroscopic scales ($m \to \infty$), low mass-specific turnover combines with large individual storage capacitance ($C_{\text{ind}} \propto m^1$), so that large organisms, such as trees, megafauna, and apex marine predators, function as low-frequency entropic shock absorbers conferring Resistance.

In the frequency domain, each organismal size class $m$ with characteristic relaxation rate $\lambda(m) \propto \rho(m) \propto m^{-1/4}$ and relaxation time $\tau(m) = \lambda(m)^{-1} \propto m^{1/4}$ acts as a first-order low-pass Fourier impedance filter with transfer function $|H(\omega; m)| = [1 + (\omega \tau(m))^2]^{-1/2}$ (Fig. \ref{fig_energy_cascade}B). Fast-turnover microbes ($\tau \sim \text{hours to days}$) track and dissipate high-frequency environmental fluctuations (such as diurnal solar cycles and synoptic weather events) into metabolic heat, whereas long-lived macroscopic organisms and detrital reservoirs ($\tau \sim \text{years to decades}$) attenuate high-frequency variance and integrate low-frequency planetary forcing (such as seasonal cycles, El Niño Southern Oscillation variability, and multi-decadal climate anomalies; Fig. \ref{fig_energy_cascade}C,D).

![The multi-scale energy dissipation cascade and size-spectrum impedance filtering. (A) Allometric partitioning of function: mass-specific metabolic dissipation $\rho(m) \propto m^{-0.25}$ (orange line) dominates microscopic scales, while standing biomass capacitance $B(m)$ (blue dashed line) acts as a high-inertia storage capacitor at macroscopic scales. (B) Dynamic frequency transfer functions $|H(\omega)|$: different body-mass classes act as tuned Fourier impedance filters, absorbing and damping environmental forcing across diurnal, seasonal, and decadal (ENSO) bands. (C) Planetary power absorption spectrum: ambient red environmental climate noise (dotted black line) is partitioned into high-frequency metabolic dissipation by microbial heatsinks (orange shaded region) and low-frequency memory integration within long-lived biomass buffers (blue shaded region). (D) Dynamic biospheric impedance across Earth system octaves, demonstrating progressive multi-scale damping from rapid diurnal solar fluctuations to multi-decadal climate stabilization.](media/fig_energy_cascade.png){#fig_energy_cascade width=85%}

## Biomass Size Spectra as Cross-Scale Signatures of Energy Dissipation

The empirical regularities of biomass size spectra in aquatic and terrestrial communities provide a direct macroecological signature of how living systems organize energy dissipation across spatiotemporal hierarchies (Sheldon et al. 1972, Kerr 1974, Platt and Denman 1977, 1978, Rodriguez and Mullin 1986, Boudreau and Dickie 1992, Choi et al. 1999). In continuum mechanics, Kolmogorov (1941) demonstrated that three-dimensional fluid turbulence resolves the disparity between macroscopic energy injection and microscopic molecular viscosity through a scale-invariant cascade across wavenumbers. In ecological communities, the continuous biomass size spectrum performs an analogous thermodynamic function across coupled spatial, temporal, and body-mass coordinates.

In classical fluid turbulence, kinetic energy enters at macroscopic integral length scales ($L_0$) driven by large-scale boundary forcing, cascades conservatively across an intermediate inertial subrange via non-linear vortex stretching, and terminates at the Kolmogorov microscale ($\eta$), where molecular viscosity converts kinetic motion irreversibly into heat. This cascade arises because macroscopic boundary forcing and molecular dissipation operate at widely separated scales.

Ecological communities confront an analogous scale disparity. Solar radiation, nutrient upwelling, seasonal hydrographic cycles, and climate anomalies inject free energy and physical perturbations across broad macroscopic spatial domains and low-frequency temporal bands, whereas irreversible biochemical respiration and nutrient mineralization occur across cellular membranes at micrometer spatial scales and sub-second biochemical reaction rates. As formulated in continuum theories of the pelagic biomass spectrum (Platt and Denman 1977, 1978, Kerr 1974, Boudreau and Dickie 1992), metabolic assimilation and trophic predation generate a continuous spectral flux of biomass and chemical free energy across logarithmic body-size octaves, coupled to the microbial and detrital remineralization loop. Within the non-equilibrium Onsager framework, this hierarchical cascade partitions into three complementary physical regimes across the spatiotemporal spectrum.

### Macro-Scale Capacitive Integration and Low-Frequency Storage

At the largest organismal and detrital scales ($m \to m_{\max}$), slow mass-specific metabolic turnover ($\rho(m) \propto m^{-1/4}$) and long generation times ($\tau(m) \propto m^{1/4}$) produce high entropic storage capacitance ($C(m) \propto B(m)/k_{\mathrm{B}}$). Large-bodied apex predators, long-lived trees, and recalcitrant soil or benthic detrital pools integrate energy and matter over large spatial foraging ranges and multi-annual to multi-decadal timescales.

Rather than tracking high-frequency environmental fluctuations, these macroscopic compartments act as low-pass thermodynamic capacitors that absorb pulse disturbances, seasonal resource deficits, and interannual climate anomalies without large excursions in intensive chemical potential ($\delta X_i = -k_{\mathrm{B}} C_i^{-1} \delta B_i$). In the size spectrum, the secondary domes and standing stocks of large-bodied guilds (Boudreau and Dickie 1992) represent localized capacitive reservoirs that anchor the low-frequency stability (Resistance) of the community.

### Trophic Spectral Transport and Cross-Scale Probability Circulation

Across intermediate body-size octaves, energy and matter are transported continuously along the size spectrum through size-selective predation, grazing, and detrital fragmentation (Kerr 1974, Platt and Denman 1977, 1978, Rodriguez and Mullin 1986). As biomass moves from primary producers through successive consumer size classes and returns via organic matter excretion and decomposition, each trophic transfer couples compartments with distinct characteristic timescales $\tau(m)$ and spatial ambits.

In the covariance-weighted drift decomposition $-\mathbf{A}\mathbf{C} = \mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega}$, this directional cross-scale flux is governed by the skew-symmetric probability circulation tensor ($\boldsymbol{\Omega}$). Because $\boldsymbol{\Omega} = -\boldsymbol{\Omega}^{\mathsf{T}}$ is antisymmetric, purely circulatory transport across size classes conserves instantaneous thermodynamic availability ($\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}\delta\mathbf{x} = 0$), functioning as the ecological counterpart to the inertial transport subrange. It couples slow, broad-scale macroscopic biomass reservoirs to fast, fine-scale microbial guilds through closed biogeochemical cycles.

### Micro-Scale Metabolic Dissipation and High-Frequency Damping

At the smallest organismal scales ($m \to m_{\min}$), encompassing bacteria, picoplankton, and microflagellates, surface-to-volume ratios and mass-specific metabolic rates reach their maxima ($\rho(m) \propto m^{-1/4} \to \infty$, $\tau(m) \to 0$). Here, the symmetric Onsager dissipative conductivity ($\mathbf{D}_{\mathrm{sym}} \succ 0$, Resilience) dominates the dynamics.

As organic matter and chemical free energy circulate into the microbial and fine detrital pools, high-turnover enzymatic respiration and remineralization rapidly degrade chemical potential gradients into low-grade thermal entropy ($\sigma = k_{\mathrm{B}}^{-1}\mathbf{X}^{\mathsf{T}}\mathbf{D}_{\mathrm{sym}}\mathbf{X} > 0$) while regenerating inorganic nutrients for primary production. The high-frequency portion of the size spectrum thus acts as the primary dissipative sink of the biosphere, damping rapid environmental perturbations before they can accumulate or destabilize slower trophic tiers.

### Cross-Scale Integrity and Anthropogenic Truncation of the Size Spectrum

Viewing biomass size spectra as cross-scale signatures of energy dissipation clarifies why perturbations to the slope or extent of the size spectrum serve as sensitive indicators of ecosystem distress (Choi et al. 1999, Kerr and Dickie 2001). In an unperturbed community, the allometric scaling of capacitance $C(m)$ and turnover $\lambda(m)$ across the size spectrum maintains a balanced impedance profile across frequencies, seamlessly coupling multi-decadal storage to diurnal metabolic dissipation.

When size-selective industrial fishing, deforestation, or chronic eutrophication truncates the macroscopic end of the size spectrum or steepens its logarithmic slope, the community loses its slow, high-capacitance storage compartments ($C(m)$ at large $m$). Energy throughput is then forced exclusively through truncated, fast-turnover planktonic and microbial loops, inflating the circulation-to-dissipation ratio ($\chi$) and elevating specific entropy production ($\sigma$), as demonstrated empirically in the exploited NPZD-Fish food web (Table \ref{tbl:aquatic_comparison}). Conversely, degrading microbial and detrital recycling guilds impairs symmetric dissipation ($\mathbf{D}_{\mathrm{sym}}$), bottlenecking nutrient regeneration. Persistence across fluctuating environments therefore requires preserving the full allometric continuum of the biomass size spectrum so that storage capacitance, cross-scale circulation, and metabolic dissipation remain coupled across spatiotemporal scales.

# The Non-Linear Regime: Quasi-Potential Landscapes and Early-Warning Diagnostics

## The Non-Equilibrium Quasi-Potential Landscape

While linear non-equilibrium thermodynamics characterizes relaxation near a stationary state, living ecosystems frequently experience large perturbations, multi-stability, and regime transitions (Holling 1973, May 1977, Scheffer et al. 2001). In this non-linear regime, stochastic population dynamics are governed by continuous Fokker-Planck diffusion equations and non-equilibrium quasi-potential landscapes (Graham 1977, Freidlin and Wentzell 1984, Ao 2004, Wang et al. 2008, Zhou et al. 2012).

The scalar quasi-potential $U(\mathbf{x}) = -\lim_{\mathcal{V} \to \infty} \mathcal{V}^{-1}\ln P_{\mathrm{ss}}(\mathbf{x})$ defines the topographical stability basin of the community in extensive state space. A deep, steep potential basin corresponds to a well-buffered ecosystem that absorbs disturbances and returns rapidly to its stationary attractor, whereas a shallow, flattened basin indicates an eroded attractor vulnerable to noise-induced transitions across a saddle barrier into an alternative state.

As derived in Appendix A.4, any smooth non-linear ecological drift field $\mathbf{f}(\mathbf{x})$ admits a Helmholtz-Hodge decomposition into two orthogonal components:

$$\mathbf{f}(\mathbf{x}) = -\mathbf{D}(\mathbf{x})\nabla U(\mathbf{x}) + \mathbf{v}_{\mathrm{curl}}(\mathbf{x}), \qquad \nabla U(\mathbf{x}) \cdot \mathbf{v}_{\mathrm{curl}}(\mathbf{x}) = 0$$

The first component is the downhill dissipative gradient drift $-\mathbf{D}(\mathbf{x})\nabla U(\mathbf{x})$, governed by the symmetric, positive-definite diffusion tensor $\mathbf{D}(\mathbf{x}) \succ 0$, which draws trajectories down the gradient of $U(\mathbf{x})$ through irreversible metabolic dissipation. The second component is the solenoidal probability circulation velocity $\mathbf{v}_{\mathrm{curl}}(\mathbf{x}) = \mathbf{J}_{\mathrm{prob}}(\mathbf{x}) / P_{\mathrm{ss}}(\mathbf{x}) = \boldsymbol{\Omega}(\mathbf{x})\nabla U(\mathbf{x})$, generated by a state-dependent skew-symmetric circulation tensor $\boldsymbol{\Omega}(\mathbf{x}) = -\boldsymbol{\Omega}(\mathbf{x})^{\mathsf{T}}$. Because $\boldsymbol{\Omega}(\mathbf{x})$ is skew-symmetric, $\mathbf{v}_{\mathrm{curl}}(\mathbf{x})$ is orthogonal to $\nabla U(\mathbf{x})$ everywhere in phase space and circulates along iso-potential contours without performing net work against $U(\mathbf{x})$. Consequently, $U(\mathbf{x})$ serves as a non-equilibrium Lyapunov function within each basin of attraction: deterministic trajectories spiral inward down $U(\mathbf{x})$ while non-equilibrium forcing sustains persistent cyclic currents around the attractor.

## Physical Early-Warning Signals for Catastrophic Regime Shifts

As environmental forcing or harvesting pressure pushes an ecosystem toward a bifurcation, the local quadratic curvature of the quasi-potential well ($\mathbf{H} = k_{\mathrm{B}}\mathbf{C}^{-1} \propto \nabla^2 U(\mathbf{x}^*)$) degrades along distinct mechanistic pathways that yield quantitative early-warning diagnostics (Scheffer et al. 2009):

- **Curvature collapse and critical slowing down (fold bifurcation):** When chronic environmental stress weakens dissipative self-regulation ($\lambda_{\min}(\mathbf{D}_{\mathrm{sym}}) \to 0$) or erodes the entropic curvature ($\lambda_{\min}(\mathbf{H}) \to 0$), a real eigenvalue of $\mathbf{A}$ approaches zero ($\lambda_1 \to 0^-$). The restoring force along the soft eigenvector direction vanishes, lengthening recovery times after perturbations and causing stationary variance to diverge ($\mathbf{C}_{11} = k_{\mathrm{B}} / \lambda_{\min}(\mathbf{H}) \to \infty$) prior to a saddle-node transition.
- **Capacitance stripping and oscillatory destabilization (Hopf bifurcation):** When selective exploitation or habitat loss strips slow macroscopic biomass capacitors ($C_{ii} \to 0$) while strong trophic throughput sustains skew-symmetric circulation $\boldsymbol{\Omega}$, the non-equilibrium circulation ratio $\chi = \|\boldsymbol{\Omega}\|_F / \|\mathbf{D}_{\mathrm{sym}}\|_F$ surges, as observed in the exploited NPZD-Fish food web (Table \ref{tbl:aquatic_comparison}). A complex conjugate eigenvalue pair $\lambda_{1,2} = \alpha \pm i\omega$ approaches the imaginary axis ($\alpha \to 0^-$ with $\omega \ne 0$), generating amplified rotational fluctuation spirals and narrowband spectral ringing prior to oscillatory collapse.

For empirical monitoring and fisheries management, combining these thermodynamic diagnostics distinguishes directional attractor flattening from oscillatory destabilization. Lengthening recovery times and monotone variance inflation along a single trophic axis indicate fold-type curvature collapse ($\det \mathbf{H} \to 0$), whereas simultaneous inflation of the circulation ratio $\chi$, rising entropy production $\sigma$, and rotational phase-space spiraling indicate that apex or detrital storage capacitance has been stripped, providing an operational warning to reduce harvest mortality before a regime shift occurs.

# Discussion and Evolutionary Synthesis

## Evolutionary Tuning of the Stability Frontier

The thermodynamic framework developed in Paper I (Choi and Hansell 2026) and tested empirically here resolves the apparent conflict between May's (1972) result that random network complexity reduces linear stability and the empirical persistence of diverse natural food webs. Living communities are not unstructured random matrices; rather, their interactions are constrained by mass-balance stoichiometry, allometric scaling across body-size spectra, and positive-definite Onsager dissipation ($\mathbf{D}_{\mathrm{sym}} \succ 0$). Standing biomass capacitance ($\mathbf{C}$, Resistance) buffers low-frequency environmental shortages and pulse shocks, mass-specific metabolic turnover ($\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}$, Resilience) drives rapid recovery through microbial and primary producer guilds, and skew-symmetric probability circulation ($\boldsymbol{\Omega}$) redistributes energy and nutrients across trophic cycles without degrading the local potential gradient.

Across biomes, communities self-organize along the hyperbolic Resistance-Resilience trade-off continuum ($B_{\text{tot}} \times \mathcal{R} \approx \text{constant}$; Fig. \ref{fig_ecosystem_comparison}; Choi and Hansell 2026, Fig. 2). The realized stationary operating point along this frontier represents a homeostatic **Le Chatelier-Braun balance**, in which coupled secondary pathways moderate primary disturbances via the matrix Schur complement and Lyapunov relaxation. When acute shocks or chronic forcing disrupt this balance, the community re-equilibrates across hierarchical timescales, conditioned upon the altered boundary gradients and the internal biological capacitance and circulation pathways that remain intact.

## Haken's Slaving Principle and Planetary Stewardship

In synergetics, Haken's (1983) slaving principle establishes that in multi-scale dynamical systems, fast relaxing modes are adiabatically slaved to slow, high-inertia order parameters. Across the biospheric size spectrum, microscopic guilds (bacteria, phytoplankton, microzooplankton) relax on timescales of hours to days, whereas macroscopic biomass reservoirs (old-growth forest boles, soil humic pools, benthic detritus, and long-lived predatory fish) relax over decades to centuries. These slow macroscopic capacitors act as order parameters that bound the amplitude of fast microbial and planktonic cycles and filter low-frequency climate variability.

Anthropogenic activities that selectively remove slow macroscopic capacitors, including old-growth deforestation, peatland drainage, and size-selective industrial fishing, strip the biosphere's low-frequency impedance filters. Deprived of capacitive damping, fast trophic modes become unslaved, increasing probability circulation volatility ($\chi$), elevating specific dissipation ($\sigma$), and eroding the quasi-potential barriers that prevent irreversible transitions into degraded regimes. Ecosystem-based management therefore requires conserving not only aggregate production fluxes, but also the multi-decadal biomass capacitors and detrital reservoirs that anchor regional and planetary stability.

## Practical Guidelines for Empirical Ecologists

Applying this non-equilibrium thermodynamic framework to field and laboratory datasets involves four operational steps:
- **Measure state variables in extensive mass or energy units:** Quantify compartment stocks in extensive units (such as $\mathrm{g\,C}$, $\mathrm{kcal}$, or $\mathrm{mmol\,N}$) normalized by reference standing biomass ($\delta\tilde{x}_i = \delta B_i / B_i^*$) rather than closed compositional simplex fractions ($\sum_i b_i = 1$), which introduce covariance singularities ($\det\mathbf{C}_b = 0$; Appendix B).
- **Include detrital and resource reservoirs in mass-balanced budgets:** Because non-living detritus and dissolved nutrient pools frequently provide the dominant storage capacitance of aquatic and terrestrial ecosystems, omitting them truncates the Schur complement buffering pathways and distorts stability estimates.
- **Decompose dynamics via the continuous Lyapunov equation:** Rather than testing raw demographic Jacobians $\mathbf{A}$ or naive diagonal products $-\mathbf{A}\operatorname{Diag}(\mathbf{B}^*)$ for symmetry, estimate the stationary covariance $\mathbf{C}$ and drift $\mathbf{A}$ from multivariate time series (or solve $\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} + 2\mathbf{D} = \mathbf{0}$) to separate positive-definite dissipation $\mathbf{D}_{\mathrm{sym}}$ from skew-symmetric circulation $\boldsymbol{\Omega}$.
- **Monitor $\det\mathbf{H}$, $\chi$, and $\sigma$ as early-warning indicators:** Track the entropic curvature $\mathbf{H} = k_{\mathrm{B}}\mathbf{C}^{-1}$, the circulation ratio $\chi$, and the stationary entropy production rate $\sigma$ across rolling time windows to detect capacitance loss and approaching bifurcations before regime shifts occur.


# Glossary of Core Concepts

**Onsager Reciprocal Relations.** Microscopic time-reversal invariance of equilibrium thermal fluctuations ensures that phenomenological transport cross-conductivities are symmetric ($L_{ij} = L_{ji}$).

**Demographic Community Matrix ($\mathbf{A}$).** The Jacobian matrix $A_{ij} = \left.\partial \dot{x}_i / \partial x_j\right|_{\mathbf{x}^*}$ governing linearized population dynamics $\delta\dot{\mathbf{x}} = \mathbf{A}\delta\mathbf{x}$ around a stationary state.

**Continuous Lyapunov Covariance Factorization.** The matrix identity $-\mathbf{A}\mathbf{C} = \mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega}$ (equivalently $\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} = -2\mathbf{D}_{\mathrm{sym}}$) that resolves demographic dynamics into symmetric dissipation and skew-symmetric probability circulation.

**Symmetric Dissipative Operator ($\mathbf{D}_{\mathrm{sym}}$).** The symmetric, positive-definite part $\mathbf{D}_{\mathrm{sym}} = -\frac{1}{2}(\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}}) \succ 0$ of the covariance-weighted drift governing irreversible entropy production and monotonic Lyapunov relaxation.

**Antisymmetric Probability Circulation Tensor ($\boldsymbol{\Omega}$).** The skew-symmetric part $\boldsymbol{\Omega} = \frac{1}{2}(\mathbf{C}\mathbf{A}^{\mathsf{T}} - \mathbf{A}\mathbf{C}) = -\boldsymbol{\Omega}^{\mathsf{T}}$ of the covariance-weighted drift quantifying non-dissipative cyclic trophic flows in state space.

**Non-Equilibrium Circulation Ratio ($\chi$).** The dimensionless Frobenius norm ratio $\chi = \|\boldsymbol{\Omega}\|_F / \|\mathbf{D}_{\mathrm{sym}}\|_F$ (with $\|-\mathbf{A}\mathbf{C}\|_F^2 = \|\mathbf{D}_{\mathrm{sym}}\|_F^2 + \|\boldsymbol{\Omega}\|_F^2 = \|\mathbf{D}_{\mathrm{sym}}\|_F^2(1 + \chi^2)$) measuring the root-mean-square magnitude of cyclic trophic probability currents relative to irreversible dissipative damping across the network.

**Biomass Capacitance ($C_i$).** The entropic storage capacity of an ecological compartment, proportional to its stationary standing stock ($C_i \propto B_i^* / k_{\mathrm{B}}$).

**Entropic Resistance.** The capacity of an ecosystem to absorb external mass or energy perturbations through standing biomass capacitance $\mathbf{C}$ without undergoing large shifts in intensive thermodynamic forces.

**Kinetic Resilience.** The mass-specific recovery rate $\mathcal{R}$ at which perturbations decay back to steady state, governed by the dissipative turnover operator $\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}$.

**Adaptive Capacity and Le Chatelier-Braun Balance.** The capacity of an ecosystem to partition its standing biomass capacitance and metabolic turnover along the hyperbolic trade-off frontier ($B_{\text{tot}} \times \mathcal{R} \approx \text{constant}$). The realized stationary operating point is a Le Chatelier-Braun balance in which coupled secondary pathways moderate primary perturbations via the matrix Schur complement and negative-definite Lyapunov decay ($\dot{V} < 0$).

**Sheldon Size Spectrum.** The empirical macroecological regularity in which standing biomass distributes approximately evenly across logarithmic body-mass octaves ($dB(m)/d\ln m \approx \text{constant}$).

**Kolmogorov Turbulence Cascade.** The multi-scale dissipative process in which energy injected at macroscopic scales is transferred across an inertial subrange via conservative circulation and dissipated into heat at microscopic scales.

**Quasi-Potential Landscape ($U(\mathbf{x})$).** The non-equilibrium scalar landscape $U(\mathbf{x}) = -\lim_{\mathcal{V}\to\infty}\mathcal{V}^{-1}\ln P_{\mathrm{ss}}(\mathbf{x})$ governing stationary probability basins and escape barriers in non-linear stochastic ecosystems.


# Appendix A: Mathematical Extensions

## A.1 Baseline Constitutive Operators and Lyapunov Factorization

The foundational derivations connecting the demographic community matrix $\mathbf{A}$ to the Onsager conductivity matrix $\mathbf{L}$ and the Le Chatelier-Braun Schur complement are established in the companion paper (Choi and Hansell 2026, Appendices A and B) and are summarized here to fix notation for the extensions that follow. For an open ecological network with $n$ extensive state deviations $\delta\mathbf{x} = \mathbf{x} - \mathbf{x}^*$ around a stationary state $\mathbf{x}^*$, the second-order expansion of total entropy change is $\Delta S_{\mathrm{tot}}(\delta\mathbf{x}) = -\frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{H}\delta\mathbf{x}$, where $\mathbf{H} = -\left.\partial^2\Delta S_{\mathrm{tot}}/\partial\mathbf{x}^2\right|_{\mathbf{x}^*} = \mathbf{H}^{\mathsf{T}} \succ 0$ is the symmetric positive-definite entropy Hessian. Conjugate thermodynamic forces $\mathbf{X} = \nabla_{\delta\mathbf{x}}\Delta S_{\mathrm{tot}} = -\mathbf{H}\delta\mathbf{x}$ are related to the stationary Gaussian fluctuation covariance $\mathbf{C} = \langle\delta\mathbf{x}\delta\mathbf{x}^{\mathsf{T}}\rangle = k_{\mathrm{B}}\mathbf{H}^{-1}$ (with effective grain scale $k_{\mathrm{B}}$; Einstein 1910, Callen 1985). Under linear Ornstein-Uhlenbeck dynamics $d\delta\mathbf{x} = \mathbf{A}\delta\mathbf{x}\,dt + \sqrt{2\mathbf{D}}\,d\mathbf{W}_t$, stationary covariance balance $\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} + 2\mathbf{D} = \mathbf{0}$ yields the unique decomposition $-\mathbf{A}\mathbf{C} = k_{\mathrm{B}}\mathbf{L} = \mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega}$, where $\mathbf{D}_{\mathrm{sym}} = -\frac{1}{2}(\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}}) = \mathbf{D} = k_{\mathrm{B}}\mathbf{L}_s \succ 0$ is the symmetric dissipative operator and $\boldsymbol{\Omega} = \frac{1}{2}(\mathbf{C}\mathbf{A}^{\mathsf{T}} - \mathbf{A}\mathbf{C}) = k_{\mathrm{B}}\mathbf{L}_a = -\boldsymbol{\Omega}^{\mathsf{T}}$ is the skew-symmetric circulation tensor.

Under primary-secondary partitioning of $\mathbf{L}$ into a perturbed process $i$ and secondary coupled processes $-i$, free secondary relaxation ($\delta\mathbf{J}_{-i} = \mathbf{0} \implies \delta\mathbf{X}_{-i} = -\mathbf{L}_{-i,-i}^{-1}\mathbf{L}_{-i,i}\delta X_i$) yields the matrix Schur complement (Schur 1917, Prigogine and Defay 1954, Horn and Johnson 2012; Choi and Hansell 2026, Appendix B):

$$L_{ii,\mathrm{eff}} = L_{ii} - \mathbf{L}_{i,-i}\mathbf{L}_{-i,-i}^{-1}\mathbf{L}_{-i,i} > 0$$

which moderates force perturbations under direct symmetric cross-coupling ($0 < L_{ii,\mathrm{eff}} \le L_{ii}$ for $\mathbf{L}_{s;i,-i} = \mathbf{L}_{s;-i,i}^{\mathsf{T}}$) and reduces stationary compliance under cyclic indirect cross-coupling ($0 < L_{ii,\mathrm{eff}}^{-1} \le L_{ii}^{-1}$ for $\mathbf{L}_{a;i,-i} = -\mathbf{L}_{a;-i,i}^{\mathsf{T}}$). In extensive state space, the quadratic Lyapunov availability functional $V(\delta\mathbf{x}) = \frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\delta\mathbf{x} = -\Delta S_{\mathrm{tot}}(\delta\mathbf{x})/k_{\mathrm{B}} > 0$ satisfies $\mathbf{C}^{-1}\mathbf{A} = -\mathbf{C}^{-1}(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}$ and $\mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} = -\mathbf{C}^{-1}(\mathbf{D}_{\mathrm{sym}} - \boldsymbol{\Omega})\mathbf{C}^{-1}$ (since $\boldsymbol{\Omega}^{\mathsf{T}} = -\boldsymbol{\Omega}$), so the skew-symmetric circulation cancels identically in the sum $\mathbf{C}^{-1}\mathbf{A} + \mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} = -2\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}$, yielding monotonic downhill relaxation (Lyapunov 1892, Tomita and Tomita 1974):

$$\dot{V}(\delta\mathbf{x}) = -\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}\delta\mathbf{x} < 0 \quad (\forall\,\delta\mathbf{x} \ne \mathbf{0})$$


## A.2 Coordinate Invariance Under Linear Transformations

Following the geometric formulation of non-equilibrium diffusion processes on smooth manifolds (Graham 1977, Eyink 1990), let state departures be transformed by an invertible linear coordinate transformation $\delta\mathbf{y} = \mathbf{M}\delta\mathbf{x}$, where $\mathbf{M} \in \mathbb{R}^{n \times n}$ with $\det \mathbf{M} \ne 0$.

Under this transformation, dynamical and stochastic operators transform according to standard contravariant and covariant tensor rules. The linearized population dynamics transform via similarity:

$$\frac{d}{dt}\delta\mathbf{y} = \mathbf{M}\frac{d}{dt}\delta\mathbf{x} = \mathbf{M}\mathbf{A}\delta\mathbf{x} = \mathbf{M}\mathbf{A}\mathbf{M}^{-1}\delta\mathbf{y} \implies \mathbf{A}_y = \mathbf{M}\mathbf{A}\mathbf{M}^{-1}$$

The stationary fluctuation covariance and diffusion tensors transform contravariantly via congruence:

$$\mathbf{C}_y = \langle \delta\mathbf{y}\delta\mathbf{y}^{\mathsf{T}} \rangle = \mathbf{M}\mathbf{C}\mathbf{M}^{\mathsf{T}}, \qquad \mathbf{D}_y = \mathbf{M}\mathbf{D}\mathbf{M}^{\mathsf{T}}$$

while the entropic curvature tensor transforms covariantly:

$$\mathbf{H}_y = k_{\mathrm{B}}\mathbf{C}_y^{-1} = k_{\mathrm{B}}(\mathbf{M}\mathbf{C}\mathbf{M}^{\mathsf{T}})^{-1} = \mathbf{M}^{-\mathsf{T}}\mathbf{H}\mathbf{M}^{-1}$$

Evaluating the continuous Lyapunov balance in the transformed coordinates confirms exact tensorial invariance:

$$\mathbf{A}_y\mathbf{C}_y + \mathbf{C}_y\mathbf{A}_y^{\mathsf{T}} + 2\mathbf{D}_y = (\mathbf{M}\mathbf{A}\mathbf{M}^{-1})(\mathbf{M}\mathbf{C}\mathbf{M}^{\mathsf{T}}) + (\mathbf{M}\mathbf{C}\mathbf{M}^{\mathsf{T}})(\mathbf{M}^{-\mathsf{T}}\mathbf{A}^{\mathsf{T}}\mathbf{M}^{\mathsf{T}}) + 2\mathbf{M}\mathbf{D}\mathbf{M}^{\mathsf{T}} = \mathbf{M}(\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} + 2\mathbf{D})\mathbf{M}^{\mathsf{T}} = \mathbf{0}$$

Similarly, the covariance-weighted drift $-\mathbf{A}_y\mathbf{C}_y$ transforms by congruence, preserving the symmetry and positive definiteness of $\mathbf{D}_{\mathrm{sym}}$ (by Sylvester's law of inertia) and the skew-symmetry of $\boldsymbol{\Omega}$:

$$-\mathbf{A}_y\mathbf{C}_y = \mathbf{M}(-\mathbf{A}\mathbf{C})\mathbf{M}^{\mathsf{T}} = \mathbf{D}_{\mathrm{sym},y} + \boldsymbol{\Omega}_y, \qquad \mathbf{D}_{\mathrm{sym},y} = \mathbf{M}\mathbf{D}_{\mathrm{sym}}\mathbf{M}^{\mathsf{T}} \succ 0, \qquad \boldsymbol{\Omega}_y = \mathbf{M}\boldsymbol{\Omega}\mathbf{M}^{\mathsf{T}} = -\boldsymbol{\Omega}_y^{\mathsf{T}}$$

All fundamental dynamical and thermodynamic scalars are invariant under any non-singular linear coordinate change $\mathbf{M}$:
- **Eigenvalue spectrum and total dissipative relaxation rate:** $\operatorname{spec}(\mathbf{A}_y) = \operatorname{spec}(\mathbf{A})$, and the aggregate kinetic relaxation rate satisfies $\operatorname{tr}(\mathbf{D}_{\mathrm{sym},y}\mathbf{C}_y^{-1}) = \operatorname{tr}(\mathbf{M}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}\mathbf{M}^{-1}) = \operatorname{tr}(\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}) = -\operatorname{tr}(\mathbf{A})$.
- **Stationary entropy production rate:** $\sigma_y = k_{\mathrm{B}}\operatorname{tr}(\boldsymbol{\Omega}_y^{\mathsf{T}}\mathbf{C}_y^{-1}\boldsymbol{\Omega}_y\mathbf{D}_y^{-1}) = k_{\mathrm{B}}\operatorname{tr}(\mathbf{M}^{-\mathsf{T}}\boldsymbol{\Omega}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{D}^{-1}\mathbf{M}^{\mathsf{T}}) = \sigma$.
- **Riemannian circulation ratio:** Evaluated in the natural Riemannian metric $\mathbf{C}^{-1}$ (standardized coordinates $\delta\tilde{\mathbf{x}} = \mathbf{C}^{-1/2}\delta\mathbf{x}$; Appendix D.1), the metric-weighted circulation ratio $\tilde{\chi} = \left[\operatorname{tr}(\boldsymbol{\Omega}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}) / \operatorname{tr}(\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1})\right]^{1/2}$ is strictly invariant under any invertible $\mathbf{M}$.

### A.2.1 Analytical Verification on Mock Numerical Networks

To verify continuous Lyapunov covariance factorization and estimator consistency across distinct physical and ecological network topologies, three analytical benchmark models implemented in `OnsagerNetwork` were evaluated (Fig. \ref{fig_app2_mock_results}):
- **Two-mode and four-mode thermal networks:** Two heat reservoirs ($T_1, T_2$) coupled by thermal conductances at $T = 300\ \mathrm{K}$ are simulated with and without non-reciprocal driving $\kappa$. At equilibrium ($\kappa = 0$), fluctuations obey detailed balance and the continuous-time quadrature estimator recovers the exact symmetric conductivity $\widehat{\mathbf{L}}_x \to \mathbf{L}$ with vanishing circulation ($\boldsymbol{\Omega} = \mathbf{0}$). Under non-equilibrium driving ($\kappa = 0.5\ \mathrm{s}^{-1}$), probability circulation $\Omega_{12}$ and excess dissipation $\sigma$ emerge and scale quadratically with $\kappa$ (Fig. \ref{fig_app2_mock_results}A,B), while diagonal coordinate rescaling $\boldsymbol{\Lambda} = \operatorname{Diag}(2.0, 0.5)$ and four-mode marginal coarse-graining confirm exact congruence transformation $\widehat{\mathbf{L}}_y = \boldsymbol{\Lambda}\widehat{\mathbf{L}}_x\boldsymbol{\Lambda}^{\mathsf{T}}$.
- **Fast-slow evolving trait network:** A two-pathway reversible Markov jump reaction network coupled to a slowly evolving behavioral or physiological trait $\theta_k$ demonstrates that adiabatic elimination of the secondary pathway via the Schur complement moderates the effective primary conductivity ($0 < L_{11,\mathrm{eff}}(\theta_k) \le L_{11}(\theta_k)$; Fig. \ref{fig_app2_mock_results}C).
- **Three-species trophic chain:** A three-species producer-herbivore-carnivore Ornstein-Uhlenbeck system with asymmetric community matrix $\mathbf{A}$ ($A_{ij} \ne A_{ji}$) confirms that continuous Lyapunov factorization recovers the positive-definite dissipative matrix $\widehat{\mathbf{K}}_{\mathrm{cov}} = -\widehat{\mathbf{A}}\widehat{\mathbf{C}}$ with relative Frobenius error below $2\%$, whereas naive biomass-fraction weighting $\mathbf{W}_B = \mathbf{A}\operatorname{Diag}(\mathbf{b})$ remains asymmetric (Fig. \ref{fig_app2_mock_results}D).

![Analytical verification of Onsager symmetry recovery, driven probability circulation, evolutionary trait adaptation, and coordinate invariance. (A) Two-mode thermal network decomposition: off-diagonal phenomenological conductivities in equilibrium ($\kappa = 0$) and driven non-equilibrium steady states (NESS, $\kappa = 0.5\ \mathrm{s}^{-1}$), showing exact recovery of symmetric conductivity $\mathbf{L}_{12}$ and emergent antisymmetric probability circulation $-\Omega_{12} / k_{\mathrm{B}}$. (B) Quadratic scaling: non-equilibrium probability circulation $\Omega_{12}^2$ and excess dissipation $\dot{S}_{\mathrm{diss}}$ scale quadratically with non-equilibrium driving force $\kappa$. (C) Fast-slow evolving trait adaptation: conditional conductivity and Schur complement moderation under Le Chatelier-Braun adaptation. (D) 3-species trophic chain: recovery of Onsager reciprocal symmetry and invariance under linear coordinate transformations.](media/fig_app2_mock_results.png){#fig_app2_mock_results width=85%}


## A.3 Extremum Dissipation Principles: Clamped Forces vs. Clamped Fluxes

Following the variational formulations of Onsager (1931a,b), Onsager and Machlup (1953), and Prigogine (1955), whether a linear non-equilibrium steady state maximizes or minimizes entropy production depends on which boundary variables are clamped (Shiner and Sieniutycz 1994, Martyushev and Seleznev 2006, Reis 2014). Under clamped thermodynamic forces $\mathbf{X}$, the Onsager-Machlup functional is (Onsager and Machlup 1953, Ziegler 1983, Dewar 2003):

$$\Phi(\mathbf{J}) = \sigma(\mathbf{J}, \mathbf{X}) - \Psi(\mathbf{J}) = \sum_{i} J_i X_i - \frac{1}{2}\sum_{i,j} R_{s;ij} J_i J_j$$

Setting the first variation with respect to flux $J_k$ to zero gives $\partial \Phi / \partial J_k = X_k - \sum_j R_{s;kj} J_j = 0 \implies \mathbf{J} = \mathbf{L}_s\mathbf{X}$. Because the Hessian with respect to $\mathbf{J}$ is negative definite ($\partial^2 \Phi / \partial \mathbf{J}^2 = -\mathbf{R}_s \prec 0$), the constitutive response maximizes $\Phi(\mathbf{J})$ (and thus boundary dissipation $\sigma = \mathbf{X}^{\mathsf{T}}\mathbf{L}_s\mathbf{X}$) at fixed driving forces.

Conversely, when boundary fluxes are clamped or a subset of internal forces $X_k$ are left unconstrained to relax to zero-flux stationarity ($J_k = 0$), differentiating $\sigma(\mathbf{X}) = \mathbf{X}^{\mathsf{T}}\mathbf{L}_s\mathbf{X}$ with respect to each free internal force $X_k$ yields:

$$\frac{\partial \sigma}{\partial X_k} = 2\sum_j L_{s;kj} X_j = 2 J_{s;k} = 0, \qquad \frac{\partial^2 \sigma}{\partial \mathbf{X}^2} = 2\mathbf{L}_s \succ 0$$

Because the Hessian $2\mathbf{L}_s$ is strictly positive definite, stationary relaxation of unconstrained internal forces minimizes entropy production (Prigogine 1955, 1967, Glansdorff and Prigogine 1971), with the minimized dissipation given directly by the Schur complement $\sigma_{\min} = L_{11,\mathrm{eff}}\,\delta X_1^2 \le L_{11}\,\delta X_1^2$.


## A.4 Non-Equilibrium Helmholtz-Hodge Decomposition in Non-Linear Phase Space

In far-from-equilibrium systems governed by the non-linear Langevin equation:

$$\dot{\mathbf{x}} = \mathbf{f}(\mathbf{x}) + \frac{1}{\sqrt{\mathcal{V}}}\boldsymbol{\xi}(t), \qquad \langle \boldsymbol{\xi}(t) \boldsymbol{\xi}^{\mathsf{T}}(t') \rangle = 2\mathbf{D}(\mathbf{x})\delta(t - t')$$

the stationary probability distribution $P_{\mathrm{ss}}(\mathbf{x})$ satisfies the stationary Fokker-Planck equation $\nabla \cdot \mathbf{J}_{\mathrm{prob}}(\mathbf{x}) = 0$. By Freidlin-Wentzell large deviation theory (Freidlin and Wentzell 1984), $P_{\mathrm{ss}}(\mathbf{x}) \asymp \exp(-\mathcal{V} U(\mathbf{x}))$, where $U(\mathbf{x})$ is the non-equilibrium quasi-potential.

The stationary probability flux is:

$$\mathbf{J}_{\mathrm{prob}}(\mathbf{x}) = \mathbf{f}(\mathbf{x})P_{\mathrm{ss}}(\mathbf{x}) - \frac{1}{\mathcal{V}}\mathbf{D}(\mathbf{x})\nabla P_{\mathrm{ss}}(\mathbf{x}) = \left( \mathbf{f}(\mathbf{x}) + \mathbf{D}(\mathbf{x})\nabla U(\mathbf{x}) \right) P_{\mathrm{ss}}(\mathbf{x}) + \mathcal{O}(\mathcal{V}^{-1})$$

Defining the stationary circulation velocity field $\mathbf{v}_{\mathrm{curl}}(\mathbf{x}) \equiv \mathbf{J}_{\mathrm{prob}}(\mathbf{x}) / P_{\mathrm{ss}}(\mathbf{x}) = \mathbf{f}(\mathbf{x}) + \mathbf{D}(\mathbf{x})\nabla U(\mathbf{x})$ yields the non-equilibrium Helmholtz-Hodge decomposition of the deterministic drift (Helmholtz 1858, Hodge 1941, Graham 1977, Ao 2004, Qian 2006):

$$\mathbf{f}(\mathbf{x}) = -\mathbf{D}(\mathbf{x})\nabla U(\mathbf{x}) + \mathbf{v}_{\mathrm{curl}}(\mathbf{x})$$

Substituting this decomposition into the leading-order WKB Hamilton-Jacobi equation $\nabla U(\mathbf{x})^{\mathsf{T}} \mathbf{D}(\mathbf{x}) \nabla U(\mathbf{x}) + \mathbf{f}(\mathbf{x})^{\mathsf{T}}\nabla U(\mathbf{x}) = 0$ in the macroscopic limit $\mathcal{V} \to \infty$ (Freidlin and Wentzell 1984, Graham 1977, Ao 2004) gives:

$$\nabla U(\mathbf{x})^{\mathsf{T}} \mathbf{D}(\mathbf{x}) \nabla U(\mathbf{x}) + \left( -\mathbf{D}(\mathbf{x})\nabla U(\mathbf{x}) + \mathbf{v}_{\mathrm{curl}}(\mathbf{x}) \right)^{\mathsf{T}}\nabla U(\mathbf{x}) = \mathbf{v}_{\mathrm{curl}}(\mathbf{x})^{\mathsf{T}}\nabla U(\mathbf{x}) = 0$$

This confirms that the stationary circulation velocity $\mathbf{v}_{\mathrm{curl}}(\mathbf{x})$ is orthogonal to the quasi-potential gradient $\nabla U(\mathbf{x})$ across phase space, circulating along iso-potential surfaces without altering $U(\mathbf{x})$.

In the path-integral formulation (Onsager and Machlup 1953, Freidlin and Wentzell 1984), the probability density functional of a continuous state trajectory $\mathbf{x}(t)$ over $[t_1, t_2]$ scales as $\mathcal{P}[\mathbf{x}(t)] \asymp \exp(-\mathcal{V}\mathcal{S}[\mathbf{x}(t)])$, governed in the linearized regime ($\mathbf{f}(\mathbf{x}) = \mathbf{A}\mathbf{x}$, $\mathbf{D}(\mathbf{x}) = \mathbf{D}_{\mathrm{sym}}$, $\mathcal{V} = 1$) by the Onsager-Machlup action functional:

$$\mathcal{S}[\mathbf{x}(t)] = \int_{t_1}^{t_2} \frac{1}{4}\left(\dot{\mathbf{x}} - \mathbf{A}\mathbf{x}\right)^{\mathsf{T}}\mathbf{D}_{\mathrm{sym}}^{-1}\left(\dot{\mathbf{x}} - \mathbf{A}\mathbf{x}\right)\,dt$$

Minimizing $\mathcal{S}[\mathbf{x}(t)]$ selects the most probable trajectory (instanton) in path space. For unconstrained relaxation from an initial state perturbation $\mathbf{x}(0) = \mathbf{x}_0$, $\mathbf{D}_{\mathrm{sym}}^{-1} \succ 0$ implies $\mathcal{S}_{\min} = 0$, attained along the deterministic relaxation path $\dot{\mathbf{x}} = \mathbf{A}\mathbf{x} = -(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}\mathbf{x}$. Conversely, for a noise-driven fluctuation excursion from the attractor $\mathbf{x}(-\infty) = \mathbf{0}$ to a displaced state $\mathbf{x}(0) = \mathbf{x}_f$, completing the square around the adjoint drift $\mathbf{A}^* = \mathbf{C}\mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} = -(\mathbf{D}_{\mathrm{sym}} - \boldsymbol{\Omega})\mathbf{C}^{-1}$ using the continuous Lyapunov identity $\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} = -2\mathbf{D}_{\mathrm{sym}}$ yields:

$$\mathcal{S}[\mathbf{x}(t)] = \int_{-\infty}^{0} \frac{1}{4}\left(\dot{\mathbf{x}} - \mathbf{A}^*\mathbf{x}\right)^{\mathsf{T}}\mathbf{D}_{\mathrm{sym}}^{-1}\left(\dot{\mathbf{x}} - \mathbf{A}^*\mathbf{x}\right)\,dt + \frac{1}{2}\mathbf{x}_f^{\mathsf{T}}\mathbf{C}^{-1}\mathbf{x}_f$$

The minimum action required to reach $\mathbf{x}_f$ against the restoring drift is attained along the uphill instanton $\dot{\mathbf{x}} = \mathbf{A}^*\mathbf{x}$ and equals the quadratic Lyapunov availability potential:

$$\mathcal{S}_{\min}(\mathbf{x}_f) = \min_{\mathbf{x}(-\infty)=\mathbf{0},\,\mathbf{x}(0)=\mathbf{x}_f} \mathcal{S}[\mathbf{x}(t)] = \frac{1}{2}\mathbf{x}_f^{\mathsf{T}}\mathbf{C}^{-1}\mathbf{x}_f = V(\mathbf{x}_f)$$

When $\boldsymbol{\Omega} \ne \mathbf{0}$, the most probable excitation path ($\dot{\mathbf{x}} = -(\mathbf{D}_{\mathrm{sym}} - \boldsymbol{\Omega})\mathbf{C}^{-1}\mathbf{x}$) and the most probable relaxation path ($\dot{\mathbf{x}} = -(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}\mathbf{x}$) do not retrace each other in reverse, but rotate in the same circulatory direction set by $\boldsymbol{\Omega}$.


## A.5 Explicit Derivation of the Stationary Entropy Production Trace Formula from Fokker-Planck Probability Currents

Following the stochastic thermodynamics of non-equilibrium stationary states (Tomita and Tomita 1974, Schnakenberg 1976, Tomé 2006, Seifert 2012, Zhang et al. 2012), this section derives the exact stationary entropy production trace formula:

$$\sigma = k_{\mathrm{B}} \operatorname{tr}\left( \boldsymbol{\Omega}^{\mathsf{T}} \mathbf{C}^{-1} \boldsymbol{\Omega} \mathbf{D}^{-1} \right)$$

from the continuous Fokker-Planck probability flux $\mathbf{J}_{\mathrm{prob}}(\mathbf{x}) = \mathbf{M}\mathbf{x} P_{\mathrm{ss}}(\mathbf{x})$.

### Step 1: The Linear Fokker-Planck Equation and Probability Current
Consider an $n$-dimensional ecological system in state space $\mathbf{x} \in \mathbb{R}^n$ (departures from reference steady state $\mathbf{x}^*$) governed by linear drift $\mathbf{A}\mathbf{x}$ and constant symmetric noise diffusion tensor $\mathbf{D} \succ 0$. The probability density $P(\mathbf{x}, t)$ evolves according to:

$$\frac{\partial P(\mathbf{x}, t)}{\partial t} = -\nabla \cdot \mathbf{J}_{\mathrm{prob}}(\mathbf{x}, t)$$

where the probability flux vector field is:

$$\mathbf{J}_{\mathrm{prob}}(\mathbf{x}, t) = \mathbf{A}\mathbf{x} P(\mathbf{x}, t) - \mathbf{D}\nabla P(\mathbf{x}, t)$$

### Step 2: Stationary Distribution and Spatial Log-Gradient
At dynamic stationarity ($\partial P_{\mathrm{ss}} / \partial t = 0$), the unconstrained linear system admits a centered multivariate Gaussian distribution:

$$P_{\mathrm{ss}}(\mathbf{x}) = \frac{1}{(2\pi)^{n/2}(\det \mathbf{C})^{1/2}} \exp\left( -\frac{1}{2}\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\mathbf{x} \right)$$

where $\mathbf{C} = \langle \mathbf{x}\mathbf{x}^{\mathsf{T}} \rangle_{\mathrm{ss}} \succ 0$ is the stationary covariance matrix satisfying the continuous Lyapunov equation:

$$\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} + 2\mathbf{D} = \mathbf{0}$$

Differentiating $P_{\mathrm{ss}}(\mathbf{x})$ with respect to state vector $\mathbf{x}$:

$$\nabla P_{\mathrm{ss}}(\mathbf{x}) = -\mathbf{C}^{-1}\mathbf{x} \, P_{\mathrm{ss}}(\mathbf{x})$$

### Step 3: Stationary Current and the Circulation Drift Operator $\mathbf{M}$
Substituting $\nabla P_{\mathrm{ss}}(\mathbf{x})$ into the stationary probability current:

$$\mathbf{J}_{\mathrm{prob}}(\mathbf{x}) = \mathbf{A}\mathbf{x} P_{\mathrm{ss}}(\mathbf{x}) - \mathbf{D}\left( -\mathbf{C}^{-1}\mathbf{x} P_{\mathrm{ss}}(\mathbf{x}) \right) = \left( \mathbf{A} + \mathbf{D}\mathbf{C}^{-1} \right)\mathbf{x} P_{\mathrm{ss}}(\mathbf{x})$$

To evaluate $\mathbf{A} + \mathbf{D}\mathbf{C}^{-1}$, multiply the continuous Lyapunov equation on the right by $\mathbf{C}^{-1}$:

$$\mathbf{A}\mathbf{C}\mathbf{C}^{-1} + \mathbf{C}\mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} + 2\mathbf{D}\mathbf{C}^{-1} = \mathbf{0} \implies \mathbf{A} + \mathbf{C}\mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} + 2\mathbf{D}\mathbf{C}^{-1} = \mathbf{0}$$

Solving for $\mathbf{D}\mathbf{C}^{-1}$:

$$\mathbf{D}\mathbf{C}^{-1} = -\frac{1}{2}\mathbf{A} - \frac{1}{2}\mathbf{C}\mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1}$$

Substituting this identity into the drift term yields:

$$\mathbf{A} + \mathbf{D}\mathbf{C}^{-1} = \mathbf{A} - \frac{1}{2}\mathbf{A} - \frac{1}{2}\mathbf{C}\mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} = \frac{1}{2}\mathbf{A} - \frac{1}{2}\mathbf{C}\mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} = \frac{1}{2}\left( \mathbf{A}\mathbf{C} - \mathbf{C}\mathbf{A}^{\mathsf{T}} \right)\mathbf{C}^{-1}$$

From the canonical Lyapunov decomposition $-\mathbf{A}\mathbf{C} = \mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega}$, where $\mathbf{D}_{\mathrm{sym}} = -\frac{1}{2}(\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}}) = \mathbf{D}$ is symmetric and $\boldsymbol{\Omega} = \operatorname{asym}(-\mathbf{A}\mathbf{C}) = -\frac{1}{2}(\mathbf{A}\mathbf{C} - \mathbf{C}\mathbf{A}^{\mathsf{T}})$ is skew-symmetric:

$$\frac{1}{2}\left( \mathbf{A}\mathbf{C} - \mathbf{C}\mathbf{A}^{\mathsf{T}} \right) = -\boldsymbol{\Omega}$$

Consequently:

$$\mathbf{A} + \mathbf{D}\mathbf{C}^{-1} = -\boldsymbol{\Omega}\mathbf{C}^{-1}$$

Defining the linear circulation drift matrix $\mathbf{M} := -\boldsymbol{\Omega}\mathbf{C}^{-1}$, the stationary probability current simplifies to:

$$\mathbf{J}_{\mathrm{prob}}(\mathbf{x}) = \mathbf{M}\mathbf{x} P_{\mathrm{ss}}(\mathbf{x}) = -\boldsymbol{\Omega}\mathbf{C}^{-1}\mathbf{x} P_{\mathrm{ss}}(\mathbf{x})$$

Note that $\mathbf{J}_{\mathrm{prob}}(\mathbf{x})$ is strictly divergence-free:

$$\nabla \cdot \mathbf{J}_{\mathrm{prob}}(\mathbf{x}) = \operatorname{tr}(\mathbf{M}) P_{\mathrm{ss}}(\mathbf{x}) + \mathbf{x}^{\mathsf{T}}\mathbf{M}^{\mathsf{T}}\nabla P_{\mathrm{ss}}(\mathbf{x}) = -\operatorname{tr}(\boldsymbol{\Omega}\mathbf{C}^{-1}) P_{\mathrm{ss}}(\mathbf{x}) + \mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}\mathbf{x} P_{\mathrm{ss}}(\mathbf{x})$$

Because $\mathbf{C}^{-1}$ is symmetric and $\boldsymbol{\Omega}$ is skew-symmetric, $\operatorname{tr}(\boldsymbol{\Omega}\mathbf{C}^{-1}) = 0$ and the quadratic form $\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}\mathbf{x} = 0$. Hence $\nabla \cdot \mathbf{J}_{\mathrm{prob}}(\mathbf{x}) = 0$, confirming stationarity.

### Step 4: Phase-Space Integration of Thermodynamic Entropy Production
In stochastic thermodynamics (Tomita and Tomita 1974, Qian 2001, Seifert 2012), the stationary total entropy production rate $\sigma$ measures the thermodynamic irreversibility of probability currents against diffusive friction:

$$\sigma = k_{\mathrm{B}} \int_{\mathbb{R}^n} \frac{\mathbf{J}_{\mathrm{prob}}(\mathbf{x})^{\mathsf{T}} \mathbf{D}^{-1} \mathbf{J}_{\mathrm{prob}}(\mathbf{x})}{P_{\mathrm{ss}}(\mathbf{x})}\, d\mathbf{x}$$

Substituting $\mathbf{J}_{\mathrm{prob}}(\mathbf{x}) = \mathbf{M}\mathbf{x} P_{\mathrm{ss}}(\mathbf{x})$:

$$\sigma = k_{\mathrm{B}} \int_{\mathbb{R}^n} \frac{\left( \mathbf{M}\mathbf{x} P_{\mathrm{ss}}(\mathbf{x}) \right)^{\mathsf{T}} \mathbf{D}^{-1} \left( \mathbf{M}\mathbf{x} P_{\mathrm{ss}}(\mathbf{x}) \right)}{P_{\mathrm{ss}}(\mathbf{x})}\, d\mathbf{x} = k_{\mathrm{B}} \int_{\mathbb{R}^n} \left( \mathbf{x}^{\mathsf{T}}\mathbf{M}^{\mathsf{T}}\mathbf{D}^{-1}\mathbf{M}\mathbf{x} \right) P_{\mathrm{ss}}(\mathbf{x})\, d\mathbf{x}$$

### Step 5: Reduction via Cyclic Trace and Stationary Covariance
Using the cyclic trace identity for quadratic forms $\mathbf{x}^{\mathsf{T}}\mathbf{K}\mathbf{x} = \operatorname{tr}(\mathbf{K}\mathbf{x}\mathbf{x}^{\mathsf{T}})$ where $\mathbf{K} = \mathbf{M}^{\mathsf{T}}\mathbf{D}^{-1}\mathbf{M}$:

$$\sigma = k_{\mathrm{B}} \int_{\mathbb{R}^n} \operatorname{tr}\left( \mathbf{M}^{\mathsf{T}}\mathbf{D}^{-1}\mathbf{M} \, \mathbf{x}\mathbf{x}^{\mathsf{T}} \right) P_{\mathrm{ss}}(\mathbf{x})\, d\mathbf{x} = k_{\mathrm{B}} \operatorname{tr}\left[ \mathbf{M}^{\mathsf{T}}\mathbf{D}^{-1}\mathbf{M} \int_{\mathbb{R}^n} \mathbf{x}\mathbf{x}^{\mathsf{T}} P_{\mathrm{ss}}(\mathbf{x})\, d\mathbf{x} \right]$$

Recognizing the integral as the stationary covariance matrix $\int_{\mathbb{R}^n} \mathbf{x}\mathbf{x}^{\mathsf{T}} P_{\mathrm{ss}}(\mathbf{x})\, d\mathbf{x} = \langle \mathbf{x}\mathbf{x}^{\mathsf{T}} \rangle_{\mathrm{ss}} = \mathbf{C}$:

$$\sigma = k_{\mathrm{B}} \operatorname{tr}\left( \mathbf{M}^{\mathsf{T}}\mathbf{D}^{-1}\mathbf{M} \, \mathbf{C} \right)$$

### Step 6: Expansion in Circulation and Covariance Tensors
Substituting $\mathbf{M} = -\boldsymbol{\Omega}\mathbf{C}^{-1}$ and $\mathbf{M}^{\mathsf{T}} = -\mathbf{C}^{-1}\boldsymbol{\Omega}^{\mathsf{T}}$:

$$\sigma = k_{\mathrm{B}} \operatorname{tr}\left( \left(-\mathbf{C}^{-1}\boldsymbol{\Omega}^{\mathsf{T}}\right) \mathbf{D}^{-1} \left(-\boldsymbol{\Omega}\mathbf{C}^{-1}\right) \mathbf{C} \right) = k_{\mathrm{B}} \operatorname{tr}\left( \mathbf{C}^{-1}\boldsymbol{\Omega}^{\mathsf{T}}\mathbf{D}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}\mathbf{C} \right)$$

Because $\mathbf{C}^{-1}\mathbf{C} = \mathbf{I}$:

$$\sigma = k_{\mathrm{B}} \operatorname{tr}\left( \mathbf{C}^{-1}\boldsymbol{\Omega}^{\mathsf{T}}\mathbf{D}^{-1}\boldsymbol{\Omega} \right)$$

Applying the cyclic invariance of the trace ($\operatorname{tr}(\mathbf{U}\mathbf{V}) = \operatorname{tr}(\mathbf{V}\mathbf{U})$) with $\mathbf{U} = \mathbf{C}^{-1}$ and $\mathbf{V} = \boldsymbol{\Omega}^{\mathsf{T}}\mathbf{D}^{-1}\boldsymbol{\Omega}$:

$$\sigma = k_{\mathrm{B}} \operatorname{tr}\left( \boldsymbol{\Omega}^{\mathsf{T}} \mathbf{C}^{-1} \boldsymbol{\Omega} \mathbf{D}^{-1} \right)$$

Using $\boldsymbol{\Omega}^{\mathsf{T}} = -\boldsymbol{\Omega}$, this is identically:

$$\sigma = -k_{\mathrm{B}} \operatorname{tr}\left( \boldsymbol{\Omega} \mathbf{C}^{-1} \boldsymbol{\Omega} \mathbf{D}^{-1} \right)$$

### Step 7: Positivity, Detailed Balance, and Invariance

Strict non-negativity of entropy production follows directly: because $\mathbf{D} \succ 0 \implies \mathbf{D}^{-1} \succ 0$ and $\mathbf{C} \succ 0 \implies \mathbf{C}^{-1} \succ 0$, the matrix $\mathbf{K} = \boldsymbol{\Omega}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega} \succeq 0$ is positive semidefinite. The trace product of two positive semidefinite matrices is non-negative, ensuring $\sigma \ge 0$ unconditionally and satisfying the Second Law. Detailed balance holds if and only if probability circulation vanishes ($\boldsymbol{\Omega} = \mathbf{0}$), in which case $\sigma = 0$; conversely, in any living food web with active trophic cycling, $\boldsymbol{\Omega} \ne \mathbf{0}$ and $\sigma > 0$. Finally, under any linear coordinate transformation $\mathbf{x}_{\mathrm{new}} = \mathbf{M}_{\mathrm{coord}}\mathbf{x}_{\mathrm{old}}$, direct substitution confirms $\sigma_{\mathrm{new}} = \sigma_{\mathrm{old}}$, establishing that $\sigma$ is an exact coordinate-invariant physical scalar.


\newpage

# Appendix B: Coordinate Breakdown Under Simplex and Logarithmic Transformations (Aitchison 1986, Itô 1951)

Following the mathematical principles of compositional data analysis (Aitchison 1986), relative coordinates introduce geometric singularities that destroy physical Onsager symmetry.

### Simplex Coordinates (Biomass Fractions)
Let $x_i \ge 0$ with $\sum_{i=1}^n x_i = B_{\text{tot}}$. Define relative fractions $b_i = x_i / B_{\text{tot}}$. By construction:

$$\sum_{i=1}^n b_i = 1 \implies \sum_{i=1}^n \delta b_i = \mathbf{1}^{\mathsf{T}}\delta\mathbf{b} = 0$$

where $\mathbf{1} = (1, 1, \dots, 1)^{\mathsf{T}}$. The covariance matrix of fractional deviations is $\mathbf{C}_b = \langle \delta\mathbf{b}\delta\mathbf{b}^{\mathsf{T}} \rangle$. Multiplying by $\mathbf{1}$:

$$\mathbf{C}_b\mathbf{1} = \langle \delta\mathbf{b}(\delta\mathbf{b}^{\mathsf{T}}\mathbf{1}) \rangle = \langle \delta\mathbf{b}(0) \rangle = \mathbf{0}$$

Because $\mathbf{1}$ is a non-trivial null vector, $\mathbf{C}_b$ has an eigenvalue of zero:

$$\det\mathbf{C}_b = 0$$

Consequently, the entropic curvature matrix $\mathbf{H}_b = k_{\mathrm{B}}\mathbf{C}_b^{-1}$ does not exist; its eigenvalues diverge to infinity. Simplex coordinates destroy the physical container.

### Log-Transformed Coordinates
Let $y_i = \ln x_i$. By Itô's lemma, if $x_i$ follows the linear diffusion $dx_i = \sum_j A_{ij}(x_j - x_j^*)dt + \sum_k \sigma_{ik}dW_k$, the stochastic differential equation for $y_i$ is:

$$dy_i = \frac{1}{x_i}dx_i - \frac{1}{2x_i^2}(dx_i)^2 = \left( \sum_j A_{ij}\frac{x_j - x_j^*}{x_i} - \frac{1}{2x_i^2}\sum_k \sigma_{ik}^2 \right) dt + \sum_k \frac{\sigma_{ik}}{x_i}dW_k$$

The drift of $y_i$ is non-linear and includes an unphysical noise-induced drift term ($-\frac{1}{2x_i^2}\sum_k \sigma_{ik}^2$). Linearizing about $y_i^* = \ln x_i^*$ yields:

$$\delta y_i \approx \frac{\delta x_i}{x_i^*}$$

While the first-order Taylor expansion matches the relative coordinate $\delta\tilde{x}_i$, exact logarithmic coordinates $y_i$ introduce non-linear curvature corrections that violate the continuous Lyapunov equation $\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} + 2\mathbf{D} = \mathbf{0}$, producing negative entropy production artifacts.


\newpage


# Appendix C: Stochastic Simulation Models, Gillespie Algorithm, and Software Suite
 
In continuous-time discrete-state Markov jump processes, ecological population configurations within control volume element $\mathcal{V}$ are represented by integer counts $\mathbf{x} = (N_1, \dots, N_n)^{\mathsf{T}} \in \mathbb{N}_0^n$ (Gillespie 1977, 1992, van Kampen 1992).

Three elementary demographic reaction channels govern the size-structured community (`PopulationJumpParams` in `src/onsagernetwork.jl`):
- **Intrinsic birth and autotrophic growth:** Each compartment $i$ reproduces at allometric rate $b_i(\mathbf{x}) = r_i m_i^{-0.25} N_i$ with stoichiometric shift $\boldsymbol{\nu}_i^{\mathrm{birth}} = +\mathbf{e}_i$.
- **Metabolic respiration and intraspecific density-dependent mortality:** Compartment $i$ loses individuals at rate $d_i(\mathbf{x}) = \mu_i m_i^{-0.25} N_i + \frac{c_i}{\mathcal{V}} N_i(N_i - 1)$ with stoichiometric shift $\boldsymbol{\nu}_i^{\mathrm{resp}} = -\mathbf{e}_i$.
- **Size-structured trophic predation ($\alpha = (i, j)$ with $m_i > m_j$):** Predation by predator $i$ on prey $j$ removes $k_{ij} = \lceil m_i / (\epsilon m_j) \rceil$ prey individuals and adds $+1$ predator individual ($\boldsymbol{\nu}_{ij} = -k_{ij}\mathbf{e}_j + \mathbf{e}_i$) with mass-action encounter propensity:

$$a_{ij}(\mathbf{x}) = \frac{\gamma_{ij}}{\mathcal{V}} m_i^{-0.25} N_i N_j$$

Using the discrete step operator $\mathbb{E}_k^{-m} f(N_k) = f(N_k - m)$, the Chemical Master Equation for the probability distribution $P(\mathbf{x}, t)$ is:

$$\frac{\partial P(\mathbf{x}, t)}{\partial t} = \sum_{i=1}^n \left( \mathbb{E}_i^{-1} - 1 \right)\left[ b_i(\mathbf{x}) P(\mathbf{x}, t) \right] + \sum_{i=1}^n \left( \mathbb{E}_i^{+1} - 1 \right)\left[ d_i(\mathbf{x}) P(\mathbf{x}, t) \right] + \sum_{i > j} \left( \mathbb{E}_i^{-1} \mathbb{E}_j^{+k_{ij}} - 1 \right) \left[ a_{ij}(\mathbf{x}) P(\mathbf{x}, t) \right]$$

Applying van Kampen's (1992) system-size expansion $\mathbf{x} = \mathcal{V} \boldsymbol{\phi}(t) + \sqrt{\mathcal{V}}\,\boldsymbol{\xi}$ and Taylor-expanding the step operators $\mathbb{E}_k^{-\nu} = 1 - \frac{\nu}{\sqrt{\mathcal{V}}}\frac{\partial}{\partial \xi_k} + \frac{\nu^2}{2 \mathcal{V}}\frac{\partial^2}{\partial \xi_k^2} + \mathcal{O}(\mathcal{V}^{-3/2})$ separates the dynamics across perturbative orders. At macroscopic order $\mathcal{O}(\mathcal{V}^0)$, one obtains the deterministic mean-field rate equations $\frac{d\boldsymbol{\phi}}{dt} = \mathbf{B}\mathbf{J}(\boldsymbol{\phi})$, whose linearization around the positive stationary attractor $\mathbf{x}^*$ yields the demographic Jacobian $\mathbf{A} = \mathbf{B}\left.\frac{\partial \mathbf{J}}{\partial \mathbf{x}}\right|_{\mathbf{x}^*}$. At fluctuation order $\mathcal{O}(\mathcal{V}^{-1/2})$, one recovers the linear Fokker-Planck equation for the fluctuation density $P(\boldsymbol{\xi}, t)$ with drift matrix $\mathbf{A}$ and symmetric demographic diffusion matrix $\mathbf{D} = \frac{1}{2}\mathbf{B}\operatorname{Diag}(\mathbf{J}^*)\mathbf{B}^{\mathsf{T}} \succeq 0$. At stationarity, the Gaussian fluctuation density $P_{\mathrm{ss}}(\delta\mathbf{x}) \propto \exp(-\mathcal{V} U(\mathbf{x})) \approx \exp\left(-\frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\delta\mathbf{x}\right)$ is governed by the continuous Lyapunov equation $\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} + 2\mathbf{D} = \mathbf{0}$, and the mean first-passage escape time across a saddle barrier $\Delta U$ scales exponentially via the Kramers-Freidlin-Wentzell law $\tau_{\mathrm{escape}} \asymp \exp(\mathcal{V}\Delta U)$.
 
The Gillespie Direct Stochastic Simulation Algorithm (SSA; Gillespie 1977) generates exact sample paths of this Chemical Master Equation:
- **Initialization:** Set time $t = 0$ and initial integer population count vector $\mathbf{n} = \mathbf{n}_0 \in \mathbb{N}_0^n$.
- **Propensity evaluation:** Evaluate all channel propensities $w_r(\mathbf{n})$ ($r \in \{1, \dots, R\}$) and their sum $w_0(\mathbf{n}) = \sum_{r=1}^R w_r(\mathbf{n})$.
- **Waiting-time sampling:** Draw $u_1 \sim \mathcal{U}(0, 1)$ and advance the waiting time by $\tau = \frac{1}{w_0(\mathbf{n})}\ln(1 / u_1)$.
- **Reaction channel selection:** Draw $u_2 \sim \mathcal{U}(0, 1)$ and select the unique channel index $\mu$ satisfying $\sum_{r=1}^{\mu-1} w_r(\mathbf{n}) < u_2 w_0(\mathbf{n}) \le \sum_{r=1}^{\mu} w_r(\mathbf{n})$.
- **State update:** Set $t \leftarrow t + \tau$ and $\mathbf{n} \leftarrow \mathbf{n} + \boldsymbol{\nu}_\mu$, and repeat until $t \ge t_{\max}$.

From stationary ensemble trajectories, the empirical probability density $\widehat{P}_{\mathrm{ss}}(\mathbf{x})$ is reconstructed via multivariate kernel density estimation, yielding the empirical quasi-potential $\widehat{U}(\mathbf{x}) = -\mathcal{V}^{-1}\ln \widehat{P}_{\mathrm{ss}}(\mathbf{x})$ and the stationary circulation velocity field $\mathbf{v}_{\mathrm{curl}}(\mathbf{x})$ (Fig. \ref{fig_cone_spring_gillespie}).

![Discrete stochastic Chemical Master Equation jump trajectories and quasi-potential landscape for the Cone Spring ecosystem. Continuous-time Gillespie Stochastic Simulation Algorithm (SSA) runs for integer species counts across trophic compartments, illustrating finite-particle demographic fluctuations, stationary probability distribution, and non-equilibrium probability circulation in state space.](media/cone-spring-gillespie-simulation.png){#fig_cone_spring_gillespie width=85%}
 
All analytical operators, numerical estimators, and stochastic simulation models are implemented in the open-source Julia package `OnsagerNetwork` (`src/onsagernetwork.jl`), verified by the unit test suite in `test/runtests.jl` and consolidated driver script `thermodynamics_onsager.jl`:
- `solve_lyapunov_covariance(A, D)` and `decompose_covariance_weighted_drift(A, C)` solve the continuous Lyapunov balance and perform the canonical decomposition $-\mathbf{A}\mathbf{C} = \mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega}$.
- `diffusion_from_innovation(A, Q, dt)` and `estimate_ou_onsager(X_data; dt, scale)` recover continuous-time drift, quadrature-inverted diffusion, Onsager conductivities, and entropy production from discrete-time trajectories without first-order Euler discretization bias.
- `cone_spring_network(; s=0.10)` and `analyze_cone_spring()` construct and decompose the empirical Cone Spring energy budget.
- `npzd_diagnostics(params)`, `npzd_fish_diagnostics(params)`, and `simulate_npzd_fish_harvest(params)` evaluate the pelagic BATS NPZD and exploited NPZD-Fish food webs.
- `compute_size_spectrum_indices(params)`, `simulate_size_spectrum_filtering(params)`, and `simulate_size_spectrum_wave(params)` evaluate allometric size spectra and multi-scale impedance filtering.
- `run_gillespie_population(N_0, params, t_end)` executes exact continuous-time Markov jump simulations.

The complete software repository is available at `https://github.com/mum0n/thermodynamics_onsager`.


\newpage


# Appendix D: Interdisciplinary Connections 

## D.1 Network Thermodynamics and Circuit Theory

The decomposition of asymmetric community matrices into symmetric dissipators and antisymmetric circulators is mathematically isomorphic to multiport electrical circuit theory (Tellegen 1948, 1952, Oster et al. 1971, Mikulecky 1985).

By Tellegen's (1952) theorem, for any network topology obeying Kirchhoff's current and voltage laws, instantaneous power across all branches sums to zero ($\sum_k v_k(t) i_k(t) = 0$). In ecological networks, extensive state deviations $\delta\mathbf{x}$ correspond to generalized capacitor charges, conjugate thermodynamic forces $\mathbf{X} = -\mathbf{H}\delta\mathbf{x} = -k_{\mathrm{B}}\mathbf{C}^{-1}\delta\mathbf{x}$ correspond to generalized node voltages, and compartment standing stocks act as generalized entropic capacitors ($C_i \propto B_i^* / k_{\mathrm{B}}$).

In the constitutive flux-force relation $\mathbf{J} = \mathbf{L}\mathbf{X} = k_{\mathrm{B}}^{-1}(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{X}$, the symmetric part $\mathbf{L}_s = \frac{1}{2}(\mathbf{L} + \mathbf{L}^{\mathsf{T}}) = k_{\mathrm{B}}^{-1}\mathbf{D}_{\mathrm{sym}} \succ 0$ represents a passive resistive conductance network governing irreversible entropy production:

$$\sigma = \mathbf{X}^{\mathsf{T}}\mathbf{L}_s\mathbf{X} = k_{\mathrm{B}}^{-1}\mathbf{X}^{\mathsf{T}}\mathbf{D}_{\mathrm{sym}}\mathbf{X} \ge 0$$

Conversely, the skew-symmetric part $\mathbf{L}_a = \frac{1}{2}(\mathbf{L} - \mathbf{L}^{\mathsf{T}}) = k_{\mathrm{B}}^{-1}\boldsymbol{\Omega}$ represents an array of ideal **Tellegen gyrators** (Tellegen 1948). A two-port gyrator with gyration conductance $g$ couples port currents and voltages via a skew-symmetric admittance matrix:

$$\begin{pmatrix} i_1 \\ i_2 \end{pmatrix} = \begin{pmatrix} 0 & g \\ -g & 0 \end{pmatrix} \begin{pmatrix} v_1 \\ v_2 \end{pmatrix}$$

Because $\mathbf{L}_a = -\mathbf{L}_a^{\mathsf{T}}$ is skew-symmetric, net instantaneous power dissipation across every gyrator is identically zero ($\mathbf{X}^{\mathsf{T}}\mathbf{L}_a\mathbf{X} = 0$). When port 2 of a gyrator is terminated by a storage capacitor $C_2$ ($i_2 = -C_2 \dot{v}_2$), substituting $v_2 = i_1 / g$ yields $v_1 = -(1/g)i_2 = (C_2 / g^2)\dot{i}_1$, so the input port behaves as an equivalent reactive inductor with inductance:

$$L_{\mathrm{eq}} = \frac{C_2}{g^2}$$

This circuit duality explains why ecological networks exhibit endogenous oscillations, trophic waves, and limit cycles despite lacking physical magnetic fields: coupling capacitive biomass storage ($\mathbf{C}$) through skew-symmetric trophic circulation ($\boldsymbol{\Omega}$) synthesizes an equivalent reactive inductance ($L_{\mathrm{eq}}$). Coupled consumer-resource pairs therefore act as damped $RLC$ oscillators that exchange availability between prey and predator compartments while dissipative conductances $\mathbf{D}_{\mathrm{sym}}$ damp the oscillation amplitude.

### Standardized Coordinates and Geometric Interpretation of the Circulation Ratio ($\chi$)

For any real matrix $\mathbf{M} \in \mathbb{R}^{n \times n}$, the Frobenius norm $\|\mathbf{M}\|_F$ is defined by the Euclidean root-sum-of-squares across all matrix entries, or equivalently across all singular values $\sigma_k(\mathbf{M})$:

$$\|\mathbf{M}\|_F = \sqrt{\operatorname{tr}\left(\mathbf{M}^{\mathsf{T}}\mathbf{M}\right)} = \sqrt{\sum_{i=1}^n \sum_{j=1}^n M_{ij}^2} = \sqrt{\sum_{k=1}^n \sigma_k^2(\mathbf{M})}$$

Using the Frobenius norm to define the non-equilibrium circulation ratio $\chi = \|\boldsymbol{\Omega}\|_F / \|\mathbf{D}_{\mathrm{sym}}\|_F$ provides three structural properties across multispecies networks:
- **Orthogonal Pythagorean decomposition:** Under the Frobenius inner product $\langle \mathbf{U}, \mathbf{V}\rangle_F = \operatorname{tr}(\mathbf{U}^{\mathsf{T}}\mathbf{V})$, every symmetric matrix is orthogonal to every skew-symmetric matrix because $\operatorname{tr}(\mathbf{D}_{\mathrm{sym}}^{\mathsf{T}}\boldsymbol{\Omega}) = \operatorname{tr}(\mathbf{D}_{\mathrm{sym}}\boldsymbol{\Omega}) = -\operatorname{tr}(\boldsymbol{\Omega}\mathbf{D}_{\mathrm{sym}}) = 0$. Consequently, the squared Frobenius norm of the covariance-weighted drift operator $-\mathbf{A}\mathbf{C} = \mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega}$ satisfies the exact Pythagorean identity:
  $$\|-\mathbf{A}\mathbf{C}\|_F^2 = \|\mathbf{D}_{\mathrm{sym}}\|_F^2 + \|\boldsymbol{\Omega}\|_F^2 = \|\mathbf{D}_{\mathrm{sym}}\|_F^2\left(1 + \chi^2\right)$$
  Geometrically, $\chi = \tan\theta$ represents the tangent of the angle $\theta$ by which the ecological drift operator departs from the symmetric Onsager reciprocal subspace.
- **Whole-network flux aggregation:** Unlike spectral norms that depend only on a single extremal mode, $\|\boldsymbol{\Omega}\|_F = \sqrt{2\sum_{i < j} \Omega_{ij}^2}$ aggregates the root-mean-square cyclic flux across all coupled trophic pairs $(i, j)$, while $\|\mathbf{D}_{\mathrm{sym}}\|_F = \sqrt{\sum_i D_{\mathrm{sym},ii}^2 + 2\sum_{i < j} D_{\mathrm{sym},ij}^2}$ aggregates all intraspecific self-damping and reciprocal cross-damping pathways.
- **Riemannian coordinate-invariant representation ($\tilde{\chi}$):** Transforming state departures into standardized whitened coordinates via the symmetric square-root capacitance matrix:

$$\delta\tilde{\mathbf{x}} = \mathbf{C}^{-1/2}\delta\mathbf{x}$$

reduces the stationary fluctuation covariance to the identity matrix ($\widetilde{\mathbf{C}} = \mathbf{I}$) and the continuous Lyapunov equation to $\widetilde{\mathbf{A}} + \widetilde{\mathbf{A}}^{\mathsf{T}} = -2\widetilde{\mathbf{D}}$. The standardized drift operator $\widetilde{\mathbf{A}} = \mathbf{C}^{-1/2}\mathbf{A}\mathbf{C}^{1/2}$ then decomposes orthogonally into a symmetric downhill dissipative sink and a skew-symmetric rotation:

$$\widetilde{\mathbf{A}} = -\widetilde{\mathbf{D}} - \widetilde{\boldsymbol{\Omega}}$$

where $\widetilde{\mathbf{D}} = \mathbf{C}^{-1/2}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1/2} \succ 0$ contracts trajectories radially toward the origin and $\widetilde{\boldsymbol{\Omega}} = \mathbf{C}^{-1/2}\boldsymbol{\Omega}\mathbf{C}^{-1/2} = -\widetilde{\boldsymbol{\Omega}}^{\mathsf{T}}$ rotates trajectories tangentially along spherical iso-entropy surfaces. In these standardized Riemannian coordinates, the Frobenius ratio yields the coordinate-invariant circulation ratio $\tilde{\chi}$ derived in Appendix A.2:

$$\tilde{\chi} = \frac{\|\widetilde{\boldsymbol{\Omega}}\|_F}{\|\widetilde{\mathbf{D}}\|_F} = \left[\frac{\operatorname{tr}\left(\boldsymbol{\Omega}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}\right)}{\operatorname{tr}\left(\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}\right)}\right]^{1/2}$$

which directly compares the root-mean-square phase-space angular rotation frequency to the root-mean-square radial contraction rate.

### The Canonical Two-Species Prototype and Regime Classification by $\chi$

Consider a canonical two-species predator-prey community matrix:

$$\mathbf{A} = \begin{pmatrix} -d_1 & -a_{12} \\ a_{21} & -d_2 \end{pmatrix}$$

where $a_{12} > 0$ is per-capita predation on prey, $a_{21} > 0$ is assimilated predator growth per unit prey, and $d_1, d_2 > 0$ are intraspecific self-damping rates. With diagonal capacitance $\mathbf{C} = \operatorname{diag}(B_1, B_2)$, the covariance-weighted drift $-\mathbf{A}\mathbf{C}$ is:

$$-\mathbf{A}\mathbf{C} = \begin{pmatrix} d_1 B_1 & a_{12} B_2 \\ -a_{21} B_1 & d_2 B_2 \end{pmatrix} = \mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega}$$

where the symmetric dissipative and skew-symmetric circulatory components are:

$$\mathbf{D}_{\mathrm{sym}} = \begin{pmatrix} d_1 B_1 & \frac{1}{2}(a_{12} B_2 - a_{21} B_1) \\ \frac{1}{2}(a_{12} B_2 - a_{21} B_1) & d_2 B_2 \end{pmatrix}, \qquad \boldsymbol{\Omega} = \begin{pmatrix} 0 & \omega \\ -\omega & 0 \end{pmatrix}$$

with trophic circulation flux $\omega = \frac{1}{2}(a_{12} B_2 + a_{21} B_1)$. When steady-state trophic flux is balanced across the link ($a_{12} B_2 = a_{21} B_1 = \omega$), $\mathbf{D}_{\mathrm{sym}} = \operatorname{diag}(d_1 B_1, d_2 B_2)$ is purely diagonal. Evaluating the Frobenius norms of $\boldsymbol{\Omega}$ and $\mathbf{D}_{\mathrm{sym}}$ explicitly yields:

$$\|\boldsymbol{\Omega}\|_F = \sqrt{0^2 + \omega^2 + (-\omega)^2 + 0^2} = \sqrt{2}\,\omega, \qquad \|\mathbf{D}_{\mathrm{sym}}\|_F = \sqrt{(d_1 B_1)^2 + (d_2 B_2)^2}$$

so that the non-equilibrium circulation ratio reduces to:

$$\chi = \frac{\sqrt{2}\,\omega}{\sqrt{(d_1 B_1)^2 + (d_2 B_2)^2}}$$

In this two-species loop, $\omega$ is the steady-state trophic flux cycling between resource and consumer, while $d_1 B_1$ and $d_2 B_2$ are the intraspecific dissipative self-damping fluxes of each compartment. The ratio $\chi$ is therefore the ecological counterpart to the quality factor ($Q$-factor) of a damped $RLC$ oscillator or a Péclet number comparing rotational advection to diffusive damping. Simultaneously, evaluating the exact Fokker-Planck trace formula $\sigma = -k_{\mathrm{B}}\operatorname{tr}(\boldsymbol{\Omega}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{D}_{\mathrm{sym}}^{-1})$ from Appendix A.5 yields:

$$\sigma = k_{\mathrm{B}}\frac{\omega^2}{B_1 B_2}\left(\frac{1}{d_1} + \frac{1}{d_2}\right) = k_{\mathrm{B}} \frac{\omega^2}{D_{\mathrm{eff}}}, \qquad D_{\mathrm{eff}} = \frac{d_1 d_2}{d_1 + d_2} B_1 B_2$$

Thus, stationary entropy production in the two-species trophic loop equals the squared circulation flux $\omega^2$ divided by the effective dissipative capacity $D_{\mathrm{eff}}$ (the product of the harmonic-mean damping rate and the geometric capacitance product $B_1 B_2$).

Across empirical and model ecosystems (Table \ref{tbl:aquatic_comparison}), $\chi$ classifies communities into four characteristic dynamical regimes:
- **Detailed balance and pure gradient flow ($\chi = 0$):** Probability circulation vanishes ($\boldsymbol{\Omega} = \mathbf{0}$), stationary housekeeping entropy production is zero ($\sigma = 0$), and perturbations relax monotonically down the potential gradient without phase-space rotation (as in isolated thermal equilibrium or symmetric resource competition; MacArthur 1970).
- **Overdamped, capacitance-buffered regime ($\chi < 1$):** Symmetric dissipative damping and standing biomass storage exceed cyclic rotational flux ($\|\boldsymbol{\Omega}\|_F < \|\mathbf{D}_{\mathrm{sym}}\|_F$). Perturbations return smoothly to the stationary attractor with heavily damped, long-period oscillations. In the **Cone Spring** benthic ecosystem, the large detrital capacitor ($B_2^* = 358.3\ \mathrm{g\,C\,m^{-2}}$) buffers trophic transfers, maintaining $\chi = 0.85$ across the five-guild network ($\chi = 0.245$ in the three-guild heterotrophic sub-chain) and low entropy production ($\sigma = 90.35\ \mathrm{yr}^{-1}$).
- **Moderately underdamped, active recycling regime ($\chi \sim 1\text{ to }1.5$):** Rotational trophic fluxes slightly exceed direct self-damping ($\|\boldsymbol{\Omega}\|_F \gtrsim \|\mathbf{D}_{\mathrm{sym}}\|_F$), generating pronounced inward phase-space spirals and rapid nutrient-plankton cycling. In the **BATS open-ocean mixed layer (NPZD)**, fast microbial and grazing turnover with minimal standing storage yields $\chi = 1.42$ and moderate dissipation ($\sigma = 257.65\ \mathrm{yr}^{-1}$).
- **Unbuffered circulation and pre-Hopf oscillatory volatility ($\chi \gg 1$):** When selective harvesting or eutrophication strips slow macroscopic biomass capacitors ($C_{ii} \to 0$) while strong trophic throughput sustains $\boldsymbol{\Omega}$, dissipative buffering collapses relative to rotational flux ($\|\boldsymbol{\Omega}\|_F \gg \|\mathbf{D}_{\mathrm{sym}}\|_F$). In the **exploited marine fishery (NPZD-Fish)**, removing predatory fish causes $\chi$ to surge to $2.68$ and $\sigma$ to climb to $425.03\ \mathrm{yr}^{-1}$, producing wide rotational phase-space orbits that signal an approaching Hopf bifurcation.


## D.2 Information Geometry and Helmholtz-Hodge Decomposition

Following Riemannian information geometry (Amari 1985, 2016), on the state space manifold $\mathcal{M} = \mathbb{R}_{> 0}^K$, the continuous Lyapunov covariance matrix defines a Riemannian Fisher information metric:

$$g_{ij}(\mathbf{x}) = [\mathbf{C}^{-1}]_{ij} = \frac{\partial^2 U(\mathbf{x})}{\partial x_i \partial x_j}$$

Under this metric, any smooth dynamical vector field $\mathbf{f}(\mathbf{x})$ decomposes uniquely into orthogonal potential and solenoidal (curl) components (Helmholtz-Hodge theorem; Helmholtz 1858, Hodge 1941, Amari 1985):

$$\mathbf{f}(\mathbf{x}) = -\mathbf{D}(\mathbf{x})\nabla U(\mathbf{x}) + \mathbf{v}_{\mathrm{curl}}(\mathbf{x}), \qquad \nabla U(\mathbf{x}) \cdot \mathbf{v}_{\mathrm{curl}}(\mathbf{x}) = 0$$

MacArthur's (1970) variational principle succeeded for pure competition precisely because symmetric resource competition generates an exact potential gradient system where $\mathbf{v}_{\mathrm{curl}} \equiv \mathbf{0}$. In contrast, trophic interactions introduce directional non-equilibrium circulation, $\mathbf{v}_{\mathrm{curl}} \ne \mathbf{0}$, which drives perpetual probability currents along closed loops.

## D.3 Cybernetic Feedback Control and the Conservation of Sensitivity (Bode Integral)

The Resistance-Resilience trade-off continuum ($B_{\mathrm{tot}} \times \mathcal{R} \approx \text{const}$) can be derived from the fundamental laws of feedback control theory (Bode 1945).

In control engineering, the sensitivity function $S(i\omega) = [1 + L_{\mathrm{loop}}(i\omega)]^{-1}$ measures disturbance attenuation across frequency $\omega$. Bode's (1945) Sensitivity Integral theorem dictates that for any open-loop stable feedback system:

$$\int_0^{\infty} \ln |S(i\omega)|\,d\omega = 0$$

This conservation law, known as the waterbed effect, proves that sensitivity cannot be reduced universally across all frequencies:

$$\int_0^{\omega_{\mathrm{c}}} |\ln |S(i\omega)||\,d\omega = \int_{\omega_{\mathrm{c}}}^{\infty} \ln |S(i\omega)|\,d\omega$$

In ecological networks, Resistance ($B_{\mathrm{tot}}$) manifests through massive biomass pools acting as low-pass filters that suppress low-frequency environmental variance ($|S(i\omega)| \to 0$ as $\omega \to 0$). Conversely, Resilience ($\mathcal{R}$) is governed by the asymptotic return rate $\mathcal{R} = |\operatorname{Re}(\lambda_{\max})|$, dictating how rapidly high-frequency perturbations decay.

Because the total integral of $\ln |S(i\omega)|$ is strictly conserved by network topology, an ecosystem cannot simultaneously maximize low-frequency disturbance rejection ($B_{\mathrm{tot}} \to \infty$) and broadband transient recovery ($\mathcal{R} \to \infty$). The hyperbolic trade-off $B_{\mathrm{tot}} \times \mathcal{R} \approx \text{const}$ is the ecological manifestation of the Bode sensitivity integral.

## D.4 Stochastic Thermodynamics and the Thermodynamic Uncertainty Relation

The connection between dissipation and ecological precision is formalized by stochastic thermodynamics through the Thermodynamic Uncertainty Relation (TUR) (Barato and Seifert 2015, Gingrich et al. 2016).

Let $J$ denote an empirical steady-state net current integrated over time interval $\tau$, and let $\operatorname{Var}(J)$ denote its fluctuation variance. The TUR proves that the precision of any non-equilibrium current is bounded from below by the total entropy production rate $\sigma$:

$$\frac{\operatorname{Var}(J)}{\langle J \rangle^2} \ge \frac{2 k_{\mathrm{B}}}{\sigma \tau}$$

This inequality has fundamental ecological implications. Achieving high ecological fidelity, characterized by low relative variance $\operatorname{Var}(J)/\langle J \rangle^2$ in nutrient and biomass currents, requires substantial thermodynamic entropy production $\sigma$. An ecosystem cannot achieve both noiseless metabolic throughput ($\operatorname{Var}(J) \to 0$) and near-zero dissipation ($\sigma \to 0$), establishing the thermodynamic impossibility of frictionless stability. Consequently, natural selection for reliable, homeostatic physiological and ecological rates operates under an inescapable physical constraint: reducing current fluctuations incurs an unavoidable metabolic entropy cost.



# References

Aitchison, J. (1986). *The Statistical Analysis of Compositional Data*. Chapman and Hall, London.

Amari, S. (1985). *Differential-Geometrical Methods in Statistics*. Lecture Notes in Statistics, Vol. 28. Springer-Verlag, New York.

Amari, S. (2016). *Information Geometry and Its Applications*. Applied Mathematical Sciences, Vol. 194. Springer, Tokyo.

Ao, P. (2004). Potential in stochastic differential equations: novel construction. *Journal of Physics A: Mathematical and General*, 37(3), pp.L25-L30.

Andersen, K. H. (2019). *Fish Ecology, Evolution, and Exploitation: A New Theoretical Synthesis*. Princeton University Press, Princeton.

Babloyantz, A. (1986). *Molecules, Dynamics and Life: An Introduction to Self-Organization of Matter*. Wiley-Interscience, Toronto.

Barato, A. C. and Seifert, U. (2015). Thermodynamic uncertainty relation for biomolecular processes. *Physical Review Letters*, 114(15), p.158101.

Bode, H. W. (1945). *Network Analysis and Feedback Amplifier Design*. D. Van Nostrand Company, New York.

Boltzmann, L. (1877). Über die Beziehung zwischen dem zweiten Hauptsatze der mechanischen Wärmetheorie und der Wahrscheinlichkeitsrechnung respektive den Sätzen über das Wärmegleichgewicht. *Wiener Berichte*, 76, pp.373-435.

Boudreau, P. R. and Dickie, L. M. (1992). Biomass spectra of aquatic ecosystems in relation to fisheries yield. *Canadian Journal of Fisheries and Aquatic Sciences*, 49(8), pp. 1528-1538.

Boyd, S. and Vandenberghe, L. (2004). *Convex Optimization*. Cambridge University Press, Cambridge.

Brown, J. H., Gillooly, J. F., Allen, A. P., Savage, V. M. and West, G. B. (2004). Toward a metabolic theory of ecology. *Ecology*, 85(7), pp. 1771-1789.

Braun, F. (1887). Ueber die Gültigkeit des Le Chatelier-Braunschen Princips. *Annalen der Physik und Chemie*, 269(2), pp. 337-353.

Byers, R. E. and Hansell, R. I. C. (1996). Implications of semi-stable attractors for ecological modelling. *Ecological Modelling*, 89, pp. 59-65.

Callen, H. B. (1985). *Thermodynamics and an Introduction to Thermostatistics*. 2nd ed. John Wiley & Sons, New York.

Casimir, H. B. G. (1945). On Onsager's principle of microscopic reversibility. *Reviews of Modern Physics*, 17(2-3), pp.343-350.

Chakrabarti, C. G. and Ghosh, K. (2009). Non-equilibrium thermodynamics of ecosystems: Entropic analysis of stability and diversity. *Ecological Modelling*, 220(16), pp.1950-1956.

Choi, J. S. (2002). *Dealing with uncertainty in a complicated thermodynamic world*. Doctoral dissertation, Université de Montréal, Montréal.

Choi, J. S. (2023). Reconstructing the decline of Atlantic cod with the help of environmental variability in the Scotian Shelf of Canada. *bioRxiv preprint*, https://doi.org/10.1101/2022.05.05.490753.

Choi, J. S. and Hansell, R. I. C. (2026). Reconciling Ecological Population Dynamics with Non-Equilibrium Thermodynamics: I. Onsager Reciprocity, Biomass Capacitance, and Conjugate Stability. *bioRxiv preprint*.

Choi, J. S. and Patten, B. C. (2001). Sustainable development: lessons from the paradox of enrichment. *Ecosystem Health*, 7, pp. 163-178.

Choi, J. S., Frank, K. T., Leggett, W. C. and Drinkwater, K. (2004). Transition to an alternate state in a continental shelf ecosystem. *Canadian Journal of Fisheries and Aquatic Sciences*, 61(4), pp. 505-510.

Choi, J. S., Mazumder, A. and Hansell, R. I. C. (1999). Measuring perturbation in a complicated, thermodynamic world. *Ecological Modelling*, 117, pp. 143-158.

de Groot, S. R. and Mazur, P. (1962). *Non-Equilibrium Thermodynamics*. North-Holland Publishing Company, Amsterdam.

de Ruiter, P. C., Neutel, A. M. and Moore, J. C. (1995). Energetics, patterns of interaction strengths, and stability in real ecosystems. *Science*, 269(5228), pp.1257-1260.

Dewar, R. C. (2003). Information theory explanation of the fluctuation theorem, maximum entropy production and self-organized criticality in non-equilibrium stationary states. *Journal of Physics A: Mathematical and General*, 36(3), pp. 631-641.

Eigen, M. and Schuster, P. (1979). *The Hypercycle: A Principle of Natural Self-Organization*. Springer-Verlag, Berlin.

Einstein, A. (1910). Theorie der Opaleszenz von homogenen Flussigkeiten und Flussigkeitsgemischen in der Nahe des kritischen Zustandes. *Annalen der Physik*, 338(16), pp. 1275-1298.

Estes, J. A., Tinker, M. T., Williams, T. M. and Doak, D. F. (1998). Killer whale predation on sea otters linking oceanic and nearshore ecosystems. *Science*, 282(5388), pp.473-476.

Eyink, G. L. (1990). Dissipation and large fluctuations in nonequilibrium thermodynamics. *Journal of Statistical Physics*, 61(3-4), pp. 533-572.

Fasham, M. J. R., Ducklow, H. W. and McKelvie, S. M. (1990). A nitrogen-based model of plankton dynamics in the oceanic mixed layer. *Journal of Marine Research*, 48(3), pp.591-639.

Frank, K. T., Petrie, B., Choi, J. S. and Leggett, W. C. (2005). Trophic cascades in a formerly cod-dominated ecosystem. *Science*, 308(5728), pp. 1621-1623.

Freidlin, M. I. and Wentzell, A. D. (1984). *Random Perturbations of Dynamical Systems*. Springer-Verlag, New York.

Freudenberg, J. S. and Looze, D. P. (1985). Right half plane poles and zeros and design limitations in feedback systems. *IEEE Transactions on Automatic Control*, 30(6), pp. 555-565.

Gillespie, D. T. (1977). Exact stochastic simulation of coupled chemical reactions. *The Journal of Physical Chemistry*, 81(25), pp.2340-2361.

Gillespie, D. T. (1992). A rigorous derivation of the chemical master equation. *Physica A: Statistical Mechanics and its Applications*, 188(1-3), pp.404-425.

Gingrich, T. R., Horowitz, J. M., Perunov, N. and England, J. L. (2016). Dissipation bounds all steady-state current fluctuations. *Physical Review Letters*, 116(12), p.120601.

Glansdorff, P. and Prigogine, I. (1971). *Thermodynamic Theory of Structure, Stability and Fluctuations*. Wiley-Interscience, London.

Graham, R. (1977). Covariant formulation of non-equilibrium statistical thermodynamics. *Zeitschrift für Physik B Condensed Matter*, 26(4), pp. 397-405.

Grebogi, C., Ott, E. and Yorke, J. A. (1983). Crises, sudden changes in chaotic attractors, and transient chaos. *Physica D: Nonlinear Phenomena*, 7(1-3), pp.181-200.

Gunderson, L. H. (2000). Ecological resilience, in theory and application. *Annual Review of Ecology and Systematics*, 31, pp. 425-439.

Haken, H. (1983). *Synergetics: An Introduction. Nonequilibrium Phase Transitions and Self-Organization in Physics, Chemistry, and Biology*. Springer-Verlag, Berlin.

Hastings, A. and Powell, T. (1991). Chaos in a three-species food chain. *Ecology*, 72(3), pp.896-903.

Helmholtz, H. von. (1858). Uber Integrale der hydrodynamischen Gleichungen, welche den Wirbelbewegungen entsprechen. *Journal fur die reine und angewandte Mathematik*, 55, pp. 25-55.

Hodge, W. V. D. (1941). *The Theory and Applications of Harmonic Integrals*. Cambridge University Press, Cambridge.

Holling, C. S. (1973). Resilience and stability of ecological systems. *Annual Review of Ecology and Systematics*, 4, pp. 1-23.

Holling, C. S. (1996). Engineering resilience versus ecological resilience. In: Schulze, P. C. (ed.), *Engineering Within Ecological Constraints*. National Academy Press, Washington, DC, pp. 31-44.

Horn, R. A. and Johnson, C. R. (2012). *Matrix Analysis*. 2nd ed. Cambridge University Press, Cambridge.

Itô, K. (1951). On stochastic differential equations. *Memoirs of the American Mathematical Society*, 4, pp. 1-51.

Kerr, S. R. (1974). Theory of size distribution in ecological communities. *Journal of the Fisheries Research Board of Canada*, 31(12), pp. 1859-1862.

Kerr, S. R. and Dickie, L. M. (2001). *The Biomass Spectrum: A Predator-Prey Theory of Aquatic Production*. Columbia University Press, New York.

Kleiber, M. (1932). Body size and metabolism. *Hilgardia*, 6(11), pp. 315-353.

Kleiber, M. (1947). Body size and metabolic rate. *Physiological Reviews*, 27(4), pp.511-541.

Kolmogorov, A. N. (1941). The local structure of turbulence in incompressible viscous fluid for very large Reynolds numbers. *Doklady Akademii Nauk SSSR*, 30, pp. 301-305.

Kuznetsov, Y. A. (1998). *Elements of Applied Bifurcation Theory*. 2nd ed. Springer-Verlag, New York.

Landi, G. T. and Paternostro, M. (2021). Irreversible entropy production, from quantum to classical. *Reviews of Modern Physics*, 93(3), p.035008.

Lax, M. (1960). Fluctuations from the nonequilibrium steady state. *Reviews of Modern Physics*, 32(1), pp. 25-64.

Le Chatelier, H. (1884). Sur un \'enonc\'e g\'en\'eral des lois des \'equilibres chimiques. *Comptes Rendus Hebdomadaires des S\'eances de l'Acad\'emie des Sciences*, 99, pp. 786-789.

Lindeman, R. L. (1942). The trophic-dynamic aspect of ecology. *Ecology*, 23(4), pp.399-417.

Lotka, A. J. (1925). *Elements of Physical Biology*. Williams & Wilkins, Baltimore.

Lyapunov, A. M. (1892). *The General Problem of the Motion's Stability*. Kharkov Mathematical Society, Kharkov. (English translation: *International Journal of Control*, 1992, 55(3), pp. 531-773).

MacArthur, R. (1970). Species packing and competitive equilibrium for many species. *Theoretical Population Biology*, 1(1), pp.1-11.

Martyushev, L. M. and Seleznev, V. D. (2006). Maximum entropy production principle in physics, chemistry and biology. *Physics Reports*, 426(1), pp. 1-45.

May, R. M. (1972). Will a large complex system be stable? *Nature*, 238(5364), pp.413-414.

May, R. M. (1973). *Stability and Complexity in Model Ecosystems*. Princeton University Press, Princeton.

May, R. M. (1974). Biological populations with nonoverlapping generations: stable points, stable cycles, and chaos. *Science*, 186(4164), pp.645-647.

May, R. M. (1977). Thresholds and breakpoints in ecosystems with a multiplicity of stable states. *Nature*, 269(5628), pp. 471-477.

McCann, K. and Yodzis, P. (1994). Nonlinear dynamics and amoebic persistence. *The American Naturalist*, 144(6), pp.873-879.

Meysman, F. J. R. and Bruers, S. (2010). Ecosystem functioning and maximum entropy production: a quantitative test of hypotheses. *Philosophical Transactions of the Royal Society B: Biological Sciences*, 365(1545), pp.1405-1416.

Michaelian, K. (2005). Thermodynamic stability of ecosystems. *Journal of Theoretical Biology*, 237(3), pp.323-335.

Mikulecky, D. C. (1985). Network thermodynamics in biology and medicine. *American Journal of Physiology*, 249(3), pp.R317-R330.

Nicolis, G. and Prigogine, I. (1977). *Self-Organization in Nonequilibrium Systems: From Dissipative Structures to Order through Fluctuations*. John Wiley & Sons, New York.

Onsager, L. (1931a). Reciprocal relations in irreversible processes. I. *Physical Review*, 37(4), pp.405-426.

Onsager, L. (1931b). Reciprocal relations in irreversible processes. II. *Physical Review*, 38(12), pp.2265-2279.

Onsager, L. and Machlup, S. (1953). Fluctuations and irreversible processes. *Physical Review*, 91(6), pp. 1505-1512.

Oster, G. F., Perelson, A. S. and Katchalsky, A. (1971). Network thermodynamics. *Nature*, 234(5329), pp.393-399.

Patten, B. C. (1978). Systems approach to the concept of environment. *The Ohio Journal of Science*, 78(4), pp.206-222.

Pimm, S. L. (1984). The complexity and stability of ecosystems. *Nature*, 307(5949), pp. 321-326.

Platt, T. and Denman, K. (1977). Organisation in the pelagic ecosystem. *Helgoländer wissenschaftliche Meeresuntersuchungen*, 30(1-4), pp. 575-581.

Platt, T. and Denman, K. (1978). The structure of pelagic ecosystems. *Rapports et Procès-Verbaux des Réunions du Conseil International pour l'Exploration de la Mer*, 173, pp. 60-65.

Prigogine, I. (1947). *Étude Thermodynamique des Phénomènes Irréversibles*. Desoer, Liège.

Prigogine, I. (1955). *Introduction to Thermodynamics of Irreversible Processes*. Charles C Thomas, Springfield.

Prigogine, I. (1967). *Introduction to Thermodynamics of Irreversible Processes*. 3rd ed. Interscience Publishers, New York.

Prigogine, I. and Defay, R. (1954). *Chemical Thermodynamics*. Longmans Green and Co., London.

Prigogine, I., Nicolis, G. and Babloyantz, A. (1972). Thermodynamics of evolution. *Physics Today*, 25(11), pp.23-28.

Qian, H. (2001). Mesoscopic biochemical basis of entropy production and the detailed balance. *Physical Review E*, 65(1), p.012101.

Qian, H. (2006). Open-system nonequilibrium steady state: statistical thermodynamics, fluctuations, and chemical oscillations. *The Journal of Physical Chemistry B*, 110(31), pp. 15063-15074.

Reis, A. H. (2014). Use and validity of principles of extremum of entropy production in the study of complex systems. *Annals of Physics*, 346, pp. 22-27.

Rodriguez, J. and Mullin, M. M. (1986). Relation between biomass and body weight of plankton in a steady state oceanic ecosystem. *Limnology and Oceanography*, 31(2), pp. 361-370.

Scheffer, M., Carpenter, S., Foley, J. A., Folke, C. and Walker, B. (2001). Catastrophic shifts in ecosystems. *Nature*, 413(6856), pp.591-596.

Scheffer, M. (2009). *Critical Transitions in Nature and Society*. Princeton University Press, Princeton.

Scheffer, M., Bascompte, J., Brock, W. A., Brovkin, V., Carpenter, S. R., Dakos, V., Held, H., van Nes, E. H., Rietkerk, M. and Sugihara, G. (2009). Early-warning signals for critical transitions. *Nature*, 461(7260), pp. 53-59.

Schnakenberg, J. (1976). Network theory of microscopic and macroscopic behavior of master equation systems. *Reviews of Modern Physics*, 48(4), pp. 571-585.

Schur, J. (1917). Über Potenzreihen, die im Innern des Einheitskreises beschränkt sind. *Journal für die reine und angewandte Mathematik*, 147, pp. 205-232.

Schrödinger, E. (1944). *What is Life? The Physical Aspect of the Living Cell*. Cambridge University Press, Cambridge.

Seifert, U. (2012). Stochastic thermodynamics, fluctuation theorems and molecular machines. *Reports on Progress in Physics*, 75(12), p.126001.

Sheldon, R. W., Prakash, A. and Sutcliffe, W. H. (1972). The size distribution of particles in the ocean. *Limnology and Oceanography*, 17(3), pp.327-340.

Shiner, J. S. and Sieniutycz, S. (1994). The chemical dynamics of biological systems: variational and extremal formulations. *Progress in Biophysics and Molecular Biology*, 62, pp. 203-221.

Spitz, Y. H., Moisan, J. R. and Abbott, M. R. (2001). Configuring an ecosystem model using data from the Bermuda Atlantic Time-series Study (BATS). *Deep Sea Research Part II: Topical Studies in Oceanography*, 48(8-9), pp. 1733-1768.

Steinberg, D. K., Carlson, C. A., Bates, N. R., Johnson, R. J., Michaels, A. F. and Knap, A. H. (2001). Overview of the US JGOFS Bermuda Atlantic Time-series Study (BATS): a decade-scale look at ocean biology and biogeochemistry. *Deep Sea Research Part II: Topical Studies in Oceanography*, 48(8-9), pp. 1405-1447.

Strogatz, S. H. (2018). *Nonlinear Dynamics and Chaos: With Applications to Physics, Biology, Chemistry, and Engineering*. 2nd ed. CRC Press, Boca Raton.

Tellegen, B. D. H. (1948). The gyrator, a new electric network element. *Philips Research Reports*, 3(2), pp. 81-101.

Tellegen, B. D. H. (1952). A general network theorem, with applications. *Philips Research Reports*, 7, pp. 259-269.

Tilly, L. J. (1968). The structure and dynamics of Cone Spring. *Ecological Monographs*, 38(2), pp.169-197.

Tomé, T. (2006). Entropy production in nonequilibrium steady states: A Fokker-Planck study. *Brazilian Journal of Physics*, 36(4A), pp. 1285-1289.

Tomita, K. and Tomita, H. (1974). Irreversible circulation of fluctuation. *Progress of Theoretical Physics*, 51(6), pp. 1731-1749.

Ulanowicz, R. E. (1986). *Growth and Development: Ecosystems Phenomenology*. Springer-Verlag, New York.

Ulanowicz, R. E. and Hannon, B. M. (1987). Life and the production of entropy. *Proceedings of the Royal Society of London Series B*, 232, pp. 181-192.

van Kampen, N. G. (1992). *Stochastic Processes in Physics and Chemistry*. North-Holland, Amsterdam.

Volterra, V. (1926). Variazioni e fluttuazioni del numero d'individui in specie animali conviventi. *Memorie della Reale Accademia Nazionale dei Lincei*, 2, pp.31-113.

Wang, J., Xu, L. and Wang, E. (2008). Potential landscape and flux framework of nonequilibrium networks: robustness, dissipation, and coherence of biochemical oscillations. *Proceedings of the National Academy of Sciences*, 105(34), pp. 12271-12276.

Webster, J. R., Waide, J. B. and Patten, B. C. (1975). Nutrient cycling and the stability of ecosystems. In: Howell, F. G., Gentry, J. B. and Smith, M. H. (eds.), *Mineral Cycling in Southeastern Ecosystems*. ERDA Symposium Series, Washington, DC, pp. 1-27.

West, G. B., Brown, J. H. and Enquist, B. J. (1997). A general model for the origin of allometric scaling laws in biology. *Science*, 276(5309), pp. 122-126.

Wiesenfeld, K. and Moss, F. (1995). Stochastic resonance and the benefits of noise: from ice ages to crayfish and SQUIDs. *Nature*, 373(6509), pp. 33-36.

Willems, J. C. (1972). Dissipative dynamical systems part I: General theory. *Archive for Rational Mechanics and Analysis*, 45(5), pp. 321-351.

Yodzis, P. (1981). The stability of real ecosystems. *Nature*, 289(5799), pp.674-676.

Yodzis, P. (1988). The indeterminacy of ecological interactions as perceived through perturbation experiments. *Ecology*, 69(2), pp. 508-515. https://doi.org/10.2307/1940449

Zhang, X.-J., Qian, H. and Qian, M. (2012). Stochastic theory of nonequilibrium steady states and its applications: A network perspective. *Physics Reports*, 518(1-2), pp. 1-70.

Ziegler, H. (1983). *An Introduction to Thermomechanics*. 2nd ed. North-Holland Publishing Company, Amsterdam.

Zheng, Y., Pasquero, C. and Schartau, M. (2024). Multi-decadal biogeochemical dynamics and planktonic turnover at the Bermuda Atlantic Time-series Study site. *Global Biogeochemical Cycles*, 38(2), e2023GB007890.

Zhou, J. X., Aliyu, M. D. S., Aurell, E. and Huang, S. (2012). Quasi-potential landscape in complex multi-stable systems. *Journal of the Royal Society Interface*, 9(77), pp. 3539-3553.

