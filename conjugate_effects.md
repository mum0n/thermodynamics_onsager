---

title: "Conjugates in Ecology"

header: "Choi & Hansell (2026): Conjugates in Ecology"

date: '\today'

journal: 'biorxiv'

author:

- name: Jae S. Choi

  footnote: 1

  corresponding: true

  email: choi.jae.seok@gmail.com

  orcid: 0000-0003-3632-5723

- name: Roger I. C. Hansell

  footnote: 2

  email: roger.hansell@utoronto.ca

affiliation:

- number: 1

  name: Bedford Institute of Oceanography, Fisheries and Oceans Canada, Dartmouth, Nova Scotia, Canada

- number: 2

  name: Department of Ecology and Evolutionary Biology, University of Toronto, Toronto, Ontario, Canada

keyword: |
  Keywords: Order, Disorder, Entropy, Non-Equilibrium Thermodynamics, Onsager Reciprocal Relations, Le Chatelier-Braun Principle, Conjugate Effects, Community Matrix, Phenomenological Conductivity, Fluctuation-Dissipation, Probability Circulation, Detailed Balance, Energy Dissipation Cascade, Biomass Capacitance, Biomass Size Spectrum, Resistance, Resilience, Spatiotemporal Hierarchy, Adaptive Capacity, Early Warning Signals

abstract: |

  Thermodynamics rests on two complementary representations: a macroscopic phenomenological
  description of bulk state variables and irreversible entropy production, and a microscopic
  statistical-mechanical description of configurational order and fluctuations. These
  representations converge in molecular systems, but reconciling them in ecology has remained
  challenging. Ecosystems span multiple spatial and temporal scales across porous boundaries,
  and demographic community matrices are asymmetric due to directional predation and body-size
  disparities—an asymmetry long thought to violate Onsager's reciprocal relations
  ($\mathbf{L} = \mathbf{L}^{\mathsf{T}}$).

  Here, we connect microscopic demographic fluctuations to macroscopic thermodynamic transport
  through Onsager's (1931a,b) reciprocal theory and the Le Chatelier-Braun principle. Through
  continuous Lyapunov covariance factorization, the demographic community matrix is shown not to
  be an unmediated Onsager conductivity, but a composite operator:
  $\mathbf{A} = -(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}$. This
  operator convolves a symmetric, positive-definite dissipative conductivity
  ($\mathbf{D}_{\mathrm{sym}} \succ 0$) governing irreversible entropy production, an
  antisymmetric circulation tensor ($\boldsymbol{\Omega} = -\boldsymbol{\Omega}^{\mathsf{T}}$)
  quantifying non-dissipative cyclic trophic flows, and standing biomass storage capacitance
  ($\mathbf{C} = k_{\mathrm{B}}\mathbf{H}^{-1}$).

  Coupled cross-pathway conductivities give rise to **conjugate effects** via the matrix Schur
  complement ($0 < L_{ii,\mathrm{eff}} \le L_{ii}$), whereby secondary pathway relaxation
  moderates primary perturbations across mutualistic, host-parasite, predator-prey, and
  biogeochemical networks. Formulated locally within intensive biological control volumes
  normalized by standing biomass rather than arbitrary spatial dimensions, the framework
  positions allometric scaling along a hyperbolic Resistance–Resilience trade-off continuum
  that balances standing biomass capacitance against mass-specific metabolic turnover. The
  realized homeostatic operating state represents a dynamic Le Chatelier-Braun balance.

  We test this framework empirically across contrasting biomes, extend it to continuous
  allometric size spectra, and connect it to multi-scale energy cascades and non-linear regime
  shifts. The empirical decomposition evaluates two canonical aquatic ecosystems: the
  detritus-buffered benthic cold-spring food web at Cone Spring and the solar-driven open-ocean
  plankton community at the Bermuda Atlantic Time-series Study (BATS) site in the Sargasso Sea.

  At Cone Spring, detrital biomass capacitance provides high entropic Resistance (shock
  absorption) and slow relaxation (oscillation period of 296 days) at a low stationary entropy
  production rate density (90.35 per year). At BATS, the upper mixed layer prioritizes kinetic
  Resilience (recovery turnover of approximately 40–42 days) over standing storage, operating at
  nearly triple the entropy production rate density (257.65 per year). Simulating industrial
  exploitation in an extended pelagic food web (NPZD-Fish) shows that harvesting long-lived
  predatory fish strips slow biomass capacitance, increasing probability circulation volatility
  and driving entropy production to 425.03 per year, which flattens the stationary potential
  basin and preconditions the ecosystem for regime collapse.

  Extending the framework to continuous allometric size spectra via the Sheldon distribution and
  Kleiber scaling links organismal body mass to multi-scale impedance filtering analogous to the
  Kolmogorov turbulence cascade: macroscopic organisms act as structural capacitors absorbing
  bulk environmental forcing, cross-scale trophic and mechanical couplings circulate energy
  across size octaves, and microscopic organisms act as high-turnover dissipative sinks. Formal
  coordinate-invariance proofs, non-linear Helmholtz-Hodge and Fokker-Planck derivations,
  compositional coordinate breakdowns, stochastic master-equation algorithms, and electrical
  network dualities are provided in Appendices A to D, accompanied by an open-source Julia
  software implementation.


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


# Introduction


An understanding of macroscopic thermodynamic states of matter was established by Carnot [-@Carnot_1824], Thomson (Lord Kelvin) [-@Thomson_1849], and Clausius [-@Clausius_1850], demonstrating that a small set of state variables (temperature, pressure, volume) were sufficient to characterize bulk physical behavior despite the systems being composed of a vast number of atoms and molecules. Non-statistical, axiomatic, and geometric formulations of the $2^{\text{nd}}$ law of thermodynamics subsequently provided rigorous metric foundations for thermodynamic entropy independent of thermal cycle heuristics [@Carathodory_1909; @LiebEtAl_1999]. In parallel, Boltzmann [-@Boltzmann_1877] and Gibbs [-@Gibbs_1902] developed a statistical-mechanical foundation based upon microscopic configuration counts, linking it to macroscopic entropy.

Owing to the success of their statistical mechanics in describing molecular and kinetic systems, macroscopic entropy and microscopic **disorder** are frequently conflated under the single term **entropy**. This conflation has caused considerable confusion; here, the term **(dis)order** is used specifically to refer to the microscopic notion of statistical, information-theoretic entropy, whereas **entropy** is reserved for macroscopic thermodynamic physical **entropy**, which quantifies the irreversible dissipation of energy during macroscopic processes.


From these foundational developments, a system is physically understood only when microscopic **disorder** and macroscopic **entropy** converge via Boltzmann's constant $k_{\mathrm{B}}$. In molecular systems, this correspondence is well-established. In living ecological systems, however, microscopic and macroscopic representations remain far from convergent. All ecological processes are equally subject to thermodynamic laws[^1]. Even the most basic attempts to account for or model matter and energy flows necessarily begin by invoking conservation of energy and matter, and as such, irreversible losses of energy from the system. Numerous attempts have been made to formalize this connection and draw law-like inferences from it, motivated by the possibility of reducing the large degrees of freedom required to describe ecological systems into a compact set of ecological "state" variables and characterizing the directionality of ecological dynamics. Because all ecological systems exhibit matter and energy cycling and boundary flows across multiple spatial and temporal scales, direct empirical accounting of *entropy* remains challenging [@Meysman_Bruers_2010].


Here, issues concerning the application of non-equilibrium thermodynamics to ecology are examined [@ChapmanEtAl_2016; @FathEtAl_2004; @Chakrabarti_Ghosh_2009; @Meysman_Bruers_2010; @YenEtAl_2014; @Choi_2019]. First, we examine how Onsager's [-@Onsager_1931a; -@Onsager_1931b] formulation connecting microscopic fluctuations to macroscopic phenomenological transport might be used to frame ecological questions. Furthermore, the **Le Chatelier-Braun principle**[^2] is shown to provide an equivalent and familiar framework for gauging how ecosystems respond to perturbations.

Then, building upon this foundation, we explore the empirical, multi-scale, and non-linear dimensions of this synthesis. **First**, the framework is evaluated empirically across contrasting aquatic biomes, comparing a benthic detritus-buffered cold spring (Cone Spring) with an open-ocean planktonic food web at the Bermuda Atlantic Time-series Study (BATS) site and an exploited marine pelagic fishery (NPZD-Fish). **Second**, the stability analysis is extended to continuous allometric size spectra by linking biomass capacitance and metabolic turnover to organismal body mass through Kleiber scaling and the Sheldon size spectrum. **Third**, a multi-scale energy cascade model analogous to Kolmogorov fluid turbulence is formulated to explain how macroscopic structural capacitors absorb bulk environmental forcing, cross-scale probability circulation transfers energy across size octaves, and microscopic organisms dissipate it into heat. **Fourth**, the linear theory is extended to non-linear Fokker-Planck quasi-potential landscapes, yielding physical early-warning diagnostics for catastrophic regime shifts. Formal coordinate-invariance proofs, non-linear phase-space derivations, compositional coordinate breakdowns, stochastic chemical master equations, and electrical circuit dualities are presented in Appendices A to D.


# Microscopic Order


Boltzmann [-@Boltzmann_1877] and Gibbs [-@Gibbs_1902] developed the statistical-mechanical foundation, linking macroscopic entropy $S$ to the multiplicity of accessible microscopic configurations $\Omega$ in phase space:


$$S = k_{\mathrm{B}} \ln \Omega$$


where $k_{\mathrm{B}}$ is Boltzmann's constant [@Planck_1901; @EhrenfestEtAl_1912]. In this framework, thermodynamic state is defined by a probability distribution over phase space, and the equilibrium macrostate corresponds to the distribution with maximum entropy, reflecting maximal microscopic uncertainty. All deviations from equilibrium are transient fluctuations around this statistical average, vanishing in the thermodynamic limit ($N \to \infty$).


The canonical illustration is an isolated volume containing $N$ identical gas molecules initially constrained to uniform positions, velocities, and momenta. In the $6N$-dimensional phase space (three spatial coordinates and three momentum components per molecule), this highly constrained configuration occupies a minimal volume ($\Omega \approx 1$), corresponding to low microscopic dispersion and an initial reference entropy. When external constraints are removed, intermolecular collisions irreversibly disperse particle trajectories across a rapidly expanding volume of accessible phase space. Free energy is converted into distributed kinetic motion and irreversible entropy generation, driving the system monotonically toward thermodynamic equilibrium, where potential energy is minimized, and entropy $S$ and phase-space volume $\Omega$ attain their global maximum.


Similarly, an internal combustion engine converts the chemical potential energy of fuel into dispersed gases, particulates, and heat, generating *entropy*. From a microscopic physical-chemical perspective, long-chain hydrocarbons with concentrated bond energies transition from a structured configuration to a disaggregated state with many more degrees of freedom, greater dispersion, and lower potential to perform useful work. In such isolated or closed systems, *order* $\rightarrow$ *disorder*.


Schrödinger [-@Schrdinger_1944] pointed out that biological systems seem to operate in a different manner than simple heat engines. The example he used was DNA, which he described as a curious "aperiodic crystal". He noted that hereditary material replicates itself with high fidelity, as mutation rates are much lower than would be expected from unconstrained thermal degradation in chemical reactions of similarly large molecules [@DrakeEtAl_1998]. Even in the absence of an explicit genetic and biochemical understanding of DNA structure [@WatsonEtAl_1953] and kinetic proofreading [@Hopfield_1974], he was able to deduce that it was this genetic fidelity that formed the basis for life: replication and fidelity.


This local stability is maintained by chemical activation energies and covalent bond stability, proofreading enzyme systems and repair proteins [@Hopfield_1974], and Darwinian selection (viability filter). Indeed, stable life cycles, developmental canalization [@Waddington_1942], phenotypic plasticity, ordered metabolic pathways such as the tricarboxylic acid (Krebs) cycle [@KrebsEtAl_1937], predator-prey interactions, host-parasite interactions, habitat-niche partitioning, animal migration patterns, and spatial species distributions all represent examples of *constrained* dynamical processes of *order $\rightarrow$ order*. These are the mainstay of biology and ecology: feedback cycles and their regulatory inter-relationships [@Levins_1968; @May_1973; @Yodzis_1981]. More generally, such open self-maintaining configurations are known as *dissipative structures* [@Prigogine_1967; @Glansdorff_Prigogine_1971; @GlansdorffEtAl_1974; @NicolisEtAl_1977]; they describe locally stable, *order $\rightarrow$ order* systems that maintain their internal structure and low local entropy at the cost of continuous free-energy degradation and entropy export to their surrounding environment. When the accounting boundary encompasses both the biological structure and its surrounding environment, the overall thermodynamic effect is *(local order $\leftrightarrow$ local order) $\rightarrow$ (global disorder)*, drawing high-grade free energy in and exporting entropy out. Physical and chemical analogues include turbulent energy cascades [@Richardson_1922; @Kolmogorov_1941], Rayleigh-Bénard convection cells [@Bnard_1900; @Rayleigh_1916], Belousov-Zhabotinsky oscillating chemical waves [@Belousov_1959; @Zhabotinsky_1964; @ZaikinEtAl_1970], and reaction-diffusion morphogenesis patterns [@Turing_1952; @Glansdorff_Prigogine_1971; @NicolisEtAl_1977]. Living systems, in the act of growth, maintenance, and reproduction, tap into external matter and energy flows to sustain local order [@Bertalanffy_1950; @ZotinEtAl_1967].


Schrödinger [-@Schrdinger_1944] also considered the steps required for the origin and diversification of life, from simple prebiotic compounds to autocatalytic matter-energy cycles [@Lotka_1922a; @Lotka_1922b] and eventually the evolution of template replication mechanisms involving RNA, DNA, proteins, and membrane compartmentalization in the presence of persistent free-energy gradients [@EigenEtAl_1979; @Wicken_1980]. Each structural step represents an increase in complexity (*order*); and each diversification of a functional role or niche represents an expansion in the number of potential functional states (which can be formally represented as an expansion in accessible macroscopic or network states). These evolutionary dynamics operate under the perpetual selective pressure of co-evolving competitors, predators, and pathogens, epitomized by the Red Queen hypothesis [@VanValen_1973; @Bell_1982], whereby continuous adaptation is mandatory merely to maintain persistent organismal fitness in a non-stationary adaptive landscape [@England_2013]. Thus in biological systems, transitions of the form *disorder $\rightarrow$ order*, or more accurately, *order $\rightarrow$ more complex order* via persistent dissipation, are frequently observed.


This apparent tension between local biological organization (*[dis]order $\rightarrow$ order*) and the $2^{\text{nd}}$ law expectation of increasing total *entropy* (*order $\rightarrow$ disorder*) has been proposed by several authors as a thermodynamic signature distinguishing living from non-living systems. Lovelock [-@Lovelock_1972] and Lovelock and Margulis [-@LovelockEtAl_1974] used this logic to formulate the "Gaia hypothesis": planetary atmospheres dominated by living processes exhibit extreme, dis-equilibrated chemical compositions far removed from abiotic thermodynamic equilibrium. The continuous throughput of solar radiation and geochemical cycles drives living matter to construct and sustain internal organization by pumping out entropy into planetary reservoirs.


The presence of these three order principles has precipitated a wide, generally confusing discussion of their relevance in living systems. These discussions demonstrate the necessity of explicitly specifying the frame of reference: the focal perspective (microscopic order/disorder versus macroscopic energy/matter), the system constraints (boundary conditions and ground/reference states), and the relevant spatial and temporal scales.


![Heuristic representation of the principles of order and corresponding changes in entropy. (A) *order $\rightarrow$ disorder*: the $2^{\text{nd}}$ law such as in simple heat engines (red dashed lines); (B) *order $\rightarrow$ order*: stasis or homeostatic behavior in biochemical systems, stable ecological systems, and genetic stability (green self-loop, "dissipative structures"); and (C) *disorder $\rightarrow$ order*: a reversal such as development, evolution, succession, and adaptation (transition from red-dashed lines to green loops). The circles show the focal (local) processes for each order principle. Note the dissipation-cascade from top to bottom as each dissipative structure connects to other dissipative structures and manifested as Onsager Relations (blue arrows; see text below), interconnected vehicles of energy-cascades (turbulent dynamics, food-web dynamics, metabolic pathways, etc.). In all cases, when the boundaries are expanded to include both the local system and its immediate environment, global entropy increases monotonically (from state 1 to state 2), preserving the Second Law. \label{fig_cascade}](media/order_cascade.png){#fig_cascade width=65%}


To illustrate how these three regimes coexist within a single physical cascade, consider a parcel of water flowing downhill along multiple paths and streams (Fig. \ref{fig_cascade}, area A). A tagged volume of water in an elevated lake initially occupies a state of high gravitational potential energy, low macroscopic kinetic energy, and uniform temperature and pressure. As it flows downhill, gravitational potential energy transforms into kinetic energy, and viscous friction across channel beds gradually dissipates that kinetic energy into thermal heat and ambient entropy: *order $\rightarrow$ disorder* ($2^{\text{nd}}$ law).


In ecological systems, biota intercept a small fraction of these downhill matter and energy flows, retarding their passage by redirecting mass into living structures through growth and reproduction ("standing biomass") before eventual metabolic dissipation: *order $\rightarrow$ order* (Fig. \ref{fig_cascade}, area B). Empirical syntheses initiated by Lindeman [-@Lindeman_1942] and extended by H. T. Odum [-@Odum_1956], E. P. Odum [-@Odum_1969], and Mann [-@Mann_1972] established that trophic transfer efficiencies generally range from 1 to 10%, while satellite radiation budgets indicate that terrestrial plant canopies dissipate over 99% of absorbed solar energy through evapotranspiration and respiration [@SchneiderEtAl_1994; @SchneiderEtAl_2005]. Only a small fraction of gross energy throughput is retained within the standing eddy of living biomass [@Johnson_1981], while the bulk flux continues downhill into entropy export. Characterizing the boundary conditions and feedback mechanisms that sustain these locally ordered material and energy eddies across subcellular, organismal, population, community, and earth-system scales is a central task of biology and ecology.


Finally, when the applied free-energy gradient exceeds viscous or metabolic damping past a critical threshold, non-linear instabilities drive transitions toward new organized configurations: *disorder $\rightarrow$ order* (Fig. \ref{fig_cascade}, area C). In hydrodynamic flows, coherent multi-scale eddy hierarchies emerge to transport and dissipate kinetic energy across wavenumbers [@Richardson_1922; @Kolmogorov_1941]; in ecological communities, biomass size spectra across aquatic and terrestrial biomes [@SheldonEtAl_1972; @Kerr_1974; @PlattEtAl_1977; @RodriguezEtAl_1986; @Boudreau_Dickie_1992; @ChoiEtAl_1999] manifest as analogous energy cascades across hierarchies of spatiotemporal scales. Across ecological and evolutionary timescales, bifurcations triggered by shifts in external free-energy gradients, novel biochemical pathways, speciation, range shifts, keystone interactions, or trophic cascades reorganize feedback networks and shift communities across alternative dynamical attractors. Through reproduction, heritable variation, and natural selection, viable variants are filtered, canalizing developmental pathways and directing ecological succession (*disorder $\rightarrow$ order*). Crucially, when the accounting boundary encompasses both the living community and its surrounding energetic reservoirs, the aggregate process yields a net increase in total entropy (from state 1 to state 2 in Fig. \ref{fig_cascade}): *(local order $\leftrightarrow$ local order) $\rightarrow$ (global disorder)*. Biological self-organization therefore operates as an engine of entropy production rather than a violation of physical law [@Prigogine_1967; @SchneiderEtAl_1994; @England_2013].


Numerous variational and "Order Principles" have been proposed to characterize the macroscopic directionality of biological systems. Lotka [-@Lotka_1922a; -@Lotka_1922b] suggested that natural selection maximizes total energy throughput: systems that capture more available power outcompete rivals [@OdumEtAl_1955]. Shannon [-@Shannon_1948] introduced an information-theoretic entropy to measure the uncertainty of discrete probability distributions, which Kullback and Leibler [-@KullbackEtAl_1951] extended to relative entropy (informational divergence). Jaynes [-@Jaynes_1957] demonstrated that statistical mechanics can be formulated as an inference problem maximizing informational entropy subject to known physical constraints. In ecosystems, information-theoretic measures have been applied to trophic flow networks through Ulanowicz's concept of ascendency [@Ulanowicz_1986; @Ulanowicz_Hannon_1987].


A rigorous evaluation of microscopic *order* and *disorder* requires an explicit dynamical and statistical *model* of the system. Because information-theoretic measures depend on the chosen state variables, coarse-graining categories, and parameterization, purely formal entropy indices applied to ecological models such as Lotka-Volterra interaction models [@Michaelian_2005; @Chakrabarti_Ghosh_2009] or aggregate input-output flow networks [@Patten_1978], yield model-dependent descriptors rather than absolute thermodynamic state functions. Historically, it was precisely the quantitative discrepancy between classical statistical models of molecular and radiation states and empirical calorimetry that revealed missing physical degrees of freedom, motivating quantum statistical mechanics [@Planck_1901; @Schrdinger_1944; @Jaynes_1957]. In ecology, information-theoretic indices have been applied to trophic flow topologies [@Ulanowicz_Hannon_1987; @UlanowiczEtAl_2006], genome size and coding complexity [@JrgensenEtAl_1995], phylogenetic branching [@Wicken_1980; @WileyEtAl_1982], and maximum-entropy species distribution modeling [@ElithEtAl_2011]. While these statistical tools quantify network diversity, constraint, or occurrence probability, connecting them to physical thermodynamics requires mapping their coarse-grained states to physical energy and matter pools with explicit microstate multiplicities and transition energetics.


# Macroscopic Entropy


Given the lack of satisfactory microscopic model representations of ecosystem phenomena, many have attempted instead to describe ecosystem processes in terms of macroscopic state variables. Such a whole system-level (*extensive*) approach is perhaps best exemplified by the engineering tradition which traces its origin directly to the founding work of Carnot [-@Carnot_1824]. The whole system free energy available to do useful work is the state variable of interest, carefully controlled and measured. Engineering applications usually focus upon systems whose boundaries can be defined explicitly (for example, a machine or heat engine) and revolve around well-defined forms of energy and matter transformation with an explicitly defined reference or ground state. These conditions permit repeated measurements of free energy and entropy, so that transfer efficiencies can be calculated to permit systematic performance analysis of the whole system.


Following this macroscopic tradition, Lindeman [-@Lindeman_1942], E. P. Odum [-@Odum_1969], Kay [-@Kay_1991], Aoki [-@Aoki_1993]; [-@Aoki_1995], Schneider and Kay [-@SchneiderEtAl_1994], Müller [-@Mller_1998], Choi et al. [-@ChoiEtAl_1999], Schneider and Sagan [-@SchneiderEtAl_2005], and Jørgensen [-@Jrgensen_2012] analyzed *extensive* free-energy gradients and their degradation across whole ecosystems. Aoki [-@Aoki_1993]; [-@Aoki_1995] estimated whole-lake entropy production from radiation and heat budgets; Choi et al. [-@ChoiEtAl_1999] examined dissipative signatures in plankton size spectra; and Schneider and Kay [-@SchneiderEtAl_1994] used satellite measurements of evapotranspiration and surface temperature as proxies for ecosystem energy degradation. However, applying whole-system *extensive* thermodynamics to open ecosystems encounters fundamental difficulties when multiple mass-energy transformations operate simultaneously across wide spatial, temporal, and organizational scales with porous boundaries, undefined chemical reference states, and internal trophic cycling [@Meysman_Bruers_2010]. Moreover, chemical compounds that serve as high-grade free-energy resources for one guild of organisms may be metabolically inert or even toxic to another.


To address internal cycling in macroscopic budgets, Patten [-@Patten_1978] expanded steady-state compartment flows into first-order linear input-output transitive closures, while H. T. Odum [-@Odum_1996] traced cumulative solar energy transformations into "emergy" conversion ratios. While these accounting frameworks confirm that macroscopic irreversible dissipation is strictly positive in accordance with the $2^{\text{nd}}$ law, aggregate throughput alone does not uniquely determine the internal stability, feedback structure, or direction of perturbation recovery of multi-species communities. Resolving how internal ecological interactions respond to perturbations requires moving from aggregate black-box budgets to the linear and local non-equilibrium formalism of Onsager [-@Onsager_1931a; -@Onsager_1931b], Prigogine [-@Prigogine_1955], and de Groot and Mazur [-@deGrootEtAl_1962].


# Onsager's relations and conjugate effects


Onsager's contributions [@Onsager_1931a; @Onsager_1931b; @OnsagerEtAl_1953; @Casimir_1945; @Mazur_1997; @Verhs_2014] tied macroscopic entropy production to microscopic statistical mechanics for generalized thermodynamic systems. This formulation is revisited here, focusing on the relationship between Onsager's relations and the well-known Le Chatelier-Braun principle [@LeChatelier_1884; @Braun_1887; @Bertalanffy_1950; @PrigogineEtAl_1954; @deGrootEtAl_1962; @GndzEtAl_2014]. When this extensive concept is applied to local control volume elements in an intensive field approach [@Prigogine_1955; @deGrootEtAl_1962], a deeper and more rigorous understanding of the connections between thermodynamics and ecology emerges.


Onsager's relations generalize empirical transport laws, such as Fourier's law of thermal conduction [@Fourier_1822], Ohm's law of electrical conduction [@Ohm_1827], and Fick's law of molecular diffusion [@Fick_1855], into a unified framework governed by total entropy production [@Onsager_1931a; @Onsager_1931b; @deGrootEtAl_1962]. In a system described by $n$ independent extensive state variables $\mathbf{x} = (x_1, \dots, x_n)^{\mathsf{T}}$ with stationary reference state $\mathbf{x}^*$ and deviations $\delta\mathbf{x} = \mathbf{x} - \mathbf{x}^*$, a second-order Taylor expansion of total entropy change yields $\Delta S_{\mathrm{tot}}(\delta\mathbf{x}) = -\frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{H}\delta\mathbf{x} + \mathcal{O}(\|\delta\mathbf{x}\|^3)$, where $\mathbf{H} = -\partial^2\Delta S_{\mathrm{tot}}/\partial\mathbf{x}^2\big|_{\mathbf{x}^*} \succ 0$ is the symmetric positive-definite entropy Hessian [@Einstein_1910; @GreeneEtAl_1951; @Callen_1985]. State fluctuations generate conjugate thermodynamic forces $\mathbf{X} = \nabla_{\delta\mathbf{x}}\Delta S_{\mathrm{tot}} = -\mathbf{H}\delta\mathbf{x}$ that drive linear conjugate fluxes $\mathbf{J}$ (or inverse resistivities $\mathbf{R} = \mathbf{L}^{-1}$ on an independent process basis):


$$J_i = \sum_{j=1}^{m} L_{ij} X_j \quad (\mathbf{J} = \mathbf{L}\mathbf{X}) \qquad \text{or} \qquad X_i = \sum_{j=1}^{m} R_{ij} J_j \quad (\mathbf{X} = \mathbf{R}\mathbf{J})$$


Under microscopic reversibility of equilibrium fluctuations (in the absence of time-reversal-odd magnetic or Coriolis fields), Onsager [-@Onsager_1931a; -@Onsager_1931b] proved that the phenomenological matrices are symmetric [@Casimir_1945]. The internal entropy production rate $\sigma = d_i S / dt$ is the bilinear product of conjugate fluxes and forces:


$$\sigma = \frac{d_i S}{dt} = \mathbf{J}^{\mathsf{T}}\mathbf{X} = \sum_{i,j=1}^{m} L_{ij} X_i X_j = \mathbf{X}^{\mathsf{T}}\mathbf{L}_s\mathbf{X} = \mathbf{J}^{\mathsf{T}}\mathbf{R}_s\mathbf{J} \ge 0$$


Non-negative internal entropy production ($\sigma \ge 0$, distinct from the signed boundary entropy exchange $d_e S / dt$ in $dS/dt = \sigma + d_e S / dt$) requires the symmetric part of the conductivity matrix, $\mathbf{L}_s = \frac{1}{2}(\mathbf{L} + \mathbf{L}^{\mathsf{T}})$, to be positive semidefinite, and strictly positive definite ($\mathbf{L}_s \succ 0$) on a non-redundant process basis [@deGrootEtAl_1962].


When pairs of irreversible transport processes are coupled through these symmetric cross-coefficients, they are referred to as conjugate processes. Experimental confirmation of Onsager reciprocity across physical and chemical systems is extensive [@Miller_1960]. Classic physical examples include thermoelectric coupling, where a temperature gradient drives an electric current [@Seebeck_1826] and an electrical current drives a reversible heat flux [@Peltier_1834; @Thomson_1854], as well as thermomagnetic Nernst-Ettingshausen effects [@vonEttingshausenEtAl_1886; @Nernst_1887]. In biological physics, analogous reciprocal couplings govern membrane electrodynamics and coupled enzymatic pathways [@KedemEtAl_1958; @KatchalskyEtAl_1965; @Oster_et_al_1971; @Mikulecky_1985].


## Resolving the Apparent Breakdown of Reciprocity in Ecology


When theoretical ecologists and physicists first attempted to apply Onsager's reciprocal relations to living communities, they encountered an immediate conceptual paradox. Ecologists formulate multi-species interactions through demographic differential equations whose linearized dynamics near steady state are governed by the demographic community matrix or Jacobian $\mathbf{A}$ [@May_1972; @Yodzis_1981]. Because feeding interactions are inherently directional, in that a predator gains biomass by consuming a prey population while the prey population declines, community interaction matrices are fundamentally asymmetric ($A_{ij} \ne A_{ji}$).


Assuming that the demographic matrix $\mathbf{A}$ must serve directly as the physical Onsager conductivity matrix $\mathbf{L}$, it was concluded that living communities violate Onsager reciprocity and operate outside the domain of non-equilibrium physical thermodynamics [@MacArthur_1970; @Ulanowicz_Hannon_1987; @Michaelian_2005; @Chakrabarti_Ghosh_2009; @Meysman_Bruers_2010]. MacArthur [-@MacArthur_1970] demonstrated that symmetric resource competition minimizes a scalar carrying-capacity potential, but noted that this variational principle collapsed when predation was included. Ulanowicz and Hannon [-@Ulanowicz_Hannon_1987] examined input-output flow networks and asserted that ecological exchanges inherently break reciprocity. Michaelian [-@Michaelian_2005] tested Lotka-Volterra community matrices as Onsager conductivities and concluded that ecological networks violate reciprocal symmetry, challenging Prigogine's stationary dissipation theorems.


This apparent conflict arises from a conceptual conflation: the demographic community matrix $\mathbf{A}$ is not the physical conductivity matrix $\mathbf{L}$. The demographic matrix describes the temporal rate of change of population biomasses ($\delta\dot{\mathbf{x}} = \mathbf{A}\delta\mathbf{x}$), whereas Onsager conductivities relate physical thermodynamic fluxes to intensive driving forces ($\mathbf{J} = \mathbf{L}\mathbf{X}$). The community matrix is a composite dynamical operator that conflates underlying physical transport conductivities with the heterogeneous biomass storage capacities of biological compartments.


A physical analogy illustrates this distinction. Consider two fluid reservoirs connected by a physical pipe with conductivity $L$. One reservoir is a large freshwater lake (representing a large detrital or forest biomass pool), while the second reservoir is a small vessel (representing a specialized, low-biomass predator population). When fluid is transferred between them, the physical transport conductivity $L$ through the pipe is identical in both directions. However, transferring a fixed volume of water produces a negligible change in the surface level of the lake, whereas that same volume transfer induces a large water-level shift in the small vessel. The demographic interaction coefficient $A_{ij} = \partial \dot{x}_i / \partial x_j$ does not measure the physical pipe conductivity $L$; rather, it measures the rate of water-level change in compartment $i$ per unit level displacement in compartment $j$. Because the demographic community matrix scales the underlying physical fluxes by the inverse storage capacities of the receiving compartments, it is inherently asymmetric ($A_{ij} \ne A_{ji}$) even when the underlying physical transport conductivities are completely reciprocal and symmetric ($L_{ij} = L_{ji}$).


This conflation resolves through continuous Lyapunov covariance factorization [@Lyapunov_1892; @Tomita_Tomita_1974; @Graham_1977; @Ao_2004; @Qian_2006]. By Einstein's fluctuation relation [@Einstein_1910; @GreeneEtAl_1951], the matrix inverse of the entropy Hessian $\mathbf{H}$ scaled by Boltzmann's constant $k_{\mathrm{B}}$ defines the stationary fluctuation covariance matrix $\mathbf{C} = \langle \delta\mathbf{x}\delta\mathbf{x}^{\mathsf{T}}\rangle = k_{\mathrm{B}}\mathbf{H}^{-1}$, which functions as the thermodynamic storage capacitance of the ecological network (mapping extensive state deviations $\delta\mathbf{x}$ to conjugate driving forces $\mathbf{X} = -k_{\mathrm{B}}\mathbf{C}^{-1}\delta\mathbf{x}$). The total demographic drift operator $-\mathbf{A}\mathbf{C}$ decomposes uniquely into a symmetric dissipative component and an antisymmetric circulation component:


$$-\mathbf{A}\mathbf{C} = \mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega}$$


Inverting the capacitance matrix yields the structural factorization of the demographic community matrix:


$$\mathbf{A} = -(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}$$


This factorization clarifies the dual nature of living ecosystems through two distinct physical operators. The symmetric Onsager dissipation tensor $\mathbf{D}_{\mathrm{sym}} = \mathbf{D}_{\mathrm{sym}}^{\mathsf{T}} \succ 0$ represents pure, irreversible thermodynamic dissipation. It acts as an energetic restorative pull that draws perturbed populations monotonically downhill along the thermodynamic entropy surface toward the stationary attractor, strictly satisfying Onsager reciprocity ($D_{ij} = D_{ji}$) and guaranteeing compliance with the Second Law of Thermodynamics. In contrast, the antisymmetric probability circulation tensor $\boldsymbol{\Omega} = -\boldsymbol{\Omega}^{\mathsf{T}}$ represents **non-dissipative** cyclic motion in state space, capturing the persistent directional trophic fluxes characteristic of living food webs, including predator-prey population cycles, seasonal succession, and microbial nutrient recycling loops. Because $\boldsymbol{\Omega}$ is skew-symmetric, it does no net thermodynamic work against the entropy gradient, circulating currents perpetually in state space as sustained by continuous boundary throughput of solar irradiance and chemical nutrients.


Thus, Onsager reciprocity is not broken in living systems. The symmetric dissipative core $\mathbf{D}_{\mathrm{sym}}$ preserves reciprocal symmetry, while the asymmetry of the demographic matrix $\mathbf{A}$ reflects the superposition of physical capacitance heterogeneity $\mathbf{C}^{-1}$ and non-equilibrium circulation $\boldsymbol{\Omega}$. See Appendix A for more details.


Because $\boldsymbol{\Omega}$ is skew-symmetric, it performs no net thermodynamic work against the potential gradient ($\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}\delta\mathbf{x} = 0$), functioning as a conservative energy and nutrient shuttler across compartments.


These physical operators map directly to ecological mechanisms. Biological standing stocks function as entropic capacitors ($\mathbf{C}$): detrital beds and forest boles store reserves of carbon and nutrients, providing physical inertia that buffers the community against seasonal droughts and resource lean periods. Metabolic dissipation ($\mathbf{D}_{\mathrm{sym}}$) represents the irreversible metabolic expenditure required to maintain living structure against thermal decay, pulling perturbations monotonically back toward stationary balance. Probability circulation ($\boldsymbol{\Omega}$) represents conservative transport within internal trophic loops, where feeding cycles and microbial recycling pathways shuttle matter and energy across species boundaries without degrading the local free-energy gradient.


Quantifying the departure from microscopic detailed balance is the network-wide magnitude of cyclic trophic transport relative to irreversible dissipative damping. This dimensionless non-equilibrium circulation ratio is:


$$\chi = \frac{\|\boldsymbol{\Omega}\|_F}{\|\mathbf{D}_{\mathrm{sym}}\|_F}$$


where $\|\mathbf{M}\|_F = \sqrt{\operatorname{tr}(\mathbf{M}^{\mathsf{T}}\mathbf{M})} = \sqrt{\sum_{i,j} M_{ij}^2}$ denotes the Frobenius matrix norm. Because symmetric and skew-symmetric matrices are mutually orthogonal under the Frobenius inner product ($\operatorname{tr}(\mathbf{D}_{\mathrm{sym}}^{\mathsf{T}}\boldsymbol{\Omega}) = 0$), the total squared norm of the covariance-weighted drift decomposes via the Pythagorean identity $\|-\mathbf{A}\mathbf{C}\|_F^2 = \|\mathbf{D}_{\mathrm{sym}}\|_F^2 + \|\boldsymbol{\Omega}\|_F^2 = \|\mathbf{D}_{\mathrm{sym}}\|_F^2(1 + \chi^2)$, where $\chi = \tan\theta$ is the tangent of the angle between the composite dynamical operator and the purely dissipative Onsager subspace. In an isolated system at thermodynamic equilibrium (or in a purely symmetric competitive community), detailed balance holds, circulation vanishes ($\boldsymbol{\Omega} = \mathbf{0}$, $\chi = 0$), and perturbations relax monotonically without rotation. In open ecosystems driven by solar irradiance and nutrient inflows, continuous boundary throughput sustains persistent cyclic currents ($\chi > 0$), indexing a continuum of dynamical regimes from capacitance-buffered overdamped relaxation ($\chi < 1$, as in detritus-dominated benthic streams) and active planktonic recycling ($\chi \sim 1\text{ to }1.5$, as in the open-ocean mixed layer) to volatile, unbuffered oscillatory spiraling when slow apex capacitors are stripped ($\chi \gg 1$, approaching a Hopf bifurcation). Coordinate-invariance proofs, geometric properties of the Frobenius ratio, and the canonical two-species prototype decomposition are presented in Appendices A and C.


## The Connection of Onsager Reciprocity to the Le Chatelier-Braun Principle: Ecological Conjugate Effects


Within the linear range of non-equilibrium thermodynamics near a stationary state, Onsager's reciprocal relations provide a quantitative mathematical formulation of the Le Chatelier-Braun principle [@LeChatelier_1884; @Braun_1887; @Bertalanffy_1950; @PrigogineEtAl_1954; @deGrootEtAl_1962; @HornEtAl_2012; @GndzEtAl_2014]. In physical chemistry, this principle states that when a system at equilibrium is subjected to an external perturbation, internal processes adjust to oppose and moderate the perturbation. In open non-equilibrium systems, extremum properties of entropy production depend explicitly on which boundary variables are clamped[^3]: when thermodynamic forces $\mathbf{X}$ are held fixed, the linear constitutive response maximizes the Onsager-Machlup dissipation functional, whereas when boundary fluxes are fixed or unconstrained internal forces relax to zero-flux stationarity ($J_k = 0$), stationary relaxation minimizes entropy production with respect to the free forces [@Onsager_1931a; @Onsager_1931b; @OnsagerEtAl_1953; @Prigogine_1955; @Glansdorff_Prigogine_1971; @ShinerEtAl_1994; @MartyushevEtAl_2006; @Reis_2014; @Verhs_2014].


Specifically, positive-definiteness of the symmetric conductivity matrix ($\mathbf{L}_s \succ 0$) requires every diagonal self-conductivity to be strictly positive ($L_{ii} > 0$) and bounds all off-diagonal cross-conductivities $L_{ij}$ ($i \ne j$) via the Cauchy-Schwarz determinant condition $L_{ii}L_{jj} - \frac{1}{4}(L_{ij} + L_{ji})^2 > 0$. Individual cross-coefficients $L_{ij}$ may be either positive or negative, and entropy production is not separately defined for individual off-diagonal terms; only the complete quadratic form $\sigma = \mathbf{X}^{\mathsf{T}}\mathbf{L}_s\mathbf{X} \ge 0$ is constrained to be non-negative [@deGrootEtAl_1962].


Following the variational formulations of Onsager [-@Onsager_1931a; -@Onsager_1931b], Onsager and Machlup [-@OnsagerEtAl_1953], and Prigogine [-@Prigogine_1955], whether a linear non-equilibrium steady state maximizes or minimizes entropy production depends on which boundary variables are clamped [@ShinerEtAl_1994; @MartyushevEtAl_2006; @Reis_2014]. Under clamped thermodynamic forces $\mathbf{X}$, the Onsager-Machlup functional is [@OnsagerEtAl_1953; @Ziegler_1983; @Dewar_2003]:


$$\Phi(\mathbf{J}) = \sigma(\mathbf{J}, \mathbf{X}) - \Psi(\mathbf{J}) = \sum_{i} J_i X_i - \frac{1}{2}\sum_{i,j} R_{s;ij} J_i J_j$$


Setting the first variation with respect to flux $J_k$ to zero gives $\partial \Phi / \partial J_k = X_k - \sum_j R_{s;kj} J_j = 0 \implies \mathbf{J} = \mathbf{L}_s\mathbf{X}$. Because the Hessian with respect to $\mathbf{J}$ is negative definite ($\partial^2 \Phi / \partial \mathbf{J}^2 = -\mathbf{R}_s \prec 0$), the constitutive response maximizes $\Phi(\mathbf{J})$ (and thus boundary dissipation $\sigma = \mathbf{X}^{\mathsf{T}}\mathbf{L}_s\mathbf{X}$) at fixed driving forces.


Conversely, when boundary fluxes are clamped or a subset of internal forces $X_k$ are left unconstrained to relax to zero-flux stationarity ($J_k = 0$), differentiating $\sigma(\mathbf{X}) = \mathbf{X}^{\mathsf{T}}\mathbf{L}_s\mathbf{X}$ with respect to each free internal force $X_k$ yields:


$$\frac{\partial \sigma}{\partial X_k} = 2\sum_j L_{s;kj} X_j = 2 J_{s;k} = 0, \qquad \frac{\partial^2 \sigma}{\partial \mathbf{X}^2} = 2\mathbf{L}_s \succ 0$$


Because the Hessian $2\mathbf{L}_s$ is strictly positive definite, stationary relaxation of unconstrained internal forces minimizes entropy production [@Prigogine_1955; @Glansdorff_Prigogine_1971], with the minimized dissipation given directly by the Schur complement $\sigma_{\min} = L_{11,\mathrm{eff}}\,\delta X_1^2 \le L_{11}\,\delta X_1^2$.


When an external force perturbation $\delta X_i$ acts upon a primary process $i$ while all secondary forces are clamped ($\delta\mathbf{X}_{-i} = \mathbf{0}$), the system responds with a direct conjugate flux $\delta J_i = L_{ii}\delta X_i$ and positive dissipation $\sigma = L_{ii}\delta X_i^2 > 0$ that acts to deplete the imposed gradient. When the coupled secondary processes $\delta\mathbf{X}_{-i}$ are instead permitted to adjust freely until their conjugate fluxes reach stationary balance ($\delta\mathbf{J}_{-i} = \mathbf{0}$, so that $\delta\mathbf{X}_{-i} = -\mathbf{L}_{-i,-i}^{-1}\mathbf{L}_{-i,i}\delta X_i$), the induced cross-fluxes redistribute the disturbance across the network and moderate the primary response via the matrix Schur complement [@Schur_1917; @PrigogineEtAl_1954; @deGrootEtAl_1962; @HornEtAl_2012]:


$$\delta J_i = L_{ii,\mathrm{eff}}\,\delta X_i, \qquad L_{ii,\mathrm{eff}} = L_{ii} - \mathbf{L}_{i,-i}\mathbf{L}_{-i,-i}^{-1}\mathbf{L}_{-i,i} > 0$$


Because the secondary submatrix has a positive-definite symmetric part ($\mathbf{L}_{s;-i,-i} \succ 0$), the quadratic correction term in this Schur complement moderates perturbations through both direct symmetric dissipative couplings ($\mathbf{L}_s$) and effective cyclic indirect couplings ($\mathbf{L}_a = k_{\mathrm{B}}^{-1}\boldsymbol{\Omega}$; Appendix B). When cross-coupling is directly reciprocal and symmetric ($\mathbf{L}_{s;i,-i} = \mathbf{L}_{s;-i,i}^{\mathsf{T}}$, as in mutualistic co-transport), $\mathbf{L}_{s;i,-i}\mathbf{L}_{s;-i,-i}^{-1}\mathbf{L}_{s;i,-i}^{\mathsf{T}} \ge 0$ reduces the effective conductivity ($0 < L_{ii,\mathrm{eff}} \le L_{ii}$), moderating the net flux drawn from an imposed force gradient $\delta X_i$. Conversely, when cross-coupling acts through cyclic indirect links that are skew-symmetric ($\mathbf{L}_{a;i,-i} = -\mathbf{L}_{a;-i,i}^{\mathsf{T}}$, as in predator-prey or host-parasite negative feedback loops), secondary relaxation adds a positive-definite circulatory restoring term $+\mathbf{L}_{a;i,-i}\mathbf{L}_{s;-i,-i}^{-1}\mathbf{L}_{a;i,-i}^{\mathsf{T}} > 0$ to $L_{ii,\mathrm{eff}} \ge L_{ii}$, which decreases the stationary compliance ($0 < L_{ii,\mathrm{eff}}^{-1} \le L_{ii}^{-1}$) and reduces the force and state displacement ($|\delta X_i| = L_{ii,\mathrm{eff}}^{-1}|\delta J_i|$) induced by an external flux disturbance $\delta J_i$. In extensive state space $\delta\mathbf{x}$, perturbations decay monotonically along the quadratic Lyapunov availability functional $V(\delta\mathbf{x}) = \frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\delta\mathbf{x} = -\Delta S_{\mathrm{tot}}(\delta\mathbf{x})/k_{\mathrm{B}}$:


$$\dot{V}(\delta\mathbf{x}) = -\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}\delta\mathbf{x} < 0 \quad (\delta\mathbf{x} \ne \mathbf{0})$$


Coupled irreversible pathways thus absorb and redistribute disturbances, moderating net force displacements and driving asymptotic relaxation back toward the stationary state. These reciprocal stabilizing responses are designated here as **conjugate effects** to emphasize their constitutive mechanism through Onsager transport.


Not every biological interaction is automatically conjugated; however, recurrent mass and energy exchanges that generate irreversible entropy production across a stationary regime exhibit direct or effective (through cyclic indirect links) **conjugate effects**. In symbiotic and mutualistic partnerships, such as plant-mycorrhizal associations and coral-zooxanthellae symbioses [@Boucher_1985; @Bronstein_1994], reciprocal nutrient and carbohydrate exchanges create mutually reinforcing pathways that buffer both partners against environmental shortages. Under severe drought stress, terrestrial plants allocate up to twenty percent of their photosynthetically fixed carbon to arbuscular mycorrhizal fungal networks in the rhizosphere [@Smith_Read_2008]. In return, extensive fungal hyphae forage soil micropores for moisture and immobile phosphorus, buffering the plant against water-potential collapse. This reciprocal cross-coupling represents a direct biological manifestation of the matrix Schur complement, where secondary pathway relaxation moderates primary environmental stress ($L_{ii,\mathrm{eff}} \le L_{ii}$). Similarly, in soil microbial loops, plant roots release organic exudates in the rhizosphere that stimulate bacterial growth. In turn, bacterial grazing by protozoa and nematodes releases mineralized ammonium and orthophosphate directly adjacent to root hairs [@Clarholm_1985; @Bonkowski_2004]. When environmental nutrient availability drops, increased root exudation accelerates bacterial grazing, releasing stored minerals back to the plant and moderating nutrient pulse shocks.


Host-parasite interactions exhibit a more nuanced, scale-dependent reciprocity across organismal and population levels. To an individual host, heavy parasitism is metabolically costly or detrimental; yet even at the physiological level, chronic low-level exposure to coevolved parasites and commensal microbiota stimulates and calibrates host immune regulation, such as regulatory T-cell pathways, protecting against secondary pathogens and moderating hyper-inflammatory or autoimmune responses, as described by the hygiene and "old friends" hypotheses [@Strachan_1989; @Rook_2009; @Smith_et_al_2012]. At the population and evolutionary scales, density-dependent parasite transmission moderates host population explosions before the host exhausts its local resource base, while selective pressure on less adapted phenotypes maintains genetic polymorphism and accelerates reciprocal adaptive evolution in fluctuating environments [@VanValen_1973; @Hamilton_1980].


Predator-prey interactions similarly act as stabilizing conjugate responses that regularize prey abundance and damp herbivore oscillations before herbivores exhaust their resource base [@Paine_1966; @EstesEtAl_1974; @Estes_et_al_1998]. In North Pacific coastal ecosystems, sea otters (*Enhydra lutris*) prey upon herbivorous sea urchins (*Strongylocentrotus polyacanthus*); where otters are depleted, dense urchin populations overgraze sublittoral kelp beds (*Laminaria* and *Alaria fistulosa*), converting productive kelp forests into urchin barrens [@EstesEtAl_1974; @Estes_et_al_1998]. In terrestrial systems, the reintroduction of gray wolves (*Canis lupus*) to Yellowstone National Park moderated elk (*Cervus canadensis*) browsing along riparian corridors, permitting willow and aspen stands to recover [@Ripple_Beschta_2004], whereas unchecked white-tailed deer (*Odocoileus virginianus*) populations in predator-depleted habitats chronically overbrowse forest understories and degrade plant community structure [@RussellEtAl_2001]. In each case, secondary relaxation of predatory consumption moderates primary herbivory perturbations in accordance with the Le Chatelier-Braun principle.


Beyond direct trophic pairings, **conjugate effects** also manifest across coupled eco-physiological and biogeochemical processes operating within physical and chemical gradients [@Kleiber_1947; @Bertalanffy_1950]. Photosynthetic biomass, evapotranspiration, and consumer respiration are reciprocally coupled across resource and microclimatic gradients, as seen in the benthic-pelagic coupling of lake ecosystems across oxygen, pH, and nutrient gradients [@RegierEtAl_1996; @SchindlerEtAl_2002] and in the marine biological carbon pump linking surface primary production to deep particulate carbon export [@EppleyEtAl_1979; @DucklowEtAl_2001]. Even when interactions are mediated indirectly across divergent timescales, Onsager reciprocity yields testable expectations that distinguish causal thermodynamic coupling from spurious correlation [@Peters_1991]. For instance, Halbach [-@Halbach_1973] observed that rotifers (*Brachionus calyciflorus*) reared at higher temperatures matured at smaller body sizes and exhibited larger-amplitude population oscillations. In an uncoupled allometric model, experimentally shifting individuals to larger body sizes at fixed conditions would simply increase per-capita and total metabolic heat dissipation; under an effective conjugate feedback, however, an increase in individual body size should be compensated by a reduction in numerical density and net metabolic heat production.


At planetary scales, biotic feedbacks link local organismal and population processes to surface temperature, albedo, and atmospheric chemical disequilibrium, as explored in the Gaia hypothesis [@Lovelock_1972; @LovelockEtAl_1974] and Daisyworld simulations [@Watson_Lovelock_1983], while anthropogenically driven greenhouse-gas forcing ($\mathrm{CO}_2$, methane, and chlorofluorocarbons) perturbs these global feedbacks. Conversely, when sustained exploitation or environmental forcing breaks existing **conjugate effects**, for example by persistently removing the largest body-size fraction and its storage capacitance, positive feedbacks can drive ecosystems into nonlinear transitions across alternative regimes. The collapse of Northwest Atlantic cod on the eastern Scotian Shelf and the shift of the continental shelf community toward small pelagic fishes and benthic macroinvertebrates [@Choi_et_al_2004; @Choi_et_al_2005a], together with the subsequent exploration of alternative equilibria modulated by environmental variability [@Choi_2023], illustrates how breaking historical conjugate feedbacks leads to the reorganization of trophic relations through order-through-fluctuation dynamics [@PrigogineEtAl_1972; @Babloyantz_1986].


**Conjugate effects** (Onsager's relations and Le Chatelier-Braun principle) provide a mechanistic framework linking these empirical ecological observations to the underlying laws of non-equilibrium physics. Reciprocal trophic couplings reflect causal thermodynamic constraints rather than coincidental statistical correlations.


# Local stability, local order, and the resistance-resilience continuum


To apply non-equilibrium thermodynamics to open, spatially heterogeneous continuum systems, Meixner [-@Meixner_1941]; [-@Meixner_1943], Prigogine [-@Prigogine_1947]; [-@Prigogine_1955], de Groot and Mazur [-@deGrootEtAl_1962], and Gyarmati [-@Gyarmati_1970] formulated Onsager's relations as a *local, intensive* field description within a small control volume element $V^\ddagger$ (denoted here by ${}^\ddagger$). Within such a local control volume, the change in subsystem entropy $dS^\ddagger$ over time interval $dt$ is the sum of internal entropy production $d_i S^\ddagger \ge 0$ generated by irreversible processes inside the element and entropy exchange $d_e S^\ddagger$ transported across its boundary:


$$dS^\ddagger = d_i S^\ddagger + d_e S^\ddagger$$


Dividing the internal production rate by the control volume $V^\ddagger$ defines the local specific internal entropy production rate $\sigma^\ddagger$:


$$\sigma^\ddagger = \frac{1}{V^\ddagger}\frac{d_i S^\ddagger}{dt} = \sum_{i,j=1}^{m} L^\ddagger_{ij} X^\ddagger_i X^\ddagger_j = \mathbf{X}^{\ddagger\mathsf{T}}\mathbf{L}^\ddagger_s\mathbf{X}^\ddagger \ge 0$$


where $X^\ddagger_i$ are the local intensive thermodynamic forces and $L^\ddagger_{ij}$ are the local specific phenomenological conductivities.


This distinction between *extensive* whole-system budgets and *local, intensive* volume elements is foundational for ecological thermodynamics [@Landsberg_1972; @ChoiEtAl_1999; @ChoiEtAl_2001][^4]. Whereas whole-ecosystem boundaries are often geographically and trophically porous [@Meysman_Bruers_2010], a local biological compartment (such as an organism, a functional guild, or a well-mixed habitat patch) satisfies local thermodynamic linearizability provided explicit scope conditions are met:

- a well-defined local stationary or quasi-stationary reference state $\mathbf{x}^{\ddagger*}$ within the control volume and observation window $T_{\mathrm{obs}}$;

- identifiable local conjugate fluxes $\mathbf{J}^\ddagger$ and thermodynamic forces $\mathbf{X}^\ddagger$;

- perturbation amplitudes $\delta\mathbf{x}^\ddagger = \mathbf{x}^\ddagger - \mathbf{x}^{\ddagger*}$ small enough that higher-order terms in the local availability expansion are negligible; and

- explicit timescale separation $\tau_{\mathrm{mix}} \ll T_{\mathrm{obs}} \ll \tau_{\mathrm{evo}}$ among the fast fluctuation mixing time $\tau_{\mathrm{mix}}$, the observation window $T_{\mathrm{obs}}$, and the successional or evolutionary timescale $\tau_{\mathrm{evo}}$ over which slow structural parameters modify $\mathbf{L}^\ddagger$ [@Landsberg_1972; @Keizer_1987]. Note that stationarity of the local distribution is distinct from detailed balance: an open volume element relaxes to a non-equilibrium steady state ($dS^\ddagger/dt = 0$ with $\sigma^\ddagger = -\frac{1}{V^\ddagger}\frac{d_e S^\ddagger}{dt} > 0$) rather than an isolated equilibrium.


Because the local entropy balance includes boundary export $d_e S^\ddagger$, an open biological compartment can maintain or decrease its internal entropy ($dS^\ddagger \le 0$) so long as it exports entropy to its environment at a rate exceeding its internal production ($-d_e S^\ddagger \ge d_i S^\ddagger \ge 0$), in full compliance with the $2^{\text{nd}}$ law [@Prigogine_1955; @SchneiderEtAl_1994; @England_2013]. Moreover, unlike physical heat engines constrained by rigid walls of fixed geometry, living systems actively grow, contract, and restructure their total biovolume and standing biomass $B_i^*$ across orders of magnitude (Fig. \ref{fig_respiration_biomass}). Normalizing ecological budgets by arbitrary spatial surface area or water-column depth introduces extrinsic geometric artifacts between two-dimensional benthic habitats and deep pelagic waters; identifying **standing biomass** (or biovolume) as the true physical capacitance container resolves these dimensional ambiguities. Consequently, macroscopic extensive dissipation and local biomass-specific dissipation rate can diverge during transient disturbances, creating scale-dependent lags between rapid metabolic adjustments and slower structural biomass recovery.


In empirical comparative analyses across global ecosystems (Fig. \ref{fig_respiration_biomass}; Webster et al. [-@WebsterEtAl_1975], DeAngelis [-@DeAngelis_1980], Choi [-@Choi_2002]), this interplay is captured by the inverse allometric relationship between the community respiration-to-biomass ratio ($R/B$, an empirical metabolic proxy for specific dissipation rate $\sigma^\ddagger$) and standing biomass $B$ (a proxy for biological storage capacitance $\mathbf{C} = k_{\mathrm{B}}\mathbf{H}^{-1}$).

Because organismal metabolic rate scales allometrically with body mass according to Kleiber's law [@Kleiber_1932; @Hemmingsen_1960; @Peters_1983; @BrownEtAl_2004], mass-specific dissipation decreases systematically as individual body size and standing biomass increase. This constraint underpins the fundamental ecological trade-off between *Resilience* (kinetic recovery speed, governed by the mass-specific relaxation operator $\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}$) and *Resistance* [@Holling_1973; @WebsterEtAl_1975; @Pimm_1984; @GrimmEtAl_1997].


![The relationship between community respiration rate (a proxy for entropy production) and standing biomass (a proxy for biovolume and storage capacitance). Data were obtained from the literature [@Choi_2002]. The form of this relationship (purple curve) is constrained by allometric relationships between organismal size and metabolic rates. Due to this constraint, high-"resilience" systems (that is, high Respiration/Biomass ratios, e.g., (a), or alternatively high mass-specific conductivity) are generally lower-resistance systems (low standing biomass); conversely, lower-resilience systems (lower Respiration/Biomass ratios) are more resistant systems (higher standing biomass) relative to a given perturbation (e.g., system (b)). Any local deviation from this global pattern (e.g., (c) if perturbed from (b)) represents a globally unstable situation from which a return toward the global pattern becomes more probable. Within each system, local deviations from the system-specific expected behavior represent a more ecologically unstable situation. As such, ecologically ("local") and evolutionarily ("global") favored directions for change can be antagonistic or mutualistic, depending upon the specific configuration of the system concerned. NOTE: systems marked with an asterisk ($*$) represent order-of-magnitude estimates; italicized systems indicate the relative magnitude of net primary production of representative systems and so serve to approximately delineate a reasonable lower bound of community respiration rates for each representative system (respiration $\gg$ production). The codes are structured as follows: [ecological type].[climatic region].[ID number]. Climatic regions: Te=temperate; Tr=tropical; Ar=arctic; Bo=boreal. Ecological types: E=estuary/brackish water; L=whole lake; P=freshwater pelagic; Litt=littoral; M=marine pelagic; Sh=continental shelf; Corr=coral reef; R=river; Tundra=tundra; Gr=grassland; Cult=culture; and F=forest. \label{fig_respiration_biomass}](media/fig2.png){#fig_respiration_biomass width=80%}


Because the product of total standing biomass capacitance ($B_{\mathrm{tot}} \propto \operatorname{Tr}(\mathbf{C})$) and mass-specific metabolic turnover ($\mathcal{R} = R_{\mathrm{tot}} / B_{\mathrm{tot}} \propto \operatorname{Tr}(\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}})$) equals the total community respiration flux ($B_{\mathrm{tot}} \times \mathcal{R} = R_{\mathrm{tot}}$) bounded by external solar and geochemical inputs, and because organismal storage capacitance ($C(M) \propto M^{1-b}$) and metabolic turnover rate ($\lambda(M) \propto M^{b-1}$, $b \approx 3/4$) have inverse allometric exponents ($C(M)\lambda(M) \propto M^0$), this trade-off organizes ecosystems along a hyperbolic stability frontier ($B_{\mathrm{tot}} \times \mathcal{R} \approx \text{constant}$): communities cannot maximize both Resistance and Resilience simultaneously [@ChoiEtAl_1999; @ChoiEtAl_2001; @FathEtAl_2001; @Choi_2002].

High-resilience communities at the lower left of the trajectory, such as pelagic plankton assemblages (Fig. \ref{fig_respiration_biomass}a) or ephemeral vernal pool blooms, maintain minimal standing capacitance and are easily displaced by acute environmental shocks (low Resistance), yet their high mass-specific metabolic turnover enables rapid recovery within days. Conversely, high-resistance communities along the upper right of the trajectory, such as higher-biomass lakes and shelf systems (Fig. \ref{fig_respiration_biomass}b), coral reefs, and mature temperate or redwood forests (*Sequoia sempervirens*), possess large standing biomass capacitance that buffers multi-year climatic anomalies with minimal state displacement, but require decades or centuries to recover if structurally cleared (low kinetic Resilience).

The capacity of an ecosystem to partition energy and operate along this Resistance-Resilience continuum (purple curve in Fig. \ref{fig_respiration_biomass}) defines its *adaptive capacity*, while the realized stationary operating point represents a **Le Chatelier-Braun balance**.


In the local *intensive* approach, local **conjugate effects** (local steady-state moderation or homeostasis; Fig. \ref{fig_respiration_biomass}) emerge naturally across scales. Whereas organismal homeostasis is universally recognized as a physiological necessity, arguments for homeostatic regulation at population, ecosystem, or planetary scales have historically been criticized as teleological or vitalistic [@Tansley_1935; @GouldEtAl_1979; @Dawkins_1986; @Mayr_1991; @GrimmEtAl_1997]. The local Onsager-Lyapunov formulation resolves this critique: local restorative directionality requires no teleological goal, following directly from the temporal arrow of positive-definite internal dissipation ($\mathbf{D}_{\mathrm{sym}} \succ 0$) and the Schur complement moderation of coupled pathways ($0 < L_{ii,\mathrm{eff}} \le L_{ii}$). Hierarchical cascades of Prigogine's [@PrigogineEtAl_1972] "dissipative structures" (Fig. \ref{fig_cascade}, area (C); O'Neill et al. 1986, Choi and Patten [-@ChoiEtAl_2001]) thus represent local fluctuations [@ChoiEtAl_1999] around stationary states across nested spatiotemporal scales, operating analogously to the Kolmogorov [-@Kolmogorov_1941] energy cascade in fluid turbulence while respecting the global $2^{\text{nd}}$ law.


Because mass-specific dissipation is governed by metabolic allometry [@Kleiber_1947; @Bertalanffy_1950; @ChoiEtAl_1999; @ChoiEtAl_2001; @FathEtAl_2001], local **conjugate effects** carry direct consequences for community size structure and evolution. Near a stationary Le Chatelier-Braun balance, altering the abundance or size structure of a predator reciprocally shifts the specific metabolic rate and size structure of its prey or competitors, and vice versa. If total community biomass is constrained, total community metabolism adjusts to compensate; if total metabolism is constrained, standing biomass adjusts; and if both biomass and metabolic throughput are constrained by boundary conditions, internal biochemical efficiencies, life-history adaptations, and species diversity must reorganize, yielding testable evolutionary and macroecological predictions directly from Onsager reciprocity.


When an acute environmental shock, climatic anomaly, or anthropogenic exploitation perturbs an ecosystem (for instance, displacing a community from (b) to (c) in Fig. \ref{fig_respiration_biomass}), the existing Le Chatelier-Braun balance is broken. If boundary conditions or structural compartments have been fundamentally altered, the system cannot simply return to its prior state; instead, a new Le Chatelier-Braun balance must dynamically re-establish, conditioned upon the altered **external gradients** (such as shifted radiative forcing, temperature baselines, hydrologic regimes, or nutrient loadings) and the **internal mechanisms that remain available** (surviving biomass capacitance $\mathbf{C}$ such as seed banks, detrital pools, and reproductive adults; intact size spectra; and functional circulation loops $\boldsymbol{\Omega}$). Because the composite community matrix $\mathbf{A} = -(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}$ is non-normal ($\mathbf{A}\mathbf{A}^{\mathsf{T}} \ne \mathbf{A}^{\mathsf{T}}\mathbf{A}$), recovery trajectories across fast microbial/planktonic turnover ($\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}$), intermediate trophic circulation ($\boldsymbol{\Omega}$), and slow structural capacitance reconstruction ($\mathbf{C}$) can exhibit transient reactive amplification before Lyapunov damping ($\dot{V} < 0$) stabilizes the new balance, or, if standing capacitance and conjugate pathways are exhausted, transition into an alternative attractor.


A recurring source of ambiguity in ecological thermodynamics is the convention of normalizing ecosystem state variables solely by geographic area ($\mathrm{m}^2$) or water volume ($\mathrm{m}^3$). Although convenient for field sampling, treating fixed spatial areas or volumes as thermodynamic containers introduces dimensional artifacts when total standing biovolume varies across orders of magnitude. An open-water plankton column, a benthic detrital bed, and a forest stand of equal ground area contain vastly different quantities of active biological matter. In biological communities, the physical vessel storing chemical energy and configurational entropy is the standing biomass ($B$) within a local control volume.


Let an ecological compartment $i$ contain stationary standing biomass $B_i^*$ (measured in extensive units such as $\mathrm{g\,C}$, $\mathrm{kcal}$, or $\mathrm{mmol\,N}$). Near a local non-equilibrium steady state where elemental stoichiometry and specific chemical energy are maintained homeostatically, the diagonal entries of the symmetric, positive-definite entropy Hessian $\mathbf{H} = -\partial^2 \Delta S_{\mathrm{tot}} / \partial\mathbf{x}^2\big|_{\mathbf{x}^*}$ scale inversely with compartment standing stock ($H_{ii} \propto 1/B_i^*$, analogous to the ideal chemical curvature $H_{ii} = \frac{1}{T}\frac{\partial \mu_i}{\partial x_i} = \frac{R_{\mathrm{gas}}}{x_i^*}$). By the Einstein-Onsager fluctuation relation ($\mathbf{C} = \langle \delta\mathbf{x}\delta\mathbf{x}^{\mathsf{T}}\rangle = k_{\mathrm{B}}\mathbf{H}^{-1}$), the entropic storage capacitance of compartment $i$ is proportional to its standing biomass:


$$C_i \propto k_{\mathrm{B}}\, B_i^*$$


Consequently, the conjugate thermodynamic driving force $\delta\mathbf{X} = -\mathbf{H}\delta\mathbf{x} = -k_{\mathrm{B}}\mathbf{C}^{-1}\delta\mathbf{x}$ induced by an extensive mass or energy perturbation $\delta\mathbf{x} = \delta\mathbf{B}$ is:


$$\delta\mathbf{X} = -k_{\mathrm{B}}\mathbf{C}^{-1}\delta\mathbf{B}, \qquad \delta B_i = -\frac{1}{k_{\mathrm{B}}}C_i\,\delta X_i$$


This constitutive capacitance relation clarifies how biomass governs entropic Resistance. For a given extensive mass or energy shock $\delta B_i$, both the induced shift in intensive thermodynamic potential ($|\delta X_i| = k_{\mathrm{B}}|\delta B_i| / C_i \propto |\delta B_i| / B_i^*$) and the relative fractional state displacement ($|\delta\tilde{x}_i| = |\delta B_i| / B_i^*$) scale inversely with standing biomass $B_i^*$. Equivalently, for a given shift in intensive boundary force $|\delta X_i|$, a compartment with large capacitance $C_i$ absorbs a correspondingly large extensive mass transfer $|\delta B_i| \propto B_i^*|\delta X_i|$ before its intensive potential is displaced. Large standing biomass $B_{\text{tot}} = \sum_i B_i^*$ therefore provides high entropic Resistance by buffering intensive potentials and relative community structure against external shocks.


Conversely, ecosystem Resilience is governed by the mass-specific dissipative turnover rate:


$$\mathcal{R} = \frac{\sum_i R_i}{\sum_i B_i^*} \quad (\mathrm{yr}^{-1})$$


which characterizes the trace of the kinetic relaxation operator $\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}$ and sets the characteristic return rate of perturbations to the stationary attractor. Normalizing extensive departures by reference standing biomass ($\delta\tilde{x}_i = \delta B_i / B_i^*$) renders the state coordinates dimensionless strain variables while preserving the positive definiteness of $\mathbf{D}_{\mathrm{sym}}$ under linear congruence transformations (Appendix A), whereas projecting onto closed compositional simplex fractions ($\sum_i b_i = 1$) introduces a null-space singularity ($\det\mathbf{C}_b = 0$; Appendix B).


## Biomass Capacitance and Kinetic Turnover: Resistance vs. Resilience


Grounding stability in biomass capacitance resolves the classical tension between ecological Resistance and ecological Resilience [@WebsterEtAl_1975; @Pimm_1984; @Holling_1996; @Gunderson_2000]. Within this non-equilibrium thermodynamic framework, the two properties correspond to complementary physical operators. Entropic Resistance is governed by the stationary covariance capacitance $\mathbf{C}$ and measures the ability of an ecosystem to absorb extensive mass or energy disturbances without undergoing large shifts in intensive thermodynamic forces or fractional species composition. Ecosystems with large biomass reservoirs, such as old-growth forests, peatlands, and detritus-buffered streams, exhibit high Resistance. Kinetic Resilience is governed by the mass-specific turnover operator $\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}$ and measures the rate at which perturbations decay back to steady state. Ecosystems with small standing biomass but high mass-specific metabolic rates, such as open-ocean surface plankton, microbial biofilms, and ephemeral pools, exhibit high Resilience; although sensitive to initial displacement, their rapid specific turnover drives fast recovery.


Because biological tissue allocation faces allometric and resource-supply constraints, ecosystems organize along a hyperbolic Resistance-Resilience trade-off continuum (Fig. \ref{fig_ecosystem_comparison}; Fig. 2):


$$B_{\text{tot}} \times \mathcal{R} \approx \text{constant}$$


where $B_{\text{tot}}$ is total standing biomass capacitance and $\mathcal{R}$ is mass-specific metabolic turnover. Under a bounded area- or volume-specific primary energetic supply $P_{\mathrm{in}}$ balanced at stationarity by total community respiration $R_{\mathrm{tot}} = \sum_i R_i \approx P_{\mathrm{in}}$, the product $B_{\text{tot}} \times \mathcal{R} = B_{\text{tot}} \times (R_{\mathrm{tot}} / B_{\text{tot}}) = R_{\mathrm{tot}}$ is constrained by the environmental energy budget (and reinforced in frequency space by the Bode sensitivity integral). Dense benthic detrital beds and mature forests occupy the high-Resistance, low-Resilience region of this frontier, whereas open pelagic waters and microbial communities occupy the low-Resistance, high-Resilience region.


The capacity of an ecosystem to partition its life-history and metabolic investments along this hyperbolic frontier defines its adaptive capacity on the thermodynamic landscape. When a stationary homeostatic operating point along this frontier is established for a given environmental regime, the community maintains a **Le Chatelier-Braun balance**. In this state, primary perturbations are moderated by coupled secondary pathways via the matrix Schur complement (both through direct symmetric dissipative cross-couplings where $0 < L_{ii,\mathrm{eff}} \le L_{ii}$ and through cyclic indirect trophic feedbacks where stationary compliance $0 < L_{ii,\mathrm{eff}}^{-1} \le L_{ii}^{-1}$ is reduced; Appendix B) and decay monotonically along the quadratic Lyapunov availability functional ($\dot{V} < 0$; Appendix A). This stationary regime reflects a boundary-versus-interior variational duality (Appendix A): under fixed external driving forces $X_0$ (incident solar irradiance, ambient temperature, or chemical affinities), boundary transport maximizes dissipation ($P_{\mathrm{boundary}} = L_{\mathrm{boundary}} X_0^2$), whereas under fixed nutrient throughflows $J_0$, unconstrained internal forces relax toward minimum internal dissipation per unit squared biomass ($\sigma / B_{\mathrm{tot}} \propto B_{\mathrm{tot}}^{-2}$).


However, when an acute shock or sustained regime shift perturbs the ecosystem, this Le Chatelier-Braun balance is broken. To persist, the system must dynamically re-establish balance under the altered conditions, governed by the modified **external gradients** (boundary thermodynamic forces such as solar flux, temperature, or nutrient inputs) and the **internal mechanisms that remain available** (surviving biomass capacitance reserves $\mathbf{C}$, allometric size-spectrum diversity, and intact non-dissipative circulation pathways $\boldsymbol{\Omega}$). This re-equilibration unfolds across a temporal hierarchy: immediate kinetic resilience ($\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}$) dampens acute shocks within days via high-turnover guilds; seasonal reorganization recruits standing capacitance ($\mathbf{C}$) and reconfigures trophic circulation loops ($\boldsymbol{\Omega}$); and multi-decadal allometric succession reconstructs slow macroscopic order parameters ($C(M) \propto M^{1-b}$, $\lambda(M) \propto M^{b-1}$). Because the community matrix $\mathbf{A} = -(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}$ is non-normal ($\mathbf{A}\mathbf{A}^{\mathsf{T}} \ne \mathbf{A}^{\mathsf{T}}\mathbf{A}$), transient reactive amplification can temporarily heighten variance or population fluctuations before asymptotic Lyapunov relaxation restores the stationary balance. If surviving internal mechanisms provide sufficient Adaptive Capacity to match the altered external gradient, the community re-equilibrates to a new Le Chatelier-Braun balance; if internal capacitors are degraded beyond recovery, the balance collapses into instability.


![Thermodynamic phase space of ecosystems: The Resistance-Resilience Trade-Off Continuum and non-equilibrium circulation. (A) The Resistance-Resilience trade-off continuum: plotting total biomass capacitance $\log_{10} B_{\text{tot}}$ (Resistance) against mass-specific metabolic turnover $\log_{10}\mathcal{R}$ (Resilience) reveals an overarching trade-off across world biomes, from dense benthic detrital beds and ancient forests to pelagic oceans. (B) Detailed balance violation: the non-equilibrium circulation ratio $\chi = \|\boldsymbol{\Omega}\|_{F} / \|\mathbf{D}_{\mathrm{sym}}\|_{F}$ quantifies driven cyclic currents in living food webs. (C) Phase space relaxation: state departures spiral inward under a negative-definite Lyapunov potential while driven currents maintain non-equilibrium circulation. (D) Characteristic relaxation timescales: complex eigenvalue distributions distinguish rapid kinetic recovery in pelagic plankton (period of approximately 42 days) from slow, massive detrital damping in benthic streams (period of approximately 296 days).](media/fig_ecosystem_comparison.png){#fig_ecosystem_comparison width=85%}


# Toy model


To verify continuous Lyapunov covariance factorization and estimator consistency across distinct physical and ecological network topologies, three analytical benchmark models implemented in `OnsagerNetwork` were evaluated (Fig. \ref{fig_app2_mock_results}):

- **Two-mode and four-mode thermal networks:** Two heat reservoirs ($T_1, T_2$) coupled by thermal conductances at $T = 300\ \mathrm{K}$ are simulated with and without non-reciprocal driving $\kappa$. At equilibrium ($\kappa = 0$), fluctuations obey detailed balance and the continuous-time quadrature estimator recovers the exact symmetric conductivity $\widehat{\mathbf{L}}_x \to \mathbf{L}$ with vanishing circulation ($\boldsymbol{\Omega} = \mathbf{0}$). Under non-equilibrium driving ($\kappa = 0.5\ \mathrm{s}^{-1}$), probability circulation $\Omega_{12}$ and excess dissipation $\sigma$ emerge and scale quadratically with $\kappa$ (Fig. \ref{fig_app2_mock_results}A,B), while diagonal coordinate rescaling $\boldsymbol{\Lambda} = \operatorname{Diag}(2.0, 0.5)$ and four-mode marginal coarse-graining confirm exact congruence transformation $\widehat{\mathbf{L}}_y = \boldsymbol{\Lambda}\widehat{\mathbf{L}}_x\boldsymbol{\Lambda}^{\mathsf{T}}$.

- **Fast-slow evolving trait network:** A two-pathway reversible Markov jump reaction network coupled to a slowly evolving behavioral or physiological trait $\theta_k$ demonstrates that adiabatic elimination of the secondary pathway via the Schur complement moderates the effective primary conductivity ($0 < L_{11,\mathrm{eff}}(\theta_k) \le L_{11}(\theta_k)$; Fig. \ref{fig_app2_mock_results}C).

- **Three-species trophic chain:** A three-species producer-herbivore-carnivore Ornstein-Uhlenbeck system with asymmetric community matrix $\mathbf{A}$ ($A_{ij} \ne A_{ji}$) confirms that continuous Lyapunov factorization recovers the positive-definite dissipative matrix $\widehat{\mathbf{K}}_{\mathrm{cov}} = -\widehat{\mathbf{A}}\widehat{\mathbf{C}}$ with relative Frobenius error below $2\%$, whereas naive biomass-fraction weighting $\mathbf{W}_B = \mathbf{A}\operatorname{Diag}(\mathbf{b})$ remains asymmetric (Fig. \ref{fig_app2_mock_results}D).


![Analytical verification of Onsager symmetry recovery, driven probability circulation, evolutionary trait adaptation, and coordinate invariance. (A) Two-mode thermal network decomposition: off-diagonal phenomenological conductivities in equilibrium ($\kappa = 0$) and driven non-equilibrium steady states (NESS, $\kappa = 0.5\ \mathrm{s}^{-1}$), showing exact recovery of symmetric conductivity $\mathbf{L}_{12}$ and emergent antisymmetric probability circulation $-\Omega_{12} / k_{\mathrm{B}}$. (B) Quadratic scaling: non-equilibrium probability circulation $\Omega_{12}^2$ and excess dissipation $\dot{S}_{\mathrm{diss}}$ scale quadratically with non-equilibrium driving force $\kappa$. (C) Fast-slow evolving trait adaptation: conditional conductivity and Schur complement moderation under Le Chatelier-Braun adaptation. (D) 3-species trophic chain: recovery of Onsager reciprocal symmetry and invariance under linear coordinate transformations.](media/fig_app2_mock_results.png){#fig_app2_mock_results width=85%}


# Empirical Applications: Benthic Cold Springs vs. Open-Ocean Plankton Ecosystems


To demonstrate the empirical utility of this non-equilibrium thermodynamic framework, the methodology is applied to two contrasting aquatic ecosystems with published empirical flow budgets: the classic benthic, detritus-buffered Cone Spring food web [@Tilly_1968; @Patten_1978; @Ulanowicz_1986] and the open-ocean plankton network at the Bermuda Atlantic Time-series Study (BATS) site in the Sargasso Sea [@FashamEtAl_1990; @Spitz_2001; @Steinberg_2001; @Zheng_2024]. In addition, an exploited marine fishery model (NPZD-Fish) is evaluated to examine how harvesting pressure alters thermodynamic attractor stability.


## The Benthic Cold-Spring Ecosystem: High-Resistance Detrital Storage (Cone Spring)


Cone Spring is a cold limnocrene freshwater spring in Iowa characterized by steady subterranean discharge, a stenothermal temperature regime (approximately 10 degrees Celsius year-round), and heavy reliance on allochthonous organic matter inputs [@Tilly_1968; @Patten_1978; @Ulanowicz_1986]. The biological community is organized into five functional guilds (Table \ref{tbl:app_cone_full}): primary producers ($x_1$), organic detritus ($x_2$), decomposer microbes ($x_3$), benthic shredders and grazers ($x_4$), and benthic predators ($x_5$). Primary producers are dominated by rooted macrophyte beds of freshwater watercress (*Nasturtium officinale*) and epiphytic benthic microalgae that carpet the spring substrate, fixing solar irradiance during spring and summer. The organic detritus pool constitutes a large non-living organic matter reservoir comprising decaying deciduous tree litter, predominantly oak, elm, and hickory foliage from the surrounding riparian forest canopy, intermixed with submerged particulate organic muck. Decomposer microbes consist of benthic heterotrophic bacteria and microbial biofilms adhering to decaying leaves, secreting extracellular enzymes to digest cellulose and refractory structural lignin. Benthic shredders and grazers are dominated by cold-adapted amphipod crustacea (*Gammarus pseudolimnaeus*) and aquatic isopods (*Asellus militaris*), which shred coarse leaf litter while assimilating bacterial biofilms coating leaf surfaces. Finally, benthic predators comprise secondary and tertiary consumers including freshwater planarians (*Phagocata morgani*), leeches, and predatory larval salamanders (*Eurycea bislineata*) that feed upon amphipods and detritivores.


| Compartment ($i$) | $B_i^*$ | Inflow $z_i$ | To $x_1$ | To $x_2$ | To $x_3$ | To $x_4$ | To $x_5$ | Exports $E_i$ | Resp. $R_i$ | Flow $T_i$ |

|:-------------------------|:------:|:---------:|:-------:|:-------:|:-------:|:-------:|:-------:|:-----------:|:---------:|:--------:|

| **1. Plants** | $285.0$ | $11\,184$ | $0$ | $0$ | $0$ | $0$ | $0$ | $300$ | $2\,003$ | $11\,184$ |

| **2. Detritus** | $3\,580.0$ | $635$ | $8\,881$ | $0$ | $1\,600$ | $200$ | $167$ | $860$ | $3\,109$ | $11\,483$ |

| **3. Bacteria** | $116.6$ | $0$ | $0$ | $5\,205$ | $0$ | $0$ | $0$ | $255$ | $3\,275$ | $5\,205$ |

| **4. Detritivores** | $60.0$ | $0$ | $0$ | $2\,309$ | $75$ | $0$ | $0$ | $0$ | $1\,814$ | $2\,384$ |

| **5. Carnivores** | $17.0$ | $0$ | $0$ | $0$ | $0$ | $370$ | $0$ | $0$ | $203$ | $370$ |


Table: Complete steady-state energy flow matrix for Cone Spring [@Tilly_1968; @Patten_1978; @Ulanowicz_1986]. Column headers denote standing biomass $B_i^*$ ($\mathrm{kcal\,m^{-2}}$), external inflow $z_i$, internal trophic transfers $T_{j\to i}$ from source row $j$ to recipient column $i$ ($x_1$: Plants, $x_2$: Detritus, $x_3$: Bacteria, $x_4$: Detritivores, $x_5$: Carnivores), net exports $E_i$, respiration dissipation $R_i$, and total throughflow $T_i$. {#tbl:app_cone_full}


Following the energetic interaction parameterization of de Ruiter et al. [-@de_Ruiter_et_al_1995], the steady-state energy flows $F_{ji}$ from prey $j$ to consumer $i$, compartment throughflows $T_i$, and respirations $R_i$ define the linearized community matrix $\mathbf{A}_{\mathrm{CS}}$ for the three-compartment living heterotrophic food chain (1: Bacteria, 2: Detritivores, 3: Carnivores):

Direct consumer suppression of prey is $A_{ji} = -F_{ji} / B_i^*$, assimilated prey enhancement of consumer growth is $A_{ij} = +e_i F_{ji} / B_j^*$ with production efficiency $e_i = (T_i - R_i) / T_i$, and intraspecific self-damping is $A_{ii} = -s R_i / B_i^*$ ($s = 0.10$):


$$\mathbf{A}_{\mathrm{CS}} = \begin{bmatrix} -2.8087 & -1.2500 & 0 \\ 0.1538 & -3.0233 & -21.7647 \\ 0 & 2.7833 & -1.1941 \end{bmatrix}\ \mathrm{yr^{-1}}$$


Spectral decomposition of $\mathbf{A}_{\mathrm{CS}}$ yields a real eigenvalue $\lambda_1 = -2.8036\ \mathrm{yr^{-1}}$ and a complex conjugate pair $\lambda_{2,3} = -2.1113 \pm 7.7414i\ \mathrm{yr^{-1}}$, corresponding to an internal oscillation period of $T = 2\pi / |\operatorname{Im}(\lambda_{2,3})| = 296\ \mathrm{days}$. Naive attempts to construct a conductivity matrix by multiplying $-\mathbf{A}_{\mathrm{CS}}$ directly by diagonal standing biomass $\operatorname{Diag}(\mathbf{B}^*)$ produce an indefinite symmetric part with a negative eigenvalue ($\lambda_{\min} = -29.16\ \mathrm{kcal\,m^{-2}\,yr^{-1}}$; Fig. \ref{fig_app3_cone_spring}A), which would falsely suggest a violation of the Second Law. In contrast, solving the continuous Lyapunov equation $\mathbf{A}_{\mathrm{CS}}\mathbf{C}_{\mathrm{CS}} + \mathbf{C}_{\mathrm{CS}}\mathbf{A}_{\mathrm{CS}}^{\mathsf{T}} + 2\mathbf{D}_{\mathrm{CS}} = \mathbf{0}$ with metabolic fluctuation diffusion $\mathbf{D}_{\mathrm{CS}} = \operatorname{Diag}(s R_i B_i^*)$ yields the positive-definite stationary covariance matrix:


$$\mathbf{C}_{\mathrm{CS}} = \begin{bmatrix} 13\,629.90 & -77.16 & -69.10 \\ -77.16 & 3\,240.05 & 49.46 \\ -69.10 & 49.46 & 404.28 \end{bmatrix}\ (\mathrm{kcal\,m^{-2}})^2$$


and the skew-symmetric non-equilibrium probability circulation tensor $\boldsymbol{\Omega}_{\mathrm{CS}} = \frac{1}{2}(\mathbf{C}_{\mathrm{CS}}\mathbf{A}_{\mathrm{CS}}^{\mathsf{T}} - \mathbf{A}_{\mathrm{CS}}\mathbf{C}_{\mathrm{CS}})$:


$$\boldsymbol{\Omega}_{\mathrm{CS}} = \begin{bmatrix} 0 & 3\,833.33 & -132.26 \\ -3\,833.33 & 0 & 8\,959.08 \\ 132.26 & -8\,959.08 & 0 \end{bmatrix}\ (\mathrm{kcal\,m^{-2}})^2\,\mathrm{yr}^{-1}$$


Evaluating these operators across the Cone Spring guilds highlights three structural properties of cold-spring stability (Fig. \ref{fig_app3_cone_spring}). First, detrital storage capacitance dominates the network: the detrital reservoir ($B_2^* = 3\,580\ \mathrm{kcal\,m^{-2}}$, or approximately $358.3\ \mathrm{g\,C\,m^{-2}}$) accounts for over 88% of total standing stock, acting as an entropic shock absorber (Resistance) that buffers seasonal pulses of autumnal leaf fall and prevents boom-and-bust starvation cycles in detritivores. Second, the community operates at a low stationary entropy production rate density ($\sigma = 90.35\ \mathrm{yr^{-1}}$) with a slow relaxation period of 296 days. Third, the non-zero entries of $\boldsymbol{\Omega}_{\mathrm{CS}}$ quantify persistent cyclic trophic flow across the benthic food chain (detritivores grazing bacteria and carnivores preying upon detritivores, with mortality returning organic matter to detritus), maintaining moderate probability circulation ($\chi = 0.85$ across the five-compartment network; $\chi = 0.245$ within the three-guild heterotrophic chain) while $\mathbf{D}_{\mathrm{sym}} = \mathbf{D}_{\mathrm{CS}} \succ 0$ guarantees monotonic Lyapunov decay (Fig. \ref{fig_app3_cone_spring}B).


![Thermodynamic flow network decomposition of the Cone Spring benthic ecosystem [@Tilly_1968]. (A) Resolution of the indefinite symmetric part paradox: while the raw community matrix sum $\mathbf{A} + \mathbf{A}^{\mathsf{T}}$ contains spurious negative eigenvalues, the continuous Lyapunov transformation $-\mathbf{A}\mathbf{C} - \mathbf{C}\mathbf{A}^{\mathsf{T}} = 2\mathbf{D}_{\mathrm{sym}}$ is strictly positive-definite. (B) Monotonic Lyapunov decay: relaxation trajectories follow negative-definite quadratic potentials $V(\delta\mathbf{x}) = \delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\delta\mathbf{x}$, demonstrating global asymptotic stability. (C) Stationary covariance structure: cross-compartment correlations across the five trophic pools (Plants, Detritus, Herbivores, Carnivores, Deposit Feeders). (D) Resistance vs. Resilience across compartments: detritus dominates biomass capacitance ($B_2^* = 358.3\ \mathrm{g\,C\,m^{-2}}$, high Resistance), while active carnivores and herbivores govern kinetic turnover (high Resilience).](media/fig_app3_cone_spring.png){#fig_app3_cone_spring width=85%}


## The Open-Ocean Plankton Ecosystem: High-Resilience Kinetic Turnover (BATS Site)


In contrast to the benthic detrital spring, open-ocean planktonic ecosystems operate in an unattached, three-dimensional fluid environment driven by high-frequency solar irradiance and rapid nutrient cycling. A four-compartment Nutrient-Phytoplankton-Zooplankton-Detritus (NPZD) network is parameterized using observations from the Bermuda Atlantic Time-series Study (BATS) in the oligotrophic Sargasso Sea [@FashamEtAl_1990; @Spitz_2001; @Steinberg_2001; @Zheng_2024].


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


When heavy industrial fishing mortality is imposed ($H = q E F$), the thermodynamic trajectory parallels documented marine groundfish collapses, such as the collapse of Northwest Atlantic cod (*Gadus morhua*) on the eastern Scotian Shelf and Grand Banks [@Choi_et_al_2004; @Choi_et_al_2005a; @Choi_2023]. Selective harvesting of long-lived predatory fish drains the slow apex capacitor ($C_{55} \to 0$, reducing total standing stock to $B_{\text{tot}} \approx 0.035\ \mathrm{g\,C\,m^{-3}}$), removing the top-down buffer that regulated lower trophic tiers. Deprived of predatory damping, the food web truncates into a volatile community dominated by fast-turnover plankton, small pelagic forage fish, and macroinvertebrates. Probability circulation between phytoplankton and zooplankton surges ($\chi = 2.68$), the characteristic response timescale shortens to 18.5 days, and internal entropy production rate density rises to $\sigma = 425.03\ \mathrm{yr^{-1}}$ (4.7 times that of Cone Spring). Stripping the slow biomass capacitor flattens the local entropic potential well ($\mathbf{H} \to 0$), so that modest temperature or wind anomalies induce large-amplitude plankton swings and precondition the ecosystem for transition into an alternative degraded Le Chatelier-Braun regime.


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


Empirical marine and terrestrial surveys reveal that total biomass tends to distribute evenly across logarithmic body-mass octaves, a macroecological regularity known as the biomass size spectrum [@SheldonEtAl_1972; @Kerr_1974; @PlattEtAl_1977; @RodriguezEtAl_1986; @Boudreau_Dickie_1992; @ChoiEtAl_1999; @KerrEtAl_2001; @Andersen_2019]:


$$\frac{dB(m)}{d\ln m} \approx \text{constant}$$


When taken as a whole, the observation of biomass size spectra in aquatic and terrestrial systems [@SheldonEtAl_1972; @Kerr_1974; @PlattEtAl_1977; @RodriguezEtAl_1986; @Boudreau_Dickie_1992; @ChoiEtAl_1999] can be seen as energy cascades across hierarchies of spatiotemporal scales. While biomass density remains approximately invariant across mass octaves, metabolic rates scale non-linearly with individual organismal mass according to Kleiber's law [@Kleiber_1932; @WestEtAl_1997; @BrownEtAl_2004]: individual metabolic rate scales as $B_{\text{ind}} \propto m^{3/4}$, which implies that mass-specific metabolic dissipation scales as:


$$\rho(m) \propto m^{-1/4}$$


This quarter-power allometric scaling creates a systematic functional partitioning across the size spectrum (Fig. \ref{fig_energy_cascade}A). At microscopic scales ($m \to 0$), high mass-specific turnover ($\rho(m) \propto m^{-0.25}$) combines with small individual storage capacitance ($C_{\text{ind}} \propto m^1$), such that small organisms, including bacteria, flagellates, and phytoplankton, function primarily as high-frequency kinetic dissipators conferring Resilience. At macroscopic scales ($m \to \infty$), low mass-specific turnover combines with large individual storage capacitance ($C_{\text{ind}} \propto m^1$), so that large organisms, such as trees, megafauna, and apex marine predators, function as low-frequency entropic shock absorbers conferring Resistance.


In the frequency domain, each organismal size class $m$ with characteristic relaxation rate $\lambda(m) \propto \rho(m) \propto m^{-1/4}$ and relaxation time $\tau(m) = \lambda(m)^{-1} \propto m^{1/4}$ acts as a first-order low-pass Fourier impedance filter with transfer function $|H(\omega; m)| = [1 + (\omega \tau(m))^2]^{-1/2}$ (Fig. \ref{fig_energy_cascade}B). Fast-turnover microbes ($\tau \sim \text{hours to days}$) track and dissipate high-frequency environmental fluctuations (such as diurnal solar cycles and synoptic weather events) into metabolic heat, whereas long-lived macroscopic organisms and detrital reservoirs ($\tau \sim \text{years to decades}$) attenuate high-frequency variance and integrate low-frequency planetary forcing (such as seasonal cycles, El Niño Southern Oscillation variability, and multi-decadal climate anomalies; Fig. \ref{fig_energy_cascade}C,D).


![The multi-scale energy dissipation cascade and size-spectrum impedance filtering. (A) Allometric partitioning of function: mass-specific metabolic dissipation $\rho(m) \propto m^{-0.25}$ (orange line) dominates microscopic scales, while standing biomass capacitance $B(m)$ (blue dashed line) acts as a high-inertia storage capacitor at macroscopic scales. (B) Dynamic frequency transfer functions $|H(\omega)|$: different body-mass classes act as tuned Fourier impedance filters, absorbing and damping environmental forcing across diurnal, seasonal, and decadal (ENSO) bands. (C) Planetary power absorption spectrum: ambient red environmental climate noise (dotted black line) is partitioned into high-frequency metabolic dissipation by microbial heatsinks (orange shaded region) and low-frequency memory integration within long-lived biomass buffers (blue shaded region). (D) Dynamic biospheric impedance across Earth system octaves, demonstrating progressive multi-scale damping from rapid diurnal solar fluctuations to multi-decadal climate stabilization.](media/fig_energy_cascade.png){#fig_energy_cascade width=85%}


## Biomass Size Spectra as Cross-Scale Signatures of Energy Dissipation


The empirical regularities of biomass size spectra in aquatic and terrestrial communities provide a direct macroecological signature of how living systems organize energy dissipation across spatiotemporal hierarchies [@SheldonEtAl_1972; @Kerr_1974; @PlattEtAl_1977; @RodriguezEtAl_1986; @Boudreau_Dickie_1992; @ChoiEtAl_1999]. In continuum mechanics, Kolmogorov [-@Kolmogorov_1941] demonstrated that three-dimensional fluid turbulence resolves the disparity between macroscopic energy injection and microscopic molecular viscosity through a scale-invariant cascade across wavenumbers. In ecological communities, the continuous biomass size spectrum performs an analogous thermodynamic function across coupled spatial, temporal, and body-mass coordinates.


In classical fluid turbulence, kinetic energy enters at macroscopic integral length scales ($L_0$) driven by large-scale boundary forcing, cascades conservatively across an intermediate inertial subrange via non-linear vortex stretching, and terminates at the Kolmogorov microscale ($\eta$), where molecular viscosity converts kinetic motion irreversibly into heat. This cascade arises because macroscopic boundary forcing and molecular dissipation operate at widely separated scales.


Ecological communities confront an analogous scale disparity. Solar radiation, nutrient upwelling, seasonal hydrographic cycles, and climate anomalies inject free energy and physical perturbations across broad macroscopic spatial domains and low-frequency temporal bands, whereas irreversible biochemical respiration and nutrient mineralization occur across cellular membranes at micrometer spatial scales and sub-second biochemical reaction rates. As formulated in continuum theories of the pelagic biomass spectrum [@PlattEtAl_1977; @Kerr_1974; @Boudreau_Dickie_1992], metabolic assimilation and trophic predation generate a continuous spectral flux of biomass and chemical free energy across logarithmic body-size octaves, coupled to the microbial and detrital remineralization loop. Within the non-equilibrium Onsager framework, this hierarchical cascade partitions into three complementary physical regimes across the spatiotemporal spectrum.


### Macro-Scale Capacitive Integration and Low-Frequency Storage


At the largest organismal and detrital scales ($m \to m_{\max}$), slow mass-specific metabolic turnover ($\rho(m) \propto m^{-1/4}$) and long generation times ($\tau(m) \propto m^{1/4}$) produce high entropic storage capacitance ($C(m) \propto B(m)/k_{\mathrm{B}}$). Large-bodied apex predators, long-lived trees, and recalcitrant soil or benthic detrital pools integrate energy and matter over large spatial foraging ranges and multi-annual to multi-decadal timescales.


Rather than tracking high-frequency environmental fluctuations, these macroscopic compartments act as low-pass thermodynamic capacitors that absorb pulse disturbances, seasonal resource deficits, and interannual climate anomalies without large excursions in intensive chemical potential ($\delta X_i = -k_{\mathrm{B}} C_i^{-1} \delta B_i$). In the size spectrum, the secondary domes and standing stocks of large-bodied guilds [@Boudreau_Dickie_1992] represent localized capacitive reservoirs that anchor the low-frequency stability (Resistance) of the community.


### Trophic Spectral Transport and Cross-Scale Probability Circulation


Across intermediate body-size octaves, energy and matter are transported continuously along the size spectrum through size-selective predation, grazing, and detrital fragmentation [@Kerr_1974; @PlattEtAl_1977; @RodriguezEtAl_1986]. As biomass moves from primary producers through successive consumer size classes and returns via organic matter excretion and decomposition, each trophic transfer couples compartments with distinct characteristic timescales $\tau(m)$ and spatial ambits.


In the covariance-weighted drift decomposition $-\mathbf{A}\mathbf{C} = \mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega}$, this directional cross-scale flux is governed by the skew-symmetric probability circulation tensor ($\boldsymbol{\Omega}$). Because $\boldsymbol{\Omega} = -\boldsymbol{\Omega}^{\mathsf{T}}$ is antisymmetric, purely circulatory transport across size classes conserves instantaneous thermodynamic availability ($\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}\delta\mathbf{x} = 0$), functioning as the ecological counterpart to the inertial transport subrange. It couples slow, broad-scale macroscopic biomass reservoirs to fast, fine-scale microbial guilds through closed biogeochemical cycles.


### Micro-Scale Metabolic Dissipation and High-Frequency Damping


At the smallest organismal scales ($m \to m_{\min}$), encompassing bacteria, picoplankton, and microflagellates, surface-to-volume ratios and mass-specific metabolic rates reach their maxima ($\rho(m) \propto m^{-1/4} \to \infty$, $\tau(m) \to 0$). Here, the symmetric Onsager dissipative conductivity ($\mathbf{D}_{\mathrm{sym}} \succ 0$, Resilience) dominates the dynamics.


As organic matter and chemical free energy circulate into the microbial and fine detrital pools, high-turnover enzymatic respiration and remineralization rapidly degrade chemical potential gradients into low-grade thermal entropy ($\sigma = k_{\mathrm{B}}^{-1}\mathbf{X}^{\mathsf{T}}\mathbf{D}_{\mathrm{sym}}\mathbf{X} > 0$) while regenerating inorganic nutrients for primary production. The high-frequency portion of the size spectrum thus acts as the primary dissipative sink of the biosphere, damping rapid environmental perturbations before they can accumulate or destabilize slower trophic tiers.


### Cross-Scale Integrity and Anthropogenic Truncation of the Size Spectrum


Viewing biomass size spectra as cross-scale signatures of energy dissipation clarifies why perturbations to the slope or extent of the size spectrum serve as sensitive indicators of ecosystem distress [@ChoiEtAl_1999; @KerrEtAl_2001]. In an unperturbed community, the allometric scaling of capacitance $C(m)$ and turnover $\lambda(m)$ across the size spectrum maintains a balanced impedance profile across frequencies, seamlessly coupling multi-decadal storage to diurnal metabolic dissipation.


When size-selective industrial fishing, deforestation, or chronic eutrophication truncates the macroscopic end of the size spectrum or steepens its logarithmic slope, the community loses its slow, high-capacitance storage compartments ($C(m)$ at large $m$). Energy throughput is then forced exclusively through truncated, fast-turnover planktonic and microbial loops, inflating the circulation-to-dissipation ratio ($\chi$) and elevating specific entropy production ($\sigma$), as demonstrated empirically in the exploited NPZD-Fish food web (Table \ref{tbl:aquatic_comparison}). Conversely, degrading microbial and detrital recycling guilds impairs symmetric dissipation ($\mathbf{D}_{\mathrm{sym}}$), bottlenecking nutrient regeneration. Persistence across fluctuating environments therefore requires preserving the full allometric continuum of the biomass size spectrum so that storage capacitance, cross-scale circulation, and metabolic dissipation remain coupled across spatiotemporal scales.


# The Non-Linear Regime: Quasi-Potential Landscapes and Early-Warning Diagnostics


## The Non-Equilibrium Quasi-Potential Landscape


While linear non-equilibrium thermodynamics characterizes relaxation near a stationary state, living ecosystems frequently experience large perturbations, multi-stability, and regime transitions [@Holling_1973; @May_1977; @SchefferEtAl_2001]. In this non-linear regime, stochastic population dynamics are governed by continuous Fokker-Planck diffusion equations and non-equilibrium quasi-potential landscapes [@Graham_1977; @Freidlin_Wentzell_1984; @Ao_2004; @WangEtAl_2008; @ZhouEtAl_2012].


The scalar quasi-potential $U(\mathbf{x}) = -\lim_{\mathcal{V} \to \infty} \mathcal{V}^{-1}\ln P_{\mathrm{ss}}(\mathbf{x})$ defines the topographical stability basin of the community in extensive state space. A deep, steep potential basin corresponds to a well-buffered ecosystem that absorbs disturbances and returns rapidly to its stationary attractor, whereas a shallow, flattened basin indicates an eroded attractor vulnerable to noise-induced transitions across a saddle barrier into an alternative state.


As derived in Appendix A, any smooth non-linear ecological drift field $\mathbf{f}(\mathbf{x})$ admits a Helmholtz-Hodge decomposition into two orthogonal components:


$$\mathbf{f}(\mathbf{x}) = -\mathbf{D}(\mathbf{x})\nabla U(\mathbf{x}) + \mathbf{v}_{\mathrm{curl}}(\mathbf{x}), \qquad \nabla U(\mathbf{x}) \cdot \mathbf{v}_{\mathrm{curl}}(\mathbf{x}) = 0$$


The first component is the downhill dissipative gradient drift $-\mathbf{D}(\mathbf{x})\nabla U(\mathbf{x})$, governed by the symmetric, positive-definite diffusion tensor $\mathbf{D}(\mathbf{x}) \succ 0$, which draws trajectories down the gradient of $U(\mathbf{x})$ through irreversible metabolic dissipation. The second component is the solenoidal probability circulation velocity $\mathbf{v}_{\mathrm{curl}}(\mathbf{x}) = \mathbf{J}_{\mathrm{prob}}(\mathbf{x}) / P_{\mathrm{ss}}(\mathbf{x}) = \boldsymbol{\Omega}(\mathbf{x})\nabla U(\mathbf{x})$, generated by a state-dependent skew-symmetric circulation tensor $\boldsymbol{\Omega}(\mathbf{x}) = -\boldsymbol{\Omega}(\mathbf{x})^{\mathsf{T}}$. Because $\boldsymbol{\Omega}(\mathbf{x})$ is skew-symmetric, $\mathbf{v}_{\mathrm{curl}}(\mathbf{x})$ is orthogonal to $\nabla U(\mathbf{x})$ everywhere in phase space and circulates along iso-potential contours without performing net work against $U(\mathbf{x})$. Consequently, $U(\mathbf{x})$ serves as a non-equilibrium Lyapunov function within each basin of attraction: deterministic trajectories spiral inward down $U(\mathbf{x})$ while non-equilibrium forcing sustains persistent cyclic currents around the attractor.


## Physical Early-Warning Signals for Catastrophic Regime Shifts


As environmental forcing or harvesting pressure pushes an ecosystem toward a bifurcation, the local quadratic curvature of the quasi-potential well ($\mathbf{H} = k_{\mathrm{B}}\mathbf{C}^{-1} \propto \nabla^2 U(\mathbf{x}^*)$) degrades along distinct mechanistic pathways that yield quantitative early-warning diagnostics [@Scheffer_2009]:


- **Curvature collapse and critical slowing down (fold bifurcation):** When chronic environmental stress weakens dissipative self-regulation ($\lambda_{\min}(\mathbf{D}_{\mathrm{sym}}) \to 0$) or erodes the entropic curvature ($\lambda_{\min}(\mathbf{H}) \to 0$), a real eigenvalue of $\mathbf{A}$ approaches zero ($\lambda_1 \to 0^-$). The restoring force along the soft eigenvector direction vanishes, lengthening recovery times after perturbations and causing stationary variance to diverge ($\mathbf{C}_{11} = k_{\mathrm{B}} / \lambda_{\min}(\mathbf{H}) \to \infty$) prior to a saddle-node transition.

- **Capacitance stripping and oscillatory destabilization (Hopf bifurcation):** When selective exploitation or habitat loss strips slow macroscopic biomass capacitors ($C_{ii} \to 0$) while strong trophic throughput sustains skew-symmetric circulation $\boldsymbol{\Omega}$, the non-equilibrium circulation ratio $\chi = \|\boldsymbol{\Omega}\|_F / \|\mathbf{D}_{\mathrm{sym}}\|_F$ surges, as observed in the exploited NPZD-Fish food web (Table \ref{tbl:aquatic_comparison}). A complex conjugate eigenvalue pair $\lambda_{1,2} = \alpha \pm i\omega$ approaches the imaginary axis ($\alpha \to 0^-$ with $\omega \ne 0$), generating amplified rotational fluctuation spirals and narrowband spectral ringing prior to oscillatory collapse.


For empirical monitoring and fisheries management, combining these thermodynamic diagnostics distinguishes directional attractor flattening from oscillatory destabilization. Lengthening recovery times and monotone variance inflation along a single trophic axis indicate fold-type curvature collapse ($\det \mathbf{H} \to 0$), whereas simultaneous inflation of the circulation ratio $\chi$, rising entropy production $\sigma$, and rotational phase-space spiraling indicate that apex or detrital storage capacitance has been stripped, providing an operational warning to reduce harvest mortality before a regime shift occurs.


# Discussion


No novel mathematical theorems are claimed in this framework; its analytical methods are drawn directly from established principles in statistical physics, network theory, and control engineering. In stochastic thermodynamics and non-equilibrium statistical mechanics, partitioning drift vector fields into a symmetric dissipative friction tensor ($\mathbf{D}_{\mathrm{sym}} \succ 0$) that governs entropy production and an antisymmetric probability circulation tensor ($\boldsymbol{\Omega} \ne \mathbf{0}$) that breaks microscopic detailed balance is standard for driven molecular motors, chemical master equations, and biophysical reaction networks [@Graham_1977; @Ao_2004; @Qian_2006; @Seifert_2012]. Analogous decompositions appear across physical and mathematical disciplines: Tellegen [-@Tellegen_1948] factored non-reciprocal electrical networks into symmetric dissipative conductances (resistors) and skew-symmetric non-dissipative couplings (gyrators); continuum mechanics partitions vector fields via the Helmholtz-Hodge decomposition into potential gradient descent and solenoidal vorticity circulation; and control theory evaluates stationary covariance and internal damping through the continuous algebraic Lyapunov equation $\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} = -2\mathbf{D}_{\mathrm{sym}}$ [@Lyapunov_1892; @BartelsEtAl_1972; @HornEtAl_2012]. Likewise, Gaussian fluctuation expansions around the entropy Hessian originate with Einstein [-@Einstein_1910], Greene and Callen [-@CallenEtAl_1951], and Callen [-@Callen_1985], while the matrix Schur complement reduction underlying the Le Chatelier-Braun principle follows Schur [-@Schur_1917], Bertalanffy [-@Bertalanffy_1950], and Prigogine and Defay [-@PrigogineEtAl_1954].


The primary contribution of this work lies in the interdisciplinary translation and synthesis of these principles to resolve a long-standing theoretical impasse in ecology. Because theoretical ecology developed Lotka-Volterra dynamics through phenomenological population modeling rather than physical transport theory, the demographic community matrix $\mathbf{A}$ was treated either as an unstructured random matrix [@May_1972] or as a direct physical conductivity [@MacArthur_1970; @Ulanowicz_Hannon_1987]. Observing opposing demographic signs in predator-prey interactions ($A_{12} < 0, A_{21} > 0$), ecologists concluded that trophic networks violate Onsager reciprocity and lie outside classical non-equilibrium thermodynamics. The Lyapunov covariance factorization $\mathbf{A} = -(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}$ demonstrates that $\mathbf{A}$ is not an unmediated Onsager conductivity, but a composite operator that convolves symmetric dissipation $\mathbf{D}_{\mathrm{sym}}$, antisymmetric circulation $\boldsymbol{\Omega}$, and standing biomass capacitance $\mathbf{C}$. Physical Onsager reciprocity holds strictly within the dissipative core $\mathbf{D}_{\mathrm{sym}} = \mathbf{D}_{\mathrm{sym}}^{\mathsf{T}} \succ 0$, whereas directional trophic asymmetry resides in the orthogonal circulation tensor $\boldsymbol{\Omega} = -\boldsymbol{\Omega}^{\mathsf{T}}$ (see Coda below).


Beyond resolving the reciprocity paradox, grounding ecological dynamics in physical biomass capacitance ($\mathbf{C} = k_{\mathrm{B}}\mathbf{H}^{-1}$) rather than arbitrary geometric boundaries aligns population state variables with intensive thermodynamic potentials. This formulation unifies the long-standing ecological debate surrounding ecosystem stability by showing that communities organize along an intrinsic Resistance-Resilience trade-off continuum (representing adaptive capacity along the Le Chatelier-Braun balance continuum in Fig. \ref{fig_respiration_biomass}) governed by standing capacitance storage $\mathbf{C}$ and mass-specific turnover velocity $\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}$ on the thermodynamic landscape. At a stationary operating point along this continuum, a Le Chatelier-Braun balance is established wherein coupled secondary pathways moderate external force displacements ($0 < L_{ii,\mathrm{eff}} \le L_{ii}$). When perturbed, this homeostatic balance dynamically re-establishes across hierarchical timescales to match altered external gradients through the internal biological and physical mechanisms that remain available. Coupled ecological feedbacks, such as mutualistic facilitation, host-parasite calibration, and predator-prey stabilization, thus emerge as physical manifestations of the Le Chatelier-Braun principle operating through convolved Onsager transport pathways.


## Implications for Ecosystem Management and Conservation


This thermodynamic framework carries direct implications for ecosystem monitoring, conservation, and resource management. Conventional management frequently targets single-species yield or uniform standing stock, for example through size-selective harvesting in capture fisheries or even-aged monocultures in forestry, without accounting for how these interventions alter the community's position along the Resistance-Resilience continuum (Fig. \ref{fig_respiration_biomass}). In demersal fisheries and old-growth forests, selectively removing the largest, longest-lived individuals depletes standing biomass capacitance ($\mathbf{C}$), eroding entropic Resistance and shifting the community toward smaller, higher-turnover guilds with elevated respiration-to-biomass ratios ($R/B$). Conversely, in agronomic or silvicultural monocultures, simplifying functional and size-structure diversity weakens the cross-trophic conjugate pathways ($\mathbf{L}_{i,-i}$) that moderate environmental shocks via the Schur complement ($L_{ii,\mathrm{eff}} = L_{ii} - \mathbf{L}_{i,-i}\mathbf{L}_{-i,-i}^{-1}\mathbf{L}_{-i,i}$). High-turnover systems such as pelagic upwelling fisheries exhibit rapid kinetic recovery ($\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}$) under moderate variability, but because their standing capacitance is small, sustained harvesting combined with climatic anomalies can rapidly exceed their buffering capacity when recruitment pathways are disrupted.


Furthermore, cyclic dynamics such as seasonal plankton blooms and predator-prey oscillations do not necessarily indicate ecological instability. Within the Lyapunov decomposition, the antisymmetric circulation tensor $\boldsymbol{\Omega}$ represents non-dissipative cyclic mass and energy transport across compartments ($\operatorname{Tr}(\boldsymbol{\Omega}\mathbf{C}^{-1}) = 0$); artificially suppressing natural population cycles or culling key trophic links distorts these rotational pathways and alters transient non-normal amplification.

Finally, the factorization $\mathbf{A} = -k_{\mathrm{B}}^{-1}(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{H}$ separates two distinct physical mechanisms of regime shifts. In a fold (saddle-node) transition, loss of curvature in the entropy Hessian along a critical mode ($\lambda_{\min}(\mathbf{H}) \to 0^+$) directly inflates stationary state covariance ($\mathbf{C} = k_{\mathrm{B}}\mathbf{H}^{-1}$, variance explosion) and drives a real eigenvalue of $\mathbf{A}$ toward zero (critical slowing down). Whereas in a Hopf (oscillatory) transition, nutrient enrichment or saturating functional responses erode symmetric dissipative damping ($\mathbf{D}_{\mathrm{sym}}$) along a coupled consumer-resource loop while circulation ($\boldsymbol{\Omega} \ne \mathbf{0}$) remains finite, driving a complex-conjugate eigenvalue pair toward the imaginary axis ($\operatorname{Re}(\lambda) \to 0^-, \operatorname{Im}(\lambda) = \pm\omega \ne 0$).

Monitoring community size spectra, respiration-to-biomass ratios, and cross-species covariance structure thus provides mechanistically grounded early-warning indicators of declining adaptive capacity prior to regime transitions.


## Evolutionary Tuning of the Stability Frontier


The above thermodynamic framework and the empirical application here resolves the apparent conflict between May's [-@May_1972] result that random network complexity reduces linear stability and the empirical persistence of diverse natural food webs. Living communities are not unstructured random matrices; rather, their interactions are constrained by mass-balance stoichiometry, allometric scaling across body-size spectra, and positive-definite Onsager dissipation ($\mathbf{D}_{\mathrm{sym}} \succ 0$). Standing biomass capacitance ($\mathbf{C}$, Resistance) buffers low-frequency environmental shortages and pulse shocks, mass-specific metabolic turnover ($\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}$, Resilience) drives rapid recovery through microbial and primary producer guilds, and skew-symmetric probability circulation ($\boldsymbol{\Omega}$) redistributes energy and nutrients across trophic cycles without degrading the local potential gradient.


Across biomes, communities self-organize along the hyperbolic Resistance-Resilience trade-off continuum ($B_{\text{tot}} \times \mathcal{R} \approx \text{constant}$; Fig. \ref{fig_ecosystem_comparison}; Fig. 2). The realized stationary operating point along this frontier represents a homeostatic **Le Chatelier-Braun balance**, in which coupled secondary pathways moderate primary disturbances via the matrix Schur complement and Lyapunov relaxation. When acute shocks or chronic forcing disrupt this balance, the community re-equilibrates across hierarchical timescales, conditioned upon the altered boundary gradients and the internal biological capacitance and circulation pathways that remain intact.


## Haken's Slaving Principle and Planetary Stewardship


In synergetics, Haken's [-@Haken_1983] slaving principle establishes that in multi-scale dynamical systems, fast relaxing modes are adiabatically slaved to slow, high-inertia order parameters. Across the biospheric size spectrum, microscopic guilds (bacteria, phytoplankton, microzooplankton) relax on timescales of hours to days, whereas macroscopic biomass reservoirs (old-growth forest boles, soil humic pools, benthic detritus, and long-lived predatory fish) relax over decades to centuries. These slow macroscopic capacitors act as order parameters that bound the amplitude of fast microbial and planktonic cycles and filter low-frequency climate variability.


Anthropogenic activities that selectively remove slow macroscopic capacitors, including old-growth deforestation, peatland drainage, and size-selective industrial fishing, strip the biosphere's low-frequency impedance filters. Deprived of capacitive damping, fast trophic modes become unslaved, increasing probability circulation volatility ($\chi$), elevating specific dissipation ($\sigma$), and eroding the quasi-potential barriers that prevent irreversible transitions into degraded regimes. Ecosystem-based management therefore requires conserving not only aggregate production fluxes, but also the multi-decadal biomass capacitors and detrital reservoirs that anchor regional and planetary stability.


## Practical Guidelines for Empirical Ecologists


Applying this non-equilibrium thermodynamic framework to field and laboratory datasets involves four operational steps:

- **Measure state variables in extensive mass or energy units:** Quantify compartment stocks in extensive units (such as $\mathrm{g\,C}$, $\mathrm{kcal}$, or $\mathrm{mmol\,N}$) normalized by reference standing biomass ($\delta\tilde{x}_i = \delta B_i / B_i^*$) rather than closed compositional simplex fractions ($\sum_i b_i = 1$), which introduce covariance singularities ($\det\mathbf{C}_b = 0$; Appendix B).

- **Include detrital and resource reservoirs in mass-balanced budgets:** Because non-living detritus and dissolved nutrient pools frequently provide the dominant storage capacitance of aquatic and terrestrial ecosystems, omitting them truncates the Schur complement buffering pathways and distorts stability estimates.

- **Decompose dynamics via the continuous Lyapunov equation:** Rather than testing raw demographic Jacobians $\mathbf{A}$ or naive diagonal products $-\mathbf{A}\operatorname{Diag}(\mathbf{B}^*)$ for symmetry, estimate the stationary covariance $\mathbf{C}$ and drift $\mathbf{A}$ from multivariate time series (or solve $\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} + 2\mathbf{D} = \mathbf{0}$) to separate positive-definite dissipation $\mathbf{D}_{\mathrm{sym}}$ from skew-symmetric circulation $\boldsymbol{\Omega}$.

- **Monitor $\det\mathbf{H}$, $\chi$, and $\sigma$ as early-warning indicators:** Track the entropic curvature $\mathbf{H} = k_{\mathrm{B}}\mathbf{C}^{-1}$, the circulation ratio $\chi$, and the stationary entropy production rate $\sigma$ across rolling time windows to detect capacitance loss and approaching bifurcations before regime shifts occur.


# Summary


Thermodynamics provides a systematic framework for ecological theory, bridging phenomenological population models and macroscopic non-equilibrium transport physics. By integrating Boltzmann's statistical entropy with Onsager's reciprocal theory, microscopic demographic interactions are formally coupled to macroscopic energy and material flows through the mathematical relationship between demographic community matrices, symmetric Onsager conductivities, the Le Chatelier-Braun principle, and the adaptive capacity balancing Resistance and Resilience to sustain or dynamically re-establish stationary homeostasis (Le Chatelier-Braun balance) across the thermodynamic landscape (Fig. \ref{fig_respiration_biomass}). The empirical applications and extensions of this framework: generalizing discrete compartments to continuous biomass spectra as Kolmogorov turbulence, and formulating non-linear demographic jump processes via chemical master equations and van Kampen expansions to derive Helmholtz-Hodge vector decompositions and stationary entropy production traces are promising. Future development in the nonlinear regime should be straightforward given the prior work found in control engineering and statistical physics.


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


# Coda: Reconciliation


The non-equilibrium thermodynamic framework developed in the present work resolves some of the tensions among several conceptual schools in theoretical ecology, systems science, and evolutionary physics. Across these paradigms, the continuous Lyapunov factorization $\mathbf{A} = -(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}$ separates three distinct physical roles that were historically conflated: symmetric, positive-definite Onsager dissipation ($\mathbf{D}_{\mathrm{sym}} = \mathbf{D}_{\mathrm{sym}}^{\mathsf{T}} \succ 0$) governing irreversible entropy production; skew-symmetric probability circulation ($\boldsymbol{\Omega} = -\boldsymbol{\Omega}^{\mathsf{T}}$) governing non-dissipative cyclic trophic transport ($\operatorname{Tr}(\boldsymbol{\Omega}\mathbf{C}^{-1}) = 0$); and standing biomass capacitance ($\mathbf{C} = k_{\mathrm{B}}\mathbf{H}^{-1}$) defining the Riemannian curvature metric of the non-equilibrium potential landscape.


**Bernard C. Patten: Network Environ Analysis, Indirect Effects, and Dynamical Divergences**:


Patten [@PattenEtAl_1976; @FathEtAl_1998; @FathEtAl_2001] formulated Network Environ Analysis (NEA) via input-output flow algebra, demonstrating through geometric series expansions of dimensionless direct flow matrices ($\mathbf{N} = (\mathbf{I} - \mathbf{G})^{-1} = \sum_{k=0}^{\infty} \mathbf{G}^k$) that indirect flows passing through intermediate compartments dominate direct pairwise transfers. Through network utility analysis, Patten further showed that although direct trophic links are predatory ($+/-$) or competitive ($-/-$), the summation of indirect feedback pathways yields predominantly positive net utilities ($+/+$, "network mutualism").


The continuous Onsager-Lyapunov framework provides a continuous-time statistical-mechanical foundation for NEA while extending it beyond static accounting. The stationary covariance of biomass fluctuations is generated by integrating the matrix propagator across all lag times:


$$\mathbf{C} = \int_0^{\infty} e^{\mathbf{A}t} (2\mathbf{D}_{\mathrm{sym}}) e^{\mathbf{A}^{\mathsf{T}}t}\, dt$$


Normalizing the community matrix by diagonal compartment turnover rates $\mathbf{D}_{\mathrm{diag}}$ as $\mathbf{A} = \mathbf{D}_{\mathrm{diag}}(\mathbf{G} - \mathbf{I})$ with spectral radius $\rho(\mathbf{G}) < 1$, the negative inverse community matrix $-\mathbf{A}^{-1} = \int_0^{\infty} e^{\mathbf{A}t}\, dt = \left(\sum_{k=0}^{\infty} \mathbf{G}^k\right)\mathbf{D}_{\mathrm{diag}}^{-1}$ is the continuous-time Laplace resolvent of Patten's transitive closure $\mathbf{N}$. Whereas NEA evaluates time-averaged static flow fractions ($G_{ij} = T_{ij}/T_j$) and treats compartments as passive transit nodes, the Lyapunov formulation embeds the network in a continuous dynamical state space where standing biomass acts as a physical storage capacitor ($\mathbf{C}$) and qualitative network mutualism emerges physically from the Le Chatelier-Braun Schur complement ($0 < L_{ii,\mathrm{eff}} \le L_{ii}$), as secondary coupled pathways relax to moderate primary perturbations.


**Ichiro Aoki: Phenomenological Entropy Budgets, Calorimetry, and Statistical-Mechanical Divergences**:


Aoki [-@Aoki_1989]; [-@Aoki_1993]; [-@Aoki_1995] investigated macroscopic entropy budgets in aquatic ecosystems ($dS/dt = d_i S/dt + d_e S/dt$) such as Lake Biwa and Lake Mendota, documenting an empirical rule of ecological succession: as communities develop from pioneer to mature stages, boundary entropy export ($|d_e S/dt|$) increases while internal entropy production per unit biomass ($d_i S/dt / B_{\mathrm{tot}}$) declines toward a minimum.


In the present framework, the macroscopic relaxation rate corresponds to the trace contraction of symmetric Onsager dissipation with the inverse capacitance metric:


$$-\operatorname{Tr}(\mathbf{A}) = \operatorname{Tr}(\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}) = k_{\mathrm{B}}^{-1}\sum_{i,j} D_{\mathrm{sym},ij} H_{ij}$$


Whereas Aoki calculated scalar entropy budgets from bulk heat fluxes and empirical respiration rates ($\Delta S = Q/T$), treating biological compartments as calorimetric black boxes, the Lyapunov formulation derives internal dissipation directly from demographic fluctuations via the Einstein-Onsager relation. Furthermore, scalar calorimetry aggregates all internal energetic fluxes into a single dissipative term, whereas factoring $\mathbf{A}$ into $\mathbf{D}_{\mathrm{sym}}$ and $\boldsymbol{\Omega}$ shows that mature communities reduce mass-specific dissipation both by accumulating large-bodied allometric biomass capacitance ($\mathbf{C} \propto B_{\mathrm{tot}}$, shifting from high kinetic Resilience toward high entropic Resistance) and by routing throughput into non-dissipative cyclic circulation ($\operatorname{Tr}(\boldsymbol{\Omega}\mathbf{C}^{-1}) = 0$).


**Alfred J. Lotka: Maximum Power, Predation Rotations, and the Resistance-Resilience Trade-Off**:


Lotka [-@Lotka_1922a]; [-@Lotka_1922b]; [-@Lotka_1925] introduced both the Maximum Power Principle, proposing that natural selection favors systems that maximize energy throughput, and the classical Lotka-Volterra predator-prey equations, whose neutral, frictionless orbits were later criticized by May [-@May_1972]; [-@May_1973] as structurally fragile to perturbation.


The factorization $-\mathbf{A}\mathbf{C} = \mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega}$ clarifies both contributions. Classical predator-prey cycling corresponds to the skew-symmetric circulation tensor $\boldsymbol{\Omega} = -\boldsymbol{\Omega}^{\mathsf{T}}$, which generates conservative rotational currents in state space. The structural fragility of neutral Lotka-Volterra orbits is resolved because open ecosystems embed $\boldsymbol{\Omega}$ within a positive-definite dissipative core $\mathbf{D}_{\mathrm{sym}} \succ 0$: symmetric dissipation supplies the asymptotic Lyapunov restoring pull toward the stationary attractor, while external solar and geochemical driving sustains cyclic rotation against dissipative damping. Moreover, ecosystems do not unconditionally maximize power throughput across all developmental stages: pioneer communities favor high mass-specific kinetic turnover $\mathcal{R}$ (Resilience) to capture unexploited flux, whereas mature communities trade mass-specific power throughput for standing biomass capacitance $\mathbf{C}$ (Resistance).


**Howard T. Odum: Emergy, Transformity, and Dynamical Divergences**:


H. T. Odum [@OdumEtAl_1955] advanced the Maximum Power Principle alongside an energetic hierarchy quantified by "emergy" and "transformity," modeling ecosystems through analog electrical circuit diagrams in which concentrated apex compartments feed regulatory work back down the trophic hierarchy to reinforce system-wide energy capture.


Within the continuous Onsager-Lyapunov framework, transformity maps onto the ratio of compartment storage capacitance to throughput flux across the allometric spectrum:


$$\text{Transformity} \propto \tau(M) = \frac{C(M)}{J(M)}$$


Large-bodied apex compartments maintain high capacitance per unit throughput, governing the slow relaxation modes of the community, while Odum's downward reinforcing control loops correspond to the off-diagonal entries of the skew-symmetric tensor $\boldsymbol{\Omega}$. At the same time, this formulation resolves three foundational ambiguities in Odum's paradigm: it replaces unconditional power maximization with the Resistance-Resilience trade-off continuum; it replaces path-dependent historical emergy bookkeeping with instantaneous state-space potentials ($\mathbf{X} = -\mathbf{H}\delta\mathbf{x}$) and the Riemannian metric $\mathbf{H} = k_{\mathrm{B}}\mathbf{C}^{-1}$; and, via Tellegen's [-@Tellegen_1948] theorem, it provides the formal matrix proof that Odum's non-reciprocal energy circuits decompose into Onsager-reciprocal resistors ($\mathbf{D}_{\mathrm{sym}}$) and non-dissipative gyrators ($\boldsymbol{\Omega}$).


**Eugene P. Odum: The Strategy of Ecosystem Development and Dynamical Divergences**:


E. P. Odum [-@Odum_1969] synthesized 24 empirical trends distinguishing pioneer from climax ecosystems across energetics, structure, and nutrient cycling (including declining production-to-biomass ($P/B$) and respiration-to-biomass ($R/B$) ratios, convergence of $P/R \to 1$, transition from linear grazing chains to detrital webs, and tightening internal nutrient cycles), interpreting these shifts as a holistic "strategy" directed toward maximum protection and stability.


Rather than treating these 24 trends as an empirical checklist or invoking a teleological ecosystem "strategy," the Lyapunov equation $\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} = -2\mathbf{D}_{\mathrm{sym}}$ derives them as coupled consequences of allometric capacitance accumulation and non-equilibrium transport. As standing biomass capacitance $\mathbf{C}$ expands during succession, mass-specific metabolic dissipation ($R/B$) declines allometrically while the circulation ratio $\chi = \|\boldsymbol{\Omega}\|_{F} / \|\mathbf{D}_{\mathrm{sym}}\|_{F}$ increases, routing nutrients through conservative internal loops ($\boldsymbol{\Omega}$) rather than open boundary leakage. Crucially, this formulation replaces E. P. Odum's monolithic notion of "stability" with the hyperbolic Resistance-Resilience trade-off ($B_{\mathrm{tot}} \times \mathcal{R} \approx \text{constant}$): pioneer communities are not dynamically unstable, but specialize in rapid kinetic Resilience ($\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}$), whereas climax communities maximize capacitive Resistance ($\mathbf{C}$) at the expense of protracted recovery times following severe structural disturbance.


**Robert E. Ulanowicz: Information Metrics, the Reciprocity Paradox, and Dynamical Divergences**:


Ulanowicz [@Ulanowicz_Hannon_1987] argued that because predator-prey interactions have opposing demographic signs ($A_{ij} \ne A_{ji}$), ecological networks violate Onsager reciprocity and therefore lie outside physical thermodynamics, requiring an autonomous ontology based on autocatalytic agency. In parallel, Ulanowicz formulated Ecological Network Analysis (ENA) using Shannon flow information to partition network organization into coherent Ascendency ($A = T \times I$) and redundant pathway Overhead ($\Phi = T \times H - A$), proposing that persistent ecosystems operate within a balanced "Window of Vitality."


The factorization $\mathbf{A} = -(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}$ resolves Ulanowicz's reciprocity paradox without invoking extra-physical agency: the demographic Jacobian $\mathbf{A}$ is not the physical Onsager conductivity $\mathbf{L}$, and Onsager reciprocity holds strictly in the dissipative core $\mathbf{D}_{\mathrm{sym}} = \mathbf{D}_{\mathrm{sym}}^{\mathsf{T}} \succ 0$ while trophic sign asymmetry resides in the gyrator tensor $\boldsymbol{\Omega} = -\boldsymbol{\Omega}^{\mathsf{T}}$. Dynamically, Ulanowicz's Window of Vitality corresponds to the balance between non-normal circulation $\boldsymbol{\Omega}$ (which sustains directed trophic throughflow, analogous to Ascendency, but can induce transient reactive amplification when $\mathbf{A}\mathbf{A}^{\mathsf{T}} \ne \mathbf{A}^{\mathsf{T}}\mathbf{A}$) and symmetric dissipation $\mathbf{D}_{\mathrm{sym}}$ coupled with biomass capacitance $\mathbf{C}$ (analogous to Overhead, which enforces monotonic Lyapunov decay $\dot{V} < 0$). Unlike ENA's static Shannon flow-share indices, this formulation grounds both components in physical master-equation fluctuations and continuous-time state-space stability.


**Jeffrey S. Wicken: Informational Entropy, Kinetic Constraints, and Dynamical Divergences**:


Wicken [-@Wicken_1980]; [-@Wicken_1987] drew a strict boundary between Shannon informational indices and physical thermodynamic entropy ($dS = dQ/T$), arguing that statistical permutations of symbols carry no thermodynamic driving force, and conceptualized organisms and food webs as hierarchical "kinetic constraints" that channel and delay free-energy degradation through catalytic cycles before release as heat.


The present framework formalizes both of Wicken's insights in matrix terms. Demographic fluctuation covariance $\mathbf{C}$ is a statistical dispersion matrix that acquires physical thermodynamic meaning through the entropy Hessian $\mathbf{H} = -\nabla^2 \Delta S_{\mathrm{tot}}\big|_{\mathbf{x}^*} = k_{\mathrm{B}}\mathbf{C}^{-1}$, which measures the physical availability cost of state displacements. Wicken's qualitative "kinetic constraints" and "dissipative delay" are given exact linear-algebraic form by the orthogonal separation between $\boldsymbol{\Omega}$ and $\mathbf{D}_{\mathrm{sym}}$, quantified by the circulation ratio $\chi = \|\boldsymbol{\Omega}\|_{F} / \|\mathbf{D}_{\mathrm{sym}}\|_{F}$, while extending Wicken's purely kinetic view to include standing biomass capacitance $\mathbf{C}$ as the structural buffer that stores exergy across timescales.


**Ludwig von Bertalanffy: Open Systems, Fliessgleichgewicht, and Dynamical Divergences**:


Bertalanffy [-@Bertalanffy_1950]; [-@Bertalanffy_1968] established that living organisms and communities are open thermodynamic systems that maintain a dynamic *Fliessgleichgewicht* (flowing balance) by continuously importing free energy and exporting entropy ($dS = d_e S + d_i S$ with $-d_e S \ge d_i S > 0$), exhibiting *equifinality*, or convergence to a common stationary state from disparate initial conditions.


Bertalanffy's *Fliessgleichgewicht* is realized mathematically by the continuous Lyapunov balance $\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} = -2\mathbf{D}_{\mathrm{sym}}$ with non-vanishing circulation $\boldsymbol{\Omega} \ne \mathbf{0}$, while equifinality is proven by the quadratic Lyapunov functional $V(\delta\mathbf{x}) = \frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\delta\mathbf{x}$, whose negative-definite derivative $\dot{V} < 0$ guarantees that arbitrary initial perturbations decay to $\mathbf{x}^*$. At the same time, the present formulation generalizes Bertalanffy's deterministic, single-compartment, surface-area ($M^{2/3}$) growth equations to stochastic multispecies networks governed by fractal Kleiber allometry ($C(M) \propto M^{1-b}$, $\lambda(M) \propto M^{b-1}$ with $b \approx 3/4$), showing that equifinality characterizes the entire stationary Gaussian fluctuation distribution $P_{\mathrm{st}}(\delta\mathbf{x}) \propto \exp(-V(\delta\mathbf{x}))$.


**Ilya Prigogine and the Brussels School: Minimum Entropy Production, Dissipative Structures, and Dynamical Divergences**:


Prigogine [-@Prigogine_1947]; [-@Prigogine_1955] proved the Theorem of Minimum Entropy Production (MinEP) for linear systems near equilibrium with symmetric conductivities ($\mathbf{L} = \mathbf{L}^{\mathsf{T}} \succ 0$), while Glansdorff and Prigogine [-@Glansdorff_Prigogine_1971] and Nicolis and Prigogine [-@NicolisEtAl_1977] formulated the universal evolution criterion ($d_X P \le 0$) and second-order excess entropy criterion ($\delta^2 S < 0$) for far-from-equilibrium dissipative structures.


Because predator-prey Jacobians are asymmetric ($A_{ij} \ne A_{ji}$), the Brussels School treated ecological oscillations as strictly non-linear bifurcations far from the linear Onsager regime. Factoring $\mathbf{A} = -(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}$ demonstrates that persistent cyclic currents ($\boldsymbol{\Omega} \ne \mathbf{0}$) coexist directly with linear Onsager reciprocity ($\mathbf{D}_{\mathrm{sym}} = \mathbf{D}_{\mathrm{sym}}^{\mathsf{T}} \succ 0$) in the local stationary regime without requiring supercritical limit-cycle bifurcations, because $\boldsymbol{\Omega}$ drops out of the Lyapunov derivative ($\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}\delta\mathbf{x} = 0$). Moreover, the Brussels School's formal macroscopic excess entropy $\delta^2 S < 0$ is identified explicitly with the negative quadratic form of the inverse fluctuation covariance, $\delta^2 S / k_{\mathrm{B}} = -\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\delta\mathbf{x} < 0$, grounding macroscopic stability in empirical demographic variance and standing biomass capacitance rather than active dissipation alone.


**Lionel Johnson: Arctic Lake Climax Ecosystems, Least Action, and Dynamical Divergences**:


From multi-decadal studies of unexploited Arctic charr (*Salvelinus alpinus*) and lake trout (*Salvelinus namaycush*) populations in northern lakes, Johnson [-@Johnson_1981]; [-@Johnson_1990]; [-@Johnson_1994] observed that undisturbed communities converge to dense, senescent, large-bodied standing stocks with minimal juvenile recruitment and low mass-specific turnover, interpreting this as a climax configuration through Maupertuis' Principle of Least Action.


Johnson's physical intuition was close to the mark. His unexploited Arctic lakes exemplify the high-Resistance, low-Resilience pole of the allometric trade-off continuum ($B_{\mathrm{tot}} \times \mathcal{R} \approx \text{constant}$), where large adult biomass capacitance ($C(M) \propto M^{1-b}$) acts as a low-pass impedance filter that damps recruitment fluctuations, representing a contextual adaptation to undisturbed, energy-limited habitats rather than a universal evolutionary endpoint for all biomes. Mathematically, although Johnson invoked Maupertuis' conservative Hamiltonian action ($\int 2T\,dt$), which applies only to frictionless mechanical systems, his core insight that climax communities follow a variational principle of least action is realized in dissipative open systems by the Onsager-Machlup and Freidlin-Wentzell path-integral action functional [@OnsagerEtAl_1953; @Freidlin_Wentzell_1984]:


$$\mathcal{S}[\mathbf{x}(t)] = \int \frac{1}{4} (\dot{\mathbf{x}} - \mathbf{A}\mathbf{x})^{\mathsf{T}} \mathbf{D}_{\mathrm{sym}}^{-1} (\dot{\mathbf{x}} - \mathbf{A}\mathbf{x})\, dt$$


Because the path probability density of a fluctuation trajectory scales as $\mathcal{P}[\mathbf{x}(t)] \propto \exp(-\mathcal{S}[\mathbf{x}(t)])$, minimizing $\mathcal{S}[\mathbf{x}(t)]$ selects the most probable trajectory in path space without invoking a teleological orientor. For spontaneous relaxation back to the attractor, the minimum action $\mathcal{S}_{\min} = 0$ recovers the deterministic trajectory $\dot{\mathbf{x}} = \mathbf{A}\mathbf{x} = -(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}\mathbf{x}$, whereas for noise-driven excursions from the attractor to a displaced state $\mathbf{x}_f$, the minimum action equals the quadratic Lyapunov availability barrier $\mathcal{S}_{\min}(\mathbf{x}_f) = \frac{1}{2}\mathbf{x}_f^{\mathsf{T}}\mathbf{C}^{-1}\mathbf{x}_f \propto \sum_i x_{f,i}^2 / B_i^*$. Consequently, accumulating large-bodied standing biomass $B_i^*$ in climax Arctic lakes maximizes the action barrier against demographic and environmental disturbances while still sustaining active internal trophic circulation ($\boldsymbol{\Omega} \ne \mathbf{0}$) along $\dot{\mathbf{x}} = \mathbf{A}\mathbf{x}$ at zero action cost, validating Johnson's empirical synthesis within stochastic non-equilibrium thermodynamics.


**Roderick Dewar and the Maximum Entropy Production (MaxEnt/MEPP) School: Boundary Decoupling and Dynamical Divergences**:


Dewar [@DewarEtAl_2008] proposed via Maximum Caliber (MaxCal) path-space inference that open non-equilibrium systems select steady states that maximize thermodynamic entropy production (MEPP). Critics noted, however, that unconstrained maximization of dissipation would favor immediate thermal short-circuits (such as wildfires or bare blackbody absorption) over living food webs.


The present framework resolves the conflict between Dewar's MEPP and Prigogine's MinEP by decoupling external force-clamped boundary conditions from internal flux-clamped network pathways. At the external boundary, solar irradiance imposes a clamped thermodynamic force ($X_0$), so expanding canopy conductance $L_{\mathrm{boundary}}$ increases boundary dissipation ($P_{\mathrm{boundary}} = L_{\mathrm{boundary}}X_0^2$, consistent with MEPP). Internally, however, stoichiometric nutrient supply and mass conservation clamp throughflow fluxes ($J_0$), so dissipated power scales inversely with conductance ($P_{\mathrm{internal}} = R_{\mathrm{internal}}J_0^2 = J_0^2 / L_{\mathrm{internal}}$); internal metabolic networks therefore minimize phenomenological resistance and specific dissipation in accordance with MinEP while routing exergy into non-dissipative circulation $\boldsymbol{\Omega}$.


**Sven Erik Jørgensen and Brian D. Fath: Eco-Exergy, Goal Functions, and Dynamical Divergences**:


Jørgensen and colleagues [@JrgensenEtAl_1977; @Jrgensen_1992; @FathEtAl_2001] proposed that ecosystems self-organize to maximize stored "Eco-Exergy" ($\mathrm{Ex}$, the Kullback-Leibler divergence of the living state from an inorganic reference soup, weighted by empirical genomic complexity multipliers $\beta_i$) alongside complementary ecological orientors and buffer capacities.


Near stationarity, the second-order Kullback-Leibler divergence reduces directly to the quadratic Lyapunov availability potential $V(\delta\mathbf{x}) = \frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\delta\mathbf{x} = \frac{1}{2k_{\mathrm{B}}}\delta\mathbf{x}^{\mathsf{T}}\mathbf{H}\delta\mathbf{x}$. This identification grounds Eco-Exergy and ecological buffer capacity in physical fluctuation mechanics without requiring teleological goal-function maximization or heuristic genomic weighting factors ($\beta_i$): the thermodynamic metric $\mathbf{H} = k_{\mathrm{B}}\mathbf{C}^{-1}$ is determined objectively by stationary demographic covariance and allometric scaling ($C(M) \propto M^{1-b}$), while Jørgensen's isolated partial-derivative buffer capacities are unified along the Resistance-Resilience frontier.


**Eric D. Schneider and James J. Kay: Gradient Degradation, Boundary Decoupling, and Dissipative Divergences**:


Schneider and Kay [@SchneiderEtAl_2005] argued that living systems self-organize to degrade externally imposed exergy gradients, citing satellite thermal infrared measurements showing that mature forest canopies re-radiate incident solar energy at lower effective brightness temperatures than pioneer or disturbed landscapes.


As shown in the boundary-interior decoupling above, Schneider and Kay's empirical observations reflect force-clamped boundary conductance expansion ($P_{\mathrm{boundary}} = L_{\mathrm{boundary}}X_0^2$) rather than a teleological imperative to maximize internal entropy production. External gradient capture does not short-circuit into destructive internal heat generation because the community matrix diverts assimilated exergy into the skew-symmetric circulation tensor $\boldsymbol{\Omega}$ ($\operatorname{Tr}(\boldsymbol{\Omega}\mathbf{C}^{-1}) = 0$) and builds standing biomass capacitance $\mathbf{C}$, reconciling high boundary solar degradation with low internal mass-specific dissipation.


**Robert M. May: Resolution of the Complexity-Stability Paradox**:


May [-@May_1972]; [-@May_1973] demonstrated via random matrix theory that unstructured networks with species richness $S$, connectance $C_c$, and interaction variance $\sigma_a^2$ become unstable once complexity exceeds $\sigma_a \sqrt{S C_c} > d$, posing the classical complexity-stability paradox.


The factorization $\mathbf{A} = -(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}$ shows that real ecological community matrices are not unstructured random draws, but are physically constrained by non-equilibrium thermodynamics. Positive-definite symmetric dissipation ($\mathbf{D}_{\mathrm{sym}} \succ 0$) and positive-definite capacitance ($\mathbf{C} \succ 0$) confine all eigenvalues of $\mathbf{A}$ to the open left half-plane ($\operatorname{Re}(\lambda_i) < 0$) regardless of species richness, while skew-symmetric trophic couplings ($\boldsymbol{\Omega} = -\boldsymbol{\Omega}^{\mathsf{T}}$) contribute purely imaginary rotational components that stabilize rather than destabilize the spectrum.


**Jeremy England et al.: Dissipative Adaptation, Fluctuation Relations, and Thermodynamic Divergences**:


Grounded in microscopic fluctuation theorems [@Crooks_1999; @Seifert_2012], England [-@England_2013]; [-@England_2015] showed that driven molecular assemblies coupled to a heat bath undergo dissipative adaptation, becoming kinetically trapped in configurations that reliably absorb and dissipate external work.


Translated to macroscopic demography, abiotic dissipation corresponds to pure symmetric friction ($\mathbf{D}_{\mathrm{sym}} \succ 0, \boldsymbol{\Omega} = \mathbf{0}$), whereas living communities channel external driving into persistent probability circulation ($\boldsymbol{\Omega} \ne \mathbf{0}$) and endogenous allometric capacitance ($\mathbf{C}$). Moreover, within stochastic thermodynamics, the Thermodynamic Uncertainty Relation [@Barato_Seifert_2015; @Gingrich_et_al_2016; @HorowitzEtAl_2020] establishes a lower bound on the metabolic dissipation $\sigma$ required to bound the relative variance of any non-equilibrium current $J$ over observation window $\tau$:


$$\frac{\operatorname{Var}(J)}{\langle J \rangle^2} \ge \frac{2 k_{\mathrm{B}}}{\sigma \tau} \quad \iff \quad \sigma \ge \frac{2 k_{\mathrm{B}} \langle J \rangle^2}{\operatorname{Var}(J) \tau}$$


Applied across all of the ecological schools above, the TUR demonstrates that maintaining precision in indirect network flows (Patten), cyclic predation (Lotka), regulatory feedbacks (Odum), closed nutrient loops, and homeostatic climax states (Bertalanffy, Johnson) is never energetically free: suppressing demographic variance in directed ecological fluxes requires continuous baseline dissipation within $\mathbf{D}_{\mathrm{sym}}$.


**Richard Dawkins: The Limits of Gene-Centric Reductionism and Whole-System Thermodynamics**:


Dawkins [-@Dawkins_1976]; [-@Dawkins_1982] formulated the gene-centric view of evolution, treating genetic replicators as the primary units of selection and organisms or extended phenotypes (such as beaver dams and coral reefs) as disposable vehicles constructed to propagate replicators.


From the perspective of non-equilibrium physics, nucleic acid polymers possess no autonomous energetic agency or fitness outside the chemiosmotic gradients and catalytic networks of the host cell and ecosystem. While genetic sequences encode microscopic reaction parameters and allometric traits, demographic persistence is governed by the collective stability of $\mathbf{A} = -(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}$ ($\operatorname{Re}(\lambda_i) < 0$): any variant that maximizes short-term replication by eroding collective capacitance $\mathbf{C}$ or positive-definite dissipation $\mathbf{D}_{\mathrm{sym}}$ destabilizes its own basin of attraction. Physically, the macroscopic vehicle and extended phenotype act as the standing biomass capacitor ($\mathbf{C} = k_{\mathrm{B}}\mathbf{H}^{-1}$) that filters environmental volatility and shields informational polymers from thermal and demographic disruption.


**Hermann Haken: Synergetics, the Slaving Principle, and Dynamical Divergences**:


Haken [-@Haken_1977]; [-@Haken_1983] developed synergetics to describe self-organization near bifurcation instabilities ($\operatorname{Re}(\lambda) \to 0$), where fast-relaxing microscopic modes are adiabatically slaved to a few slow macroscopic order parameters.


In multi-species ecosystems, allometric metabolic scaling ($C(M) \propto M^{1-b}$ and $\lambda(M) \propto M^{b-1}$ with $b \approx 0.75$) provides a permanent, dimensional physical realization of Haken's slaving principle across body-size spectra. Unlike classical synergetics, which is restricted to the neighborhood of critical bifurcations and typically assumes dimensionless modal amplitudes descending scalar potentials, allometric timescale separation operates continuously within deeply stable stationary states ($\operatorname{Re}(\lambda_i) < 0$), where large-bodied biomass capacitors ($\mathbf{C}$) define the slow macroscopic order parameters, fast microbial and planktonic guilds relax adiabatically, and non-normal circulation ($\boldsymbol{\Omega}$) couples scales across the trophic hierarchy.


# Appendix A: The Details of **A** vs **L**


The relationship between the demographic community matrix $\mathbf{A}$ and the physical Onsager phenomenological conductivity matrix $\mathbf{L}$ follows directly from thermodynamic fluctuation theory and continuous Lyapunov covariance factorization.


Consider an ecological system described by $n$ independent extensive state variables $\mathbf{x} = (x_1, \dots, x_n)^{\mathsf{T}}$, representing compartment biomasses or energy pools in contact with external energetic and material reservoirs at temperature $T$, with stationary reference state $\mathbf{x}^*$ and state deviations $\delta\mathbf{x} = \mathbf{x} - \mathbf{x}^*$. Following Einstein [-@Einstein_1910], Greene and Callen [-@CallenEtAl_1951], and Callen [-@Callen_1985], the total entropy change $\Delta S_{\mathrm{tot}}(\delta\mathbf{x})$ of the system plus its environment is expanded in a Taylor series about $\mathbf{x}^*$:


$$\Delta S_{\mathrm{tot}}(\delta\mathbf{x}) = \Delta S_{\mathrm{tot}}(\mathbf{0}) + \left.\nabla \Delta S_{\mathrm{tot}}\right|_{\mathbf{x}^*}^{\mathsf{T}}\delta\mathbf{x} - \frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{H}\delta\mathbf{x} + \mathcal{O}(\|\delta\mathbf{x}\|^3)$$


At a stationary state, first-order variations vanish ($\left.\nabla \Delta S_{\mathrm{tot}}\right|_{\mathbf{x}^*} = \mathbf{0}$). Setting the reference $\Delta S_{\mathrm{tot}}(\mathbf{0}) = 0$, the second-order expansion is:


$$\Delta S_{\mathrm{tot}}(\delta\mathbf{x}) = -\frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{H}\delta\mathbf{x}$$


where $\mathbf{H} = -\partial^2 \Delta S_{\mathrm{tot}} / \partial\mathbf{x}^2\big|_{\mathbf{x}^*}$ is the symmetric, positive-definite entropy Hessian (entropic curvature or thermodynamic stiffness matrix). Positive-definiteness ($\mathbf{H} = \mathbf{H}^{\mathsf{T}} \succ 0$) is required for local thermodynamic stability, ensuring that total entropy attains an isolated local maximum at the reference state [@Glansdorff_Prigogine_1971; @Callen_1985].


Thermodynamic conjugate forces $\mathbf{X} = (X_1, \dots, X_n)^{\mathsf{T}}$ are defined by the entropy gradient with respect to state displacements:


$$\mathbf{X} = \nabla_{\delta\mathbf{x}} \Delta S_{\mathrm{tot}} = -\mathbf{H}\delta\mathbf{x}$$


By Einstein's fluctuation formula, the stationary probability density $P(\delta\mathbf{x})$ of fluctuations about the reference state is:


$$P(\delta\mathbf{x}) \propto \exp\left( \frac{\Delta S_{\mathrm{tot}}(\delta\mathbf{x})}{k_{\mathrm{B}}} \right) = \exp\left( -\frac{1}{2k_{\mathrm{B}}}\delta\mathbf{x}^{\mathsf{T}}\mathbf{H}\delta\mathbf{x} \right)$$


which is a multivariate zero-mean Gaussian distribution with covariance matrix:


$$\mathbf{C} = \langle \delta\mathbf{x}\delta\mathbf{x}^{\mathsf{T}} \rangle = k_{\mathrm{B}}\mathbf{H}^{-1} \quad \iff \quad \mathbf{H} = k_{\mathrm{B}}\mathbf{C}^{-1}$$


The entropy Hessian $\mathbf{H}$ and the stationary fluctuation covariance matrix $\mathbf{C}$ are thus matrix inverses up to the fluctuation scale factor $k_{\mathrm{B}}$ (representing Boltzmann's constant in molecular systems or the effective demographic grain scale in finite-population master-equation expansions[@Keizer_1987; @Qian_2006]. In open systems at a non-equilibrium steady state, $\frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\delta\mathbf{x} = -\Delta S_{\mathrm{tot}}(\delta\mathbf{x})/k_{\mathrm{B}}$ defines the local Gaussian approximation to the non-equilibrium quasi-potential or excess availability functional [@Graham_1977; @Ao_2004; @Seifert_2012]. Physically, $\mathbf{C}$ represents the thermodynamic storage capacitance matrix of the ecological network, quantifying the capacity of each compartment to store biomass and absorb fluctuations without generating steep thermodynamic force gradients.


In linear non-equilibrium thermodynamics, thermodynamic forces $\mathbf{X}$ drive conjugate fluxes $\mathbf{J} = (J_1, \dots, J_n)^{\mathsf{T}}$ of the state variables according to linear phenomenological relations [@Onsager_1931a; @Onsager_1931b; @deGrootEtAl_1962]:


$$\mathbf{J} = \mathbf{L}\mathbf{X}$$


where $\mathbf{L} = [L_{ij}]$ is the phenomenological conductivity matrix (if expressed in terms of $m$ underlying reaction pathways with stoichiometric matrix $\boldsymbol{\nu}$ and pathway conductivity $\mathbf{L}_r$, the state-space conductivity is the congruent projection $\mathbf{L} = \boldsymbol{\nu}\mathbf{L}_r\boldsymbol{\nu}^{\mathsf{T}}$). The internal entropy production rate $\sigma$ is the bilinear product of fluxes and forces:


$$\sigma = \mathbf{J}^{\mathsf{T}}\mathbf{X} = \mathbf{X}^{\mathsf{T}}\mathbf{L}_s\mathbf{X} \ge 0$$


where $\mathbf{L}_s = \frac{1}{2}(\mathbf{L} + \mathbf{L}^{\mathsf{T}}) \succ 0$ is the symmetric part of the conductivity matrix; under microscopic reversibility at equilibrium, $\mathbf{L} = \mathbf{L}^{\mathsf{T}} = \mathbf{L}_s$.


In theoretical ecology, the linearized dynamics of compartment biomass deviations are written in terms of the demographic community matrix (Jacobian) $\mathbf{A} = [\partial f_i / \partial x_j\big|_{\mathbf{x}^*}]$:


$$\delta\dot{\mathbf{x}} = \mathbf{A}\delta\mathbf{x}$$


Because the rate of change of the extensive state variables equals the net flux vector $\delta\dot{\mathbf{x}} = \mathbf{J}$, substituting the constitutive relation $\mathbf{J} = \mathbf{L}\mathbf{X}$ and the force definition $\mathbf{X} = -\mathbf{H}\delta\mathbf{x} = -k_{\mathrm{B}}\mathbf{C}^{-1}\delta\mathbf{x}$ yields:


$$\delta\dot{\mathbf{x}} = \mathbf{L}\mathbf{X} = -\mathbf{L}\mathbf{H}\delta\mathbf{x} = -k_{\mathrm{B}}\mathbf{L}\mathbf{C}^{-1}\delta\mathbf{x}$$


Comparing this expression with $\delta\dot{\mathbf{x}} = \mathbf{A}\delta\mathbf{x}$ establishes the structural identity:


$$\mathbf{A} = -\mathbf{L}\mathbf{H} = -k_{\mathrm{B}}\mathbf{L}\mathbf{C}^{-1}$$


This identity explains why the demographic community matrix $\mathbf{A}$ cannot be equated directly with the physical conductivity $\mathbf{L}$. Even when the phenomenological transport matrix $\mathbf{L}$ is strictly symmetric ($L_{ij} = L_{ji}$), the community matrix $\mathbf{A}$ right-multiplies $\mathbf{L}$ by the inverse capacitance matrix $\mathbf{C}^{-1} = \mathbf{H} / k_{\mathrm{B}}$. Because biological compartments differ by orders of magnitude in standing biomass and storage capacitance, $\mathbf{C}^{-1}$ is strongly heterogeneous, and the product of a symmetric matrix $\mathbf{L}$ with a heterogeneous matrix $\mathbf{C}^{-1}$ is asymmetric: $(\mathbf{L}\mathbf{C}^{-1})^{\mathsf{T}} = \mathbf{C}^{-1}\mathbf{L} \ne \mathbf{L}\mathbf{C}^{-1}$.


## Decomposition of **A** via Continuous Lyapunov Covariance Factorization


In open ecological networks driven far from detailed balance by persistent solar or geochemical throughput, the transport operator $k_{\mathrm{B}}\mathbf{L}$ also contains an antisymmetric rotational component in addition to its symmetric dissipative part. To decompose $\mathbf{A}$ into its dissipative and circulatory components directly from demographic dynamics, consider the linear Langevin equation around stationarity [@Lyapunov_1892; @Willems_1972; @Tomita_Tomita_1974; @Graham_1977; @Ao_2004; @Qian_2006]:


$$\delta\dot{\mathbf{x}} = \mathbf{A}\delta\mathbf{x} + \boldsymbol{\xi}(t)$$


where $\boldsymbol{\xi}(t)$ is zero-mean Gaussian white noise with symmetric, positive-definite diffusion covariance $\langle \boldsymbol{\xi}(t)\boldsymbol{\xi}^{\mathsf{T}}(t') \rangle = 2\mathbf{D}_{\mathrm{sym}}\delta(t - t')$ ($\mathbf{D}_{\mathrm{sym}} = \mathbf{D}_{\mathrm{sym}}^{\mathsf{T}} \succ 0$). At stationarity, the state covariance matrix $\mathbf{C} = \langle \delta\mathbf{x}\delta\mathbf{x}^{\mathsf{T}} \rangle$ satisfies the continuous algebraic Lyapunov equation:


$$\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} = -2\mathbf{D}_{\mathrm{sym}}$$


The covariance-weighted drift matrix $-\mathbf{A}\mathbf{C} = k_{\mathrm{B}}\mathbf{L}$ decomposes uniquely into its symmetric and antisymmetric parts:


$$-\mathbf{A}\mathbf{C} = \operatorname{sym}(-\mathbf{A}\mathbf{C}) + \operatorname{asym}(-\mathbf{A}\mathbf{C}) = \mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega}$$


where the symmetric dissipative tensor $\mathbf{D}_{\mathrm{sym}} = k_{\mathrm{B}}\mathbf{L}_s$ and the antisymmetric probability circulation tensor $\boldsymbol{\Omega} = k_{\mathrm{B}}\mathbf{L}_a$ are given by:


$$\mathbf{D}_{\mathrm{sym}} = -\frac{1}{2}(\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}}) = \mathbf{D}_{\mathrm{sym}}^{\mathsf{T}} \succ 0$$


$$\boldsymbol{\Omega} = -\frac{1}{2}(\mathbf{A}\mathbf{C} - \mathbf{C}\mathbf{A}^{\mathsf{T}}) = -\boldsymbol{\Omega}^{\mathsf{T}}$$


Multiplying $-\mathbf{A}\mathbf{C} = \mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega}$ on the right by the inverse capacitance matrix $\mathbf{C}^{-1}$ yields the factorization of the demographic community matrix:


$$\mathbf{A} = -(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}$$


The demographic community matrix $\mathbf{A}$ thus factors into three distinct physical operators: a symmetric, positive-definite dissipative conductivity $\mathbf{D}_{\mathrm{sym}} = k_{\mathrm{B}}\mathbf{L}_s$ that satisfies Onsager reciprocity ($D_{\mathrm{sym},ij} = D_{\mathrm{sym},ji}$) and drives monotonic downhill relaxation; an antisymmetric probability circulation tensor $\boldsymbol{\Omega} = k_{\mathrm{B}}\mathbf{L}_a$ that quantifies non-dissipative cyclic trophic currents sustained by external throughput; and the inverse storage capacitance matrix $\mathbf{C}^{-1} = \mathbf{H} / k_{\mathrm{B}}$, which normalizes transport fluxes by the entropic stiffness of the receiving compartments. Empirically, these operators are uniquely identifiable either from multivariate population time series (where $\mathbf{C} = \langle\delta\mathbf{x}\delta\mathbf{x}^{\mathsf{T}}\rangle$ is estimated from zero-lag covariance and $\mathbf{A}$ from lagged cross-covariances $\langle\delta\mathbf{x}(t+\tau)\delta\mathbf{x}^{\mathsf{T}}(t)\rangle = e^{\mathbf{A}\tau}\mathbf{C}$) or from mass-balanced trophic budgets (where diagonal compartment capacitance scales with standing biomass, $C_{ii} \propto B_i^*$, and demographic shot noise $\mathbf{D}_{\mathrm{sym}}$ scales with reaction throughflows, uniquely determining $\mathbf{C}$ and $\boldsymbol{\Omega}$ via the Lyapunov equation).


Because $\boldsymbol{\Omega}$ is skew-symmetric, it performs no net thermodynamic work against the potential gradient ($\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}\delta\mathbf{x} = 0$), functioning as a conservative energy and nutrient shuttler across compartments.


These physical operators map directly to ecological mechanisms. Biological standing stocks function as entropic capacitors ($\mathbf{C}$): detrital beds and forest boles store reserves of carbon and nutrients, providing physical inertia that buffers the community against seasonal droughts and resource lean periods. Metabolic dissipation ($\mathbf{D}_{\mathrm{sym}}$) represents the irreversible metabolic expenditure required to maintain living structure against thermal decay, pulling perturbations monotonically back toward stationary balance. Probability circulation ($\boldsymbol{\Omega}$) represents conservative transport within internal trophic loops, where feeding cycles and microbial recycling pathways shuttle matter and energy across species boundaries without degrading the local free-energy gradient.


The dimensionless non-equilibrium circulation ratio quantifies the network-wide magnitude of cyclic trophic transport relative to irreversible dissipative damping and thus measures the departure from microscopic detailed balance. It is computed as:


$$\chi = \frac{\|\boldsymbol{\Omega}\|_F}{\|\mathbf{D}_{\mathrm{sym}}\|_F}$$


where $\|\mathbf{M}\|_F = \sqrt{\operatorname{tr}(\mathbf{M}^{\mathsf{T}}\mathbf{M})} = \sqrt{\sum_{i,j} M_{ij}^2}$ denotes the Frobenius matrix norm. Because symmetric and skew-symmetric matrices are mutually orthogonal under the Frobenius inner product ($\operatorname{tr}(\mathbf{D}_{\mathrm{sym}}^{\mathsf{T}}\boldsymbol{\Omega}) = 0$), the total squared norm of the covariance-weighted drift decomposes via the Pythagorean identity $\|-\mathbf{A}\mathbf{C}\|_F^2 = \|\mathbf{D}_{\mathrm{sym}}\|_F^2 + \|\boldsymbol{\Omega}\|_F^2 = \|\mathbf{D}_{\mathrm{sym}}\|_F^2(1 + \chi^2)$, where $\chi = \tan\theta$ is the tangent of the angle between the composite dynamical operator and the purely dissipative Onsager subspace. In an isolated system at thermodynamic equilibrium (or in a purely symmetric competitive community), detailed balance holds, circulation vanishes ($\boldsymbol{\Omega} = \mathbf{0}$, $\chi = 0$), and perturbations relax monotonically without rotation. In open ecosystems driven by solar irradiance and nutrient inflows, continuous boundary throughput sustains persistent cyclic currents ($\chi > 0$), indexing a continuum of dynamical regimes from capacitance-buffered overdamped relaxation ($\chi < 1$, as in detritus-dominated benthic streams) and active planktonic recycling ($\chi \sim 1\text{ to }1.5$, as in the open-ocean mixed layer) to volatile, unbuffered oscillatory spiraling when slow apex capacitors are stripped ($\chi \gg 1$, approaching a Hopf bifurcation). Coordinate-invariance proofs, geometric properties of the Frobenius ratio, and the canonical two-species prototype decomposition are presented in Appendices A and C.


# Appendix B: Connecting the Le Chatelier-Braun Principle and Onsager Reciprocity via the Schur Complement


The Le Chatelier-Braun principle for coupled non-equilibrium networks arises algebraically from the moderation of primary perturbations by secondary coupled pathways via the matrix Schur complement, while global asymptotic relaxation in state space follows from a quadratic Lyapunov decay theorem.


Consider an ecological network whose linearized thermodynamic fluxes $\delta\mathbf{J}$ and conjugate forces $\delta\mathbf{X}$ are coupled through the phenomenological conductivity matrix $\mathbf{L} = \mathbf{L}_s + \mathbf{L}_a = k_{\mathrm{B}}^{-1}(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})$, whose symmetric part is strictly positive definite ($\mathbf{L}_s = \mathbf{L}_s^{\mathsf{T}} \succ 0$) and whose antisymmetric part is skew-symmetric ($\mathbf{L}_a = -\mathbf{L}_a^{\mathsf{T}}$). Partitioning the network into a primary perturbed process (subscript $i$) and the remaining $n - 1$ secondary coupled processes (subscript $-i$) gives:


$$\begin{pmatrix} \delta J_i \\ \delta\mathbf{J}_{-i} \end{pmatrix} = \begin{pmatrix} L_{ii} & \mathbf{L}_{i,-i} \\ \mathbf{L}_{-i,i} & \mathbf{L}_{-i,-i} \end{pmatrix} \begin{pmatrix} \delta X_i \\ \delta\mathbf{X}_{-i} \end{pmatrix}$$


where $L_{ii} > 0$ is the primary self-conductivity, $\mathbf{L}_{-i,-i} \in \mathbb{R}^{(n-1) \times (n-1)}$ is the secondary submatrix (with positive-definite symmetric part $\mathbf{L}_{s;-i,-i} \succ 0$, ensuring invertibility of $\mathbf{L}_{-i,-i}$), and $\mathbf{L}_{i,-i}, \mathbf{L}_{-i,i}$ represent cross-pathway couplings.


Two operational boundary conditions characterize the network's response to an external perturbation. Under clamped secondary forces (the isolated response, $\delta\mathbf{X}_{-i} = \mathbf{0}$), the primary flux response to an imposed force perturbation $\delta X_i$ is governed solely by the self-conductivity:


$$\left.\delta J_i\right|_{\mathrm{clamped}} = L_{ii}\delta X_i$$


Under free secondary relaxation (the unconstrained stationary response), secondary processes adjust until their net conjugate fluxes vanish ($\delta\mathbf{J}_{-i} = \mathbf{0}$). Solving $\delta\mathbf{J}_{-i} = \mathbf{L}_{-i,i}\delta X_i + \mathbf{L}_{-i,-i}\delta\mathbf{X}_{-i} = \mathbf{0}$ yields the relaxed secondary forces:


$$\delta\mathbf{X}_{-i} = -\mathbf{L}_{-i,-i}^{-1}\mathbf{L}_{-i,i}\delta X_i$$


Substituting $\delta\mathbf{X}_{-i}$ back into the primary flux equation gives:


$$\left.\delta J_i\right|_{\mathrm{free}} = L_{ii}\delta X_i + \mathbf{L}_{i,-i}\left( -\mathbf{L}_{-i,-i}^{-1}\mathbf{L}_{-i,i}\delta X_i \right) = \left( L_{ii} - \mathbf{L}_{i,-i}\mathbf{L}_{-i,-i}^{-1}\mathbf{L}_{-i,i} \right) \delta X_i$$


The effective phenomenological conductivity governing the primary process under free secondary relaxation is therefore the matrix Schur complement of $\mathbf{L}_{-i,-i}$ in $\mathbf{L}$ [@Schur_1917; @BoydEtAl_2004; @HornEtAl_2012]:


$$L_{ii,\mathrm{eff}} = L_{ii} - \mathbf{L}_{i,-i}\mathbf{L}_{-i,-i}^{-1}\mathbf{L}_{-i,i}$$


This Schur complement identity unifies two complementary modes of Le Chatelier-Braun moderation across ecological networks:

- **Direct conjugate effects via symmetric dissipative cross-coupling ($\mathbf{L} = \mathbf{L}_s$, $\mathbf{L}_{i,-i} = \mathbf{L}_{-i,i}^{\mathsf{T}}$):** Because $\mathbf{L}_{-i,-i}^{-1} \succ 0$, the quadratic form $\mathbf{L}_{i,-i}\mathbf{L}_{-i,-i}^{-1}\mathbf{L}_{i,-i}^{\mathsf{T}}$ is strictly positive for any non-zero cross-coupling vector $\mathbf{L}_{i,-i} \ne \mathbf{0}$, and because the Schur complement of a positive-definite matrix is positive definite [@HornEtAl_2012], $L_{ii,\mathrm{eff}}$ satisfies:


$$0 < L_{ii,\mathrm{eff}} \le L_{ii}$$


with strict inequality ($L_{ii,\mathrm{eff}} < L_{ii}$) whenever $\mathbf{L}_{i,-i} \ne \mathbf{0}$ [@LeChatelier_1884; @Braun_1887; @PrigogineEtAl_1954]. In mutualistic and co-transport networks, unconstrained relaxation of secondary coupled pathways reduces the effective conductivity of a primary force perturbation.

- **Effective conjugate effects via cyclic indirect cross-coupling ($\mathbf{L}_{a;i,-i} = -\mathbf{L}_{a;-i,i}^{\mathsf{T}}$):** When primary and secondary compartments are coupled through skew-symmetric consumer-resource or host-parasite circulation ($\mathbf{L}_{i,-i} = -\mathbf{L}_{-i,i}^{\mathsf{T}}$ with diagonal secondary damping $\mathbf{L}_{s;-i,-i} \succ 0$), substituting $\mathbf{L}_{-i,i} = -\mathbf{L}_{i,-i}^{\mathsf{T}}$ into the Schur complement yields $L_{ii,\mathrm{eff}} = L_{ii} + \mathbf{L}_{i,-i}\mathbf{L}_{s;-i,-i}^{-1}\mathbf{L}_{i,-i}^{\mathsf{T}} \ge L_{ii}$. Under an external flux perturbation $\delta J_i$ (such as herbivore recruitment or nutrient loading), the stationary force and state displacement $\delta X_i = [(\mathbf{L}^{-1})_{ii}]\delta J_i = L_{ii,\mathrm{eff}}^{-1}\delta J_i$ satisfies $0 < L_{ii,\mathrm{eff}}^{-1} \le L_{ii}^{-1}$, demonstrating that predatory and parasitic feedback loops increase restorative stiffness and attenuate primary state displacements.


In extensive state space, asymptotic decay of perturbations back to the stationary state is governed by the quadratic Lyapunov availability functional $V(\delta\mathbf{x})$ defined by the inverse capacitance metric:


$$V(\delta\mathbf{x}) = \frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\delta\mathbf{x} = \frac{1}{2k_{\mathrm{B}}}\delta\mathbf{x}^{\mathsf{T}}\mathbf{H}\delta\mathbf{x} = -\frac{\Delta S_{\mathrm{tot}}(\delta\mathbf{x})}{k_{\mathrm{B}}}$$


Because $\mathbf{C}^{-1} = \mathbf{H} / k_{\mathrm{B}} \succ 0$, $V(\delta\mathbf{x}) > 0$ for all $\delta\mathbf{x} \ne \mathbf{0}$ and $V(\mathbf{0}) = 0$. Differentiating $V(\delta\mathbf{x})$ with respect to time along trajectories of $\delta\dot{\mathbf{x}} = \mathbf{A}\delta\mathbf{x}$ gives:


$$\dot{V}(\delta\mathbf{x}) = \frac{1}{2}\delta\dot{\mathbf{x}}^{\mathsf{T}}\mathbf{C}^{-1}\delta\mathbf{x} + \frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\delta\dot{\mathbf{x}} = \frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}(\mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} + \mathbf{C}^{-1}\mathbf{A})\delta\mathbf{x}$$


Substituting the factorization $\mathbf{A} = -(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}$ from Appendix A yields:


$$\mathbf{C}^{-1}\mathbf{A} = -\mathbf{C}^{-1}(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}, \qquad \mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} = -\mathbf{C}^{-1}(\mathbf{D}_{\mathrm{sym}} - \boldsymbol{\Omega})\mathbf{C}^{-1}$$


Summing these two expressions cancels the antisymmetric circulation tensor $\boldsymbol{\Omega} = -\boldsymbol{\Omega}^{\mathsf{T}}$ identically ($\mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} + \mathbf{C}^{-1}\mathbf{A} = -2\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}$), reducing the Lyapunov time derivative to:


$$\dot{V}(\delta\mathbf{x}) = -\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}\delta\mathbf{x} = -k_{\mathrm{B}}^{-1}\delta\mathbf{X}^{\mathsf{T}}\mathbf{L}_s\delta\mathbf{X} < 0 \quad (\forall \; \delta\mathbf{x} \ne \mathbf{0})$$


Because $\mathbf{C}^{-1} \succ 0$ and $\mathbf{D}_{\mathrm{sym}} = k_{\mathrm{B}}\mathbf{L}_s \succ 0$, $\dot{V}(\delta\mathbf{x})$ is strictly negative for all non-zero displacements [@Lyapunov_1892; @Willems_1972; @Tomita_Tomita_1974]. Antisymmetric probability circulation $\boldsymbol{\Omega}$ performs no net thermodynamic work against the availability landscape ($\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}\delta\mathbf{x} = 0$), while positive-definite Onsager dissipation $\mathbf{D}_{\mathrm{sym}} = k_{\mathrm{B}}\mathbf{L}_s$ drives monotonic relaxation to the stationary attractor.


# Appendix C: Coordinate Invariance Under Linear Transformations


Following the geometric formulation of non-equilibrium diffusion processes on smooth manifolds [@Graham_1977; @Eyink_1990], let state departures be transformed by an invertible linear coordinate transformation $\delta\mathbf{y} = \mathbf{M}\delta\mathbf{x}$, where $\mathbf{M} \in \mathbb{R}^{n \times n}$ with $\det \mathbf{M} \ne 0$.


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


- **Riemannian circulation ratio:** Evaluated in the natural Riemannian metric $\mathbf{C}^{-1}$ (standardized coordinates $\delta\tilde{\mathbf{x}} = \mathbf{C}^{-1/2}\delta\mathbf{x}$; Appendix C), the metric-weighted circulation ratio $\tilde{\chi} = \left[\operatorname{tr}(\boldsymbol{\Omega}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}) / \operatorname{tr}(\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1})\right]^{1/2}$ is strictly invariant under any invertible $\mathbf{M}$.


[^1]: Landsberg's [-@Landsberg_1961; -@Landsberg_1972] representation of the laws of thermodynamics is among the most concise and clear, as the laws are stated as simple postulates of existence: the zeroth law postulates that empirical temperature exists; the first law establishes that internal energy exists and is conserved; the second law dictates that entropy and absolute temperature exist, such that every transformation incurs unrecoverable loss; the third law states that systems cannot attain absolute zero; and the fourth law asserts that extensive (aggregate) and intensive (density) variables exist for equilibrium states and at least some subset of near-equilibrium and non-equilibrium states.


[^2]: The Le Chatelier-Braun principle, formulated in 1884-1888 (Le Chatelier [-@LeChatelier_1884; -@Braun_1887], Gündüz and Gündüz [-@GndzEtAl_2014]), describes how physical-chemical systems in equilibrium respond to external perturbations by shifting internal equilibria to moderate the perturbation. The generalized linear non-equilibrium manifestation of this moderation is designated as *conjugate effects* to highlight the underlying Onsager transport mechanism.


[^3]: Extremum principles for entropy production have generated substantial debate. Following Onsager [-@Onsager_1931a; -@Onsager_1931b] and Onsager and Machlup [-@OnsagerEtAl_1953], and later formalized by Shiner and Sieniutycz [-@ShinerEtAl_1994], linear near-equilibrium systems exhibit minimum dissipation when unconstrained internal forces relax toward steady state under fixed boundary fluxes, and maximum dissipation under fixed boundary forces. This work operates strictly within the linear range of Onsager's relations, where these extremum properties are mathematically well-defined.


[^4]: The $4^{\text{th}}$ law, attributable to Landsberg [-@Landsberg_1972], is not universally acknowledged as a thermodynamic "law". Though not controversial, it is important in the Onsager-Prigogine-Landsberg school and merits emphasis as it is not always appreciated in the ecological literature. To emphasize this distinction, the qualification (*local, intensive*) is highlighted throughout this work. When system volume is assumed constant, *intensive* and *extensive* quantities are frequently conflated, particularly in atmospheric applications. In ecological systems, macroscopic (*extensive*) biovolume variations of several orders of magnitude complicate naive applications of whole-system Onsager relations. Defining thermodynamic states within constant local biovolume elements provides a mathematically rigorous foundation for applying Onsager's reciprocity.

