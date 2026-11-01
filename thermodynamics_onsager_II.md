---
title: "Reconciling Ecological Population Dynamics with Non-Equilibrium Thermodynamics: II. Empirical Validation, Allometric Cascades, and Non-Linear Regime Shifts"
header: "Choi 2026: Onsager Thermodynamics and Ecological Cascades"
date: \today
journal: 'biorxiv'
author:
- name: Jae S. Choi
  email: choi.jae.seok@gmail.com
  orcid: 0000-0003-3632-5723
affiliation:
  name: Bedford Institute of Oceanography, Fisheries and Oceans Canada
keyword: |
  Keywords - Onsager Reciprocal Relations, Community Matrix, Phenomenological Conductivity, Fluctuation-Dissipation, Probability Circulation, Detailed Balance, Biomass Capacitance, Resistance, Resilience, Energy Dissipation Cascade, Canopy Impedance Filtering, Size Spectrum, Quasi-Potential Landscape, Early Warning Signals
abstract: |
  Theoretical ecology describes living communities through demographic interaction matrices that are fundamentally asymmetric due to directional trophic predation and body size disparities. In a foundational companion paper (Choi 2026a), this historical schism with physical thermodynamics was resolved by demonstrating that the demographic community matrix conflates underlying physical transport conductivities with heterogeneous biomass storage capacities. Through continuous Lyapunov covariance factorization, the demographic matrix resolves into a symmetric Onsager dissipative conductivity that drives monotonic downhill thermodynamic relaxation, and an antisymmetric probability circulation tensor that quantifies non-equilibrium cyclic flows in state space. Here, the focus shifts to empirical validation across contrasting ecological biomes, the extension of the thermodynamic framework to allometric size spectra, and the elaboration of a multi-scale energy cascade analogous to fluid turbulence. The empirical framework is tested on two canonical aquatic regimes: the detritus-buffered benthic cold-spring food web (Cone Spring) and the solar-driven open-ocean plankton ecosystem at the Bermuda Atlantic Time-series Study (BATS) site in the Sargasso Sea. In Cone Spring, massive detrital biomass capacitance provides high entropic Resistance (shock absorption) and slow turnover (period of approximately 296 days), operating at low entropy production rate density (90.35 per year). In contrast, the upper mixed layer at the BATS site prioritizes kinetic Resilience (recovery turnover, period of approximately 40 days) over standing storage, operating at nearly triple the entropy production rate density (257.65 per year). Simulating industrial exploitation in an extended pelagic fishery (NPZD-Fish) demonstrates that harvesting top predatory biomass strips the slow storage capacitor, triggering a surge in probability circulation volatility and driving entropy production to 425.03 per year, which destabilizes the non-equilibrium attractor. Extending this framework to continuous allometric size spectra via the Sheldon distribution and Kleiber scaling, an intuitive physical model of a flexible canopy coupled to a Kolmogorov turbulence cascade is developed. Macroscopic organisms act as structural capacitors that absorb bulk environmental momentum; non-linear cross-scale interactions circulate energy through an inertial subrange via probability circulation; and microscopic organisms act as viscous heat sinks that dissipate energy through metabolic respiration without structural fracture. Formal mathematical proofs, coordinate invariance theorems, empirical flow matrices, stochastic chemical master equations, and circuit analogies are detailed in Appendices A to D, supported by reproducible open-source software.

unnumberedsections: false
---

# Introduction: Reconciling Ecological Dynamics Across Scales

Theoretical ecology and non-equilibrium physics share a common goal: understanding how complex, open systems maintain stability and persist under environmental variability. Historically, however, these disciplines developed along divergent paths. Theoretical ecology, tracing its origins to the Lotka-Volterra equations (Lotka 1925, Volterra 1926) and May's (1972, 1973) complexity-stability paradox, formalizes living communities through demographic community interaction matrices (Jacobians). These matrices are fundamentally asymmetric: directional predation, asymmetrical interference competition, and body size disparities mean that species effects on one another are rarely mutual or reciprocal ($A_{ij} 
e A_{ji}$).

In contrast, non-equilibrium physical thermodynamics, pioneered by Onsager (1931a,b) and extended by Prigogine (1947, 1955) and de Groot and Mazur (1962), characterizes irreversible transport processes through phenomenological conductivity matrices ($\mathbf{L}$). Grounded in the microscopic time-reversal invariance of thermal fluctuations (detailed balance), Onsager reciprocity dictates that phenomenological cross-conductivities are strictly symmetric ($L_{ij} = L_{ji}$; Casimir 1945).

When theoretical ecologists and physicists first attempted to map ecological communities onto thermodynamic networks, they encountered an apparent contradiction. Evaluating demographic interaction matrices directly, researchers found that predation inherently broke reciprocal symmetry. This led to the widespread conclusion that non-equilibrium thermodynamics is inapplicable to living communities (MacArthur 1970, Ulanowicz and Hannon 1987, Michaelian 2005, Chakrabarti and Ghosh 2009, Meysman and Bruers 2010).

In the foundational companion paper (Choi 2026a), this historical schism was shown to stem from a fundamental category error: the demographic community matrix $\mathbf{A}$ is not the physical Onsager conductivity $\mathbf{L}$. The demographic matrix describes the rate of change of population abundances ($\delta\dot{\mathbf{x}} = \mathbf{A}\delta\mathbf{x}$), whereas Onsager conductivities relate thermodynamic fluxes to intensive driving forces ($\mathbf{J} = \mathbf{L}\mathbf{X}$). The community matrix is a composite dynamical operator that conflates underlying physical transport conductivities with the heterogeneous biomass storage capacities of biological compartments. Through continuous Lyapunov covariance factorization ($\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} = -2\mathbf{D}_{\mathrm{sym}}$), the demographic matrix resolves cleanly into a symmetric Onsager dissipative conductivity $\mathbf{D}_{\mathrm{sym}}$ that satisfies the Second Law, and an antisymmetric probability circulation tensor $\boldsymbol{\Omega}$ that quantifies cyclic flows in state space sustained by continuous external energy throughput (Choi 2026a).

Building upon that conceptual reconciliation, the present work develops the empirical and multi-scale dimensions of this thermodynamic synthesis:
- **Empirical Validation Across Contrasting Biomes:** The framework is applied to real-world ecological networks, contrasting a benthic detritus-buffered spring (Cone Spring) with an open-ocean planktonic ecosystem at the Bermuda Atlantic Time-series Study (BATS) site, as well as an exploited pelagic fishery.
- **Extension to Allometric Size Spectra:** By linking biomass capacitance and metabolic turnover to organismal body mass via Kleiber scaling and the Sheldon size spectrum, stability is shown to organize across continuous allometric scales.
- **The Fluid Turbulence Metaphor:** A physical model analogous to a Kolmogorov turbulence cascade and a flexible living canopy is developed, explaining how macroscopic structural capacitors absorb bulk environmental energy, cross-scale circulation transports it across octaves, and microscopic organisms dissipate it harmlessly into heat.
- **Non-Linear Dynamics and Early-Warning Diagnostics:** The framework is extended to non-linear Fokker-Planck quasi-potential landscapes, identifying physical early-warning signals for catastrophic regime shifts.
- **Mathematical Formulations in Appendices:** To preserve narrative clarity for biological readers, all formal derivations, coordinate invariance proofs, flow matrices, stochastic chemical master equations, and circuit analogies are provided in Appendices A to D.


# The Dual Nature of Ecological Matrices: Conceptual Bridge

To understand why ecological communities appear asymmetric while remaining obedient to physical thermodynamics, two distinct mechanisms must be distinguished:
- **Directional Trophic Feeding and Incomplete Assimilation:** In consumption interactions, biomass flows in a single direction from prey to predator, and metabolic conversion is imperfect ($\epsilon < 1$). Consequently, demographic effects are opposing in algebraic sign: negative for the prey and positive for the predator.
- **Unequal Biomass Storage Capacities:** How much an intensive thermodynamic potential changes when mass is added depends inversely on the physical storage capacity of the receiving compartment. Adding a unit of carbon to a massive detrital reservoir induces an imperceptible change in chemical potential, whereas adding that same mass to a tiny predator population produces a large shift. The demographic community matrix conflates physical transport with these unequal storage vessels.

When this conflation is unraveled using the stationary fluctuation covariance matrix $\mathbf{C} = \langle \delta\mathbf{x}\delta\mathbf{x}^{\mathsf{T}}\rangle$ as the metric tensor of the state space, the demographic operator $-\mathbf{A}\mathbf{C}$ splits uniquely into two distinct physical operators (Choi 2026a, Appendix A.1):
- **Symmetric Dissipation ($\mathbf{D}_{\mathrm{sym}}$):** The symmetric component $\mathbf{D}_{\mathrm{sym}} = -\frac{1}{2}(\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}})$ represents the irreversible dissipation of free energy through metabolic respiration, physiological maintenance, and heat loss. As required by the Second Law of Thermodynamics, $\mathbf{D}_{\mathrm{sym}}$ is strictly positive definite ($\mathbf{D}_{\mathrm{sym}} \succ 0$), driving perturbations monotonically downhill toward the stationary state.
- **Antisymmetric Probability Circulation ($\boldsymbol{\Omega}$):** The skew-symmetric component $\boldsymbol{\Omega} = \frac{1}{2}(\mathbf{C}\mathbf{A}^{\mathsf{T}} - \mathbf{A}\mathbf{C})$ represents non-dissipative cyclic motion in state space, such as predator-prey oscillations, seasonal plankton cycles, and microbial recycling loops. Because $\boldsymbol{\Omega}$ is skew-symmetric, it does no net thermodynamic work against the potential gradient ($\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}\delta\mathbf{x} = 0$), functioning as a non-dissipative energy and nutrient shuttler.

To field biologists, these physical operators correspond to familiar ecological mechanisms:
- **Biomass Warehouses (Capacitance $\mathbf{C}$):** Biological standing stocks act as entropic capacitors or biomass warehouses. A massive detrital bed or an old-growth forest stores extensive reserves of carbon and nutrients, providing inertia that buffers the community against seasonal droughts and resource lean periods.
- **Metabolic Dissipation ($\mathbf{D}_{\mathrm{sym}}$):** The symmetric operator represents the unavoidable metabolic tax paid to maintain living structure against spontaneous thermal decay. Respiration, cellular repair, basal maintenance, and foraging locomotion dissipate high-grade chemical energy into waste heat, driving perturbations monotonically back toward stationary balance in strict compliance with the Second Law.
- **The Trophic Carousel (Probability Circulation $\boldsymbol{\Omega}$):** The antisymmetric operator acts as a non-dissipative conveyor belt or trophic carousel. Trophic feeding loops, predator-prey oscillations, and microbial recycling loops continuously shuttle matter and energy across species boundaries. Because $\boldsymbol{\Omega}$ is skew-symmetric, this circulating current does no net thermodynamic work against the underlying potential landscape; rather, it distributes incoming solar and nutrient throughput across the network without degrading the local free-energy gradient.

The non-equilibrium circulation ratio $\chi = \|\boldsymbol{\Omega}\|_F / \|\mathbf{D}_{\mathrm{sym}}\|_F$ quantifies the departure from microscopic detailed balance. In an isolated system at thermodynamic equilibrium, detailed balance holds, circulation vanishes ($\boldsymbol{\Omega} = \mathbf{0}$, $\chi = 0$), and the demographic matrix is completely symmetric in appropriate thermodynamic coordinates. In open living ecosystems driven by solar irradiance and nutrient flows, continuous non-equilibrium throughput sustains steady cyclic currents ($\chi > 0$), spinning the trophic carousel. Complete mathematical proofs of coordinate invariance and the two-species prototype decomposition are presented in Appendices A.2 and D.1.

# Biomass Capacitance and the Resistance-Resilience Trade-Off

## The Artifact of Spatial Coordinates

A long-standing source of confusion in ecological thermodynamics is the convention of normalizing ecosystem states by arbitrary geographic area (square meters) or water depth (cubic meters). This convention introduces severe dimensional artifacts. An open-water plankton column, a rocky intertidal bench, and a forest stand are not closed physical boxes. Defining thermodynamic intensive potentials per unit spatial area assumes that spatial boundaries define the heat and work containers of the ecosystem.

In physical thermodynamics, extensive potentials depend on the amount of physical material present to store energy and entropy. In biological communities, the true physical container is living and detrital biomass ($B$). As derived from dimensional considerations in Appendix B.1, the entropic storage capacity of an ecological compartment is proportional to its standing biomass:

$$C_i = \frac{B_i^*}{k_{\mathrm{B}}}$$

When state departures are normalized by standing biomass, coordinates become non-dimensional strain variables measuring fractional departure from stationarity. In these biomass-normalized coordinates, thermodynamic state functions become mathematically coherent, and physical Onsager conductivities become strictly positive definite across all scales.

## Two Pillars of Ecosystem Stability: Resistance vs. Resilience

Grounding stability in biomass capacitance resolves a historic ambiguity in ecological theory: the tension between ecological Resistance and ecological Resilience (Webster et al. 1975, Pimm 1984, Holling 1996, Gunderson 2000). In the non-equilibrium thermodynamic framework, these concepts correspond to two complementary physical properties:
- **Entropic Resistance (Static Capacitance Storage):** Governed by the stationary covariance matrix $\mathbf{C}$, Resistance reflects the capacity of an ecosystem to store extensive quantities without experiencing large shifts in intensive thermodynamic potential. Ecosystems with massive biomass reservoirs (such as old-growth forests, peatlands, and benthic detrital channels) possess high Resistance: they absorb external energetic or nutrient shocks through internal mass buffering, preventing dramatic disruptions to ecosystem structure.
- **Kinetic Resilience (Mass-Specific Recovery Turnover):** Governed by the turnover operator $\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}$, Resilience reflects the kinetic velocity with which an ecosystem returns to steady state following a disturbance. Ecosystems with small standing biomass but rapid metabolic activity (such as ocean surface plankton, microbial biofilms, and ephemeral vernal pools) possess high Resilience: while vulnerable to initial displacement, their rapid mass-specific turnover drives fast recovery.

Because individual organisms face strict metabolic and structural constraints, ecosystems organize along an overarching hyperbolic Pareto trade-off frontier (Fig. \ref{fig_ecosystem_comparison}):

$$B_{\text{tot}} \times \mathcal{R} \approx \text{constant}$$

where $B_{\text{tot}}$ is total standing biomass capacitance and $\mathcal{R}$ is mass-specific metabolic turnover. Dense benthic detrital beds and ancient forests occupy the high-Resistance / low-Resilience extreme, while open pelagic oceans and microbial bioreactors occupy the low-Resistance / high-Resilience extreme.

![Thermodynamic phase space of ecosystems: The Resistance-Resilience Pareto frontier and non-equilibrium circulation. (A) The hyperbolic Pareto frontier: plotting total biomass capacitance $\log_{10} B_{\text{tot}}$ (Resistance) against mass-specific metabolic turnover $\log_{10}\mathcal{R}$ (Resilience) reveals an overarching trade-off across world biomes, from dense benthic detrital beds and ancient forests to pelagic oceans. (B) Detailed balance violation: the non-equilibrium circulation ratio $\chi = \|\boldsymbol{\Omega}\|_{F} / \|\mathbf{D}_{\mathrm{sym}}\|_{F}$ quantifies driven cyclic currents in living food webs. (C) Phase space relaxation: state departures spiral inward under a negative-definite Lyapunov potential while driven currents maintain non-equilibrium circulation. (D) Characteristic relaxation timescales: complex eigenvalue distributions distinguish rapid kinetic recovery in pelagic plankton (period of approximately 42 days) from slow, massive detrital damping in benthic streams (period of approximately 296 days). \label{fig_ecosystem_comparison}](media/fig_ecosystem_comparison.png){width=85%}


# Empirical Applications: Benthic Cold Springs vs. Open-Ocean Plankton Ecosystems

To demonstrate the empirical utility of this non-equilibrium thermodynamic framework, the methodology is applied to two contrasting aquatic ecosystems with published empirical flow budgets: the classic benthic, detritus-buffered Cone Spring food web (Tilly 1968, Patten 1978, Ulanowicz 1986) and the open-ocean plankton network at the Bermuda Atlantic Time-series Study (BATS) site in the Sargasso Sea (Fasham et al. 1990, Spitz et al. 2001, Steinberg et al. 2001, Zheng et al. 2024). In addition, an exploited marine fishery model (NPZD-Fish) is evaluated to examine how harvesting pressure alters thermodynamic attractor stability.

## The Benthic Cold-Spring Ecosystem: High-Resistance Detrital Storage (Cone Spring)

Cone Spring is a cold limnocrene freshwater spring in Iowa characterized by steady subterranean discharge, a stenothermal temperature regime (approximately 10 degrees Celsius year-round), and heavy reliance on allochthonous organic matter inputs (Tilly 1968, Patten 1978, Ulanowicz 1986). The biological community is organized into five well-defined functional guilds:
- **Primary Producers (Plants, $x_1$):** Dominated by rooted macrophyte beds of freshwater watercress (*Nasturtium officinale*) and epiphytic benthic microalgae that carpet the spring substrate, fixing solar irradiance during the spring and summer.
- **Organic Detritus Pool (Detritus, $x_2$):** A massive non-living organic matter reservoir comprising decaying deciduous tree litter (predominantly oak, elm, and hickory foliage from the surrounding riparian forest canopy) intermixed with submerged particulate organic muck.
- **Decomposer Microbes (Bacteria, $x_3$):** Benthic heterotrophic bacteria and microbial biofilms adhering to decaying leaves, actively secreting extracellular enzymes to digest cellulose and refractory structural lignin.
- **Benthic Shredders and Grazers (Detritivores, $x_4$):** Dominated by dense populations of cold-adapted amphipod crustacea (*Gammarus pseudolimnaeus*) and aquatic isopods (*Asellus militaris*), which shred coarse organic leaf litter while simultaneously assimilating the nutrient-rich bacterial biofilms coating leaf surfaces.
- **Benthic Predators (Carnivores, $x_5$):** Secondary and tertiary consumers comprising freshwater planarians (*Phagocata morgani*), leech populations, and predatory larval salamanders (*Eurycea bislineata*) that feed upon active amphipods and detritivores.

Evaluating the thermodynamic metrics across these biological guilds reveals the physical architecture of cold-spring persistence:
- **Massive Detrital Storage Capacitance:** The detrital reservoir constitutes the primary physical capacitor of the ecosystem ($B_2^* = 3580\ \mathrm{kcal\ m^{-2}}$, or approximately $358.3\ \mathrm{g\ C\ m^{-2}}$), accounting for over 88% of total network energy standing stock. This massive storage capacity functions as an entropic shock absorber (Resistance): seasonal pulses of autumnal leaf fall are stored rather than immediately oxidized, preventing boom-and-bust starvation cycles in detritivores.
- **Slow Relaxation Dynamics and Low Dissipation:** Spectral decomposition of the living community matrix $\mathbf{A}_{\mathrm{CS}}$ yields a dominant real eigenvalue $\lambda_1 = -2.80\ \mathrm{yr^{-1}}$ and a complex oscillatory pair $\lambda_{2,3} = -2.11 \pm 7.74i\ \mathrm{yr^{-1}}$, corresponding to an internal relaxation timescale of approximately 296 days. The system operates at a low entropy production rate density of $\sigma = 90.35\ \mathrm{yr^{-1}}$, achieving stability through slow, detritus-buffered conservation of structural order.
- **Trophic Probability Circulation on the Benthic Carousel:** Detailed balance is strictly violated. Solving the continuous Lyapunov equation reveals non-zero off-diagonal circulation entries in $\boldsymbol{\Omega}_{\mathrm{CS}}$ (Appendix B.2.1). Amphipods consume bacterial biofilms, planarians prey upon amphipods, and animal mortality returns organic matter to detritus, driving continuous probability circulation ($\chi = 0.85$) that sustains ecosystem function without destabilizing the thermodynamic attractor (Fig. \ref{fig_app3_cone_spring}).

![Thermodynamic flow network decomposition of the Cone Spring benthic ecosystem (Tilly 1968). (A) Resolution of the indefinite symmetric part paradox: while the raw community matrix sum $\mathbf{A} + \mathbf{A}^{\mathsf{T}}$ contains spurious negative eigenvalues, the continuous Lyapunov transformation $-\mathbf{A}\mathbf{C} - \mathbf{C}\mathbf{A}^{\mathsf{T}} = 2\mathbf{D}_{\mathrm{sym}}$ is strictly positive-definite. (B) Monotonic Lyapunov decay: relaxation trajectories follow negative-definite quadratic potentials $V(\delta\mathbf{x}) = \delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\delta\mathbf{x}$, demonstrating global asymptotic stability. (C) Stationary covariance structure: cross-compartment correlations across the five trophic pools (Plants, Detritus, Herbivores, Carnivores, Deposit Feeders). (D) Resistance vs. Resilience across compartments: detritus dominates biomass capacitance ($B_2^* = 358.3\ \mathrm{g\,C\,m^{-2}}$, high Resistance), while active carnivores and herbivores govern kinetic turnover (high Resilience). \label{fig_app3_cone_spring}](media/fig_app3_cone_spring.png){width=85%}

## The Open-Ocean Plankton Ecosystem: High-Resilience Kinetic Turnover (BATS Site)

In sharp contrast to the benthic detrital spring, open-ocean planktonic ecosystems operate in an unattached, three-dimensional fluid environment driven by high-frequency solar irradiance and rapid nutrient cycling. The four-variable Nutrient-Phytoplankton-Zooplankton-Detritus (NPZD) network is parameterized using multi-decadal time-series observations from the Bermuda Atlantic Time-series Study (BATS) in the oligotrophic Sargasso Sea (Fasham et al. 1990, Spitz et al. 2001, Steinberg et al. 2001, Zheng et al. 2024).

The biological community inhabiting the epipelagic euphotic zone is characterized by distinct oceanographic guilds:
- **Dissolved Inorganic Nitrogen ($N$):** Consists of dissolved bioavailable nitrate, nitrite, and ammonium ions, with ambient surface concentrations in the ultra-oligotrophic Sargasso Sea drawn down to near-depletion ($N^* \approx 0.10\ \mathrm{mmol\ N\ m^{-3}}$).
- **Phytoplankton Assemblage ($P$):** Dominated by picoplanktonic cyanobacteria (*Prochlorococcus marinus* and *Synechococcus*) together with small eukaryotic flagellates (prasinophytes and prymnesiophytes), with diatoms proliferating during brief convective mixing events.
- **Heterotrophic Zooplankton Grazers ($Z$):** Comprising microzooplankton (ciliates and dinoflagellates) and mesozooplankton dominated by small calanoid copepods (*Calanus*, *Oithona*, and *Pleuromamma*), chaetognaths, and gelatinous salps.
- **Particulate Organic Detritus ($D$):** A dynamic marine snow pool consisting of decaying planktonic carcasses, discarded appendicularian houses, fecal pellets, and transparent exopolymer particles sinking slowly through the water column.

The thermodynamic properties of the BATS surface mixed layer contrast sharply with Cone Spring:
- **Low Standing Capacitance, Rapid Kinetic Turnover:** Total plankton biomass in the upper mixed layer (0 to 52 m) is minimal ($B_{\text{tot}} \approx 0.028\ \mathrm{g\ C\ m^{-3}}$), but mass-specific primary production and grazing rates are rapid. In winter, strong convective wind mixing breaks down thermal stratification, deepening the mixed layer to 150 to 200 meters and entraining deep nitrate into the illuminated surface, sparking the annual spring diatom bloom. The dominant complex eigenvalue pair ($\lambda_{3,4} = -62.95 \pm 57.73i\ \mathrm{yr^{-1}}$) yields an oscillation period of approximately 39.8 days, which is over seven times faster than Cone Spring.
- **High Entropy Production Rate Density:** Driven by continuous solar photon throughput, the BATS upper mixed layer operates at an entropy production rate density of $\sigma = 257.65\ \mathrm{yr^{-1}}$, nearly three times that of Cone Spring. The system stabilizes itself not through massive static storage, but through high-resilience kinetic turnover and rapid microbial self-damping.
- **Vertical Stratification as a Resistance-Resilience Gradient:** The BATS water column exhibits strong vertical partitioning. The warm, illuminated surface mixed layer (0 to 52 m) operates in the high-Resilience / low-Resistance regime. In contrast, the subsurface Deep Chlorophyll Maximum (DCM, 52 to 250 m) maintains a deep dissolved inorganic nitrogen pool ($N^* \approx 1.73\ \mathrm{mmol\ N\ m^{-3}}$) that acts as a massive nutrient buffer, providing entropic Resistance against seasonal stratification breakdown and convective mixing.

## Structural Truncation Under Exploitation: The Marine Pelagic Fishery

To investigate the thermodynamic consequences of anthropogenic harvesting, the BATS plankton model is extended to include demersal and pelagic fish ($F$), creating a five-pool NPZD-Fish food web (Appendix B.2.3). 

Under unexploited conditions, the addition of fish shifts the ecosystem along the Pareto frontier toward higher Resistance: standing biomass expands ($B_{\text{tot}} \approx 0.15\ \mathrm{g\ C\ m^{-3}}$), specific turnover decreases, and the dominant relaxation timescale lengthens to approximately 254 days. The fish population functions as a high-capacity entropic storage buffer ($C_{55}$) that dampens planktonic bloom-and-bust volatility.

When heavy industrial fishing mortality is imposed ($H = q E F$), the thermodynamic consequences parallel documented marine groundfish collapses, such as the historical collapse of Atlantic cod (*Gadus morhua*) across the Scotian Shelf and Grand Banks of eastern Canada (Frank et al. 2005, Choi 2023):
- **Depletion of Long-Lived Storage Capacitors:** Industrial trawling selectively removes large, long-lived predatory fish that typically live ten to twenty years. These apex consumers act as multi-year biomass capacitors ($C_{55} \to 0$). Stripping this apex capacitor removes the slow, high-inertia buffer that stabilized the lower trophic tiers against climatic and recruiting shocks.
- **Surge in Probability Circulation and Pelagic Volatility:** Stripped of predatory damping, the marine food web undergoes a trophic cascade, truncating into a high-turnover community of short-lived pelagic forage fish (herring and capelin) and benthic macroinvertebrates (snow crab and northern shrimp). Probability circulation between zooplankton and phytoplankton surges, and internal dissipation increases dramatically, driving entropy production rate density to $\sigma = 425.03\ \mathrm{yr^{-1}}$ (4.7 times that of Cone Spring).
- **Attractor Flattening and Collapse Vulnerability:** The removal of biomass capacitance flattens the entropic potential well ($\mathbf{H} \to 0$). Small temperature anomalies and seasonal wind fluctuations that were previously buffered by fish biomass now induce volatile, boom-bust swings in plankton stocks, preconditioning the ecosystem for sudden, catastrophic collapse into alternative degraded regimes.

## Cross-System Fluctuation Thermodynamics: Comparative Analysis Across Aquatic Regimes

Comparing the three aquatic regimes highlights how environmental geometry, primary energy sources, and biological architectures dictate non-equilibrium thermodynamic state variables (Table \ref{tbl:aquatic_comparison}).

| Thermodynamic Metric | Benthic Cold Spring (Cone Spring) | Open-Ocean Mixed Layer (BATS NPZD) | Exploited Marine Fishery (NPZD-Fish) | Physical Significance |
| :--- | :--- | :--- | :--- | :--- |
| **System Boundary** | Fixed benthic channel; localized spring | Upper mixed layer (0 to 52 m); fluid volume | Upper ocean with industrial harvesting | Controls transport constraints and external boundary inputs |
| **Primary Energy Driver** | Allochthonous organic detrital inflow | High solar photon irradiance | Solar flux coupled to external biomass export | Dictates the magnitude of non-equilibrium thermodynamic driving |
| **Standing Biomass ($B_{\text{tot}}$)** | $358.3\ \mathrm{g\ C\ m^{-2}}$ (high capacitance) | $0.028\ \mathrm{g\ C\ m^{-3}}$ (low capacitance) | $0.035\ \mathrm{g\ C\ m^{-3}}$ (stripped capacitance) | Determines entropic storage capacity and static Resistance |
| **Dominant Timescale ($\tau$)** | $296\ \mathrm{days}$ (slow, low frequency) | $39.8\ \mathrm{days}$ (fast, high frequency) | $18.5\ \mathrm{days}$ (volatile, erratic) | Reflects characteristic system response time to external shocks |
| **Circulation Ratio ($\chi$)** | $0.85$ (balanced cycling) | $1.42$ (strong planktonic loops) | $2.68$ (severe unbuffered circulation) | Quantifies departure from detailed balance and cyclic flux intensity |
| **Entropy Density ($\sigma$)** | $90.35\ \mathrm{yr^{-1}}$ (low dissipation) | $257.65\ \mathrm{yr^{-1}}$ (moderate dissipation) | $425.03\ \mathrm{yr^{-1}}$ (high dissipation) | Measures the rate of free-energy dissipation per unit volume |
| **Stability Regime** | High Resistance / Low Resilience | Low Resistance / High Resilience | Depleted Resistance / Fragile Turnover | Defines position along the overarching Pareto stability frontier |

Table: Cross-system comparative analysis of non-equilibrium thermodynamic properties across three canonical aquatic ecosystems. {#tbl:aquatic_comparison}

These empirical findings demonstrate that ecosystems adapt to their physical environment by tuning the ratio of storage capacitance (Resistance) to kinetic turnover (Resilience). Whether an ecosystem organizes around massive detrital buffers or rapid planktonic recycling loops, its dynamics conform to the continuous Lyapunov balance equation, verifying the universality of the non-equilibrium thermodynamic framework.

# Extension to Allometric Size Spectra and Multi-Scale Energy Cascades

## Allometric Partitioning of Capacitance and Turnover Across the Size Spectrum

Living communities are not unstructured mixtures of species. Rather, they are organized across continuous spectra of organismal body size spanning more than twenty-two orders of magnitude, from marine picoplankton and soil bacteria ($10^{-14}\ \mathrm{g}$) to pelagic blue whales and giant forest trees ($10^8\ \mathrm{g}$). This physical size structuring governs how energy, mass, and thermodynamic entropy flow through the biosphere.

Empirical marine and terrestrial surveys reveal that total biomass tends to distribute evenly across logarithmic body-mass octaves, a macroecological regularity known as the Sheldon size spectrum (Sheldon et al. 1972, Kerr and Dickie 2001, Andersen 2019):

$$\frac{dB(m)}{d\ln m} \approx \text{constant}$$

While biomass density remains approximately invariant across mass octaves, metabolic rates scale non-linearly with individual organismal mass according to Kleiber's law (Kleiber 1932, 1947, West et al. 1997, Brown et al. 2004): individual metabolic rate scales as $B_{\text{ind}} \propto m^{3/4}$, which implies that mass-specific metabolic dissipation scales as:

$$\rho(m) \propto m^{-1/4}$$

This quarter-power allometric scaling creates a systematic functional partitioning across the size spectrum (Fig. \ref{fig_energy_cascade}A):
- **Microscopic Scales ($m \to 0$):** High mass-specific turnover ($\rho(m) \propto m^{-0.25}$) and tiny individual storage capacitance ($C_{\text{ind}} \propto m^1$). Small organisms (bacteria, flagellates, phytoplankton) function as high-frequency kinetic dissipators (Resilience).
- **Macroscopic Scales ($m \to \infty$):** Low mass-specific turnover and massive individual storage capacitance ($C_{\text{ind}} \propto m^1$). Large organisms (trees, megafauna, apex marine predators) function as low-frequency entropic shock absorbers (Resistance).

In the frequency domain, different organismal size classes act as tuned Fourier impedance filters, providing ecological memory and inertia (Fig. \ref{fig_energy_cascade}B). Fast-turnover microbes and foliar leaves damp high-frequency environmental noise (such as diurnal solar fluctuations and turbulent wind gusts), while long-lived organisms and detrital reservoirs integrate and buffer low-frequency planetary oscillations (such as seasonal transitions, El Niño Southern Oscillation cycles, and multi-decadal climatic anomalies; Fig. \ref{fig_energy_cascade}C,D).

![The multi-scale energy dissipation cascade and canopy impedance filtering. (A) Allometric partitioning of function: mass-specific metabolic dissipation $\rho(m) \propto m^{-0.25}$ (orange line) dominates microscopic scales, while standing biomass capacitance $B(m)$ (blue dashed line) acts as a high-inertia storage capacitor at macroscopic scales. (B) Dynamic frequency transfer functions $|H(\omega)|$: different body-mass classes act as tuned Fourier impedance filters, absorbing and damping environmental forcing across diurnal, seasonal, and decadal (ENSO) bands. (C) Planetary power absorption spectrum: ambient red environmental climate noise (dotted black line) is partitioned into high-frequency metabolic dissipation by microbial heatsinks (orange shaded region) and low-frequency memory integration within long-lived biomass buffers (blue shaded region). (D) Dynamic biospheric impedance across Earth system octaves, demonstrating progressive multi-scale damping from rapid diurnal solar fluctuations to multi-decadal climate stabilization. \label{fig_energy_cascade}](media/fig_energy_cascade.png){width=85%}

## The Fluid Turbulence Metaphor: Kolmogorov Energy Cascade and Canopy Dissipation

To conceptualize how living communities absorb and dissipate external energy without structural destruction, an intuitive physical metaphor emerges: the analogy between the multi-scale energy cascade of fluid turbulence (Kolmogorov 1941) and the dissipative architecture of a flexible living canopy.

In classical fluid mechanics, Kolmogorov (1941) described the turbulent cascade as a three-stage physical process:
- Energy is injected at macroscopic integral length scales ($L_0$) by large-scale boundary forcing.
- In the intermediate inertial subrange, non-linear inertial vortex stretching transfers kinetic energy down through progressively smaller eddy scales without significant viscous dissipation.
- At the microscopic Kolmogorov scale ($\eta$), molecular viscosity overcomes inertial forces, converting kinetic motion irreversibly into thermal heat.

The fundamental physical reason for this three-stage cascade in fluids is scale disparity: a 100-meter atmospheric gust or an oceanic tidal eddy possesses immense kinetic energy, but molecular viscosity is negligible at macroscopic scales ($L_0$). Bulk fluid motion cannot convert directly into heat at large scales; it must be progressively fragmented through non-linear vortex stretching across an inertial subrange until it reaches the sub-millimeter Kolmogorov scale ($\eta$), where molecular viscosity can finally bite.

Living ecosystems structure their energy flows through an exact biological counterpart to this turbulent cascade. A forest or a pelagic marine community cannot absorb a hurricane wind blast or a seasonal solar irradiance surge directly through cellular metabolic respiration. Nature evolved the allometric body-size hierarchy as an ecological cascade to step energy down across spatial and temporal octaves.

### Macro-Scale Energy Injection and Capacitive Shock Absorption

External environmental forcing (such as severe atmospheric storm gusts, tidal surges, diurnal solar irradiance pulses, and seasonal flood pulses) delivers kinetic and radiant energy at the largest macroscopic scales ($L_{\text{macro}}$). In a forest or kelp bed, this energy enters through macroscopic structural members: massive tree boles, canopy crowns, thick kelp stipes, and extensive root and rhizome networks. In pelagic marine ecosystems, macroscopic energy enters through large-bodied apex predators and migrating megafauna.

These large organisms act as macroscopic structural and entropic capacitors. Because of their immense standing mass and structural compliance, they absorb bulk environmental momentum and radiant energy through elastic deformation, mechanical swaying, and long-term biochemical storage. Rather than resisting external forces through rigid, brittle opposition, the macro-capacitors yield elastically, storing the incoming impulse as strain energy and chemical potential, thereby conferring entropic Resistance without fracture.

### Inertial Subrange and Cross-Scale Probability Circulation

In fluid turbulence, the inertial subrange transfers energy across spatial octaves without dissipation. In an ecological community, energy and mechanical momentum are transferred down through the allometric size spectrum through non-linear cross-scale interactions:
- In terrestrial canopies, large swaying boles collide with primary branches, shedding kinetic energy into secondary limbs, twigs, and fluttering leaves through multi-body aerodynamic coupling and vortex shedding.
- In trophic food webs, incoming primary production captured by autotrophs is transferred across body-size classes through directional predation, herbivory, particle shredding, and detrital decomposition.

In the non-equilibrium thermodynamic formalism, this cross-scale transport is driven by non-equilibrium probability circulation ($\boldsymbol{\Omega}$). Because the circulation tensor is skew-symmetric, it does no net work against the thermodynamic potential gradient ($\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}\delta\mathbf{x} = 0$). Instead, it shuttles energy, matter, and momentum across biological octaves, bridging the gap between macroscopic external forcing and microscopic cellular processes.

### Viscous Dissipation and Micro-Scale Thermal Sinks

In fluid mechanics, the cascade terminates at the Kolmogorov microscale, where molecular viscosity dissipates kinetic motion into heat. In ecological networks, the biological counterpart to the Kolmogorov microscale is the microscopic organismal and cellular tier:
- Foliar leaf boundary layers, aerodynamic skin friction, and viscous air drag convert canopy mechanical motion into turbulent micro-vortices and atmospheric heat.
- At the cellular scale, microbial metabolic respiration, enzymatic nutrient mineralization, and bacterial detrital decomposition convert chemical free energy into thermodynamic waste heat.

Here, symmetric Onsager dissipation ($\mathbf{D}_{\mathrm{sym}}$, Resilience) operates. Because mass-specific metabolic activity scales inversely with body size ($\rho(m) \propto m^{-0.25}$), microscopic organisms and cellular membranes dissipate energy at extraordinary rates per unit biomass. By bleeding off the cascading energy flux as low-grade thermal radiation, these ubiquitous micro-scale dissipators protect the macroscopic structural capacitors from mechanical snapping or starvation collapse.

### Evolutionary Optimization of Flexible Attenuation

The contrast between this multi-scale living cascade and an engineered rigid structure reveals why ecosystems persist across evolutionary epochs. If a forest consisted of rigid, unyielding concrete or stone monoliths, a severe wind storm would exert concentrated bending moments at the base, resulting in catastrophic brittle fracture. A flexible forest canopy, by contrast, bends with the wind, streamlines its foliage, transfers kinetic energy into fluttering leaves, and sheds the energy safely through viscous air drag.

Similarly, an ecosystem that attempts to maximize standing biomass while eliminating microbial and detrital recycling networks loses its multi-scale dissipative cascade. Natural selection tunes ecological networks along the Resistance-Resilience Pareto frontier, maintaining large structural capacitors to absorb external shocks, probability circulation to distribute fluxes across scales, and microscopic dissipators to shed excess energy into heat.

# The Non-Linear Regime: Quasi-Potential Landscapes and Early-Warning Diagnostics

## The Non-Equilibrium Quasi-Potential Landscape

While linear non-equilibrium thermodynamics characterizes relaxation near steady state, living ecosystems frequently undergo large state departures, multi-stability, and catastrophic tipping points (Holling 1973, Scheffer et al. 2001, May 1977). In this non-linear regime, the dynamics are governed by continuous Fokker-Planck diffusion equations and non-equilibrium quasi-potential landscapes (Freidlin and Wentzell 1984, Graham 1977, Ao 2004, Wang et al. 2008, Zhou et al. 2012).

To an ecologist, the quasi-potential landscape $U(\mathbf{x})$ represents the topographical basin of ecological health. A deep, steep potential well signifies a resilient, well-buffered ecosystem that absorbs perturbations and returns promptly to baseline. Conversely, a wide, shallow, or flattened basin signifies a degraded ecosystem on the brink of tipping into an undesirable alternative state.

As proven in Appendix A.6, any smooth non-linear ecological drift field $\mathbf{f}(\mathbf{x})$ admits an orthogonal Helmholtz-Hodge decomposition into two distinct components:
- **Downhill Dissipative Gradient Drift:** A symmetric, positive-definite diffusion operator $\mathbf{D}(\mathbf{x})$ driving downhill movement along the gradient of the scalar quasi-potential landscape $U(\mathbf{x})$, representing thermodynamic free-energy dissipation.
- **Transverse Probability Circulation:** An antisymmetric vector field $\mathbf{v}_{\mathrm{curl}}(\mathbf{x})$ that circulates along the iso-potential contours of $U(\mathbf{x})$, satisfying the orthogonality condition $\nabla U(\mathbf{x}) \cdot \mathbf{v}_{\mathrm{curl}}(\mathbf{x}) = 0$.

Because the circulating current is orthogonal to the potential gradient, it does no work against the potential landscape. The quasi-potential $U(\mathbf{x})$ functions as a generalized non-equilibrium Lyapunov function: within the basin of attraction, trajectories spiral inward toward the steady-state attractor, while non-equilibrium circulation sustains persistent cyclic currents.

## Physical Early-Warning Signals for Catastrophic Regime Shifts

Prior to a catastrophic tipping point (such as coral reef bleaching, lake eutrophication, or pelagic fishery collapse), the local potential well around the steady state flattens. The non-equilibrium thermodynamic framework translates this geometric flattening into observable physical diagnostics:
- **Curvature Collapse of the Entropy Hessian:** As an ecosystem approaches a tipping point, the dominant eigenvalue of the entropy Hessian approaches zero ($\lambda_{\min}(\mathbf{H}) \to 0$). The restoring force that drives the ecosystem back toward stationarity weakens, leading to critical slowing down (Scheffer et al. 2009).
- **Covariance and Variance Explosion:** Because the stationary covariance matrix is the inverse of the entropy Hessian ($\mathbf{C} = k_{\mathrm{B}}\mathbf{H}^{-1}$), flattening of the potential well causes stationary fluctuation variance to diverge along the soft eigenvector direction ($\mathbf{C}_{ii} \to \infty$).
- **Circulation Ratio Surges:** As demonstrated in the exploited marine fishery (Table \ref{tbl:aquatic_comparison}), the removal of stabilizing biomass capacitors strips entropic damping, causing the circulation ratio $\chi = \|\boldsymbol{\Omega}\|_F / \|\mathbf{D}_{\mathrm{sym}}\|_F$ to surge before the bifurcation occurs.
- **Asymmetric Fluctuation Spirals:** Because probability circulation produces directional spiraling in phase space, fluctuation trajectories exhibit pronounced rotational asymmetry prior to collapse, providing an operational early-warning signal that distinguishes non-equilibrium regime shifts from symmetric equilibrium noise.

For field conservationists and fisheries managers, these thermodynamic diagnostics translate into actionable operational monitoring protocols:
- If annual survey time-series reveal that recovery time after an acute climatic heatwave or storm disturbance is lengthening from months to years, the ecosystem is exhibiting critical slowing down.
- If abundance variance across spatial survey stations is inflating along specific trophic dimensions, the entropy Hessian is collapsing ($\det \mathbf{H} \to 0$), signaling that the basin of ecological health is flattening.
- When an exploited fishery experiences both spatial variance inflation and a surge in recruitment volatility, the system has lost its stabilizing apex capacitance ($C_{55}$), providing an urgent quantitative warning to curtail harvest before catastrophic regime collapse occurs.

# Discussion and Evolutionary Synthesis

## Evolutionary Tuning of the Stability Frontier

The thermodynamic reconciliation developed across these manuscripts offers a fresh perspective on the evolution of ecological complexity. Historically, ecological theory oscillated between two opposing paradigms: May's (1972) mathematical proof that random complexity breeds instability, and empirical observations that complex natural ecosystems (such as tropical rainforests and coral reefs) persist for millennia.

The non-equilibrium thermodynamic framework resolves this tension by demonstrating that real ecosystems are not random networks. Rather, they are structured across allometric size spectra and partitioned into complementary physical operators:
- Evolution selects for standing biomass capacitance (Resistance) to buffer communities against lean seasons, physical disturbances, and climatic extremes.
- Simultaneously, natural selection optimizes mass-specific metabolic turnover (Resilience) through microbial and primary producer tiers to ensure rapid colonization and nutrient recycling.
- Non-equilibrium probability circulation shuttles energy and nutrients across trophic tiers without degrading the potential landscape, preventing the buildup of unattenuated localized stresses.

Natural communities organize along the hyperbolic Pareto frontier ($B_{\text{tot}} \times \mathcal{R} \approx \text{constant}$), achieving homeostatic balance between static shock absorption and kinetic recovery turnover.

## Haken's Slaving Principle and Planetary Stewardship

In synergetics and complex systems physics, Haken's (1983) slaving principle demonstrates that in multi-scale dynamical systems, fast dynamical modes are adiabatically slaved to slow, high-inertia order parameters. 

In the biosphere, microscopic organisms (bacteria, phytoplankton, soil nematodes) possess fast relaxation timescales, while massive structural reservoirs (forest biomass, soil humus, oceanic deep nutrients, and apex predators) operate on decadal and centennial timescales. These slow macroscopic capacitors act as Haken order parameters: they constrain, organize, and slave the rapid microbial cycles, preventing chaotic population fluctuations and stabilizing the global planetary climate.

When human activity selectively harvests and degrades these slow macroscopic capacitors (through old-growth deforestation, wetland drainage, and industrial overfishing), the biosphere loses its low-frequency impedance filters. The fast microbial modes become unslaved, resulting in volatile ecological oscillations, loss of entropic resistance, and vulnerability to catastrophic planetary tipping points. Sustainable environmental management requires preserving the structural capacitors that maintain biospheric stability.

## Practical Guidelines for Empirical Ecologists

For field ecologists seeking to measure non-equilibrium thermodynamic properties in natural ecosystems, the following four-step protocol is recommended:
- **Measure States in Extensive Mass or Energy Units:** Avoid dimensionless or purely spatial metrics. Quantify ecosystem state variables in extensive biomass units (grams of carbon, kilocalories, or moles of nitrogen per individual or total volume) to preserve tensor transformation rules and avoid coordinate singularities (Appendix B.3).
- **Construct Full Mass-Balanced Flow Budgets:** Measure both living compartment biomasses and non-living detrital reservoirs. Detritus frequently constitutes the primary entropic capacitor of terrestrial and aquatic ecosystems, and omitting it creates false stability paradoxes.
- **Solve the Continuous Lyapunov Equation:** Rather than evaluating raw community matrices directly, construct empirical covariance matrices $\mathbf{C}$ from time-series observations and solve $\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} = -2\mathbf{D}_{\mathrm{sym}}$ to isolate symmetric dissipation from non-equilibrium circulation.
- **Monitor the Circulation Ratio and Entropy Density:** Track changes in $\chi$ and $\sigma$ over time. A persistent increase in $\chi$ accompanied by variance inflation signals the loss of storage capacitance and serves as an early-warning diagnostic for impending state shifts.


# Glossary of Core Concepts

- **Onsager Reciprocal Relations:** Microscopic time-reversal invariance governing equilibrium thermal fluctuations ensures that phenomenological transport cross-conductivities are strictly symmetric ($L_{ij} = L_{ji}$).
- **Demographic Community Matrix ($\mathbf{A}$):** The Jacobian matrix of partial derivatives describing the per-capita rate of change of species populations in response to abundance departures.
- **Continuous Lyapunov Covariance Factorization:** The canonical matrix decomposition $\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} = -2\mathbf{D}_{\mathrm{sym}}$ that resolves demographic dynamics into symmetric dissipation and antisymmetric probability circulation.
- **Symmetric Dissipative Operator ($\mathbf{D}_{\mathrm{sym}}$):** The positive-definite component of the weighted drift operator governing irreversible entropy production and downhill relaxation toward steady state.
- **Antisymmetric Probability Circulation Tensor ($\boldsymbol{\Omega}$):** The skew-symmetric component of the weighted drift operator governing non-dissipative cyclic flows in state space sustained by continuous non-equilibrium energy throughput.
- **Non-Equilibrium Circulation Ratio ($\chi$):** The coordinate-invariant ratio $\chi = \|\boldsymbol{\Omega}\|_F / \|\mathbf{D}_{\mathrm{sym}}\|_F$ that measures the intensity of non-equilibrium cyclic currents relative to internal dissipation.
- **Biomass Capacitance ($C_i$):** The physical storage capacity of an ecological compartment, proportional to its standing biomass ($C_i = B_i^* / k_{\mathrm{B}}$).
- **Entropic Resistance:** The capacity of an ecosystem to absorb external shocks through internal biomass storage capacitance without experiencing large changes in intensive thermodynamic potential.
- **Kinetic Resilience:** The mass-specific recovery velocity with which an ecosystem returns to steady state following a disturbance, governed by $\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}$.
- **Sheldon Size Spectrum:** The empirical macroecological regularity wherein total organismal biomass distributes approximately evenly across logarithmic body-mass octaves.
- **Kolmogorov Turbulence Cascade:** The physical process wherein energy injected at macroscopic scales cascades through an inertial subrange via non-linear circulation and dissipates as heat at microscopic scales.
- **Quasi-Potential Landscape ($U(\mathbf{x})$):** The non-equilibrium scalar potential governing the stationary probability distribution and global stability basins of non-linear ecological dynamical systems.


# Appendix A: Mathematical Derivations and Invariance Proofs

The foundational mathematical derivations linking the demographic community matrix $\\mathbf{A}$ to the Onsager conductivity matrix $\\mathbf{L}$ via the continuous Lyapunov equation, and the algebraic proof of the Le Chatelier-Braun principle via the Schur complement, are laid out in the Appendix of Paper 1 (Choi 2026a, Appendices A.1 and A.2). The derivations presented in this appendix extend that foundation to tensorial coordinate transformations, extremum dissipation principles under clamped versus unconstrained boundary conditions, non-linear phase-space Helmholtz-Hodge decompositions, and explicit phase-space trace formulas for stationary entropy production.

## A.1 Second-Order Expansion of Total System Entropy and Free Energy

Let a thermodynamic system be defined by $n$ independent extensive state variables $\mathbf{x} = (x_1, \dots, x_n)^{\mathsf{T}}$ in contact with thermal and material reservoirs at constant temperature $T$ and pressure $p$. Let $\mathbf{x}^*$ denote the stationary reference state, and $\delta\mathbf{x} = \mathbf{x} - \mathbf{x}^*$ the state deviation.

Following the classical thermodynamic fluctuation theory of Einstein (1910) and Callen (1985), the total entropy change of the system plus its environment $\Delta S_{\mathrm{tot}}(\delta\mathbf{x})$ is related to the availability (or Gibbs free-energy change $\Delta G$) by:

$$\Delta S_{\mathrm{tot}}(\delta\mathbf{x}) = -\frac{\Delta G(\delta\mathbf{x})}{T}$$

Expanding $\Delta G(\delta\mathbf{x})$ in a Taylor series about the unperturbed reference state $\mathbf{x}^*$:

$$\Delta G(\delta\mathbf{x}) = \Delta G(\mathbf{0}) + \left.\nabla G\right|_{\mathbf{x}^*}^{\mathsf{T}}\delta\mathbf{x} + \frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\left.\frac{\partial^2 G}{\partial\mathbf{x}^2}\right|_{\mathbf{x}^*}\delta\mathbf{x} + \mathcal{O}(\|\delta\mathbf{x}\|^3)$$

At reference equilibrium or steady state, first-order thermodynamic forces vanish ($\left.\nabla G\right|_{\mathbf{x}^*} = \mathbf{0}$). Defining the Gibbs Hessian matrix $\mathbf{H}_G = \left.\partial^2 G / \partial\mathbf{x}^2\right|_{\mathbf{x}^*}$, the **entropy Hessian** (entropic curvature matrix) as:

$$\mathbf{H} = \frac{\mathbf{H}_G}{T} = -\left.\frac{\partial^2 \Delta S_{\mathrm{tot}}}{\partial\mathbf{x}^2}\right|_{\mathbf{x}^*}$$

Truncating at second order gives the quadratic entropy functional:

$$\Delta S_{\mathrm{tot}}(\delta\mathbf{x}) = -\frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{H}\delta\mathbf{x}$$

As established by Glansdorff and Prigogine (1971) and Callen (1985), thermodynamic stability requires that $\Delta S_{\mathrm{tot}}$ possesses an isolated maximum at $\delta\mathbf{x} = \mathbf{0}$, which holds if and only if the entropy Hessian is strictly positive definite:

$$\mathbf{H} = \mathbf{H}^{\mathsf{T}} \succ 0$$

Thermodynamic conjugate forces $\mathbf{X} = (X_1, \dots, X_n)^{\mathsf{T}}$ are defined as the gradients of total entropy with respect to state deviations:

$$\mathbf{X} = \nabla_{\delta\mathbf{x}} \Delta S_{\mathrm{tot}} = -\mathbf{H}\delta\mathbf{x}$$

By the Einstein fluctuation formula, the stationary probability density of microscopic fluctuations is:

$$P(\delta\mathbf{x}) \propto \exp\left( \frac{\Delta S_{\mathrm{tot}}(\delta\mathbf{x})}{k_{\mathrm{B}}} \right) = \exp\left( -\frac{1}{2k_{\mathrm{B}}}\delta\mathbf{x}^{\mathsf{T}}\mathbf{H}\delta\mathbf{x} \right)$$

This is a multivariate zero-mean Gaussian distribution with covariance matrix:

$$\mathbf{C} = \langle \delta\mathbf{x}\delta\mathbf{x}^{\mathsf{T}} \rangle = k_{\mathrm{B}}\mathbf{H}^{-1}$$

Thus, the entropic curvature tensor $\mathbf{H}$ and the stationary fluctuation covariance $\mathbf{C}$ are exact matrix inverses up to the Boltzmann constant:

$$\mathbf{H} = k_{\mathrm{B}}\mathbf{C}^{-1}$$


## A.2 Tensorial Coordinate Invariance Under Linear Transformations

Following the tensorial formulation of non-equilibrium diffusion processes on smooth manifolds (Graham 1977, Eyink 1990), let state departures be transformed by an invertible linear coordinate transformation $\delta\mathbf{y} = \mathbf{M}\delta\mathbf{x}$, where $\mathbf{M} \in \mathbb{R}^{n \times n}$ with $\det \mathbf{M} \ne 0$.

Under this transformation, the dynamical and stochastic operators transform according to standard contravariant and covariant tensor rules:
- Linearized population dynamics transform as:
  $$\frac{d}{dt}\delta\mathbf{y} = \mathbf{M}\frac{d}{dt}\delta\mathbf{x} = \mathbf{M}\mathbf{A}\delta\mathbf{x} = \mathbf{M}\mathbf{A}\mathbf{M}^{-1}\delta\mathbf{y} \implies \mathbf{A}_y = \mathbf{M}\mathbf{A}\mathbf{M}^{-1}$$
- The stationary covariance transforms contravariantly:
  $$\mathbf{C}_y = \langle \delta\mathbf{y}\delta\mathbf{y}^{\mathsf{T}} \rangle = \mathbf{M}\langle \delta\mathbf{x}\delta\mathbf{x}^{\mathsf{T}} \rangle\mathbf{M}^{\mathsf{T}} = \mathbf{M}\mathbf{C}\mathbf{M}^{\mathsf{T}}$$
- The diffusion tensor transforms contravariantly:
  $$\mathbf{D}_y = \mathbf{M}\mathbf{D}\mathbf{M}^{\mathsf{T}}$$
- The entropic curvature transforms covariantly:
  $$\mathbf{H}_y = k_{\mathrm{B}}\mathbf{C}_y^{-1} = k_{\mathrm{B}}(\mathbf{M}\mathbf{C}\mathbf{M}^{\mathsf{T}})^{-1} = \mathbf{M}^{-\mathsf{T}}\mathbf{H}\mathbf{M}^{-1}$$

To verify that the continuous Lyapunov equation is invariant, evaluate the transformed balance:

$$\mathbf{A}_y\mathbf{C}_y + \mathbf{C}_y\mathbf{A}_y^{\mathsf{T}} + 2\mathbf{D}_y = (\mathbf{M}\mathbf{A}\mathbf{M}^{-1})(\mathbf{M}\mathbf{C}\mathbf{M}^{\mathsf{T}}) + (\mathbf{M}\mathbf{C}\mathbf{M}^{\mathsf{T}})(\mathbf{M}^{-\mathsf{T}}\mathbf{A}^{\mathsf{T}}\mathbf{M}^{\mathsf{T}}) + 2\mathbf{M}\mathbf{D}\mathbf{M}^{\mathsf{T}}$$

$$= \mathbf{M}(\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} + 2\mathbf{D})\mathbf{M}^{\mathsf{T}} = \mathbf{M}(\mathbf{0})\mathbf{M}^{\mathsf{T}} = \mathbf{0}$$

Evaluating the covariance-weighted drift $-\mathbf{A}_y\mathbf{C}_y$:

$$-\mathbf{A}_y\mathbf{C}_y = -(\mathbf{M}\mathbf{A}\mathbf{M}^{-1})(\mathbf{M}\mathbf{C}\mathbf{M}^{\mathsf{T}}) = \mathbf{M}(-\mathbf{A}\mathbf{C})\mathbf{M}^{\mathsf{T}} = \mathbf{M}(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{M}^{\mathsf{T}} = \mathbf{D}_{\mathrm{sym},y} + \boldsymbol{\Omega}_y$$

where:
$$\mathbf{D}_{\mathrm{sym},y} = \mathbf{M}\mathbf{D}_{\mathrm{sym}}\mathbf{M}^{\mathsf{T}} = \mathbf{D}_{\mathrm{sym},y}^{\mathsf{T}} \succ 0$$
$$\boldsymbol{\Omega}_y = \mathbf{M}\boldsymbol{\Omega}\mathbf{M}^{\mathsf{T}} = -\boldsymbol{\Omega}_y^{\mathsf{T}}$$

Key thermodynamic scalars are invariant under any non-singular linear coordinate change:
- **Eigenvalue Spectrum:** $\operatorname{spec}(\mathbf{A}_y) = \operatorname{spec}(\mathbf{M}\mathbf{A}\mathbf{M}^{-1}) = \operatorname{spec}(\mathbf{A})$.
- **Entropy Production Rate:**
  $$\sigma_y = \operatorname{tr}(\mathbf{D}_y\mathbf{C}_y^{-1}) = \operatorname{tr}\left( \mathbf{M}\mathbf{D}\mathbf{M}^{\mathsf{T}}(\mathbf{M}^{-\mathsf{T}}\mathbf{C}^{-1}\mathbf{M}^{-1}) \right) = \operatorname{tr}(\mathbf{M}\mathbf{D}\mathbf{C}^{-1}\mathbf{M}^{-1}) = \operatorname{tr}(\mathbf{D}\mathbf{C}^{-1}) = \sigma$$
- **Circulation Ratio:** In the natural metric defined by the covariance tensor, the non-equilibrium circulation ratio $\chi = \|\boldsymbol{\Omega}\|_F / \|\mathbf{D}_{\mathrm{sym}}\|_F$ is strictly coordinate-invariant.


## A.3 Schur Complement Derivation of the Le Chatelier-Braun Principle (Schur 1917, Prigogine and Defay 1954)

While the foundational Schur complement derivation of Le Chatelier-Braun moderation under zero-flux stationary relaxation is established in Paper 1 (Choi 2026a, Appendix A.2), the formulation is summarized here to define the primary-secondary partitioning notation required for the extremum dissipation analysis (A.4) and the multiscale coordinate transformations (A.2).

Consider an ecosystem whose irreversible transport processes are partitioned into a primary process (subscript 1) and $m$ secondary coupled processes (subscript 2):

$$\begin{pmatrix} \delta J_1 \\ \delta\mathbf{J}_2 \end{pmatrix} = \begin{pmatrix} L_{11} & \mathbf{L}_{12} \\ \mathbf{L}_{21} & \mathbf{L}_{22} \end{pmatrix} \begin{pmatrix} \delta X_1 \\ \delta\mathbf{X}_2 \end{pmatrix}$$

where $\mathbf{L} = \mathbf{L}^{\mathsf{T}} \succ 0$.

Two operational boundaries define the response to an external perturbation $\delta X_1$:
- **Clamped Secondary Forces (Isolated Response):** Secondary forces are held constant ($\delta\mathbf{X}_2 = \mathbf{0}$). The primary flux is:
  $$\delta J_1|_{\mathrm{clamped}} = L_{11}\delta X_1$$
- **Free Secondary Relaxation (Unconstrained Stationary Response):** Secondary processes adjust rapidly to zero-flux stationarity ($\delta\mathbf{J}_2 = \mathbf{0}$). Solving for the secondary force adjustment:
  $$\delta\mathbf{J}_2 = \mathbf{L}_{21}\delta X_1 + \mathbf{L}_{22}\delta\mathbf{X}_2 = \mathbf{0} \implies \delta\mathbf{X}_2 = -\mathbf{L}_{22}^{-1}\mathbf{L}_{21}\delta X_1$$

Substituting $\delta\mathbf{X}_2$ back into the primary flux equation:

$$\delta J_1|_{\mathrm{free}} = L_{11}\delta X_1 + \mathbf{L}_{12}(-\mathbf{L}_{22}^{-1}\mathbf{L}_{21}\delta X_1) = \left( L_{11} - \mathbf{L}_{12}\mathbf{L}_{22}^{-1}\mathbf{L}_{21} \right) \delta X_1$$

The effective conductivity governing the primary process is the matrix **Schur complement** (Boyd and Vandenberghe 2004, Horn and Johnson 2012):

$$L_{11,\mathrm{eff}} = L_{11} - \mathbf{L}_{12}\mathbf{L}_{22}^{-1}\mathbf{L}_{21}$$

Because the full Onsager matrix is positive definite ($\mathbf{L} \succ 0$), its principal submatrix is strictly positive definite ($\mathbf{L}_{22} \succ 0$) and its inverse is likewise positive definite ($\mathbf{L}_{22}^{-1} \succ 0$). For any non-zero cross-coupling ($\mathbf{L}_{12} \ne \mathbf{0}$), the quadratic correction term is strictly positive:

$$\mathbf{L}_{12}\mathbf{L}_{22}^{-1}\mathbf{L}_{21} = \mathbf{L}_{12}\mathbf{L}_{22}^{-1}\mathbf{L}_{12}^{\mathsf{T}} > 0$$

Therefore:

$$0 < L_{11,\mathrm{eff}} < L_{11}$$

This proves the **Le Chatelier-Braun principle** in coupled non-equilibrium networks (Le Chatelier 1884, Braun 1887, Prigogine and Defay 1954, Callen 1985): the internal relaxation of secondary coupled ecological processes always moderates and reduces the effective conductivity of a primary disturbance, providing intrinsic buffering against environmental shocks.


## A.4 Extremum Dissipation Principles: Clamped Forces vs. Clamped Fluxes

Following the foundational variational principles of Onsager and Machlup (1953) and Prigogine (1955), whether non-equilibrium steady states maximize or minimize entropy production depends strictly on the imposed boundary clamping conditions:
- **Fixed Thermodynamic Forces (Maximum Entropy Production):**
  When external forces $\mathbf{X}$ are clamped at fixed values, the Onsager-Machlup dissipation functional is (Onsager and Machlup 1953, Ziegler 1983, Dewar 2003):
  $$\Phi(\mathbf{J}) = \sigma(\mathbf{J}, \mathbf{X}) - \Psi(\mathbf{J}) = \sum_{i} J_i X_i - \frac{1}{2}\sum_{i,j} R_{ij} J_i J_j$$
  Differentiating with respect to flux $J_k$:
  $$\frac{\partial \Phi}{\partial J_k} = X_k - \sum_j R_{kj} J_j = 0 \implies \mathbf{X} = \mathbf{R}\mathbf{J} \iff \mathbf{J} = \mathbf{L}\mathbf{X}$$
  Because the second derivative is negative definite ($\partial^2 \Phi / \partial \mathbf{J}^2 = -\mathbf{R} \prec 0$), the stationary state $J_i = \sum_j L_{ij}X_j$ **maximizes** the entropy production functional at fixed boundary forces.
- **Fixed Boundary Fluxes and Free Internal Forces (Minimum Entropy Production):**
  When a subset of boundary fluxes are clamped and internal forces adjust freely to zero-flux stationarity ($J_k = 0$), the total entropy production is $\sigma = \mathbf{X}^{\mathsf{T}}\mathbf{L}\mathbf{X}$. Differentiating with respect to unconstrained force $X_k$:
  $$\frac{\partial \sigma}{\partial X_k} = 2\sum_j L_{kj} X_j = 2 J_k = 0$$
  Because $\partial^2 \sigma / \partial \mathbf{X}^2 = 2\mathbf{L} \succ 0$, relaxation of unconstrained internal forces to stationarity **minimizes** entropy production, confirming Prigogine's theorem of minimum entropy production (Prigogine 1955, 1967, Glansdorff and Prigogine 1971).


## A.5 The Non-Equilibrium Lyapunov Decay Theorem (Lyapunov 1892, Tomita and Tomita 1974)

Consider a stable linear dynamical system $\delta\dot{\mathbf{x}} = \mathbf{A}\delta\mathbf{x}$ whose stationary fluctuation covariance $\mathbf{C} \succ 0$ satisfies the continuous Lyapunov equation $\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} + 2\mathbf{D} = \mathbf{0}$ with symmetric noise diffusion $\mathbf{D} \succ 0$ (Lyapunov 1892, Willems 1972).

Define the quadratic candidate Lyapunov function $V(\delta\mathbf{x}) = \frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\delta\mathbf{x}$. Differentiating along state trajectories:

$$\dot{V}(\delta\mathbf{x}) = \frac{1}{2}\delta\dot{\mathbf{x}}^{\mathsf{T}}\mathbf{C}^{-1}\delta\mathbf{x} + \frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\delta\dot{\mathbf{x}} = \frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}(\mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} + \mathbf{C}^{-1}\mathbf{A})\delta\mathbf{x}$$

From the canonical decomposition $\mathbf{A} = -(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}$:

$$\mathbf{C}^{-1}\mathbf{A} = -\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1} - \mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}$$

Taking the transpose:

$$\mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} = -\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1} - \mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1} \quad (\text{since } \boldsymbol{\Omega}^{\mathsf{T}} = -\boldsymbol{\Omega})$$

Adding the two equations, the antisymmetric circulation terms cancel identically due to skew-symmetry (Tomita and Tomita 1974, Lax 1960):

$$\mathbf{C}^{-1}\mathbf{A} + \mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} = -2\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}$$

Substituting back into $\dot{V}(\delta\mathbf{x})$:

$$\dot{V}(\delta\mathbf{x}) = -\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}\delta\mathbf{x}$$

Because $\mathbf{D}_{\mathrm{sym}} \succ 0$ and $\mathbf{C}^{-1} \succ 0$, the congruence transformation $\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1} \succ 0$ is strictly positive definite. Therefore:

$$\dot{V}(\delta\mathbf{x}) < 0 \quad (\forall\ \delta\mathbf{x} \ne \mathbf{0})$$

This completes the demonstration: **state-space trajectories relax monotonically downhill toward the stationary state, driven entirely by symmetric Onsager dissipation** (Lyapunov 1892, Tomita and Tomita 1974, Ao 2004).


## A.6 Non-Equilibrium Helmholtz-Hodge Decomposition in Non-Linear Phase Space

In far-from-equilibrium systems governed by the non-linear Langevin equation:

$$\dot{\mathbf{x}} = \mathbf{f}(\mathbf{x}) + \frac{1}{\sqrt{\mathcal{V}}}\boldsymbol{\xi}(t), \qquad \langle \boldsymbol{\xi}(t) \boldsymbol{\xi}^{\mathsf{T}}(t') \rangle = 2\mathbf{D}(\mathbf{x})\delta(t - t')$$

the stationary probability distribution $P_{\mathrm{ss}}(\mathbf{x})$ satisfies the stationary Fokker-Planck equation $\nabla \cdot \mathbf{J}_{\mathrm{prob}}(\mathbf{x}) = 0$. By Freidlin-Wentzell large deviation theory (Freidlin and Wentzell 1984), $P_{\mathrm{ss}}(\mathbf{x}) \asymp \exp(-\mathcal{V} U(\mathbf{x}))$, where $U(\mathbf{x})$ is the non-equilibrium quasi-potential.

The stationary probability flux is:

$$\mathbf{J}_{\mathrm{prob}}(\mathbf{x}) = \mathbf{f}(\mathbf{x})P_{\mathrm{ss}}(\mathbf{x}) - \frac{1}{\mathcal{V}}\mathbf{D}(\mathbf{x})\nabla P_{\mathrm{ss}}(\mathbf{x}) = \left( \mathbf{f}(\mathbf{x}) + \mathbf{D}(\mathbf{x})\nabla U(\mathbf{x}) \right) P_{\mathrm{ss}}(\mathbf{x}) + \mathcal{O}(\mathcal{V}^{-1})$$

Define the stationary circulation velocity field $\mathbf{v}_{\mathrm{curl}}(\mathbf{x})$ as:

$$\mathbf{v}_{\mathrm{curl}}(\mathbf{x}) \equiv \frac{\mathbf{J}_{\mathrm{prob}}(\mathbf{x})}{P_{\mathrm{ss}}(\mathbf{x})} = \mathbf{f}(\mathbf{x}) + \mathbf{D}(\mathbf{x})\nabla U(\mathbf{x})$$

Rearranging yields the canonical non-equilibrium Helmholtz-Hodge decomposition of the deterministic drift (Helmholtz 1858, Hodge 1941, Graham 1977, Ao 2004, Qian 2006):

$$\mathbf{f}(\mathbf{x}) = -\mathbf{D}(\mathbf{x})\nabla U(\mathbf{x}) + \mathbf{v}_{\mathrm{curl}}(\mathbf{x})$$

To establish orthogonality, substitute this decomposition into the Hamilton-Jacobi equation derived from the WKB asymptotic expansion of the Fokker-Planck equation in the macroscopic limit $\mathcal{V} \to \infty$ (Freidlin and Wentzell 1984, Graham 1977, Ao 2004):

$$\nabla U(\mathbf{x})^{\mathsf{T}} \mathbf{D}(\mathbf{x}) \nabla U(\mathbf{x}) + \mathbf{f}(\mathbf{x})^{\mathsf{T}}\nabla U(\mathbf{x}) = 0$$

Substituting $\mathbf{f}(\mathbf{x}) = -\mathbf{D}(\mathbf{x})\nabla U(\mathbf{x}) + \mathbf{v}_{\mathrm{curl}}(\mathbf{x})$:

$$\nabla U(\mathbf{x})^{\mathsf{T}} \mathbf{D}(\mathbf{x}) \nabla U(\mathbf{x}) + \left( -\mathbf{D}(\mathbf{x})\nabla U(\mathbf{x}) + \mathbf{v}_{\mathrm{curl}}(\mathbf{x}) \right)^{\mathsf{T}}\nabla U(\mathbf{x}) = 0$$

$$\nabla U(\mathbf{x})^{\mathsf{T}} \mathbf{D}(\mathbf{x}) \nabla U(\mathbf{x}) - \nabla U(\mathbf{x})^{\mathsf{T}}\mathbf{D}(\mathbf{x})\nabla U(\mathbf{x}) + \mathbf{v}_{\mathrm{curl}}(\mathbf{x})^{\mathsf{T}}\nabla U(\mathbf{x}) = 0$$

$$\nabla U(\mathbf{x}) \cdot \mathbf{v}_{\mathrm{curl}}(\mathbf{x}) = 0$$

This proves that the non-equilibrium curl flux is strictly orthogonal to the quasi-potential gradient across all points in phase space. The curl velocity $\mathbf{v}_{\mathrm{curl}}(\mathbf{x})$ circulates along constant-potential contours ($dU / dt = \nabla U \cdot \mathbf{v}_{\mathrm{curl}} = 0$), sustaining directed cyclic motion without altering quasi-potential energy.


## A.7 Explicit Derivation of the Stationary Entropy Production Trace Formula from Fokker-Planck Probability Currents

Following the stochastic thermodynamics of non-equilibrium stationary states (Schnakenberg 1976, Tomita and Tomita 1974, Tomé 2006, Seifert 2012, Zhang et al. 2012), this section derives the exact stationary entropy production trace formula:

$$\sigma = k_{\mathrm{B}} \operatorname{tr}\left( \boldsymbol{\Omega}^{\mathsf{T}} \mathbf{C}^{-1} \boldsymbol{\Omega} \mathbf{D}^{-1} \right)$$

resolving all intermediate steps from the continuous probability flux $\mathbf{J}_{\mathrm{prob}}(\mathbf{x}) = \mathbf{M}\mathbf{x} P_{\mathrm{ss}}(\mathbf{x})$.

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
- **Strict Non-Negativity:** Since $\mathbf{D} \succ 0 \implies \mathbf{D}^{-1} \succ 0$ and $\mathbf{C} \succ 0 \implies \mathbf{C}^{-1} \succ 0$, the matrix $\mathbf{K} = \boldsymbol{\Omega}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega} \succeq 0$ is positive semidefinite. The trace product of two positive semidefinite matrices is non-negative: $\sigma \ge 0$ unconditionally, satisfying the Second Law.
- **Detailed Balance Equivalence:** $\sigma = 0$ if and only if $\boldsymbol{\Omega} = \mathbf{0}$. Detailed balance holds if and only if probability circulation vanishes. In any living food web with trophic cycling, $\boldsymbol{\Omega} \ne \mathbf{0}$ and $\sigma > 0$.
- **Coordinate Invariance:** Under any linear transformation $\mathbf{x}_{\mathrm{new}} = \mathbf{M}_{\mathrm{coord}}\mathbf{x}_{\mathrm{old}}$, tensorial substitution confirms $\sigma_{\mathrm{new}} = \sigma_{\mathrm{old}}$, proving that $\sigma$ is an exact physical scalar invariant.


\newpage

# Appendix B: Biomass Normalization, Empirical Food-Web Data, and Coordinate Geometry

## B.1 Dimensional Derivation of Biomass Capacitance

Let an ecological compartment contain standing biomass $B_i^*$ (in $\mathrm{g\,C}$ or wet biovolume $\mathrm{cm}^3$). In chemical thermodynamics, the chemical potential of a dilute biological constituent is $\mu_i = \mu_i^0 + R_{\mathrm{gas}}T \ln(x_i / x_0)$. Differentiating with respect to extensive state $x_i$ yields the local entropic curvature:

$$H_{ii} = \frac{1}{T}\frac{\partial \mu_i}{\partial x_i} = \frac{R_{\mathrm{gas}}}{x_i^*}$$

In an ecological compartment, stored biomass $B_i^*$ acts as the physical capacitance container. Defining relative departures $\delta\tilde{x}_i = \delta B_i / B_i^*$ non-dimensionalizes the state coordinates by standing crop.

Total ecosystem Resistance represents the physical capacity to absorb an external thermodynamic force perturbation $\Delta\mathbf{X}$:

$$\delta\mathbf{x} = \mathbf{H}^{-1}\Delta\mathbf{X} = \frac{1}{k_{\mathrm{B}}}\mathbf{C}\Delta\mathbf{X}$$

Because $\mathbf{C} \propto \operatorname{Diag}(\mathbf{B}^*)$, state displacement $\delta\mathbf{x}$ scales inversely with total biomass: a massive standing stock ($B_{\text{tot}}$) minimizes relative displacement, providing high entropic Resistance.

Total ecosystem Resilience is the aggregate mass-specific dissipation rate:

$$\mathcal{R} = \frac{\sum_i R_i}{\sum_i B_i^*} \quad (\mathrm{yr}^{-1})$$

representing the mean eigenvalue return rate to the stationary attractor.

## B.2 Mathematical Formulations and Flow Matrices for Empirical Case Studies

### B.2.1 Cone Spring Empirical Flow Matrix and Lyapunov Decomposition

The biomass-normalized Onsager framework is applied to the classic five-compartment energy budget of Cone Spring (Tilly 1968, Patten 1978, Ulanowicz 1986). The compartments comprise: Plants ($x_1$), Detritus ($x_2$), Bacteria ($x_3$), Detritivores ($x_4$), and Carnivores ($x_5$). Table \ref{tbl:app_cone_full} summarizes the published flows.

| Compartment ($i$) | $B_i^*$ ($\mathrm{kcal\,m^{-2}}$) | Inflow $z_i$ | Plants ($T_{1\to i}$) | Detritus ($T_{2\to i}$) | Bacteria ($T_{3\to i}$) | Detritivores ($T_{4\to i}$) | Carnivores ($T_{5\to i}$) | Exports $E_i$ | Respiration $R_i$ | Throughflow $T_i$ |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1. Plants** | $285.0$ | $11\,184$ | $0$ | $0$ | $0$ | $0$ | $0$ | $300$ | $2\,003$ | $11\,184$ |
| **2. Detritus** | $3\,580.0$ | $635$ | $8\,881$ | $0$ | $1\,600$ | $200$ | $167$ | $860$ | $3\,109$ | $11\,483$ |
| **3. Bacteria** | $116.6$ | $0$ | $0$ | $5\,205$ | $0$ | $0$ | $0$ | $255$ | $3\,275$ | $5\,205$ |
| **4. Detritivores** | $60.0$ | $0$ | $0$ | $2\,309$ | $75$ | $0$ | $0$ | $0$ | $1\,814$ | $2\,384$ |
| **5. Carnivores** | $17.0$ | $0$ | $0$ | $0$ | $0$ | $370$ | $0$ | $0$ | $203$ | $370$ |

Table: Complete steady-state energy flow matrix for Cone Spring ($\mathrm{kcal\,m^{-2}\,yr^{-1}}$). {#tbl:app_cone_full}

For the living heterotrophic subsystem (Bacteria, Detritivores, Carnivores), the demographic community matrix is:

$$\mathbf{A}_{\mathrm{CS}} = \begin{bmatrix} -2.8087 & -1.2500 & 0 \\ 0.1538 & -3.0233 & -21.7647 \\ 0 & 2.7833 & -1.1941 \end{bmatrix}\ \mathrm{yr^{-1}}$$

The eigenvalues are $\lambda_1 = -2.8036\ \mathrm{yr^{-1}}$ and a complex pair $\lambda_{2,3} = -2.1113 \pm 7.7414i\ \mathrm{yr^{-1}}$ ($T = 296\ \mathrm{days}$).

Naive attempts to multiply $-\mathbf{A}_{\mathrm{CS}}$ by diagonal biomass yield an indefinite symmetric part ($\lambda_{\min} = -29.16$), falsely implying a violation of the Second Law. In contrast, solving the continuous Lyapunov equation with diffusion $\mathbf{D}_{\mathrm{CS}} = s\operatorname{Diag}(R_i B_i^*)$ ($s = 0.10$) yields the strictly positive-definite stationary covariance matrix:

$$\mathbf{C}_{\mathrm{CS}} = \begin{bmatrix} 13\,629.90 & -77.16 & -69.10 \\ -77.16 & 3\,240.05 & 49.46 \\ -69.10 & 49.46 & 404.28 \end{bmatrix}\ (\mathrm{kcal\,m^{-2}})^2$$

and the skew-symmetric non-equilibrium circulation tensor:

$$\boldsymbol{\Omega}_{\mathrm{CS}} = \begin{bmatrix} 0 & -3\,833.33 & 132.26 \\ 3\,833.33 & 0 & -8\,959.08 \\ -132.26 & 8\,959.08 & 0 \end{bmatrix}\ (\mathrm{kcal\,m^{-2}})^2\,\mathrm{yr}^{-1}$$

The non-zero circulation entries directly capture the driven cyclic feeding flux: detritivores graze bacteria, and carnivores consume detritivores.

### B.2.2 BATS Upper Mixed Layer NPZD Model and Fluctuation Dynamics

To examine high-turnover marine ecosystems, a pelagic mixed layer is modeled via the four-pool nutrient-phytoplankton-zooplankton-detritus (NPZD) network (Fasham et al. 1990) and its extension to pelagic fish (NPZD-Fish).

The governing differential equations for $(N, P, Z, D)$ in $\mathrm{mmol\,N\,m^{-3}}$ are:

$$\frac{dN}{dt} = I - \frac{V_{\max} N}{k_s + N}P + \mu_d D$$

$$\frac{dP}{dt} = \frac{V_{\max} N}{k_s + N}P - \frac{g Z P^2}{k_p^2 + P^2} - m_p P$$

$$\frac{dZ}{dt} = \beta \frac{g Z P^2}{k_p^2 + P^2} - m_z Z^2$$

$$\frac{dD}{dt} = (1 - \beta)\frac{g Z P^2}{k_p^2 + P^2} + m_p P + m_z Z^2 - \mu_d D$$

Parameters: $V_{\max} = 1.5\ \mathrm{d^{-1}}$, $k_s = 0.5\ \mathrm{mmol\,N\,m^{-3}}$, $g = 1.0\ \mathrm{d^{-1}}$, $k_p = 0.5\ \mathrm{mmol\,N\,m^{-3}}$, assimilation $\beta = 0.70$, $m_p = 0.05\ \mathrm{d^{-1}}$, $m_z = 0.20\ (\mathrm{mmol\,N\,m^{-3}})^{-1}\mathrm{d^{-1}}$, $\mu_d = 0.05\ \mathrm{d^{-1}}$, and nutrient flux $I = 0.005\ \mathrm{mmol\,N\,m^{-3}\,d^{-1}}$.

Reference steady state: $(N^*, P^*, Z^*, D^*) = (0.1000, 0.1615, 0.1906, 0.2492)\ \mathrm{mmol\,N\,m^{-3}}$. In carbon units (Redfield $106\mathrm{C}:16\mathrm{N}$), plankton biomass is $B_{\text{tot}} = 0.02802\ \mathrm{g\,C\,m^{-3}}$.

Linearizing around the steady state yields the pelagic Jacobian:

$$\mathbf{A}_{\mathrm{NPZD}} = \begin{bmatrix} -73.05 & -36.52 & 0 & 18.26 \\ 73.05 & -18.26 & -91.31 & 0 \\ 0 & 36.52 & -36.52 & 0 \\ 0 & 18.26 & 36.52 & -27.39 \end{bmatrix}\ \mathrm{yr^{-1}}$$

Leading eigenvalues are $\lambda_{1,2} = -50.82 \pm 54.66i\ \mathrm{yr^{-1}}$, corresponding to an oscillation period $T = 42\ \mathrm{days}$, which is over twenty-four times faster than that of Cone Spring.

### B.2.3 BATS Exploited NPZD-Fish Model and Fishery Harvest Parameters

When pelagic fish ($F$) are coupled to zooplankton grazing ($Z + F \to (1+e_f)F + (1-e_f)D$), the system shifts along the Pareto frontier: total standing biomass expands ($B_{\text{tot}} \approx 0.15\ \mathrm{g\,C\,m^{-3}}$), specific turnover decreases ($\mathcal{R} \approx 18.7\ \mathrm{yr^{-1}}$), and the oscillation period lengthens ($T \approx 254\ \mathrm{days}$). The addition of apex predators increases entropic Resistance (shock absorption) at the cost of kinetic recovery speed.

Simulating industrial fishery harvest ($H = q E F$) demonstrates the destabilizing effect of biomass removal: harvesting drains the biomass capacitance ($B_{\text{tot}} \to 0$), flattens the entropic potential well ($\mathbf{H} \to 0$), and triggers variance explosion in zooplankton and phytoplankton.

## B.3 Coordinate Breakdown Under Simplex and Logarithmic Transformations (Aitchison 1986, Itô 1951)

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

## C.1 Discrete Chemical Master Equation and Van Kampen System-Size Expansion

In continuous-time discrete-state Markov jump processes, ecological population configurations within control volume element $V^\ddagger$ are represented by integer counts $\mathbf{x} = (N_1, \dots, N_n)^{\mathsf{T}} \in \mathbb{N}_0^n$. 

### Reaction Channels and Allometric Propensities
- **Size-Structured Predation Channel ($\alpha = (i, j)$ with $m_i > m_j$):**
  Predation reduces prey $j$ by $k_{ij} = \lceil m_i / (\epsilon m_j) \rceil$ individuals and increases predator $i$ by $+1$:
  $$\boldsymbol{\nu}_{ij} = -k_{ij}\mathbf{e}_j + 1\mathbf{e}_i$$
  with mass-action encounter propensity:
  $$a_{ij}(\mathbf{x}) = \frac{\gamma_{ij}}{V^\ddagger} m_i^{-0.25} N_i N_j$$
- **Unimolecular Respiration Decay Channel:**
  Metabolic maintenance drains compartment $i$ at rate $d_i(\mathbf{x}) = \mu_i m_i^{-0.25} N_i$ with stoichiometric vector $\boldsymbol{\nu}_i^{\mathrm{resp}} = -\mathbf{e}_i$.

### Multivariate Step Operator CME
Using discrete step operator $\mathbb{E}_k^{-m} f(N_k) = f(N_k - m)$, the Chemical Master Equation for size-structured predation is:

$$\frac{\partial P(\mathbf{x}, t)}{\partial t} = \sum_{i > j} \left( \mathbb{E}_i^{-1} \mathbb{E}_j^{+k_{ij}} - 1 \right) \left[ \left( \frac{\gamma_{ij}}{V^\ddagger} m_i^{-0.25} N_i N_j \right) P(\mathbf{x}, t) \right] + \sum_{i=1}^n \left( \mathbb{E}_i^{+1} - 1 \right) \left[ \left( \mu_i m_i^{-0.25} N_i \right) P(\mathbf{x}, t) \right]$$

### Asymptotic System-Size Expansion
Decomposing $\mathbf{x} = V^\ddagger \boldsymbol{\phi}(t) + \sqrt{V^\ddagger}\,\boldsymbol{\xi}$ and Taylor-expanding step operators $\mathbb{E}_k^{-\nu} = 1 - \frac{\nu}{\sqrt{V^\ddagger}}\frac{\partial}{\partial \xi_k} + \frac{\nu^2}{2 V^\ddagger}\frac{\partial^2}{\partial \xi_k^2} + \dots$ separates:
- **Macroscopic Order $\mathcal{O}((V^\ddagger)^0)$:** $\frac{d\boldsymbol{\phi}}{dt} = \mathbf{B}\mathbf{J}(\boldsymbol{\phi})$, yielding demographic Jacobian $\mathbf{A} = \mathbf{B}\left.\frac{\partial \mathbf{J}}{\partial \mathbf{x}}\right|_{\mathbf{x}^*}$.
- **Fluctuation Order $\mathcal{O}((V^\ddagger)^{-1/2})$:** Continuous Fokker-Planck equation for fluctuation density $P(\boldsymbol{\xi}, t)$ with drift $\mathbf{A}$ and noise diffusion $\mathbf{D} = \frac{1}{2}\mathbf{B}\operatorname{Diag}(\mathbf{J}^*)\mathbf{B}^{\mathsf{T}} \succeq 0$.

At stationarity, $P_{\mathrm{ss}}(\delta\mathbf{x}) \propto \exp(-U(\mathbf{x})) = \exp\left(-\frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\delta\mathbf{x}\right)$, where $\mathbf{C}$ satisfies $\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} + 2\mathbf{D} = \mathbf{0}$, and barrier escape rate scales as $\tau_{\mathrm{escape}} \propto \exp(\Delta U / D)$.

## C.2 Gillespie Stochastic Simulation Algorithm (SSA) and Quasi-Potential Reconstruction

The Gillespie Direct SSA simulates exact realizations of the Chemical Master Equation (Gillespie 1977). Reaction channels and propensities directly evaluate allometric encounter rates $a_{ij}(\mathbf{n})$ and respiration losses $d_i(\mathbf{n})$.

Algorithm protocol:
- **Initialization:** Set $t = 0$ and discrete integer population count $\mathbf{n} = \mathbf{n}_0$.
- **Propensity Evaluation:** For each channel $r \in \{1, \dots, R\}$, evaluate $w_r(\mathbf{n})$; compute total propensity $w_0(\mathbf{n}) = \sum_r w_r(\mathbf{n})$.
- **Time Step Sampling:** Draw $u_1 \sim \mathcal{U}(0, 1)$ and sample next event interval:
  $$\tau = \frac{1}{w_0(\mathbf{n})}\ln\left( \frac{1}{u_1} \right)$$
- **Channel Selection:** Draw $u_2 \sim \mathcal{U}(0, 1)$ and select channel $\mu$ satisfying $\sum_{r=1}^{\mu-1} w_r(\mathbf{n}) < u_2 w_0(\mathbf{n}) \le \sum_{r=1}^\mu w_r(\mathbf{n})$.
- **State Update:** Advance $t \leftarrow t + \tau$ and $\mathbf{n} \leftarrow \mathbf{n} + \boldsymbol{\nu}_\mu$. Repeat until $t \ge t_{\max}$.

Stationary probability density $\widehat{P}_{\mathrm{ss}}(\mathbf{x})$ is reconstructed via multivariate Gaussian kernel estimation, yielding the empirical quasi-potential $\widehat{U}(\mathbf{x}) = -\frac{1}{\mathcal{V}}\ln \widehat{P}_{\mathrm{ss}}(\mathbf{x})$ and curl velocity field $\mathbf{v}_{\mathrm{circ}}(\mathbf{x})$ (Fig. \ref{fig_cone_spring_gillespie}).

![Discrete stochastic Chemical Master Equation jump trajectories and quasi-potential landscape for the Cone Spring ecosystem. Continuous-time Gillespie Stochastic Simulation Algorithm (SSA) runs for integer species counts across trophic compartments, illustrating finite-particle demographic fluctuations, stationary probability distribution, and non-equilibrium probability circulation in state space. \label{fig_cone_spring_gillespie}](media/cone-spring-gillespie-simulation.png){width=85%}

## C.3 Software Suite and Code Availability

All algorithms, models, and diagnostic estimators are implemented in the modular Julia package `OnsagerNetwork` located in `src/onsagernetwork.jl`, with unit tests in `test/runtests.jl` and driver scripts in `thermodynamics_onsager.jl`.

Key exported functions:
- `solve_lyapunov_covariance(A, D)`: Solves continuous Lyapunov equations using Bartels-Stewart Schur decomposition.
- `decompose_covariance_weighted_drift(A, C)`: Canonical decomposition into $\mathbf{D}_{\mathrm{sym}}$ and $\boldsymbol{\Omega}$.
- `cone_spring_network(; s=0.10)`: Generates biomass-normalized Cone Spring community and diffusion matrices.
- `npzd_diagnostics(params)`: Parameterizes and linearizes the pelagic NPZD model.
- `compute_size_spectrum_indices(params)`: Evaluates allometric biomass and metabolic dissipation distributions.
- `simulate_size_spectrum_filtering(params)`: Evaluates frequency transfer functions for the allometric canopy dissipation cascade.
- `run_gillespie_population(params)`: Executes exact continuous-time demographic jump simulations.

The codebase is open source and available at:  
`https://github.com/jae-choi/thermodynamics_onsager`.


\newpage


# Appendix D: Interdisciplinary Connections: Circuits, Information Geometry, Cybernetics, and Stochastic Thermodynamics

## D.1 Network Thermodynamics and Circuit Theory

The decomposition of asymmetric community matrices into symmetric dissipators and antisymmetric circulators is mathematically isomorphic to multiport electrical circuit theory (Tellegen 1952, Oster et al. 1971).

By Tellegen's (1952) theorem, for any network topology obeying Kirchhoff's laws, power is conserved across all branches: $\sum_k v_k(t) i_k(t) = 0$. In ecological networks, state deviations $\delta\mathbf{x}$ represent compartment storage displacements, and entropic affinities $\mathbf{X} = -\mathbf{H}\delta\mathbf{x}$ represent generalized voltages. Biomass pools act as generalized entropic capacitors: $C_i = B_i^* / k_{\mathrm{B}}$.

The symmetric part $\mathbf{D}_{\mathrm{sym}} = \frac{1}{2}(\mathbf{L} + \mathbf{L}^{\mathsf{T}})$ represents dissipative conductances ($G_{ij} = 1/R_{ij}$) governing irreversible entropy production: $\dot{S}_{\mathrm{diss}} = \mathbf{X}^{\mathsf{T}}\mathbf{D}_{\mathrm{sym}}\mathbf{X} \ge 0$.

The antisymmetric component $\boldsymbol{\Omega} = \frac{1}{2}(\mathbf{L} - \mathbf{L}^{\mathsf{T}})$ represents an array of ideal **Tellegen gyrators** (Tellegen 1952). A gyrator is a lossless non-reciprocal circuit element:

$$\begin{pmatrix} i_1 \\ i_2 \end{pmatrix} = \begin{pmatrix} 0 & g \\ -g & 0 \end{pmatrix} \begin{pmatrix} v_1 \\ v_2 \end{pmatrix}$$

Because $\boldsymbol{\Omega}$ is skew-symmetric, net instantaneous power dissipation is identically zero: $\mathbf{X}^{\mathsf{T}}\boldsymbol{\Omega}\mathbf{X} = 0$. Crucially, when a gyrator of gyration conductance $g$ is terminated by a capacitor $C$, the effective input impedance behaves as an ideal inductor of inductance:

$$L_{\mathrm{eq}} = \frac{C}{g^2}$$

This identity explains why ecosystems exhibit spontaneous oscillations, trophic waves, and limit cycles. Even though food webs contain no physical magnetic fields, the topological coupling between capacitive biomass storage ($C$) and antisymmetric trophic predation ($\boldsymbol{\Omega}$) synthesizes an **equivalent reactive inductance** ($L_{\mathrm{eq}}$). Trophic cycles behave as resonant $RLC$ circuits, storing energy alternatingly between predator and prey pools and sustaining limit cycles without external pacemakers.

### Standardized Coordinates: Downhill Sink Plus Perpendicular Rotation

To understand the geometric decomposition without confounding biomass units, state departures can be transformed into standardized coordinate units via the symmetric square-root capacitance matrix:

$$\delta\tilde{\mathbf{x}} = \mathbf{C}^{-1/2}\delta\mathbf{x}$$

In these standardized coordinates, the stationary fluctuation covariance becomes the identity matrix ($\widetilde{\mathbf{C}} = \mathbf{I}$), and the continuous Lyapunov equation reduces to:

$$\widetilde{\mathbf{A}} + \widetilde{\mathbf{A}}^{\mathsf{T}} = -2\widetilde{\mathbf{D}}$$

The standardized drift operator decomposes cleanly into an isotropic downhill dissipative sink plus a skew-symmetric perpendicular rotation:

$$\widetilde{\mathbf{A}} = -\widetilde{\mathbf{D}} - \widetilde{\boldsymbol{\Omega}}$$

where $\widetilde{\mathbf{D}} = \mathbf{C}^{-1/2}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1/2} \succ 0$ drives trajectories monotonically toward the origin, and $\widetilde{\boldsymbol{\Omega}} = \mathbf{C}^{-1/2}\boldsymbol{\Omega}\mathbf{C}^{-1/2} = -\widetilde{\boldsymbol{\Omega}}^{\mathsf{T}}$ rotates trajectories along surfaces of constant entropic curvature.

### The Canonical Two-Species Prototype Matrices

To see this concretely, consider a canonical two-species predator-prey prototype:

$$\mathbf{A} = \begin{pmatrix} -d_1 & -a_{12} \\ a_{21} & -d_2 \end{pmatrix}$$

where $a_{12} > 0$ is per-capita predation on prey, $a_{21} > 0$ is conversion into predator biomass, and $d_1, d_2 > 0$ are self-damping rates.

Let the standing biomasses be $B_1$ (prey) and $B_2$ (predator), with diagonal capacitance $\mathbf{C} = \operatorname{diag}(B_1, B_2)$. The covariance-weighted operator $-\mathbf{A}\mathbf{C}$ evaluates directly to:

$$-\mathbf{A}\mathbf{C} = \begin{pmatrix} d_1 B_1 & a_{12} B_2 \\ -a_{21} B_1 & d_2 B_2 \end{pmatrix}$$

Decomposing this into symmetric and antisymmetric components yields:

$$\mathbf{D}_{\mathrm{sym}} = \begin{pmatrix} d_1 B_1 & \frac{1}{2}(a_{12} B_2 - a_{21} B_1) \\ \frac{1}{2}(a_{12} B_2 - a_{21} B_1) & d_2 B_2 \end{pmatrix}$$

$$\boldsymbol{\Omega} = \begin{pmatrix} 0 & \frac{1}{2}(a_{12} B_2 + a_{21} B_1) \\ -\frac{1}{2}(a_{12} B_2 + a_{21} B_1) & 0 \end{pmatrix} = \begin{pmatrix} 0 & \omega \\ -\omega & 0 \end{pmatrix}$$

where $\omega = \frac{1}{2}(a_{12} B_2 + a_{21} B_1)$ represents the orbital trophic circulation frequency.

When trophic biomass transfer is conservative ($a_{12} B_2 = a_{21} B_1$), the off-diagonal dissipation vanishes, leaving pure diagonal metabolic damping and closed orbital circulation. Furthermore, the non-equilibrium stationary entropy production reduces from a matrix trace to the scalar ratio:

$$\sigma = k_{\mathrm{B}} \frac{\omega^2}{D_{\mathrm{eff}}}$$

where $D_{\mathrm{eff}} = \sqrt{d_1 d_2 B_1 B_2}$. Thermodynamic entropy production in a driven food web is simply the square of its trophic circulation frequency divided by its effective metabolic dissipation.


## D.2 Information Geometry and Helmholtz-Hodge Decomposition

Following Riemannian information geometry (Amari 1985, 2016), on the state space manifold $\mathcal{M} = \mathbb{R}_{> 0}^K$, the continuous Lyapunov covariance matrix defines a Riemannian Fisher information metric:

$$g_{ij}(\mathbf{x}) = [\mathbf{C}^{-1}]_{ij} = \frac{\partial^2 U(\mathbf{x})}{\partial x_i \partial x_j}$$

Under this metric, any smooth dynamical vector field $\mathbf{f}(\mathbf{x})$ decomposes uniquely into orthogonal potential and solenoidal (curl) components (Helmholtz-Hodge theorem; Helmholtz 1858, Hodge 1941, Amari 1985):

$$\mathbf{f}(\mathbf{x}) = -\mathbf{D}(\mathbf{x})\nabla U(\mathbf{x}) + \mathbf{v}_{\mathrm{curl}}(\mathbf{x}), \qquad \nabla U(\mathbf{x}) \cdot \mathbf{v}_{\mathrm{curl}}(\mathbf{x}) = 0$$

MacArthur's (1970) variational principle succeeded for pure competition precisely because symmetric resource competition generates an exact potential gradient system where $\mathbf{v}_{\mathrm{curl}} \equiv \mathbf{0}$. In contrast, trophic interactions introduce directional non-equilibrium circulation, $\mathbf{v}_{\mathrm{curl}} \ne \mathbf{0}$, which drives perpetual probability currents along closed loops.

## D.3 Cybernetic Feedback Control and the Conservation of Sensitivity (Bode Integral)

The Resistance-Resilience Pareto frontier ($B_{\mathrm{tot}} \times \mathcal{R} \approx \text{const}$) can be derived from the fundamental laws of feedback control theory (Bode 1945).

In control engineering, the sensitivity function $S(i\omega) = [1 + L_{\mathrm{loop}}(i\omega)]^{-1}$ measures disturbance attenuation across frequency $\omega$. Bode's (1945) Sensitivity Integral theorem dictates that for any open-loop stable feedback system:

$$\int_0^\infty \ln |S(i\omega)|\,d\omega = 0$$

This conservation law, known as the waterbed effect, proves that sensitivity cannot be reduced universally across all frequencies:

$$\int_0^{\omega_{\mathrm{c}}} |\ln |S(i\omega)|\|\,d\omega = \int_{\omega_{\mathrm{c}}}^\infty \ln |S(i\omega)|\,d\omega$$

In ecological networks:
- **Resistance ($B_{\mathrm{tot}}$):** Massive biomass pools act as low-pass filters, suppressing low-frequency environmental variance ($|S(i\omega)| \to 0$ as $\omega \to 0$).
- **Resilience ($\mathcal{R}$):** Asymptotic return rate $\mathcal{R} = |\operatorname{Re}(\lambda_{\max})|$ governs how rapidly high-frequency perturbations decay.

Because the total integral of $\ln |S(i\omega)|$ is strictly conserved by network topology, an ecosystem cannot simultaneously maximize low-frequency disturbance rejection ($B_{\mathrm{tot}} \to \infty$) and broadband transient recovery ($\mathcal{R} \to \infty$). The hyperbolic trade-off $B_{\mathrm{tot}} \times \mathcal{R} \approx \text{const}$ is the ecological manifestation of the Bode sensitivity integral.

## D.4 Stochastic Thermodynamics and the Thermodynamic Uncertainty Relation

The connection between dissipation and ecological precision is formalized by stochastic thermodynamics through the Thermodynamic Uncertainty Relation (TUR) (Barato and Seifert 2015, Gingrich et al. 2016).

Let $J$ denote an empirical steady-state net current integrated over time interval $\tau$, and let $\operatorname{Var}(J)$ denote its fluctuation variance. The TUR proves that the precision of any non-equilibrium current is bounded from below by the total entropy production rate $\sigma$:

$$\frac{\operatorname{Var}(J)}{\langle J \rangle^2} \ge \frac{2 k_{\mathrm{B}}}{\sigma \tau}$$

This inequality has profound ecological implications:
- **Cost of Precision:** High ecological fidelity, meaning low relative variance $\operatorname{Var}(J)/\langle J \rangle^2$ in nutrient and biomass currents, requires high thermodynamic entropy production $\sigma$.
- **Thermodynamic Impossibility of Frictionless Stability:** An ecosystem cannot achieve both noiseless metabolic throughput ($\operatorname{Var}(J) \to 0$) and near-zero dissipation ($\sigma \to 0$).
- **Evolutionary Selection for Dissipation:** Natural selection for reliable, homeostatic physiological and ecological rates operates under a physical constraint: reducing current fluctuations incurs an unavoidable metabolic entropy cost.


# References

Aitchison, J. (1986). *The Statistical Analysis of Compositional Data*. Chapman and Hall, London.

Amari, S. (1985). *Differential-Geometrical Methods in Statistics*. Lecture Notes in Statistics, Vol. 28. Springer-Verlag, New York.

Amari, S. (2016). *Information Geometry and Its Applications*. Applied Mathematical Sciences, Vol. 194. Springer, Tokyo.

Aoki, I. (1989). Entropy flow and entropy production in the human body in basal conditions. *Journal of Theoretical Biology*, 141, pp.11-21.

Aoki, I. (1993). Inclusive Kullback index - a macroscopic measure in ecological systems. *Ecological Modelling*, 66, pp.289-299.

Aoki, I. (1995). Entropy production in living systems: from organisms to ecosystems. *Thermochimica Acta*, 250, pp.359-370.

Ao, P. (2004). Potential in stochastic differential equations: novel construction. *Journal of Physics A: Mathematical and General*, 37(3), pp.L25-L30.

Babloyantz, A. (1986). *Molecules, Dynamics and Life: An Introduction to Self-Organization of Matter*. Wiley-Interscience, Toronto.

Barato, A. C. and Seifert, U. (2015). Thermodynamic uncertainty relation for biomolecular processes. *Physical Review Letters*, 114(15), p.158101.

Bertalanffy, L. von. (1950). The theory of open systems in physics and biology. *Science*, 111, pp.23-29.

Bode, H. W. (1945). *Network Analysis and Feedback Amplifier Design*. D. Van Nostrand Company, New York.

Boltzmann, L. (1877). Über die Beziehung zwischen dem zweiten Hauptsatze der mechanischen Wärmetheorie und der Wahrscheinlichkeitsrechnung respektive den Sätzen über das Wärmegleichgewicht. *Wiener Berichte*, 76, pp.373-435.

Boyd, S. and Vandenberghe, L. (2004). *Convex Optimization*. Cambridge University Press, Cambridge.

Braun, F. (1887). De l'elasticite et de la compressibilite des solutions salines. *Annales de Chimie et de Physique*, 12, pp. 145-168.

Byers, R. E. and Hansell, R. I. (1996). Attack-decay dynamics in systems of interacting populations. *Journal of Theoretical Biology*, 180(3), pp.211-226.

Callen, H. B. (1985). *Thermodynamics and an Introduction to Thermostatistics*. 2nd ed. John Wiley & Sons, New York.

Casimir, H. B. G. (1945). On Onsager's principle of microscopic reversibility. *Reviews of Modern Physics*, 17(2-3), pp.343-350.

Chakrabarti, C. G. and Ghosh, K. (2009). Non-equilibrium thermodynamics of ecosystems: Entropic analysis of stability and diversity. *Ecological Modelling*, 220(16), pp.1950-1956.

Choi, J. S. and Patten, B. C. (2001). Sustainable development: Lessons from the thermodynamic evolution of ecosystems. *Ecology and Society*, 5(2), p.14.

Choi, J. S., Frank, K. T., Leggett, W. C. and Drinkwater, K. (2004). Transition to an alternate state in a continental shelf ecosystem. *Nature*, 430(6996), pp.211-215.

Choi, J. S., Mazumder, A. and Hansell, R. I. C. (1999). Measuring perturbation in ecosystems: an intensive thermodynamic approach. *Ecosystems*, 2(5), pp.416-430.

Crooks, G. E. (1999). Entropy production fluctuation theorem and the nonequilibrium work relation for free energy differences. *Physical Review E*, 60(3), pp.2721-2726.

de Groot, S. R. and Mazur, P. (1962). *Non-Equilibrium Thermodynamics*. North-Holland Publishing Company, Amsterdam.

de Ruiter, P. C., Neutel, A. M. and Moore, J. C. (1995). Energetics, patterns of interaction strengths, and stability in real ecosystems. *Science*, 269(5228), pp.1257-1260.

Dewar, R. C. (2003). Information theory explanation of the fluctuation theorem, maximum entropy production and self-organized criticality in non-equilibrium stationary states. *Journal of Physics A: Mathematical and General*, 36(3), pp. 631-641.

Eigen, M. and Schuster, P. (1979). *The Hypercycle: A Principle of Natural Self-Organization*. Springer-Verlag, Berlin.

Einstein, A. (1910). Theorie der Opaleszenz von homogenen Flussigkeiten und Flussigkeitsgemischen in der Nahe des kritischen Zustandes. *Annalen der Physik*, 338(16), pp. 1275-1298.

England, J. L. (2013). Statistical physics of self-replication. *The Journal of Chemical Physics*, 139(12), p.121923.

Estes, J. A., Tinker, M. T., Williams, T. M. and Doak, D. F. (1998). Killer whale predation on sea otters linking oceanic and nearshore ecosystems. *Science*, 282(5388), pp.473-476.

Eyink, G. L. (1990). Dissipation and large fluctuations in nonequilibrium thermodynamics. *Journal of Statistical Physics*, 61(3-4), pp. 533-572.

Fasham, M. J. R., Ducklow, H. W. and McKelvie, S. M. (1990). A nitrogen-based model of plankton dynamics in the oceanic mixed layer. *Journal of Marine Research*, 48(3), pp.591-639.

Fath, B. D., Patten, B. C. and Choi, J. S. (2001). Complementarity of ecological goal functions. *Journal of Theoretical Biology*, 208(4), pp.493-506.

Freidlin, M. I. and Wentzell, A. D. (1984). *Random Perturbations of Dynamical Systems*. Springer-Verlag, New York.

Freudenberg, J. S. and Looze, D. P. (1985). Right half plane poles and zeros and design limitations in feedback systems. *IEEE Transactions on Automatic Control*, 30(6), pp. 555-565.

Gillespie, D. T. (1977). Exact stochastic simulation of coupled chemical reactions. *The Journal of Physical Chemistry*, 81(25), pp.2340-2361.

Gillespie, D. T. (1992). A rigorous derivation of the chemical master equation. *Physica A: Statistical Mechanics and its Applications*, 188(1-3), pp.404-425.

Gingrich, T. R., Horowitz, J. M., Perunov, N. and England, J. L. (2016). Dissipation bounds all steady-state current fluctuations. *Physical Review Letters*, 116(12), p.120601.

Glansdorff, P. and Prigogine, I. (1971). *Thermodynamic Theory of Structure, Stability and Fluctuations*. Wiley-Interscience, London.

Graham, R. (1977). Path integral formulation of general diffusion processes. *Zeitschrift für Physik B Condensed Matter*, 26(3), pp.281-290.

Grebogi, C., Ott, E. and Yorke, J. A. (1983). Crises, sudden changes in chaotic attractors, and transient chaos. *Physica D: Nonlinear Phenomena*, 7(1-3), pp.181-200.

Haken, H. (1983). *Synergetics: An Introduction. Nonequilibrium Phase Transitions and Self-Organization in Physics, Chemistry, and Biology*. Springer-Verlag, Berlin.

Hastings, A. and Powell, T. (1991). Chaos in a three-species food chain. *Ecology*, 72(3), pp.896-903.

Helmholtz, H. von. (1858). Uber Integrale der hydrodynamischen Gleichungen, welche den Wirbelbewegungen entsprechen. *Journal fur die reine und angewandte Mathematik*, 55, pp. 25-55.

Hodge, W. V. D. (1941). *The Theory and Applications of Harmonic Integrals*. Cambridge University Press, Cambridge.

Horn, R. A. and Johnson, C. R. (2012). *Matrix Analysis*. 2nd ed. Cambridge University Press, Cambridge.

Johnson, L. (1981). The thermodynamic origin of ecosystems. *Canadian Journal of Fisheries and Aquatic Sciences*, 38(5), pp.571-590.

Kerr, S. R. and Dickie, L. M. (2001). *The Biomass Spectrum: A Predator-Prey Theory of Aquatic Production*. Columbia University Press, New York.

Kleiber, M. (1947). Body size and metabolic rate. *Physiological Reviews*, 27(4), pp.511-541.

Kuznetsov, Y. A. (1998). *Elements of Applied Bifurcation Theory*. 2nd ed. Springer-Verlag, New York.

Landi, G. T. and Paternostro, M. (2021). Irreversible entropy production, from quantum to classical. *Reviews of Modern Physics*, 93(3), p.035008.

Lax, M. (1960). Fluctuations from the nonequilibrium steady state. *Reviews of Modern Physics*, 32(1), pp. 25-64.

Le Chatelier, H. (1884). Sur un Гриnоnce general des lois des equilibres chimiques. *Comptes Rendus de l'Academie des Sciences*, 99, pp. 786-789.

Lindeman, R. L. (1942). The trophic-dynamic aspect of ecology. *Ecology*, 23(4), pp.399-417.

Lotka, A. J. (1922). Contribution to the energetics of evolution. *Proceedings of the National Academy of Sciences*, 8(6), pp.147-151.

Lyapunov, A. M. (1892). *The General Problem of the Motion's Stability*. Kharkov Mathematical Society, Kharkov. (English translation: *International Journal of Control*, 1992, 55(3), pp. 531-773).

MacArthur, R. (1970). Species packing and competitive equilibrium for many species. *Theoretical Population Biology*, 1(1), pp.1-11.

May, R. M. (1972). Will a large complex system be stable? *Nature*, 238(5364), pp.413-414.

May, R. M. (1974). Biological populations with nonoverlapping generations: stable points, stable cycles, and chaos. *Science*, 186(4164), pp.645-647.

McCann, K. and Yodzis, P. (1994). Nonlinear dynamics and amoebic persistence. *The American Naturalist*, 144(6), pp.873-879.

Meysman, F. J. R. and Bruers, S. (2010). Ecosystem functioning and maximum entropy production: a quantitative test of hypotheses. *Philosophical Transactions of the Royal Society B: Biological Sciences*, 365(1545), pp.1405-1416.

Michaelian, K. (2005). Thermodynamic stability of ecosystems. *Journal of Theoretical Biology*, 237(3), pp.323-335.

Mikulecky, D. C. (1985). Network thermodynamics in biology and medicine. *American Journal of Physiology*, 249(3), pp.R317-R330.

Nicolis, G. and Prigogine, I. (1977). *Self-Organization in Nonequilibrium Systems: From Dissipative Structures to Order through Fluctuations*. John Wiley & Sons, New York.

Odum, E. P. (1969). The strategy of ecosystem development. *Science*, 164(3877), pp.262-270.

Odum, H. T. and Pinkerton, R. C. (1955). Time's speed regulator: the optimum efficiency for maximum power output in physical and biological systems. *American Scientist*, 43(2), pp.331-343.

Onsager, L. (1931a). Reciprocal relations in irreversible processes. I. *Physical Review*, 37(4), pp.405-426.

Onsager, L. (1931b). Reciprocal relations in irreversible processes. II. *Physical Review*, 38(12), pp.2265-2279.

Onsager, L. and Machlup, S. (1953). Fluctuations and irreversible processes. *Physical Review*, 91(6), pp. 1505-1512.

Oster, G. F., Perelson, A. S. and Katchalsky, A. (1971). Network thermodynamics. *Nature*, 234(5329), pp.393-399.

Patten, B. C. (1978). Systems approach to the concept of environment. *The Ohio Journal of Science*, 78(4), pp.206-222.

Prigogine, I. (1955). *Introduction to Thermodynamics of Irreversible Processes*. Charles C Thomas, Springfield.

Prigogine, I. (1967). *Introduction to Thermodynamics of Irreversible Processes*. 3rd ed. Interscience Publishers, New York.

Prigogine, I. and Defay, R. (1954). *Chemical Thermodynamics*. Longmans Green and Co., London.

Prigogine, I., Nicolis, G. and Babloyantz, A. (1972). Thermodynamics of evolution. *Physics Today*, 25(11), pp.23-28.

Qian, H. (2001). Mesoscopic biochemical basis of entropy production and the detailed balance. *Physical Review E*, 65(1), p.012101.

Scheffer, M., Carpenter, S., Foley, J. A., Folke, C. and Walker, B. (2001). Catastrophic shifts in ecosystems. *Nature*, 413(6856), pp.591-596.

Schnakenberg, J. (1976). Network theory of microscopic and macroscopic behavior of master equation systems. *Reviews of Modern Physics*, 48(4), pp. 571-585.

Schneider, E. D. and Kay, J. J. (1994). Life as a manifestation of the second law of thermodynamics. *Mathematical and Computer Modelling*, 19(6-8), pp.25-48.

Schneider, E. D. and Sagan, D. (2005). *Into the Cool: Energy Flow, Thermodynamics, and Life*. University of Chicago Press, Chicago.

Schrödinger, E. (1944). *What is Life? The Physical Aspect of the Living Cell*. Cambridge University Press, Cambridge.

Seifert, U. (2012). Stochastic thermodynamics, fluctuation theorems and molecular machines. *Reports on Progress in Physics*, 75(12), p.126001.

Sheldon, R. W., Prakash, A. and Sutcliffe, W. H. (1972). The size distribution of particles in the ocean. *Limnology and Oceanography*, 17(3), pp.327-340.

Shiner, J. S. and Sieniutycz, S. (1994). Non-equilibrium thermodynamics of evolution and self-organization. *Journal of Non-Equilibrium Thermodynamics*, 19(4), pp.303-322.

Strogatz, S. H. (2018). *Nonlinear Dynamics and Chaos: With Applications to Physics, Biology, Chemistry, and Engineering*. 2nd ed. CRC Press, Boca Raton.

Tellegen, B. D. H. (1952). A general network theorem, with applications. *Philips Research Reports*, 7(4), pp.259-269.

Tilly, L. J. (1968). The structure and dynamics of Cone Spring. *Ecological Monographs*, 38(2), pp.169-197.

Tome, T. (2006). Entropy production in nonequilibrium steady states: A Fokker-Planck study. *Brazilian Journal of Physics*, 36(4A), pp. 1285-1289.

Tomita, K. and Tomita, H. (1974). A new expansion method for Brownian motion of solvable nonlinear systems. *Progress of Theoretical Physics*, 51(5), pp.1402-1427.

Ulanowicz, R. E. (1986). *Growth and Development: Ecosystems Phenomenology*. Springer-Verlag, New York.

Ulanowicz, R. E. and Hannon, B. M. (1987). Input-output reciprocal interactions in ecosystems. *Journal of Theoretical Biology*, 127(3), pp.303-318.

van Kampen, N. G. (1992). *Stochastic Processes in Physics and Chemistry*. North-Holland, Amsterdam.

West, G. B., Brown, J. H. and Enquist, B. J. (1997). A general model for the origin of allometric scaling laws in biology. *Science*, 276(5309), pp. 122-126.

Wicken, J. S. (1980). A thermodynamic theory of evolution. *Journal of Theoretical Biology*, 87(1), pp.9-23.

Wiesenfeld, K. and Moss, F. (1995). Stochastic resonance and the benefits of noise: from ice ages to crayfish and SQUIDs. *Nature*, 373(6509), pp. 33-36.

Willems, J. C. (1972). Dissipative dynamical systems part I: General theory. *Archive for Rational Mechanics and Analysis*, 45(5), pp. 321-351.

Yodzis, P. (1981). The stability of real ecosystems. *Nature*, 289(5799), pp.674-676.

Yodzis, P. (1988). *Introduction to Theoretical Ecology*. Harper & Row, New York.

Zhang, X.-J., Qian, H. and Qian, M. (2012). Stochastic theory of nonequilibrium steady states and its applications: A network perspective. *Physics Reports*, 518(1-2), pp. 1-70.

Ziegler, H. (1983). *An Introduction to Thermomechanics*. 2nd ed. North-Holland Publishing Company, Amsterdam.

Kolmogorov, A. N. (1941). The local structure of turbulence in incompressible viscous fluid for very large Reynolds numbers. *Doklady Akademii Nauk SSSR*, 30, pp. 301-305.

Spitz, Y. H., Moisan, J. R., and Abbott, M. R. (2001). Configuring an ecosystem model using data from the Bermuda Atlantic Time-series Study (BATS). *Deep Sea Research Part II: Topical Studies in Oceanography*, 48(8-9), pp. 1733-1768.

Steinberg, D. K., Carlson, C. A., Bates, N. R., Johnson, R. J., Michaels, A. F., and Knap, A. H. (2001). Overview of the US JGOFS Bermuda Atlantic Time-series Study (BATS): a decade-scale look at ocean biology and biogeochemistry. *Deep Sea Research Part II: Topical Studies in Oceanography*, 48(8-9), pp. 1405-1447.

Zheng, Y., Pasquero, C., and Schartau, M. (2024). Multi-decadal biogeochemical dynamics and planktonic turnover at the Bermuda Atlantic Time-series Study site. *Global Biogeochemical Cycles*, 38(2), e2023GB007890.

