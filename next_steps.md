# Advanced Non-Equilibrium Ecological Thermodynamics: Non-Linear Master Equations, Allometric Transmission Lines, Multi-Field Transductions, and Interdisciplinary Foundations

## Overview and Relationship to the Linear Onsager Framework

The foundational formulation developed in `conjugate_effects.md` establishes the linear non-equilibrium thermodynamic framework for ecological networks near stationary balance. There, ecological compartments are analyzed within local control volumes where extensive state variables fluctuate around a non-equilibrium steady state, and the demographic community Jacobian $\mathbf{A}$ factors through the continuous Lyapunov equation into a symmetric, positive-definite dissipation matrix $\mathbf{D}_{\mathrm{sym}} \succ 0$, a skew-symmetric probability circulation tensor $\boldsymbol{\Omega} = -\boldsymbol{\Omega}^{\mathsf{T}}$, and an inverse storage capacitance matrix $\mathbf{C}^{-1} = \mathbf{H} / k_{\mathrm{B}}$.

The present document extends this foundation beyond the linear Gaussian-fluctuation domain into six advanced physical regimes that govern ecological self-organization, multi-scale wave transport, non-linear phase space topologies, and the epistemological limits of empirical parameter estimation:

- **Part 1: Discrete Pseudo-Chemical Master Equations, the Non-Linear Range, and Attractor Landscapes**: Formulating multi-species ecological interactions as discrete stochastic jump processes; exploring the breakdown of linear Onsager reciprocity far from equilibrium via the De Donder–Guldberg–Waage non-linear affinity relation and Glansdorff–Prigogine excess entropy production ($\delta^2\sigma$); cataloging the four fundamental classes of non-equilibrium attractors (fixed points, limit cycles with astronomical phase-locking, tori, and strange attractors); deriving non-linear Fokker–Planck equations and state-dependent diffusion tensors via the Van Kampen system-size expansion; mapping non-equilibrium quasi-potential landscapes $U(\mathbf{x})$, instanton escape trajectories with transition-path hysteresis, and the exact step-by-step Fokker–Planck derivation of the steady-state circulation dissipation trace formula; and differentiating mechanistic early-warning diagnostics for fold versus Hopf bifurcations.
- **Part 2: Size-Structured Predation Master Equations & Van Kampen Field Theory**: Generalizing discrete jump processes to continuous allometric size spectra; parameterizing size-dependent predation kernels and quarter-power metabolic scalings; deriving early-warning signals of curvature collapse ($\mathbf{H} \to 0$) and variance explosion ($\det\mathbf{C} \to \infty$); and providing a self-contained Julia simulation suite with Moore–Penrose pseudoinverse curvature estimation.
- **Part 3: Allometric Transmission Line Theory, Impedance Matching, and the Flexible Canopy Cascade**: Presenting the flexible canopy mechanical analogy for multi-scale energy absorption; formulating the continuous metabolic dissipation spectrum $P(m) = P_0 m^{-\beta}$ and the ecological cochlea Fourier filtering model; mapping allometric cascades to electrodynamic transmission line and acoustic waveguide telegrapher equations; establishing characteristic wave impedances $Z(m) = \sqrt{\mathcal{L}(m)/\mathcal{C}(m)}$; analyzing chromatic frequency resonance across environmental climate bands; and deriving step-boundary reflection coefficients ($\Gamma$) that drive variance amplification when apex capacitors are harvested.
- **Part 4: Multi-Field Biophysical Onsager Transductions (Off-Diagonal Cross-Effects)**: Extending Onsager reciprocal relations across distinct physical, chemical, and ecological state fields; detailing thermo-sinking, photo-trophic, stoichiometric-allometric, shear-circulation, and allelopathic-grazing transductions; and proving generalized Le Chatelier–Braun moderation through multi-field matrix Schur complement reductions.
- **Part 5: The Canonical Onsager Estimator, Stationarity Over-Identification, and Epistemological Scope Conditions**: Formalizing the parameter-free estimator identity $\mathbf{L} = -\mathbf{A}\mathbf{C}/k_{\mathrm{B}}$; deriving the $n(n+1)/2$ over-identifying consistency constraints imposed by stationarity $\operatorname{sym}(\mathbf{D} + \mathbf{A}\mathbf{C}) = \mathbf{0}$; establishing coordinate invariance proofs under non-singular linear transformations; developing extremum dissipation principles under clamped forces versus clamped fluxes; proving monotonic Lyapunov availability relaxation; detailing the four structural obstructions for population census data; and establishing the coarse-graining block projection theorem for latent ecological variables.
- **Part 6: Interdisciplinary Foundations: Circuit Duality, Information Geometry, and Cybernetic Control**: Establishing formal mathematical equivalences between non-equilibrium ecological networks and multiport electrical circuit theory (Tellegen's theorem, non-dissipative gyrator arrays, equivalent reactive inductance synthesis $L_{\mathrm{eq}} = C_2 / g^2$, and damped $RLC$ oscillators); Riemannian information geometry (the Fisher information metric $g_{ij}(\mathbf{x}) = [\mathbf{C}^{-1}]_{ij}$ and the geometric breakdown of MacArthur's variational principle under non-zero curl); and cybernetic feedback control (Bode's sensitivity integral $\int_0^{\infty} \ln |S(i\omega)|\,d\omega = 0$, the waterbed effect, and the frequency-domain proof of the hyperbolic resistance–resilience trade-off $B_{\mathrm{tot}} \times \mathcal{R} \approx \text{const}$).

---

# Part 1: Discrete Pseudo-Chemical Master Equations, the Non-Linear Range, and Attractor Landscapes

## 1.1 Ecosystems as Discrete Pseudo-Chemical Reaction Networks

While continuous differential equations approximate the average trajectory of large populations, living ecosystems consist of discrete individual organisms undergoing discrete stochastic demographic events: birth, predation, metabolic senescence, and nutrient uptake. In a local volume element $V^\ddagger$, the state of an $n$-compartment ecological network is defined by an integer particle vector:

$$\mathbf{X} = (X_1, X_2, \dots, X_n)^{\mathsf{T}} \in \mathbb{Z}_{\ge 0}^n$$

where $X_i$ represents the discrete number of individuals (or discrete molar quantum units of limiting nutrient / biomass) in compartment $i$.

The network evolves through $r$ elementary stoichiometric reaction channels $\alpha \in \{1, 2, \dots, r\}$. Each channel $\alpha$ is characterized by:

- A stoichiometric transition vector $\boldsymbol{\nu}_\alpha = (\nu_{1\alpha}, \nu_{2\alpha}, \dots, \nu_{n\alpha})^{\mathsf{T}} \in \mathbb{Z}^n$, representing the net integer change in particle counts when reaction $\alpha$ fires ($\mathbf{X} \to \mathbf{X} + \boldsymbol{\nu}_\alpha$);
- A state-dependent reaction propensity $a_\alpha(\mathbf{X})$, such that $a_\alpha(\mathbf{X})\,dt$ defines the probability that reaction channel $\alpha$ fires in the infinitesimal time interval $[t, t + dt)$.

### Canonical Reaction Channels in Pelagic (NPZD) Food Webs

For a canonical four-compartment pelagic network consisting of Dissolved Inorganic Nutrient ($N$), Phytoplankton ($P$), Zooplankton ($Z$), and Detritus ($D$), elementary channels include:

- **Autotrophic Nutrient Uptake ($\alpha = 1$, $N + P \xrightarrow{\kappa_{np}} 2P$):**
  $$\boldsymbol{\nu}_1 = (-1, +1, 0, 0)^{\mathsf{T}}, \qquad a_1(\mathbf{X}) = \frac{\kappa_{np}}{V^\ddagger} X_N X_P$$
- **Zooplankton Grazing with Holling Type-II Satiation ($\alpha = 2$, $P + Z \to (1+e_z)Z + (1-e_z)D$):**
  $$\boldsymbol{\nu}_2 = (0, -1, +1, 0)^{\mathsf{T}}, \qquad a_2(\mathbf{X}) = \frac{\kappa_{pz} (X_P / V^\ddagger)}{1 + (X_P / V^\ddagger) / K_p} X_Z$$
  where $e_z$ is assimilation efficiency, $K_p$ is the half-saturation constant, and unassimilated grazing $(1 - e_z)$ is routed directly to detritus $D$.
- **Phytoplankton Senescence and Lysis ($\alpha = 3$, $P \xrightarrow{\mu_p} D$):**
  $$\boldsymbol{\nu}_3 = (0, -1, 0, +1)^{\mathsf{T}}, \qquad a_3(\mathbf{X}) = \mu_p X_P$$
- **Zooplankton Basal Respiration and Quadratic Mortality ($\alpha = 4$, $Z \xrightarrow{\mu_z, c_z} D$):**
  $$\boldsymbol{\nu}_4 = (0, 0, -1, +1)^{\mathsf{T}}, \qquad a_4(\mathbf{X}) = \mu_z X_Z + \frac{c_z}{V^\ddagger} X_Z(X_Z - 1)$$
  where $c_z$ accounts for density-dependent interference and disease.
- **Microbial Detrital Remineralization ($\alpha = 5$, $D \xrightarrow{\mu_d} N$):**
  $$\boldsymbol{\nu}_5 = (+1, 0, 0, -1)^{\mathsf{T}}, \qquad a_5(\mathbf{X}) = \mu_d X_D$$

## 1.2 The Chemical Master Equation and Gillespie Stochastic Simulation

The time evolution of the joint probability distribution $P(\mathbf{X}, t) = \operatorname{Prob}\{\mathbf{X}(t) = \mathbf{X}\}$ is governed by the exact continuous-time Chemical Master Equation (CME):

$$\frac{\partial P(\mathbf{X}, t)}{\partial t} = \sum_{\alpha=1}^r \left[ a_\alpha(\mathbf{X} - \boldsymbol{\nu}_\alpha) P(\mathbf{X} - \boldsymbol{\nu}_\alpha, t) - a_\alpha(\mathbf{X}) P(\mathbf{X}, t) \right]$$

The CME accounts for finite-particle discreteness, demographic stochasticity, and non-linear propensity correlations without introducing heuristic Gaussian approximations.

Because analytical solutions to multi-dimensional non-linear CMEs are generally intractable, exact sample trajectories are generated via Gillespie's Direct Stochastic Simulation Algorithm (SSA):

- **Evaluate Total Propensity**: Compute $a_0(\mathbf{X}) = \sum_{\alpha=1}^r a_\alpha(\mathbf{X})$.
- **Generate Next-Event Time Interval ($\tau$)**: Draw an exponential random variate $\tau = \frac{1}{a_0(\mathbf{X})} \ln(1 / r_1)$, with uniform random number $r_1 \in (0, 1)$.
- **Select Firing Channel ($\mu$)**: Choose index $\mu$ satisfying $\sum_{\alpha=1}^{\mu-1} a_\alpha(\mathbf{X}) < r_2 a_0(\mathbf{X}) \le \sum_{\alpha=1}^\mu a_\alpha(\mathbf{X})$, with uniform random number $r_2 \in (0, 1)$.
- **Update State and Clock**: Advance time $t \to t + \tau$ and update integer particle counts $\mathbf{X} \to \mathbf{X} + \boldsymbol{\nu}_\mu$.

## 1.3 Van Kampen System-Size Expansion and Non-Linear Fokker–Planck Dynamics

To establish the bridge between discrete master-equation jumps and continuous macroscopic transport physics, the Van Kampen system-size expansion sets extensive volume $V^\ddagger = \Omega \gg 1$ and decomposes discrete counts into deterministic concentrations $\boldsymbol{\phi}(t)$ plus scaled stochastic fluctuations $\boldsymbol{\xi}(t)$:

$$\mathbf{X}(t) = \Omega \boldsymbol{\phi}(t) + \Omega^{1/2} \boldsymbol{\xi}(t), \qquad \mathbf{x}(t) = \frac{\mathbf{X}(t)}{\Omega} = \boldsymbol{\phi}(t) + \Omega^{-1/2} \boldsymbol{\xi}(t)$$

Expanding the step operators $E_i^{-\nu_{i\alpha}} = 1 - \Omega^{-1/2}\nu_{i\alpha}\frac{\partial}{\partial \xi_i} + \frac{1}{2}\Omega^{-1}\nu_{i\alpha}^2 \frac{\partial^2}{\partial \xi_i^2} + \dots$ in powers of $\Omega^{-1/2}$ yields:

- **Order $\Omega^{1/2}$ (Macroscopic Deterministic Drift)**:
  $$\frac{d\boldsymbol{\phi}}{dt} = \mathbf{f}(\boldsymbol{\phi}) = \sum_{\alpha=1}^r \boldsymbol{\nu}_\alpha \tilde{a}_\alpha(\boldsymbol{\phi})$$
  where $\tilde{a}_\alpha(\boldsymbol{\phi}) = \lim_{\Omega\to\infty} \Omega^{-1} a_\alpha(\Omega\boldsymbol{\phi})$ are the intensive reaction rates.
- **Order $\Omega^0$ (Non-Linear Fluctuation Fokker–Planck Equation)**:
  $$\frac{\partial \Pi(\boldsymbol{\xi}, t)}{\partial t} = -\sum_{i,j=1}^n \frac{\partial}{\partial \xi_i} \left[ A_{ij}(\boldsymbol{\phi}(t)) \xi_j \Pi(\boldsymbol{\xi}, t) \right] + \frac{1}{2}\sum_{i,j=1}^n B_{ij}(\boldsymbol{\phi}(t)) \frac{\partial^2 \Pi(\boldsymbol{\xi}, t)}{\partial \xi_i \partial \xi_j}$$
  where the demographic Jacobian is $A_{ij}(\boldsymbol{\phi}) = \frac{\partial f_i}{\partial \phi_j}$, and the state-dependent diffusion tensor is:
  $$\mathbf{B}(\boldsymbol{\phi}) = \sum_{\alpha=1}^r \boldsymbol{\nu}_\alpha \boldsymbol{\nu}_\alpha^{\mathsf{T}} \tilde{a}_\alpha(\boldsymbol{\phi})$$

In terms of continuous concentration variables $\mathbf{x} = \mathbf{X}/\Omega$, the dynamics correspond to the non-linear Langevin stochastic differential equation:

$$d\mathbf{x} = \mathbf{f}(\mathbf{x})\,dt + \Omega^{-1/2} \mathbf{g}(\mathbf{x})\,d\mathbf{W}(t)$$

where $\mathbf{g}(\mathbf{x})\mathbf{g}(\mathbf{x})^{\mathsf{T}} = \mathbf{B}(\mathbf{x})$, and $d\mathbf{W}(t)$ is an $r$-dimensional standard Wiener process.

## 1.4 The Far-From-Equilibrium Non-Linear Range and Breakdown of Linear Reciprocity

A fundamental physical distinction separates the linear near-equilibrium regime from the far-from-equilibrium non-linear range:

- **The Linear Near-Equilibrium Range**: When thermodynamic affinities $X_r = -\Delta\mu_r / T$ are small ($|X_r| \ll 2k_{\mathrm{B}}$), fluxes depend linearly on forces ($J_r = \sum_s L_{rs} X_s$), and the Onsager conductivities $L_{rs}$ are constants satisfying microscopic time-reversal symmetry ($L_{rs} = L_{sr}$). Prigogine's Theorem of Minimum Entropy Production (MinEP) holds globally under fixed forces, confining the system to a single stable point attractor.
- **The Far-From-Equilibrium Non-Linear Range**: Ecosystems are open dissipative structures driven far from equilibrium by large solar gradients ($T_{\mathrm{sun}} \approx 5800\ \mathrm{K}$ vs. $T_{\mathrm{space}} \approx 3\ \mathrm{K}$). For elementary biochemical and trophic reactions, the exact De Donder–Guldberg–Waage relation gives:
  $$J_r(X_r) = w_r^+ - w_r^- = w_r^- \left( \exp\left(\frac{X_r}{k_{\mathrm{B}}}\right) - 1 \right) \approx 2 w_r^{\mathrm{eq}} \sinh\left(\frac{X_r}{2 k_{\mathrm{B}}}\right)$$
  which is linear only when $|X_r| \ll 2 k_{\mathrm{B}}$. In macroscopic food webs, non-linearities are further compounded by Holling Type II/III satiation kinetics, predator interference, and stoichiometric thresholds:
  $$\Phi_{ij}(x_i, x_j) = \frac{a_{ij} x_i x_j}{1 + a_{ij} h_{ij} x_i + c_i x_i^2}$$

In this non-linear regime, the phenomenological conductivity tensor $\mathbf{D}(\mathbf{x})$ and probability circulation tensor $\boldsymbol{\Omega}(\mathbf{x})$ become state-dependent functions of position in phase space. MinEP no longer holds globally; instead, stability is governed by the **Glansdorff–Prigogine excess entropy production criterion**:

$$\delta^2 \sigma = \frac{1}{2} \sum_{r=1}^r \delta J_r \, \delta X_r$$

When external throughput drives an ecosystem past a critical bifurcation threshold, excess entropy production can become negative ($\delta^2\sigma < 0$). This destabilizes the stationary thermodynamic branch, driving symmetry-breaking transitions and self-organization into non-equilibrium **dissipative structures**.

## 1.5 Phase Space Geometry and Typology of Ecological Attractors

Dissipative contraction of phase-space volume ($\operatorname{div}\mathbf{f}(\mathbf{x}) < 0$) confines long-term ecosystem trajectories to compact invariant subsets (attractors $\mathcal{A} \subset \mathbb{R}_{\ge 0}^n$). The non-linear range supports four fundamental classes of non-equilibrium attractors:

| Attractor Class | Phase Space Geometry | Dynamical Mechanism | Thermodynamic Signature | Ecological Examples |
|:----------------|:---------------------|:--------------------|:------------------------|:--------------------|
| **Point Attractor** (Fixed Point) | Dimension $0$: Isolated point $\mathbf{x}^* \in \mathbb{R}_{\ge 0}^n$ with basin $\mathcal{B}(\mathbf{x}^*)$ | Local linear stability $\operatorname{Re}(\lambda_i(\mathbf{A})) < 0$; quadratic potential minimum $\nabla U(\mathbf{x}^*) = \mathbf{0}$ | Constant dissipation $\sigma^* = k_{\mathrm{B}}\operatorname{tr}(\boldsymbol{\Omega}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{D}^{-1}) > 0$; local MinEP holds | Climax forest; oligotrophic oceanic gyre; chemostat steady state |
| **Periodic Attractor** (Limit Cycle) | Dimension $1$: Closed isolated loop $\gamma(t+T) = \gamma(t)$ with phase $\theta \in [0, 2\pi)$ | Supercritical Hopf bifurcation; complex conjugate pair crosses imaginary axis ($\operatorname{Re}(\lambda_{1,2}) = 0$) | Annular potential gutter $\nabla U \cdot \mathbf{v}_{\mathrm{curl}} = 0$; perpetual directed circulation $\mathbf{v}_{\mathrm{curl}} \ne \mathbf{0}$ along orbit | Predator-prey cycles; seasonal plankton blooms; circadian metabolic cycles |
| **Toroidal Attractor** (Quasi-Periodicity) | Dimension $m \ge 2$: Invariant torus $\mathbb{T}^m$ in state space | Non-linear coupling of $m$ limit cycles with incommensurate frequencies ($\omega_1 / \omega_2 \notin \mathbb{Q}$) | Multi-frequency entropy production; dense irrational winding on constant potential surface | Inter-annual plankton cycles coupled to seasonal forcing and El Niño / NAO cycles |
| **Strange Attractor** (Deterministic Chaos) | Fractal dimension $D_F \in (2, 3)$: Bounded, non-repeating fractal manifold | Local exponential stretching ($\lambda_{\max} > 0$) combined with global phase-space folding | Broadband continuous power spectrum $S(\omega)$; positive Kolmogorov–Sinai entropy production rate | Tri-trophic food chains (Hastings–Powell); chaotic marine fish recruitment; multi-species competition |

### Phase Dynamics and Astronomical Synchronization on Limit Cycles

A limit cycle possesses an intrinsic dynamical phase $\theta(t) = \omega_0 t + \theta_0 \pmod{2\pi}$. Because limit cycles are structurally stable attractors (unlike conservative Lotka–Volterra orbits), this phase degree of freedom enables ecosystems to **phase-lock** and **entrain** to planetary astronomical rhythms: diurnal solar insolation, semi-diurnal tides, and annual orbital cycles. In non-linear phase space, external periodic forcing generates Arnold tongues, subharmonic resonances, and phase synchronization across trophic levels.

## 1.6 Non-Equilibrium Quasi-Potential Landscapes, Instanton Hysteresis, and Circulation Dissipation

In non-equilibrium systems where detailed balance is broken, the deterministic drift field $\mathbf{f}(\mathbf{x})$ cannot be expressed as the gradient of a single scalar potential. In stochastic systems governed by the non-linear Langevin equation:

$$\dot{\mathbf{x}} = \mathbf{f}(\mathbf{x}) + \frac{1}{\sqrt{\Omega}}\boldsymbol{\xi}(t), \qquad \langle \boldsymbol{\xi}(t) \boldsymbol{\xi}^{\mathsf{T}}(t') \rangle = 2\mathbf{D}(\mathbf{x})\delta(t - t')$$

the stationary probability distribution $P_{\mathrm{ss}}(\mathbf{x})$ satisfies the stationary Fokker–Planck equation $\nabla \cdot \mathbf{J}_{\mathrm{prob}}(\mathbf{x}) = 0$. By Freidlin–Wentzell large deviation theory, in the macroscopic volume limit ($\Omega \to \infty$), the distribution scales asymptotically as:

$$P_{\mathrm{ss}}(\mathbf{x}) \asymp \exp\left( -\Omega\, U(\mathbf{x}) \right), \qquad U(\mathbf{x}) = -\lim_{\Omega \to \infty} \frac{1}{\Omega} \ln P_{\mathrm{ss}}(\mathbf{x})$$

where $U(\mathbf{x})$ is the non-equilibrium quasi-potential landscape.

The stationary probability flux is:

$$\mathbf{J}_{\mathrm{prob}}(\mathbf{x}) = \mathbf{f}(\mathbf{x})P_{\mathrm{ss}}(\mathbf{x}) - \frac{1}{\Omega}\mathbf{D}(\mathbf{x})\nabla P_{\mathrm{ss}}(\mathbf{x}) = \left( \mathbf{f}(\mathbf{x}) + \mathbf{D}(\mathbf{x})\nabla U(\mathbf{x}) \right) P_{\mathrm{ss}}(\mathbf{x}) + \mathcal{O}(\Omega^{-1})$$

Defining the stationary circulation velocity field $\mathbf{v}_{\mathrm{curl}}(\mathbf{x}) \equiv \mathbf{J}_{\mathrm{prob}}(\mathbf{x}) / P_{\mathrm{ss}}(\mathbf{x}) = \mathbf{f}(\mathbf{x}) + \mathbf{D}(\mathbf{x})\nabla U(\mathbf{x})$ yields the non-equilibrium **Helmholtz–Hodge decomposition** of the non-linear deterministic drift:

$$\mathbf{f}(\mathbf{x}) = -\mathbf{D}(\mathbf{x})\nabla U(\mathbf{x}) + \mathbf{v}_{\mathrm{curl}}(\mathbf{x})$$

Substituting this decomposition into the leading-order WKB Hamilton–Jacobi equation $\nabla U(\mathbf{x})^{\mathsf{T}} \mathbf{D}(\mathbf{x}) \nabla U(\mathbf{x}) + \mathbf{f}(\mathbf{x})^{\mathsf{T}}\nabla U(\mathbf{x}) = 0$ in the macroscopic limit $\Omega \to \infty$ confirms exact orthogonality:

$$\nabla U(\mathbf{x})^{\mathsf{T}} \mathbf{D}(\mathbf{x}) \nabla U(\mathbf{x}) + \left( -\mathbf{D}(\mathbf{x})\nabla U(\mathbf{x}) + \mathbf{v}_{\mathrm{curl}}(\mathbf{x}) \right)^{\mathsf{T}}\nabla U(\mathbf{x}) = \mathbf{v}_{\mathrm{curl}}(\mathbf{x})^{\mathsf{T}}\nabla U(\mathbf{x}) = 0$$

- The symmetric dissipative tensor $\mathbf{D}(\mathbf{x}) \succ 0$ drives trajectories downhill toward quasi-potential minima ($dU/dt \le 0$ along the dissipative gradient);
- The circulation velocity field $\mathbf{v}_{\mathrm{curl}}(\mathbf{x}) = \boldsymbol{\Omega}(\mathbf{x})\nabla U(\mathbf{x})$ circulates along iso-potential contours without altering $U(\mathbf{x})$, sustaining non-equilibrium consumer-resource oscillations.

### Eyring–Kramers Escape Kinetics and Topological Transition-Path Hysteresis

In the path-integral formulation, the probability density functional of a continuous trajectory $\mathbf{x}(t)$ over $[t_1, t_2]$ scales as $\mathcal{P}[\mathbf{x}(t)] \asymp \exp(-\Omega\,\mathcal{S}[\mathbf{x}(t)])$, governed in the linearized regime ($\mathbf{f}(\mathbf{x}) = \mathbf{A}\mathbf{x}$, $\mathbf{D}(\mathbf{x}) = \mathbf{D}_{\mathrm{sym}}$, $\Omega = 1$) by the Onsager–Machlup action functional:

$$\mathcal{S}[\mathbf{x}(t)] = \int_{t_1}^{t_2} \frac{1}{4}\left(\dot{\mathbf{x}} - \mathbf{A}\mathbf{x}\right)^{\mathsf{T}}\mathbf{D}_{\mathrm{sym}}^{-1}\left(\dot{\mathbf{x}} - \mathbf{A}\mathbf{x}\right)\,dt$$

Minimizing $\mathcal{S}[\mathbf{x}(t)]$ selects the most probable trajectory (instanton) in path space. For unconstrained relaxation from an initial perturbation $\mathbf{x}(0) = \mathbf{x}_0$, $\mathbf{D}_{\mathrm{sym}}^{-1} \succ 0$ implies $\mathcal{S}_{\min} = 0$, attained along the deterministic downhill relaxation path:

$$\dot{\mathbf{x}} = \mathbf{A}\mathbf{x} = -\left(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega}\right)\mathbf{C}^{-1}\mathbf{x}$$

Conversely, for a noise-driven fluctuation excursion from the attractor $\mathbf{x}(-\infty) = \mathbf{0}$ to a displaced state $\mathbf{x}(0) = \mathbf{x}_f$, completing the square around the time-reversed adjoint drift $\mathbf{A}^* = \mathbf{C}\mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} = -(\mathbf{D}_{\mathrm{sym}} - \boldsymbol{\Omega})\mathbf{C}^{-1}$ using the continuous Lyapunov identity $\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} = -2\mathbf{D}_{\mathrm{sym}}$ yields:

$$\mathcal{S}[\mathbf{x}(t)] = \int_{-\infty}^{0} \frac{1}{4}\left(\dot{\mathbf{x}} - \mathbf{A}^*\mathbf{x}\right)^{\mathsf{T}}\mathbf{D}_{\mathrm{sym}}^{-1}\left(\dot{\mathbf{x}} - \mathbf{A}^*\mathbf{x}\right)\,dt + \frac{1}{2}\mathbf{x}_f^{\mathsf{T}}\mathbf{C}^{-1}\mathbf{x}_f$$

The minimum action required to reach $\mathbf{x}_f$ against restoring drift is attained along the uphill instanton $\dot{\mathbf{x}} = \mathbf{A}^*\mathbf{x}$ and equals the quadratic Lyapunov availability potential:

$$\mathcal{S}_{\min}(\mathbf{x}_f) = \min_{\mathbf{x}(-\infty)=\mathbf{0},\,\mathbf{x}(0)=\mathbf{x}_f} \mathcal{S}[\mathbf{x}(t)] = \frac{1}{2}\mathbf{x}_f^{\mathsf{T}}\mathbf{C}^{-1}\mathbf{x}_f = V(\mathbf{x}_f)$$

When non-linearities create multiple attractor basins $\mathbf{x}_A^*$ and $\mathbf{x}_B^*$ separated by a saddle-point ridge $\mathbf{x}_S$, the mean escape time $\tau_{\mathrm{escape}}$ from an intact basin across the saddle ridge into an alternative degraded basin scales exponentially:

$$\tau_{\mathrm{escape}} \approx \frac{2\pi}{|\lambda_u|} \left( \frac{-\det \mathbf{H}_S}{\det \mathbf{H}_A} \right)^{1/2} \exp\left( \Omega\, \Delta U \right) \propto \exp\left( B_{\text{tot}}\, \Delta U \right)$$

where $\Delta U = U(\mathbf{x}_S) - U(\mathbf{x}_A^*)$ is the quasi-potential barrier height, and $\mathbf{H}_A, \mathbf{H}_S$ are the Hessians at the attractor and saddle.

Crucially, because $\boldsymbol{\Omega} \ne \mathbf{0}$, the deterministic relaxation path ($\dot{\mathbf{x}} = -(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}\mathbf{x}$) and the noise-activated uphill escape path ($\dot{\mathbf{x}} = -(\mathbf{D}_{\mathrm{sym}} - \boldsymbol{\Omega})\mathbf{C}^{-1}\mathbf{x}$) do not retrace one another in reverse. Both rotate in the same circulatory direction set by $\boldsymbol{\Omega}$, breaking time-reversal symmetry: the path of regime collapse ($\mathcal{A}_1 \to \mathcal{A}_2$) is geometrically distinct from the path of recovery ($\mathcal{A}_2 \to \mathcal{A}_1$). This topological irreversibility provides a physical foundation for ecological hysteresis.

### Exact Matrix Trace Formula for Steady-State Circulation Dissipation

The stationary total entropy production rate $\sigma$ measures the thermodynamic irreversibility of probability currents against diffusive friction. Its exact matrix trace formula is derived from the linear Fokker–Planck equation through seven systematic steps:

- **Step 1: Linear Fokker–Planck Dynamics**: Consider an $n$-dimensional state vector $\mathbf{x} \in \mathbb{R}^n$ (departures from reference steady state $\mathbf{x}^*$) governed by linear drift $\mathbf{A}\mathbf{x}$ and constant symmetric noise diffusion tensor $\mathbf{D} \succ 0$. The probability density $P(\mathbf{x}, t)$ evolves via $\partial_t P(\mathbf{x}, t) = -\nabla \cdot \mathbf{J}_{\mathrm{prob}}(\mathbf{x}, t)$, with probability flux:
  $$\mathbf{J}_{\mathrm{prob}}(\mathbf{x}, t) = \mathbf{A}\mathbf{x} P(\mathbf{x}, t) - \mathbf{D}\nabla P(\mathbf{x}, t)$$

- **Step 2: Stationary Distribution and Spatial Log-Gradient**: At dynamic stationarity ($\partial_t P_{\mathrm{ss}} = 0$), the unconstrained linear system admits a centered multivariate Gaussian distribution:
  $$P_{\mathrm{ss}}(\mathbf{x}) = \frac{1}{(2\pi)^{n/2}(\det \mathbf{C})^{1/2}} \exp\left( -\frac{1}{2}\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\mathbf{x} \right)$$
  where $\mathbf{C} = \langle \mathbf{x}\mathbf{x}^{\mathsf{T}} \rangle_{\mathrm{ss}} \succ 0$ is the stationary covariance matrix satisfying $\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} + 2\mathbf{D} = \mathbf{0}$. Differentiating yields the spatial gradient:
  $$\nabla P_{\mathrm{ss}}(\mathbf{x}) = -\mathbf{C}^{-1}\mathbf{x} \, P_{\mathrm{ss}}(\mathbf{x})$$

- **Step 3: Stationary Current and Circulation Drift Operator**: Substituting $\nabla P_{\mathrm{ss}}(\mathbf{x})$ into the probability current gives:
  $$\mathbf{J}_{\mathrm{prob}}(\mathbf{x}) = \mathbf{A}\mathbf{x} P_{\mathrm{ss}}(\mathbf{x}) - \mathbf{D}\left( -\mathbf{C}^{-1}\mathbf{x} P_{\mathrm{ss}}(\mathbf{x}) \right) = \left( \mathbf{A} + \mathbf{D}\mathbf{C}^{-1} \right)\mathbf{x} P_{\mathrm{ss}}(\mathbf{x})$$
  Multiplying the continuous Lyapunov equation on the right by $\mathbf{C}^{-1}$ yields $\mathbf{A} + \mathbf{C}\mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} + 2\mathbf{D}\mathbf{C}^{-1} = \mathbf{0}$, so $\mathbf{D}\mathbf{C}^{-1} = -\frac{1}{2}\mathbf{A} - \frac{1}{2}\mathbf{C}\mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1}$. Substituting this into the drift term gives:
  $$\mathbf{A} + \mathbf{D}\mathbf{C}^{-1} = \frac{1}{2}\left( \mathbf{A}\mathbf{C} - \mathbf{C}\mathbf{A}^{\mathsf{T}} \right)\mathbf{C}^{-1}$$
  From the canonical Lyapunov decomposition $-\mathbf{A}\mathbf{C} = \mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega}$, the skew-symmetric circulation tensor satisfies $\frac{1}{2}(\mathbf{A}\mathbf{C} - \mathbf{C}\mathbf{A}^{\mathsf{T}}) = -\boldsymbol{\Omega}$. Defining the circulation drift matrix $\mathbf{M} := -\boldsymbol{\Omega}\mathbf{C}^{-1}$, the stationary probability current reduces to:
  $$\mathbf{J}_{\mathrm{prob}}(\mathbf{x}) = \mathbf{M}\mathbf{x} P_{\mathrm{ss}}(\mathbf{x}) = -\boldsymbol{\Omega}\mathbf{C}^{-1}\mathbf{x} P_{\mathrm{ss}}(\mathbf{x})$$
  Because $\mathbf{C}^{-1}$ is symmetric and $\boldsymbol{\Omega}$ is skew-symmetric, $\operatorname{tr}(\boldsymbol{\Omega}\mathbf{C}^{-1}) = 0$ and $\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}\mathbf{x} = 0$, confirming that $\mathbf{J}_{\mathrm{prob}}(\mathbf{x})$ is strictly divergence-free: $\nabla \cdot \mathbf{J}_{\mathrm{prob}}(\mathbf{x}) = 0$.

- **Step 4: Phase-Space Integration of Thermodynamic Entropy Production**: In stochastic thermodynamics, stationary entropy production is evaluated by integrating local dissipation against diffusive friction:
  $$\sigma = k_{\mathrm{B}} \int_{\mathbb{R}^n} \frac{\mathbf{J}_{\mathrm{prob}}(\mathbf{x})^{\mathsf{T}} \mathbf{D}^{-1} \mathbf{J}_{\mathrm{prob}}(\mathbf{x})}{P_{\mathrm{ss}}(\mathbf{x})}\, d\mathbf{x} = k_{\mathrm{B}} \int_{\mathbb{R}^n} \left( \mathbf{x}^{\mathsf{T}}\mathbf{M}^{\mathsf{T}}\mathbf{D}^{-1}\mathbf{M}\mathbf{x} \right) P_{\mathrm{ss}}(\mathbf{x})\, d\mathbf{x}$$

- **Step 5: Reduction via Cyclic Trace and Stationary Covariance**: Applying the cyclic trace identity for quadratic forms $\mathbf{x}^{\mathsf{T}}\mathbf{K}\mathbf{x} = \operatorname{tr}(\mathbf{K}\mathbf{x}\mathbf{x}^{\mathsf{T}})$ where $\mathbf{K} = \mathbf{M}^{\mathsf{T}}\mathbf{D}^{-1}\mathbf{M}$:
  $$\sigma = k_{\mathrm{B}} \operatorname{tr}\left[ \mathbf{M}^{\mathsf{T}}\mathbf{D}^{-1}\mathbf{M} \int_{\mathbb{R}^n} \mathbf{x}\mathbf{x}^{\mathsf{T}} P_{\mathrm{ss}}(\mathbf{x})\, d\mathbf{x} \right] = k_{\mathrm{B}} \operatorname{tr}\left( \mathbf{M}^{\mathsf{T}}\mathbf{D}^{-1}\mathbf{M} \, \mathbf{C} \right)$$

- **Step 6: Expansion in Circulation and Covariance Tensors**: Substituting $\mathbf{M} = -\boldsymbol{\Omega}\mathbf{C}^{-1}$ and $\mathbf{M}^{\mathsf{T}} = -\mathbf{C}^{-1}\boldsymbol{\Omega}^{\mathsf{T}}$:
  $$\sigma = k_{\mathrm{B}} \operatorname{tr}\left( \left(-\mathbf{C}^{-1}\boldsymbol{\Omega}^{\mathsf{T}}\right) \mathbf{D}^{-1} \left(-\boldsymbol{\Omega}\mathbf{C}^{-1}\right) \mathbf{C} \right) = k_{\mathrm{B}} \operatorname{tr}\left( \mathbf{C}^{-1}\boldsymbol{\Omega}^{\mathsf{T}}\mathbf{D}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}\mathbf{C} \right)$$
  Because $\mathbf{C}^{-1}\mathbf{C} = \mathbf{I}$, cyclic invariance of the trace yields:
  $$\sigma = k_{\mathrm{B}} \operatorname{tr}\left( \boldsymbol{\Omega}^{\mathsf{T}} \mathbf{C}^{-1} \boldsymbol{\Omega} \mathbf{D}^{-1} \right) = -k_{\mathrm{B}} \operatorname{tr}\left( \boldsymbol{\Omega} \mathbf{C}^{-1} \boldsymbol{\Omega} \mathbf{D}^{-1} \right)$$

- **Step 7: Positivity and Detailed Balance**: Because $\mathbf{D}^{-1} \succ 0$ and $\mathbf{C}^{-1} \succ 0$, the matrix $\mathbf{K} = \boldsymbol{\Omega}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega} \succeq 0$ is positive semidefinite. The trace product of two positive semidefinite matrices is non-negative, ensuring $\sigma \ge 0$ unconditionally. Detailed balance holds if and only if circulation vanishes ($\boldsymbol{\Omega} = \mathbf{0}$), yielding $\sigma = 0$; conversely, in any living ecosystem with active trophic cycling, $\boldsymbol{\Omega} \ne \mathbf{0}$ and $\sigma > 0$.

### Mechanistic Early-Warning Diagnostics: Fold vs. Hopf Bifurcations

As environmental exploitation, warming, or toxic stress pushes an ecosystem toward a bifurcation, the local quadratic curvature of the quasi-potential well ($\mathbf{H} = k_{\mathrm{B}}\mathbf{C}^{-1} \propto \nabla^2 U(\mathbf{x}^*)$) degrades along two distinct mechanistic pathways that serve as operational early-warning diagnostics:

- **Curvature Collapse and Critical Slowing Down (Fold Bifurcation)**: When chronic environmental stress weakens dissipative self-regulation ($\lambda_{\min}(\mathbf{D}_{\mathrm{sym}}) \to 0$) or erodes entropic curvature ($\lambda_{\min}(\mathbf{H}) \to 0$), a real eigenvalue of $\mathbf{A}$ approaches zero ($\lambda_1 \to 0^-$). The restoring force along the corresponding soft eigenvector vanishes, lengthening recovery times after perturbations and causing stationary variance to diverge along the soft coordinate ($\mathbf{C}_{11} = k_{\mathrm{B}} / \lambda_{\min}(\mathbf{H}) \to \infty$) prior to a saddle-node transition.
- **Capacitance Stripping and Oscillatory Destabilization (Hopf Bifurcation)**: When selective harvesting or habitat fragmentation strips slow macroscopic biomass capacitors ($C_{ii} \to 0$) while strong trophic throughput sustains skew-symmetric circulation $\boldsymbol{\Omega}$, the non-equilibrium circulation ratio surges:
  $$\chi = \frac{\|\boldsymbol{\Omega}\|_F}{\|\mathbf{D}_{\mathrm{sym}}\|_F} \to \infty$$
  This surge induces spiral phase-space dynamics and inflates the stationary entropy production rate $\sigma$, signaling imminent loss of dynamic stability via limit-cycle emergence rather than directional attractor flattening.

## 1.7 Julia Implementation: Gillespie SSA and Non-Linear Potential Landscape Solver

```julia
# ==============================================================================
# Non-Linear Stochastic Gillespie SSA and Potential Landscape Solver
# 
# Simulates discrete jump processes for a non-linear NPZD ecological network,
# extracts the stationary fluctuation covariance matrix, and reconstructs the
# one-dimensional quasi-potential landscape slice U(x_1) = -ln P_ss(x_1).
# ==============================================================================

using LinearAlgebra
using Random
using Statistics
using Printf

"""
    GillespieNPZDParams

Parameter container for discrete non-linear NPZD stochastic simulation.

# Fields
- `V::Float64`: Local volume element (m^3)
- `kappa_np::Float64`: Primary production rate constant
- `kappa_pz::Float64`: Maximum zooplankton grazing rate constant
- `K_p::Float64`: Holling Type-II half-saturation concentration
- `e_z::Float64`: Zooplankton assimilation efficiency
- `mu_p::Float64`: Phytoplankton mortality and senescence rate
- `mu_z::Float64`: Zooplankton basal mortality rate
- `mu_d::Float64`: Microbial detrital remineralization rate
"""
struct GillespieNPZDParams
    V::Float64
    kappa_np::Float64
    kappa_pz::Float64
    K_p::Float64
    e_z::Float64
    mu_p::Float64
    mu_z::Float64
    mu_d::Float64
end

function GillespieNPZDParams(; 
    V=100.0, 
    kappa_np=0.05, 
    kappa_pz=0.20, 
    K_p=15.0, 
    e_z=0.60, 
    mu_p=0.05, 
    mu_z=0.10, 
    mu_d=0.08
)
    return GillespieNPZDParams(V, kappa_np, kappa_pz, K_p, e_z, mu_p, mu_z, mu_d)
end

"""
    run_gillespie_ssa(p::GillespieNPZDParams, X0::Vector{Int}, max_steps::Int)

Executes Gillespie's Direct Stochastic Simulation Algorithm for discrete counts
of Nutrient (N), Phytoplankton (P), Zooplankton (Z), and Detritus (D).

# Inputs
- `p`: Model parameters (GillespieNPZDParams)
- `X0`: Initial integer particle counts [N0, P0, Z0, D0]
- `max_steps`: Total discrete jump events to simulate

# Outputs
- `times`: Vector of transition event timestamps
- `trajectory`: Matrix of compartment concentrations (4 x (max_steps + 1))
"""
function run_gillespie_ssa(p::GillespieNPZDParams, X0::Vector{Int}, max_steps::Int)
    num_species = 4
    num_reactions = 5
    
    # Stoichiometric matrix B (4 x 5):
    # R1: N + P -> 2P
    # R2: P + Z -> (1 + e_z)Z + (1 - e_z)D (Holling II)
    # R3: P -> D
    # R4: Z -> D
    # R5: D -> N
    B = [
        -1   0   0   0  +1; # N
        +1  -1  -1   0   0; # P
         0  +1   0  -1   0; # Z
         0   0  +1  +1  -1  # D
    ]
    
    times = zeros(Float64, max_steps + 1)
    trajectory = zeros(Float64, num_species, max_steps + 1)
    
    X = copy(X0)
    trajectory[:, 1] = X ./ p.V
    t = 0.0
    times[1] = t
    
    for step in 1:max_steps
        N, P, Z, D = X[1], X[2], X[3], X[4]
        
        # Calculate non-linear reaction propensities
        a = zeros(Float64, num_reactions)
        a[1] = (p.kappa_np * N * P) / p.V
        P_conc = P / p.V
        a[2] = (p.kappa_pz * P_conc / (1.0 + P_conc / p.K_p)) * Z
        a[3] = p.mu_p * P
        a[4] = p.mu_z * Z
        a[5] = p.mu_d * D
        
        a0 = sum(a)
        if a0 <= 0.0
            break
        end
        
        # Draw next event timestamp
        r1 = rand()
        tau = -log(r1) / a0
        t += tau
        
        # Select firing reaction channel
        r2 = rand() * a0
        cum_a = 0.0
        selected_rxn = 1
        for i in 1:num_reactions
            cum_a += a[i]
            if cum_a >= r2
                selected_rxn = i
                break
            end
        end
        
        # Update integer counts with non-negativity protection
        for s in 1:num_species
            X[s] += B[s, selected_rxn]
            if X[s] < 0
                X[s] = 0
            end
        end
        
        times[step + 1] = t
        trajectory[:, step + 1] = X ./ p.V
    end
    
    return times, trajectory
end

"""
    compute_1d_potential(vals::Vector{Float64}; nbins=20)

Computes bin centers, empirical stationary probabilities, and non-equilibrium
quasi-potential values U(x) = -ln P_ss(x) from stochastic sample trajectories.
"""
function compute_1d_potential(vals::Vector{Float64}; nbins=20)
    min_v, max_v = minimum(vals), maximum(vals)
    if min_v == max_v
        error("Degenerate sample variance: minimum equals maximum value.")
    end
    
    edges = range(min_v, max_v, length=nbins+1)
    counts = zeros(Int, nbins)
    
    for v in vals
        bin_idx = floor(Int, (v - min_v) / (max_v - min_v) * nbins) + 1
        if bin_idx > nbins
            bin_idx = nbins
        elseif bin_idx < 1
            bin_idx = 1
        end
        counts[bin_idx] += 1
    end
    
    total_counts = sum(counts)
    probs = counts ./ total_counts
    centers = [0.5 * (edges[i] + edges[i+1]) for i in 1:nbins]
    
    results = Tuple{Float64, Float64, Float64}[]
    for i in 1:nbins
        if probs[i] > 0.0
            push!(results, (centers[i], probs[i], -log(probs[i])))
        end
    end
    
    return results
end

# Execution demonstration
let
    params = GillespieNPZDParams(V=200.0)
    X0 = [200, 100, 50, 50]
    total_steps = 100000
    
    times, traj = run_gillespie_ssa(params, X0, total_steps)
    
    # Analyze steady-state distribution from second half of trajectory
    steady_steps = Int(total_steps / 2):total_steps
    steady_data = traj[:, steady_steps]
    
    mean_conc = mean(steady_data, dims=2)
    cov_matrix = cov(steady_data, dims=2)
    
    @printf("=== NON-LINEAR NPZD GILLESPIE SSA RESULTS ===\n")
    @printf("Total Steps Simulated: %d\n", total_steps)
    @printf("Final Elapsed Time:    %.2f time units\n", times[end])
    @printf("Mean Concentrations:   N=%.3f, P=%.3f, Z=%.3f, D=%.3f\n\n",
            mean_conc[1], mean_conc[2], mean_conc[3], mean_conc[4])
            
    @printf("Stationary Fluctuation Covariance Matrix C:\n")
    for i in 1:4
        @printf("  [ %9.4f %9.4f %9.4f %9.4f ]\n",
                cov_matrix[i,1], cov_matrix[i,2], cov_matrix[i,3], cov_matrix[i,4])
    end
    
    potential_profile = compute_1d_potential(steady_data[2, :], nbins=15)
    @printf("\n=== RECONSTRUCTED QUASI-POTENTIAL LANDSCAPE U(P) ===\n")
    @printf("%-15s %-15s %-15s\n", "Phytoplankton P", "Prob P_ss(P)", "Potential U(P)")
    for (center, prob, u_val) in potential_profile
        @printf("%-15.4f %-15.6f %-15.4f\n", center, prob, u_val)
    end
end
```

## 1.8 Summary Comparison: Linearized Gaussian vs. Non-Linear Stochastic Jump Dynamics

| Theoretical Dimension | Linearized Gaussian Regime (Near Steady State) | Non-Linear Stochastic Jump Regime (Master Equation) |
|:----------------------|:----------------------------------------------|:---------------------------------------------------|
| **Reaction Propensities** | Constant linear expansion coefficients $\mathbf{A}$ | Non-linear satiation kinetics $a_\alpha(\mathbf{X})$ (Holling II/III, quadratic loss) |
| **State Distribution** | Multivariate Gaussian $P(\mathbf{x}) \propto \exp(-\frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\delta\mathbf{x})$ | Non-Gaussian, multi-modal probability density $P(\mathbf{X}, t)$ |
| **Diffusion Tensor** | Constant white-noise diffusion matrix $\mathbf{D}_{\mathrm{sym}}$ | State-dependent diffusion tensor $\mathbf{B}(\mathbf{x}) = \sum_\alpha \boldsymbol{\nu}_\alpha \boldsymbol{\nu}_\alpha^{\mathsf{T}} \tilde{a}_\alpha(\mathbf{x})$ |
| **Potential Landscape** | Single quadratic harmonic basin $V(\delta\mathbf{x}) = \frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\delta\mathbf{x}$ | Multi-basin landscape $U(\mathbf{x}) = -\lim_{\Omega\to\infty} \Omega^{-1}\ln P_{\mathrm{ss}}(\mathbf{x})$ with saddle ridges |
| **Probability Circulation** | Constant skew-symmetric tensor $\boldsymbol{\Omega} = \frac{1}{2}(\mathbf{C}\mathbf{A}^{\mathsf{T}} - \mathbf{A}\mathbf{C})$ | State-dependent circulation velocity field $\mathbf{w}(\mathbf{x}) = \mathbf{J}_{\mathrm{prob}}(\mathbf{x}) / P_{\mathrm{ss}}(\mathbf{x})$ |
| **Tipping Kinetics** | Local Lyapunov decay ($\dot{V} < 0$, critical slowing down) | Noise-activated barrier crossing via Eyring–Kramers kinetics ($\tau \propto \exp(\Omega\Delta U)$) with instanton hysteresis |

---

# Part 2: Size-Structured Predation Master Equations & Van Kampen Field Theory

## 2.1 Continuous Size Spectra as Discrete Stochastic Jump Processes

Empirical regularities in aquatic and terrestrial ecosystems show that biomass distributes evenly across logarithmic body-size octaves ($dB(m)/d\ln m \approx \text{constant}$). To resolve how microscopic individual predation events generate macroscopic size-spectrum stability, the continuous body-mass domain $[m_{\min}, m_{\max}]$ is partitioned into $K$ discrete logarithmic bins:

$$m_k = m_{\min} \cdot \beta^{k-1}, \qquad \beta = \left(\frac{m_{\max}}{m_{\min}}\right)^{\frac{1}{K-1}}, \quad k \in \{1, 2, \dots, K\}$$

The discrete state vector $\mathbf{X} = (X_1, X_2, \dots, X_K)^{\mathsf{T}}$ records the integer count of living organisms in body-mass bin $k$ within volume element $V^\ddagger$.

## 2.2 Allometric Propensity Kernels

Elementary stochastic transition channels across size classes include:

- **Allometric Predation ($\alpha = \text{pred}(i, j)$)**: An organism in size class $i$ encounters and captures an organism in smaller size class $j$ ($m_i > m_j$).
  - Stoichiometric vector: $\boldsymbol{\nu}_{\text{pred}(i,j)}$ decreases prey count $X_j$ by $1$ and increases predator count $X_i$ by stochastic biomass assimilation:
    $$\Delta X_j = -1, \qquad \Delta X_i = \begin{cases} 1 & \text{with probability } \gamma \frac{m_j}{m_i} \\ 0 & \text{with probability } 1 - \gamma \frac{m_j}{m_i} \end{cases}$$
  - Propensity: $a_{\text{pred}(i,j)}(\mathbf{X}) = \frac{K(m_i, m_j)}{V^\ddagger} X_i X_j$, where the allometric encounter and capture kernel is:
    $$K(m_i, m_j) = k_0 m_i^{0.75} \exp\left( -\frac{(\ln(m_i/m_j) - \ln\phi_{\mathrm{opt}})^2}{2\sigma_\phi^2} \right)$$
    with optimal predator-to-prey mass ratio $\phi_{\mathrm{opt}} \approx 10^2 \text{ to } 10^3$.
- **Mass-Specific Respiration and Maintenance ($\alpha = \text{resp}(i)$)**:
  - Stoichiometric vector: $\Delta X_i = -1$.
  - Propensity: $a_{\text{resp}(i)}(\mathbf{X}) = \rho(m_i) X_i = \rho_0 m_i^{-0.25} X_i$, following Kleiber's quarter-power scaling.
- **Density-Dependent Quadratic Interference ($\alpha = \text{mort}(i)$)**:
  - Stoichiometric vector: $\Delta X_i = -1$.
  - Propensity: $a_{\text{mort}(i)}(\mathbf{X}) = \frac{\delta_i}{V^\ddagger} X_i(X_i - 1)$, representing intraspecific territoriality, cannibalism, or pathogen transmission.
- **Autotrophic Primary Inflow ($\alpha = \text{grow}(1)$)**:
  - Stoichiometric vector: $\Delta X_1 = +1$.
  - Propensity: $a_{\text{grow}}(\mathbf{X}) = \Phi_0 V^\ddagger$, representing solar-driven carbon fixation at the base of the size spectrum.

## 2.3 Van Kampen Asymptotic Expansion of the Size-Structured CME

Applying the Van Kampen expansion $\mathbf{x} = \mathbf{X} / V^\ddagger$ yields the continuous macroscopic drift vector $\mathbf{f}(\mathbf{x})$:

$$f_i(\mathbf{x}) = \Phi_0 \delta_{i,1} - \rho_0 m_i^{-0.25} x_i - \delta_i x_i^2 + \gamma \sum_{j < i} K(m_i, m_j)\frac{m_j}{m_i} x_i x_j - \sum_{k > i} K(m_k, m_i) x_k x_i$$

- The fourth term represents allometric energy import cascading upward from smaller prey size octaves;
- The fifth term represents mortality loss from predation by larger predator size octaves.

The state-dependent allometric diffusion tensor $\mathbf{B}(\mathbf{x})$ accounts for demographic fluctuation variance:

$$B_{ii}(\mathbf{x}) = \Phi_0 \delta_{i,1} + \rho_0 m_i^{-0.25} x_i + \delta_i x_i^2 + \gamma^2 \sum_{j < i} K(m_i, m_j)\left(\frac{m_j}{m_i}\right)^2 x_i x_j + \sum_{k > i} K(m_k, m_i) x_k x_i$$

$$B_{ij}(\mathbf{x}) = -\gamma K(m_i, m_j)\frac{m_j}{m_i} x_i x_j \quad (i > j)$$

## 2.4 Early-Warning Indicators in Size Spectra

Near an ecological tipping point (such as overfishing of apex size classes or climate-driven thermal mismatch), the allometric master equation yields three coupled physical early-warning indicators:

- **Entropic Curvature Collapse ($\mathbf{H} \to 0$)**: As top predator classes are depleted, the second derivative of quasi-potential entropy vanishes along the dominant eigenvector $\mathbf{v}_{\min}$:
  $$\lambda_{\min}(\mathbf{H}) = \min_{\|\mathbf{v}\|=1} \mathbf{v}^{\mathsf{T}} \mathbf{H} \mathbf{v} \to 0^+$$
- **Critical Slowing Down ($\operatorname{Re}(\lambda_{\max}) \to 0$)**: The leading eigenvalue of the demographic Jacobian approaches zero from below, causing recovery times to diverge as $\tau_{\mathrm{rec}} \propto |\operatorname{Re}(\lambda_{\max})|^{-1} \to \infty$.
- **Fluctuation Variance Explosion ($\det\mathbf{C} \to \infty$)**: By the Einstein–Onsager relation $\mathbf{C} = k_{\mathrm{B}}\mathbf{H}^{-1}$, the covariance determinant diverges inversely with curvature:
  $$\det\mathbf{C} = \frac{k_{\mathrm{B}}^K}{\det\mathbf{H}} \to \infty$$
  manifesting as a surge in population variance in size classes immediately adjacent to the truncation boundary.

## 2.5 Julia Implementation: Size-Structured Predation SSA

```julia
# ==============================================================================
# Size-Structured Predation Master Equation Simulator
#
# Simulates discrete jump processes across logarithmic body-mass octaves via
# Gillespie's SSA, computes sample covariance C, and evaluates early-warning
# entropic curvature metrics H = C^-1 using the Moore-Penrose pseudoinverse.
# ==============================================================================

using LinearAlgebra
using Random
using Statistics
using Printf

"""
    SizeSpectrumCME

Parameter container for discrete allometric size-structured Master Equation.

# Fields
- `K::Int`: Number of discrete body-mass octaves
- `m_vec::Vector{Float64}`: Individual body masses (kg) across size classes
- `V::Float64`: Control volume element (m^3)
- `gamma::Float64`: Biomass assimilation efficiency
- `phi_opt::Float64`: Optimal predator-prey mass ratio
- `sigma_phi::Float64`: Log-normal predation window width
- `k0::Float64`: Allometric search rate constant
- `rho_vec::Vector{Float64}`: Mass-specific respiration rates (rho0 * m^-0.25)
- `delta_vec::Vector{Float64}`: Density-dependent interference mortality rates
"""
struct SizeSpectrumCME
    K::Int
    m_vec::Vector{Float64}
    V::Float64
    gamma::Float64
    phi_opt::Float64
    sigma_phi::Float64
    k0::Float64
    rho_vec::Vector{Float64}
    delta_vec::Vector{Float64}
end

function SizeSpectrumCME(; K=4, V=100.0, m_min=1e-5, m_max=1e-1)
    beta = (m_max / m_min)^(1.0 / (K - 1))
    m_vec = [m_min * (beta^(k - 1)) for k in 1:K]
    
    gamma = 0.25
    phi_opt = 100.0
    sigma_phi = 1.2
    k0 = 0.08
    
    # Quarter-power metabolic scaling: rho(m) = 0.10 * (m / m_min)^(-0.25)
    rho_vec = 0.10 .* (m_vec ./ m_min).^(-0.25)
    delta_vec = 0.005 .* ones(K)
    
    return SizeSpectrumCME(K, m_vec, V, gamma, phi_opt, sigma_phi, k0, rho_vec, delta_vec)
end

"""
    predation_kernel(sys::SizeSpectrumCME, i::Int, j::Int)

Calculates the allometric predation rate kernel between predator class i and
prey class j based on body-mass ratios.
"""
function predation_kernel(sys::SizeSpectrumCME, i::Int, j::Int)
    if sys.m_vec[i] <= sys.m_vec[j]
        return 0.0
    end
    mass_ratio = sys.m_vec[i] / sys.m_vec[j]
    preference = exp(-(log(mass_ratio) - log(sys.phi_opt))^2 / (2.0 * sys.sigma_phi^2))
    search_volume = sys.k0 * (sys.m_vec[i] / sys.m_vec[1])^0.75
    return search_volume * preference
end

"""
    run_size_spectrum_ssa(sys::SizeSpectrumCME; max_events=100000, seed=123)

Simulates discrete demographic jumps across size octaves using Gillespie's SSA.
"""
function run_size_spectrum_ssa(sys::SizeSpectrumCME; max_events=100000, seed=123)
    Random.seed!(seed)
    K = sys.K
    V = sys.V
    
    # Initialize discrete counts inversely proportional to body mass
    X = [round(Int, V * 2.0 * (sys.m_vec[1] / sys.m_vec[k])^0.3) for k in 1:K]
    
    times = zeros(Float64, max_events + 1)
    trajectories = zeros(Float64, K, max_events + 1)
    
    t = 0.0
    times[1] = t
    trajectories[:, 1] = X ./ V
    
    for event in 1:max_events
        propensities = Float64[]
        transitions = Vector{Int}[]
        
        # Primary autotrophic influx into smallest size class
        a_grow = 5.0 * V
        push!(propensities, a_grow)
        nu_grow = zeros(Int, K); nu_grow[1] = 1
        push!(transitions, nu_grow)
        
        # Respiration across all size classes
        for i in 1:K
            a_resp = sys.rho_vec[i] * X[i]
            push!(propensities, a_resp)
            nu_resp = zeros(Int, K); nu_resp[i] = -1
            push!(transitions, nu_resp)
        end
        
        # Density-dependent mortality
        for i in 1:K
            if X[i] >= 2
                a_mort = (sys.delta_vec[i] / V) * X[i] * (X[i] - 1)
                push!(propensities, a_mort)
                nu_mort = zeros(Int, K); nu_mort[i] = -1
                push!(transitions, nu_mort)
            end
        end
        
        # Allometric predation between size pairs
        for i in 1:K
            for j in 1:K
                if i != j && X[i] > 0 && X[j] > 0
                    k_ij = predation_kernel(sys, i, j)
                    if k_ij > 0.0
                        a_pred = (k_ij / V) * X[i] * X[j]
                        push!(propensities, a_pred)
                        
                        nu_pred = zeros(Int, K)
                        nu_pred[j] -= 1
                        # Stochastic assimilation integer gain
                        if rand() < (sys.gamma * sys.m_vec[j] / sys.m_vec[i])
                            nu_pred[i] += 1
                        end
                        push!(transitions, nu_pred)
                    end
                end
            end
        end
        
        a_total = sum(propensities)
        if a_total <= 0.0
            break
        end
        
        # Exponential time step
        tau = -log(rand()) / a_total
        t += tau
        
        # Select reaction
        r = rand() * a_total
        cum = 0.0
        sel = 1
        for idx in 1:length(propensities)
            cum += propensities[idx]
            if cum >= r
                sel = idx
                break
            end
        end
        
        # State transition
        X .+= transitions[sel]
        for k in 1:K
            if X[k] < 0
                X[k] = 0
            end
        end
        
        times[event + 1] = t
        trajectories[:, event + 1] = X ./ V
    end
    
    return times, trajectories
end

# Execution demonstration
let
    sys = SizeSpectrumCME(K=4, V=150.0)
    total_events = 120000
    
    times, traj = run_size_spectrum_ssa(sys, max_events=total_events)
    
    # Compute stationary covariance matrix from final 50% of trajectory
    tail_indices = Int(total_events / 2):total_events
    tail_data = traj[:, tail_indices]
    
    means = mean(tail_data, dims=2)
    C_mat = cov(tail_data, dims=2)
    
    # Calculate entropic curvature via Moore-Penrose pseudoinverse to handle
    # potentially unpopulated or extinct size classes on the active manifold
    H_mat = pinv(C_mat)
    
    @printf("=== ALLOMETRIC SIZE SPECTRUM SSA RESULTS ===\n")
    @printf("Simulated Events: %d across %d size classes\n", total_events, sys.K)
    @printf("Final Timestamp:  %.2f time units\n\n", times[end])
    
    @printf("Mean Densities by Body-Mass Class:\n")
    for k in 1:sys.K
        @printf("  Class %d (m = %.2e kg): x_%d = %.4f\n", 
                k, sys.m_vec[k], k, means[k])
    end
    
    @printf("\nCovariance Determinant det(C): %.6e\n", det(C_mat))
    @printf("Minimum Entropic Curvature lambda_min(H): %.6e\n\n", minimum(eigvals(H_mat)))
    
    @printf("Entropic Curvature Matrix H = C^-1:\n")
    for i in 1:sys.K
        @printf("  [ ")
        for j in 1:sys.K
            @printf("%9.3f ", H_mat[i, j])
        end
        @printf("]\n")
    end
end
```

---

# Part 3: Allometric Transmission Line Theory, Impedance Matching, and the Flexible Canopy Cascade

## 3.1 The Flexible Canopy Analogy of Multi-Scale Dissipation

A mechanical analogy clarifies how ecosystems dissipate energy across multi-scale hierarchies: a flexible vegetative canopy (such as a coastal kelp bed or a bamboo forest) exposed to high-velocity turbulent storm gusts.

- **Large Trunks and Stems $\leftrightarrow$ Storage Capacitance ($\mathbf{C}$)**: Massive structural boles and anchor holdfasts possess high physical inertia. They do not track rapid high-frequency air or water gusts; instead, they integrate mechanical momentum across low-frequency cycles, providing structural Resistance against structural uprooting.
- **Inter-Stem Collisions and Elastic Swaying $\leftrightarrow$ Conservative Circulation ($\boldsymbol{\Omega}$)**: Tightly coupled stalks sway, collide, and bend, transferring kinetic momentum sideways and upward across canopy octaves without converting motion directly into heat. This rotational motion circulates kinetic shocks across the entire spatial array.
- **Vibrating Leaves and Microscopic Drag $\leftrightarrow$ Dissipative Respiration ($\mathbf{D}_{\mathrm{sym}}$)**: Small, flexible leaves and fine fronds flutter at high frequencies, converting kinetic motion into acoustic vibrations and gentle thermal dissipation via boundary-layer viscous friction. Rapid leaf turnover provides kinetic Resilience.

In an ecological community, macroscopic organisms (trees, marine mammals, large fish) act as the structural canopy boles (storage capacitance $\mathbf{C}$); trophic predation and loop feedbacks circulate energy across size octaves (circulation $\boldsymbol{\Omega}$); and high-turnover microbes and picoplankton dissipate energy into metabolic heat (dissipation $\mathbf{D}_{\mathrm{sym}}$).

## 3.2 Continuous Metabolic Dissipation Spectra and the Ecological Cochlea

Demographic surveys typically measure the size-abundance distribution $N(m) = N_0 m^{-\lambda}$ ($\lambda \approx 0.75\text{ to }1.1$). Multiplying abundance by individual basal metabolic power ($q_{\mathrm{ind}}(m) = q_0 m^{0.75}$) constructs the continuous **metabolic dissipation spectrum**:

$$P(m) = N(m) \cdot q_{\mathrm{ind}}(m) = N_0 q_0 m^{-\lambda + 0.75} = P_0 m^{-\beta}$$

where $\beta = \lambda - 0.75$ is the metabolic dissipation slope exponent:

- When $\beta \approx 0$, energy flux is flat across size octaves, satisfying Sheldon's biomass spectrum hypothesis and indicating balanced cross-scale trophic transfer.
- When $\beta > 0$, dissipation tilts heavily into the microbial end, signaling excessive metabolic leakage, structural truncation, or severe nutrient limitation.

### The Ecological Cochlea

Just as the mammalian inner ear (cochlea) uses a continuous mechanical membrane with varying stiffness to perform a physical Fourier transform on acoustic pressure waves, an ecosystem's continuous body-mass spectrum functions as an **Ecological Cochlea**:

$$\text{Climate Forcing } S_{\mathrm{env}}(\omega) \xrightarrow{\quad} \left[ \text{Size Class } m \text{ with } \tau(m) \propto m^{0.25} \right] \xrightarrow{\quad} \text{Scale-Selective Filtering}$$

Environmental variance is decomposed across body-mass classes, where each class acts as an impedance filter absorbing forcing at its characteristic resonance frequency $\omega \tau(m) \sim 1$.

## 3.3 Allometric Transmission Line Theory

In electrodynamics and acoustics, continuous energy transmission across space is formulated via telegrapher equations, where voltage represents potential force and current represents material flux. In non-equilibrium ecological thermodynamics, an analogous transmission line governs the continuous cascade of energy and biomass across logarithmic body-size coordinates:

$$u = \ln\left(\frac{m}{m_0}\right)$$

Defining $v(u, t)$ as the intensive thermodynamic chemical affinity at size octave $u$, and $j(u, t)$ as the cross-scale trophic flux of biomass cascading through octave $u$, the dynamics obey:

$$\frac{\partial v(u, t)}{\partial u} = -Z_0 \frac{\partial j(u, t)}{\partial t} - R_{\mathrm{line}}(u) j(u, t)$$

$$\frac{\partial j(u, t)}{\partial u} = -Y_0 \frac{\partial v(u, t)}{\partial t} - G_{\mathrm{line}}(u) v(u, t)$$

where:

- $Z_0$ represents the allometric inductive inertia (trophic biomass conversion lag);
- $Y_0$ represents the allometric capacitive compliance ($Y_0 \propto C(m) = k_{\mathrm{B}} / H(m)$);
- $R_{\mathrm{line}}(u)$ represents frictional dissipation from metabolic respiration ($\rho(m) \propto m^{-0.25}$);
- $G_{\mathrm{line}}(u)$ represents non-predatory mortality leakage.

## 3.4 Characteristic Allometric Impedance and Chromatic Frequency Resonance

The characteristic wave impedance of the ecological size spectrum at body-mass octave $m$ is:

$$Z(m) = \sqrt{\frac{L_{\mathrm{inertial}}(m)}{C_{\mathrm{storage}}(m)}} \propto \sqrt{\frac{m^{0.25}}{m^1}} = m^{-0.375}$$

Because characteristic physiological relaxation times scale as:

$$\tau(m) \propto m^{0.25}$$

the allometric ratio $\phi = m_{k+1} / m_k \approx 10^2 \text{ to } 10^3$ between predator and prey size classes creates a smooth, continuous impedance gradient across the intact size spectrum. Energy cascades conservatively across size octaves with near-zero wave reflection, transferring solar and detrital inputs smoothly into long-lived apex buffers.

When ecosystems are subjected to environmental climate noise with variance power spectrum $S_{\mathrm{env}}(\omega)$, the response of body-mass octave $m$ depends on the resonance condition:

$$\omega_{\mathrm{env}} \tau(m) \sim 1$$

- **High-Frequency Regime ($\omega_{\mathrm{env}} \tau(m) \gg 1$)**: Environmental oscillations occur much faster than organismal turnover. The compartment cannot follow the forcing dynamically, acting as an inertial low-pass filter that absorbs variance into standing biomass storage (Capacitive Resistance).
- **Resonant Absorption Regime ($\omega_{\mathrm{env}} \tau(m) \sim 1$)**: Forcing frequency matches physiological turnover. Energy is absorbed with maximal efficiency and transferred across trophic loops via non-equilibrium circulation ($\boldsymbol{\Omega}$).
- **Low-Frequency Quasi-Static Regime ($\omega_{\mathrm{env}} \tau(m) \ll 1$)**: Forcing varies slowly relative to turnover. Small organisms maintain near-instantaneous steady state with boundary forcing, rapidly degrading variance into heat via cellular respiration (Kinetic Resilience).

## 3.5 Step-Boundary Impedance Mismatch and Variance Reflection

When industrial fishing, deforestation, or habitat fragmentation truncates the upper size classes ($m > m_{\mathrm{harvest}}$), the smooth allometric transmission line is severed. Removing large-bodied capacitors ($C(m) \to 0$) creates a step-boundary impedance mismatch:

$$Z_1 = Z(m_{\mathrm{harvest}}), \qquad Z_2 \to \infty \quad (\text{open-circuit termination})$$

The complex wave reflection coefficient at the truncation boundary is:

$$\Gamma = \frac{Z_2 - Z_1}{Z_2 + Z_1} \xrightarrow{Z_2 \to \infty} +1.0$$

and the Standing Wave Ratio (SWR) diverges:

$$\mathrm{SWR} = \frac{1 + |\Gamma|}{1 - |\Gamma|} \to \infty$$

Without large-bodied containers to absorb low-frequency environmental variance, the incoming energy flux is reflected backward down the trophic cascade:

$$\text{Incoming Variance Wave} \xrightarrow{\quad} [m_{\text{small}}] \to [m_{\text{medium}}] \to [m_{\text{harvest}}] \;\Big| \quad (\text{Hard Boundary})$$
$$\text{Reflected Variance Wave} \xleftarrow{\quad\quad\quad\quad\quad\quad\quad\quad\quad\quad\quad\quad\quad\quad\quad} \;\Big| \quad (\Gamma \to +1)$$

Constructive interference between incoming climate forcing and reflected variance waves produces a stationary standing wave with an antinode (variance peak) positioned immediately below the truncation cutoff:

$$\langle \delta x(u)^2 \rangle = \langle \delta x_0^2 \rangle \left[ 1 + |\Gamma|^2 + 2|\Gamma| \cos(2 k u + \theta_\Gamma) \right]$$

This standing-wave antinode explains why size-selective harvesting of apex predators triggers massive, unbuffered population oscillations in forage fish and macro-invertebrates: stripping capacitive impedance prevents dissipative energy outflow, causing reflected variance to destabilize the remaining lower trophic tiers.

---

# Part 4: Multi-Field Biophysical Onsager Transductions (Off-Diagonal Cross-Effects)

## 4.1 Foundations of Cross-Coupled Force-Flux Dynamics

In linear non-equilibrium thermodynamics, total internal entropy production is the sum of products of conjugate thermodynamic forces and process fluxes across $r$ elementary transport and transformation channels:

$$\sigma = \sum_{k=1}^r X_k J_k = \mathbf{X}^{\mathsf{T}}\mathbf{J} \ge 0$$

Near steady state, phenomenological force-flux relations take the matrix form:

$$J_i = \sum_{j=1}^r L_{ij} X_j = L_{ii} X_i + \sum_{j \ne i}^r L_{ij} X_j$$

By microscopic time-reversibility, Onsager reciprocity guarantees symmetry of the cross-conductivities:

$$L_{ij} = L_{ji}$$

while the Second Law imposes positive-definiteness on the symmetric matrix ($\mathbf{L} \succ 0$), requiring:

$$L_{ii} > 0, \qquad L_{ii} L_{jj} - L_{ij}^2 \ge 0 \implies |L_{ij}| \le \sqrt{L_{ii} L_{jj}}$$

In ecological systems, off-diagonal entries $L_{ij} \ne 0$ represent **Biophysical Transductions**, in which a thermodynamic force in one physical or chemical domain (e.g., temperature, irradiance, fluid shear) drives a conjugate biological or material flux in another domain (e.g., carbon sinking, nutrient exocytosis, trophic circulation).

## 4.2 Thermo-Sinking Transduction

The coupling between water-column thermal gradients and gravitational carbon export provides a physical analogue of the Seebeck–Peltier thermoelectric effect:

$$\begin{pmatrix} J_Q \\ J_{\mathrm{sink}} \end{pmatrix} = \begin{pmatrix} L_{TT} & L_{T,\mathrm{sink}} \\ L_{\mathrm{sink},T} & L_{\mathrm{sink},\mathrm{sink}} \end{pmatrix} \begin{pmatrix} X_T \\ X_{\mathrm{sink}} \end{pmatrix}$$

where:

- $X_T = \delta(1/T)$ is the thermal affinity force;
- $X_{\mathrm{sink}} = -\nabla \mu_{\mathrm{POC}} / T$ is the chemical potential gradient of Particulate Organic Carbon (POC);
- $J_Q$ is sensible heat dissipation;
- $J_{\mathrm{sink}}$ is gravitational downward particle flux.

### Mechanism and Allometric Ballasting

Rising surface temperatures ($X_T$) accelerate cellular respiration relative to photosynthesis ($\rho(m) \propto m^{-0.25} e^{-E_a/k_{\mathrm{B}}T}$), decreasing mean plankton cell radius $r$ and lipid-to-protein ratios. By Stokes' law, settling velocity $v_s = \frac{2 g r^2 \Delta\rho}{9\eta}$ declines non-linearly with cell radius and fluid viscosity.

- **Conjugate Effect**: A thermal force shift ($X_T$) drives an anomalous reduction in particulate carbon export ($J_{\mathrm{sink}} = L_{\mathrm{sink},T} X_T$ with $L_{\mathrm{sink},T} < 0$).
- **Reciprocal Effect**: Reciprocally, altering particle export ($X_{\mathrm{sink}}$) shifts upper-ocean turbidity, solar absorption profiles, and subsurface heat dissipation ($J_Q = L_{T,\mathrm{sink}} X_{\mathrm{sink}}$).
- **Systemic Manifestation**: Ocean surface warming suppresses the carbon export ratio ($e\text{-ratio} = J_{\mathrm{sink}} / \text{NPP}$), shunting organic carbon into fast surface microbial loops and elevating surface dissipation noise.

## 4.3 Photo-Trophic Transduction

Solar irradiance drives autotrophic fixation, but simultaneously cross-couples into bacterial remineralization and optical water-column clarity:

$$\begin{pmatrix} J_{\mathrm{photon}} \\ J_{\mathrm{cdom}} \end{pmatrix} = \begin{pmatrix} L_{\nu\nu} & L_{\nu,\mathrm{cdom}} \\ L_{\mathrm{cdom},\nu} & L_{\mathrm{cdom},\mathrm{cdom}} \end{pmatrix} \begin{pmatrix} X_\nu \\ X_{\mathrm{cdom}} \end{pmatrix}$$

- Under elevated surface irradiance ($X_\nu = \delta(h\nu/T)$), photosynthetic electron flux exceeds carbon fixation capacity, forcing phytoplankton to exude labile dissolved organic matter (DOC).
- Heterotrophic bacteria consume labile DOC and excrete refractory Chromophoric Dissolved Organic Matter (CDOM), altering the optical diffuse attenuation coefficient $K_d(\lambda)$:
  $$I(z) = I_0 \exp\left( -\int_0^z [K_w + k_c P(z') + k_{\mathrm{cdom}} \mathrm{CDOM}(z')]\,dz' \right)$$
- Increased CDOM production acts as a negative optical feedback, dampening photo-inhibition in the upper mixed layer and stabilizing the subsurface Deep Chlorophyll Maximum (DCM).

## 4.4 Stoichiometric-Allometric Coupling

Systemic shifts in limiting nutrient ratios (e.g., Nitrogen-to-Phosphorus, $\mathrm{N:P}$) cross-couple into the slope of the continuous biomass size spectrum:

$$\begin{pmatrix} J_{\mathrm{N:P}} \\ J_{\mathrm{spectrum}} \end{pmatrix} = \begin{pmatrix} L_{\mathrm{chem},\mathrm{chem}} & L_{\mathrm{chem},\mathrm{size}} \\ L_{\mathrm{size},\mathrm{chem}} & L_{\mathrm{size},\mathrm{size}} \end{pmatrix} \begin{pmatrix} X_{\mathrm{N:P}} \\ X_{\mathrm{size}} \end{pmatrix}$$

- Fast-growing picoplankton ($m_{\min}$) have high RNA contents and low $\mathrm{N:P}$ requirements ($\sim 10:1$), whereas large structural diatoms and macro-invertebrates ($m_{\max}$) require high $\mathrm{N:P}$ ($\sim 20:1\text{ to }30:1$) and $\mathrm{Si:N}$.
- Imposing a chemical potential force $\delta X_{\mathrm{N:P}} = \delta(\mu_N - \mu_P)/T$ shifts competitive advantage across size classes, tilting the normalized Sheldon size-spectrum slope $\lambda_m$ ($N(m) = N_0 m^{-\lambda_m}$).
- Phosphorus limitation steepens size spectra ($|\lambda_m| \uparrow$), contracting total standing biomass storage capacitance ($\mathbf{C} \propto B_{\mathrm{tot}}$) and shifting the community toward smaller, higher-turnover kinetic resilience ($\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}$).

## 4.5 Shear-Patchiness Transduction

Mechanical energy input from wind and tides creates fluid shear gradients $\delta(\nabla \mathbf{v})$ that cross-couple into non-equilibrium probability circulation:

$$\begin{pmatrix} J_{\mathrm{viscous}} \\ J_{\mathrm{circ}} \end{pmatrix} = \begin{pmatrix} L_{\mathrm{shear},\mathrm{shear}} & L_{\mathrm{shear},\mathrm{circ}} \\ L_{\mathrm{circ},\mathrm{shear}} & L_{\mathrm{circ},\mathrm{circ}} \end{pmatrix} \begin{pmatrix} X_{\mathrm{shear}} \\ X_{\mathrm{circ}} \end{pmatrix}$$

- Physical turbulence enhances encounter kernels between planktonic predators and prey:
  $$K_{ij}(\epsilon) = \pi (r_i + r_j)^2 \left[ (v_i^2 + v_j^2) + \frac{1.3\epsilon}{\nu}(r_i + r_j)^2 \right]^{1/2}$$
  where $\epsilon$ is turbulent dissipation rate and $\nu$ is kinematic viscosity.
- Elevated encounter rates amplify off-diagonal antisymmetric predator-prey circulation ($\|\boldsymbol{\Omega}\|_F \uparrow$), accelerating trophic cycling and preventing localized variance pooling in individual size classes.

## 4.6 Allelopathic-Grazing Cross-Coupling

Secondary chemical metabolites (such as phycotoxins, glucosinolates, or tannins) couple consumption forces to chemical defense potentials:

$$\begin{pmatrix} J_{\mathrm{grazing}} \\ J_{\mathrm{defense}} \end{pmatrix} = \begin{pmatrix} L_{gg} & L_{gd} \\ L_{dg} & L_{dd} \end{pmatrix} \begin{pmatrix} X_{\mathrm{grazing}} \\ X_{\mathrm{defense}} \end{pmatrix}$$

- Elevated herbivore grazing force ($X_{\mathrm{grazing}}$) induces plant and algal synthesis of defense compounds ($X_{\mathrm{defense}} = \mu_{\mathrm{toxin}}/T$).
- Because cross-conductivity is negative ($L_{gd} = L_{dg} < 0$), secondary metabolite accumulation suppresses consumer ingestion ($J_{\mathrm{grazing}}$), moderating trophic exploitation through negative feedback.

## 4.7 Schur-Complement Reduction and Generalized Le Chatelier–Braun Moderation

The unifying mathematical mechanism across all six transductions is Schur-complement matrix reduction. Partitioning any multi-field force-flux network into a primary targeted process $i$ and secondary coupled processes $-i$:

$$\begin{pmatrix} J_i \\ \mathbf{J}_{-i} \end{pmatrix} = \begin{pmatrix} L_{ii} & \mathbf{L}_{i,-i} \\ \mathbf{L}_{-i,i} & \mathbf{L}_{-i,-i} \end{pmatrix} \begin{pmatrix} X_i \\ \mathbf{X}_{-i} \end{pmatrix}$$

When an external disturbance shifts force $X_i$ while secondary pathways freely adjust to zero net flux ($\mathbf{J}_{-i} = \mathbf{0}$):

$$\mathbf{X}_{-i} = -\mathbf{L}_{-i,-i}^{-1} \mathbf{L}_{-i,i} X_i$$

Substituting $\mathbf{X}_{-i}$ yields the effective primary conductivity:

$$J_i = L_{ii,\mathrm{eff}} X_i, \qquad L_{ii,\mathrm{eff}} = L_{ii} - \mathbf{L}_{i,-i} \mathbf{L}_{-i,-i}^{-1} \mathbf{L}_{-i,i}$$

Because the secondary submatrix is strictly positive-definite ($\mathbf{L}_{-i,-i} \succ 0$), the quadratic correction term is strictly non-negative:

$$\mathbf{L}_{i,-i} \mathbf{L}_{-i,-i}^{-1} \mathbf{L}_{-i,i} \ge 0 \implies L_{ii,\mathrm{eff}} \le L_{ii}$$

This inequality proves the **Generalized Le Chatelier–Braun Principle for Multi-Field Ecosystems**:

Coupled cross-transductions across secondary physical, chemical, and biological degrees of freedom always moderate the effective conductivity of primary disturbances ($L_{ii,\mathrm{eff}} \le L_{ii}$), dampening the displacement of intensive thermodynamic potentials and conferring multi-field stability upon the living network.

## 4.8 Summary Matrix of Cross-Coupled Ecological Transductions

| Primary Force ($X_i$) | Direct Flux ($J_i$) | Coupled Force ($X_j$) | Cross-Flux ($J_j$) | Macroscopic System Manifestation |
|:----------------------|:-------------------|:----------------------|:-------------------|:--------------------------------|
| **Thermal Shift $\delta(1/T)$** | Sensible heat dissipation ($J_Q$) | Particulate chemical potential ($-\nabla\mu_{\mathrm{POC}}$) | Gravitational carbon sinking ($J_{\mathrm{sink}}$) | Shifts $e$-ratio; shunts organic carbon into high-dissipation surface microbial loops |
| **Photon Irradiance $\delta(h\nu/T)$** | Autotrophic carbon fixation ($J_{\mathrm{photo}}$) | CDOM chemical potential ($\mu_{\mathrm{cdom}}/T$) | Heterotrophic bacterial exocytosis ($J_{\mathrm{cdom}}$) | Induces negative optical feedback; stabilizes subsurface Deep Chlorophyll Maximum |
| **Nutrient Ratio $\delta(\mu_N - \mu_P)/T$** | Enzymatic nutrient uptake ($J_{\mathrm{uptake}}$) | Allometric size coordinate ($u = \ln m$) | Biomass size-spectrum tilt ($J_{\mathrm{spectrum}}$) | Trades structural storage capacitance ($\mathbf{C}$) for high-turnover kinetic resilience ($\mathbf{C}^{-1}\mathbf{D}$) |
| **Fluid Velocity Shear $\delta(\nabla\mathbf{v})$** | Viscous fluid dissipation ($J_{\mathrm{viscous}}$) | Predator-prey encounter kernel | Trophic probability circulation ($\boldsymbol{\Omega}$) | Converts mechanical fluid shear into rotational probability currents; prevents variance pooling |
| **Herbivore Grazing Force** | Plant tissue consumption ($J_{\mathrm{grazing}}$) | Allelopathic toxin affinity ($\mu_{\mathrm{toxin}}/T$) | Secondary metabolite synthesis ($J_{\mathrm{defense}}$) | Schur-complement negative feedback ($L_{gd} < 0$); moderates consumer exploitation cascades |

---

# Part 5: The Canonical Onsager Estimator, Stationarity Over-Identification, and Epistemological Scope Conditions

## 5.1 The Canonical Estimator and Parameter-Free Consistency

A central insight formalizing the bridge between stochastic demographic time series and physical transport physics is that physical conductivity $\mathbf{L}$ and the entropic curvature Hessian $\mathbf{H}$ are not two separate empirical measurements. Rather, in properly calibrated conjugate coordinates, they represent two projections of a single stationary covariance matrix $\mathbf{C}$:

$$\mathbf{H} = k_{\mathrm{B}}\mathbf{C}^{-1}, \qquad \mathbf{L} = -\frac{\mathbf{A}\mathbf{C}}{k_{\mathrm{B}}} = \frac{\mathbf{D}}{k_{\mathrm{B}}}$$

When state variables are expressed in conjugate extensive coordinates (molar amounts or extensive energies in contact with known reference potentials), the estimator has zero free parameters:

$$\mathbf{L} = -\frac{1}{k_{\mathrm{B}}}\mathbf{A}\mathbf{C}$$

Nothing is fitted, tuned, or projected onto symmetry by hand. If the underlying system obeys thermodynamic equilibrium, the product $-\mathbf{A}\mathbf{C}$ is automatically symmetric by an algebraic identity.

## 5.2 Stationarity Over-Identification Test and Detailed-Balance Residual

In an empirical network of dimension $n$, dynamic stationarity requires satisfaction of the continuous Lyapunov covariance balance equation:

$$\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} + 2\mathbf{D} = \mathbf{0} \iff \operatorname{sym}(\mathbf{D} + \mathbf{A}\mathbf{C}) = \mathbf{0}$$

This condition imposes:

$$\frac{n(n + 1)}{2}$$

independent scalar consistency equations on the empirical data. Because these conditions contain zero adjustable constants, they over-identify the stationary model and provide a parameter-free diagnostic test of whether the observed dynamics conform to stationary linear-response physics.

### Detailed-Balance Residual and Exact Dissipation Rate

The antisymmetric part of the drift-covariance product is unconstrained by stationarity. It isolates the non-equilibrium probability current tensor:

$$\boldsymbol{\Omega} = \operatorname{asym}(-\mathbf{A}\mathbf{C}) = \frac{1}{2}\left( \mathbf{C}\mathbf{A}^{\mathsf{T}} - \mathbf{A}\mathbf{C} \right) = -\boldsymbol{\Omega}^{\mathsf{T}}$$

The relative detailed-balance residual:

$$\mathcal{R}_{\mathrm{DB}} = \frac{\|\mathbf{D} + \mathbf{A}\mathbf{C}\|_F}{\|\mathbf{D}\|_F}$$

provides a rigorous physical measurement with a well-defined null hypothesis:

- When $\mathcal{R}_{\mathrm{DB}} = 0$, microscopic detailed balance holds strictly, circulation vanishes ($\boldsymbol{\Omega} = \mathbf{0}$), and the system is at equilibrium.
- When $\mathcal{R}_{\mathrm{DB}} > 0$, detailed balance is broken, and the antisymmetric tensor $\boldsymbol{\Omega}$ directly quantifies the non-equilibrium circulation, yielding the exact macroscopic entropy production rate:
  $$\sigma = k_{\mathrm{B}} \operatorname{tr}\left( \boldsymbol{\Omega}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{D}^{-1} \right) \ge 0$$

## 5.3 Four Structural Obstructions for Population Census Data

The product $-\mathbf{A}\mathbf{C}$ computed from population census time series is an exploratory dynamical diagnostic, but cannot be equated to a physical Onsager conductivity without meeting four strict physical scope conditions:

- **Coordinate Conjugacy**: Species counts $N_i$ and masses $B_i$ are counts and mass densities, not extensive thermodynamic amounts whose partial derivatives define chemical potentials ($\mu_i = \partial G / \partial N_i$). Logarithmic coordinate transformations ($\ln N_i$) are non-linear, which destroys the tensorial transformation properties of the conductivity matrix. Physical calibration requires molar pool amounts with defined reference chemical states.
- **Noise Dissipation Relation**: Demographic stochasticity arises from discrete birth-death integer jumps, and environmental noise arises from exogenous weather driving. Neither noise source satisfies the Einstein–Onsager dissipation relation $\mathbf{D} = k_{\mathrm{B}}\mathbf{L}$. Non-dissipative noise rescales $-\mathbf{A}\mathbf{C}$ silently without internal algebraic detection.
- **Reference State Equilibrium vs. Throughput**: In chemical physics, Onsager reciprocity applies around an un-driven thermodynamic equilibrium ($\mathbf{X}^* = \mathbf{0}$). Ecological ecosystems operate at driven non-equilibrium steady states sustained by continuous boundary flux throughput, where asymmetry in $-\mathbf{A}\mathbf{C}$ reflects steady-state probability circulation rather than a breakdown of physical law.
- **Process Identifiability**: A demographic community matrix $\mathbf{A}$ convolves birth, grazing, predation, competition, excretion, and respiration into a single net Jacobian. True phenomenological conductivities are defined on elementary process fluxes with an independent reaction basis. Without event-level flux and affinity measurements, population data identify at most the stoichiometric projection $\mathbf{B}\mathbf{L}\mathbf{B}^{\mathsf{T}}$, not $\mathbf{L}$ itself.

## 5.4 Coarse-Graining Block Inversion and Latent Variable Projection

In empirical ecology, observing every state variable is impossible; unobserved microbial pools, dissolved nutrients, or detrital fractions are routinely omitted. Partitioning state space into observed compartments $\mathbf{x}_1$ and unobserved latent compartments $\mathbf{x}_2$:

$$\mathbf{x} = \begin{pmatrix} \mathbf{x}_1 \\ \mathbf{x}_2 \end{pmatrix}, \qquad \mathbf{C} = \begin{pmatrix} \mathbf{C}_{11} & \mathbf{C}_{12} \\ \mathbf{C}_{21} & \mathbf{C}_{22} \end{pmatrix}, \qquad \mathbf{H} = \begin{pmatrix} \mathbf{H}_{11} & \mathbf{H}_{12} \\ \mathbf{H}_{21} & \mathbf{H}_{22} \end{pmatrix}$$

By the block matrix inversion theorem, the empirical covariance $\mathbf{C}_1 = \mathbf{C}_{11}$ observed on the marginal subspace yields an effective marginal entropic curvature:

$$\mathbf{H}_{1,\mathrm{eff}} = k_{\mathrm{B}}\mathbf{C}_{11}^{-1} = \mathbf{H}_{11} - \mathbf{H}_{12}\mathbf{H}_{22}^{-1}\mathbf{H}_{21}$$

which is exactly the Schur complement of the full entropy Hessian $\mathbf{H}$.

Similarly, the effective phenomenological conductivity observed in the reduced subspace is:

$$\mathbf{L}_{1,\mathrm{eff}} = \mathbf{L}_{11} - \mathbf{L}_{12}\mathbf{L}_{22}^{-1}\mathbf{L}_{21}$$

This establishes the **Coarse-Graining Projection Theorem for Ecological Networks**:

Omitting latent unobserved ecological compartments does not introduce arbitrary mathematical errors. Rather, unobserved variables project systematically into the observed sub-network through the matrix Schur complement, reducing the apparent entropic stiffness ($\mathbf{H}_{1,\mathrm{eff}} \le \mathbf{H}_{11}$) and effective conductivity ($\mathbf{L}_{1,\mathrm{eff}} \le \mathbf{L}_{11}$) in strict accordance with the generalized Le Chatelier–Braun principle.

## 5.5 Coordinate Invariance Under Non-Singular Linear Transformations

Following the geometric formulation of non-equilibrium diffusion processes on smooth manifolds, let extensive state departures be transformed by an invertible linear coordinate map $\delta\mathbf{y} = \mathbf{M}\delta\mathbf{x}$, where $\mathbf{M} \in \mathbb{R}^{n \times n}$ with $\det \mathbf{M} \ne 0$.

Under this transformation, dynamical and stochastic operators transform according to standard contravariant and covariant tensor rules:

- **Dynamical Jacobian (Similarity Transformation)**:
  $$\frac{d}{dt}\delta\mathbf{y} = \mathbf{M}\frac{d}{dt}\delta\mathbf{x} = \mathbf{M}\mathbf{A}\delta\mathbf{x} = \mathbf{M}\mathbf{A}\mathbf{M}^{-1}\delta\mathbf{y} \implies \mathbf{A}_y = \mathbf{M}\mathbf{A}\mathbf{M}^{-1}$$

- **Fluctuation Covariance and Diffusion Tensors (Contravariant Congruence)**:
  $$\mathbf{C}_y = \langle \delta\mathbf{y}\delta\mathbf{y}^{\mathsf{T}} \rangle = \mathbf{M}\mathbf{C}\mathbf{M}^{\mathsf{T}}, \qquad \mathbf{D}_y = \mathbf{M}\mathbf{D}\mathbf{M}^{\mathsf{T}}$$

- **Entropic Curvature Hessian (Covariant Congruence)**:
  $$\mathbf{H}_y = k_{\mathrm{B}}\mathbf{C}_y^{-1} = k_{\mathrm{B}}(\mathbf{M}\mathbf{C}\mathbf{M}^{\mathsf{T}})^{-1} = \mathbf{M}^{-\mathsf{T}}\mathbf{H}\mathbf{M}^{-1}$$

Evaluating the continuous Lyapunov balance in the transformed coordinates confirms exact tensorial invariance:

$$\mathbf{A}_y\mathbf{C}_y + \mathbf{C}_y\mathbf{A}_y^{\mathsf{T}} + 2\mathbf{D}_y = (\mathbf{M}\mathbf{A}\mathbf{M}^{-1})(\mathbf{M}\mathbf{C}\mathbf{M}^{\mathsf{T}}) + (\mathbf{M}\mathbf{C}\mathbf{M}^{\mathsf{T}})(\mathbf{M}^{-\mathsf{T}}\mathbf{A}^{\mathsf{T}}\mathbf{M}^{\mathsf{T}}) + 2\mathbf{M}\mathbf{D}\mathbf{M}^{\mathsf{T}} = \mathbf{M}(\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} + 2\mathbf{D})\mathbf{M}^{\mathsf{T}} = \mathbf{0}$$

Similarly, the covariance-weighted drift $-\mathbf{A}_y\mathbf{C}_y$ transforms by congruence:

$$-\mathbf{A}_y\mathbf{C}_y = \mathbf{M}(-\mathbf{A}\mathbf{C})\mathbf{M}^{\mathsf{T}} = \mathbf{D}_{\mathrm{sym},y} + \boldsymbol{\Omega}_y$$

where $\mathbf{D}_{\mathrm{sym},y} = \mathbf{M}\mathbf{D}_{\mathrm{sym}}\mathbf{M}^{\mathsf{T}} \succ 0$ preserves strict positive definiteness by Sylvester's law of inertia, and $\boldsymbol{\Omega}_y = \mathbf{M}\boldsymbol{\Omega}\mathbf{M}^{\mathsf{T}} = -\boldsymbol{\Omega}_y^{\mathsf{T}}$ preserves skew-symmetry.

All fundamental physical and thermodynamic scalars are invariant under any non-singular linear coordinate change $\mathbf{M}$:

- **Eigenvalue Spectrum**: $\operatorname{spec}(\mathbf{A}_y) = \operatorname{spec}(\mathbf{A})$;
- **Aggregate Dissipative Relaxation Rate**:
  $$\operatorname{tr}\left(\mathbf{D}_{\mathrm{sym},y}\mathbf{C}_y^{-1}\right) = \operatorname{tr}\left(\mathbf{M}\mathbf{D}_{\mathrm{sym}}\mathbf{M}^{\mathsf{T}}\mathbf{M}^{-\mathsf{T}}\mathbf{C}^{-1}\mathbf{M}^{-1}\right) = \operatorname{tr}\left(\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}\right) = -\operatorname{tr}(\mathbf{A})$$
- **Stationary Entropy Production Rate**:
  $$\sigma_y = k_{\mathrm{B}}\operatorname{tr}\left(\boldsymbol{\Omega}_y^{\mathsf{T}}\mathbf{C}_y^{-1}\boldsymbol{\Omega}_y\mathbf{D}_y^{-1}\right) = k_{\mathrm{B}}\operatorname{tr}\left(\mathbf{M}^{-\mathsf{T}}\boldsymbol{\Omega}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{D}^{-1}\mathbf{M}^{\mathsf{T}}\right) = \sigma$$
- **Riemannian Circulation Ratio**: Evaluated in the natural Riemannian metric $\mathbf{C}^{-1}$ (standardized coordinates $\delta\tilde{\mathbf{x}} = \mathbf{C}^{-1/2}\delta\mathbf{x}$), the metric-weighted circulation ratio:
  $$\tilde{\chi} = \left[ \frac{\operatorname{tr}\left(\boldsymbol{\Omega}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}\right)}{\operatorname{tr}\left(\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}\right)} \right]^{1/2}$$
  is strictly invariant under any invertible transformation $\mathbf{M}$.

## 5.6 Extremum Dissipation Principles: Clamped Forces vs. Clamped Fluxes

Whether a linear non-equilibrium steady state maximizes or minimizes entropy production depends explicitly on which boundary variables are clamped:

- **Clamped Thermodynamic Forces (Maximum Dissipation)**: When boundary driving forces $\mathbf{X}$ are held fixed, the linear constitutive response maximizes the Onsager–Machlup dissipation functional:
  $$\Phi(\mathbf{J}) = \sigma(\mathbf{J}, \mathbf{X}) - \Psi(\mathbf{J}) = \sum_i J_i X_i - \frac{1}{2}\sum_{i,j} R_{s;ij} J_i J_j$$
  Setting the first variation with respect to flux $J_k$ to zero gives:
  $$\frac{\partial\Phi}{\partial J_k} = X_k - \sum_j R_{s;kj} J_j = 0 \implies \mathbf{J} = \mathbf{L}_s\mathbf{X}$$
  Because the Hessian with respect to fluxes is strictly negative definite:
  $$\frac{\partial^2\Phi}{\partial\mathbf{J}^2} = -\mathbf{R}_s \prec 0$$
  the linear constitutive response maximizes $\Phi(\mathbf{J})$ and boundary dissipation $\sigma = \mathbf{X}^{\mathsf{T}}\mathbf{L}_s\mathbf{X}$ at fixed driving forces.

- **Clamped Boundary Fluxes and Free Force Relaxation (Minimum Dissipation)**: When boundary throughput fluxes are clamped or a subset of internal forces $X_k$ are left unconstrained to relax to zero-flux stationarity ($J_{s;k} = 0$), differentiating total entropy production $\sigma(\mathbf{X}) = \mathbf{X}^{\mathsf{T}}\mathbf{L}_s\mathbf{X}$ with respect to each free internal force $X_k$ yields:
  $$\frac{\partial\sigma}{\partial X_k} = 2\sum_j L_{s;kj} X_j = 2 J_{s;k} = 0, \qquad \frac{\partial^2\sigma}{\partial\mathbf{X}^2} = 2\mathbf{L}_s \succ 0$$
  Because the Hessian $2\mathbf{L}_s$ is strictly positive definite, stationary relaxation of unconstrained internal forces minimizes entropy production, with the minimized dissipation given directly by the Schur complement:
  $$\sigma_{\min} = L_{11,\mathrm{eff}}\,\delta X_1^2 \le L_{11}\,\delta X_1^2$$

## 5.7 Quadratic Lyapunov Availability Potential and Monotonic Relaxation

In extensive state space, the quadratic Lyapunov availability functional:

$$V(\delta\mathbf{x}) = \frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\delta\mathbf{x} = -\frac{\Delta S_{\mathrm{tot}}(\delta\mathbf{x})}{k_{\mathrm{B}}} > 0$$

governs the energetic distance of demographic departures from the stationary attractor. Differentiating $V(\delta\mathbf{x})$ along deterministic trajectories $\dot{\delta\mathbf{x}} = \mathbf{A}\delta\mathbf{x}$ gives:

$$\dot{V}(\delta\mathbf{x}) = \frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\left( \mathbf{C}^{-1}\mathbf{A} + \mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} \right)\delta\mathbf{x}$$

Using $-\mathbf{A}\mathbf{C} = \mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega}$, expanding the drift operators yields:

$$\mathbf{C}^{-1}\mathbf{A} = -\mathbf{C}^{-1}\left(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega}\right)\mathbf{C}^{-1}, \qquad \mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} = -\mathbf{C}^{-1}\left(\mathbf{D}_{\mathrm{sym}} - \boldsymbol{\Omega}\right)\mathbf{C}^{-1}$$

Because $\boldsymbol{\Omega}$ is skew-symmetric ($\boldsymbol{\Omega}^{\mathsf{T}} = -\boldsymbol{\Omega}$), the circulation terms cancel identically in the sum:

$$\mathbf{C}^{-1}\mathbf{A} + \mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} = -2\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}$$

Consequently, deterministic relaxation is strictly monotonic and downhill:

$$\dot{V}(\delta\mathbf{x}) = -\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}\delta\mathbf{x} < 0 \quad (\forall\,\delta\mathbf{x} \ne \mathbf{0})$$

This identity proves that non-equilibrium probability circulation $\boldsymbol{\Omega}$ rotates along iso-potential availability contours without impeding or accelerating global Lyapunov decay, while the symmetric dissipative core $\mathbf{D}_{\mathrm{sym}}$ guarantees asymptotic convergence to stationarity.

---

# Part 6: Interdisciplinary Foundations: Circuit Duality, Information Geometry, and Cybernetic Control

## 6.1 Network Thermodynamics and Multiport Circuit Theory

The decomposition of asymmetric demographic community matrices into symmetric dissipators and antisymmetric circulators is mathematically isomorphic to multiport electrical network theory.

By Tellegen's theorem, for any network topology obeying Kirchhoff's current and voltage laws, the instantaneous sum of power across all branches is identically zero:

$$\sum_k v_k(t) i_k(t) = 0$$

In ecological networks, state and dynamical variables map directly to electrical multiport elements:

- Extensive state departures $\delta\mathbf{x}$ correspond to generalized capacitor charges $\mathbf{q}$;
- Conjugate thermodynamic forces $\mathbf{X} = -\mathbf{H}\delta\mathbf{x} = -k_{\mathrm{B}}\mathbf{C}^{-1}\delta\mathbf{x}$ correspond to generalized node voltages $\mathbf{v}$;
- Compartment biomass standing stocks $B_i^* / k_{\mathrm{B}}$ act as generalized entropic storage capacitors $C_i$.

In the constitutive flux-force relation $\mathbf{J} = \mathbf{L}\mathbf{X} = k_{\mathrm{B}}^{-1}(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{X}$:

- The symmetric component $\mathbf{L}_s = \frac{1}{2}(\mathbf{L} + \mathbf{L}^{\mathsf{T}}) = k_{\mathrm{B}}^{-1}\mathbf{D}_{\mathrm{sym}} \succ 0$ represents a passive resistive conductance network governing irreversible thermodynamic entropy production:
  $$\sigma = \mathbf{X}^{\mathsf{T}}\mathbf{L}_s\mathbf{X} = k_{\mathrm{B}}^{-1}\mathbf{X}^{\mathsf{T}}\mathbf{D}_{\mathrm{sym}}\mathbf{X} \ge 0$$
- The skew-symmetric component $\mathbf{L}_a = \frac{1}{2}(\mathbf{L} - \mathbf{L}^{\mathsf{T}}) = k_{\mathrm{B}}^{-1}\boldsymbol{\Omega}$ represents an array of ideal **Tellegen gyrators**. A two-port gyrator with gyration conductance $g$ couples port currents and voltages through a skew-symmetric admittance matrix:
  $$\begin{pmatrix} i_1 \\ i_2 \end{pmatrix} = \begin{pmatrix} 0 & g \\ -g & 0 \end{pmatrix} \begin{pmatrix} v_1 \\ v_2 \end{pmatrix}$$

Because $\mathbf{L}_a = -\mathbf{L}_a^{\mathsf{T}}$, instantaneous power dissipation across every gyrator is identically zero ($\mathbf{X}^{\mathsf{T}}\mathbf{L}_a\mathbf{X} \equiv 0$). When port 2 of an ideal gyrator is terminated by a capacitive storage element $C_2$ ($i_2 = -C_2 \dot{v}_2$), substituting $v_2 = i_1 / g$ yields:

$$v_1 = -\frac{1}{g}i_2 = \frac{C_2}{g^2}\dot{i}_1$$

Consequently, the input port behaves as an equivalent reactive inductor with inductance:

$$L_{\mathrm{eq}} = \frac{C_2}{g^2}$$

This circuit duality reveals the physical origin of endogenous ecological oscillations: ecological food webs exhibit limit cycles, trophic waves, and sustained oscillations despite lacking physical magnetic fields because coupling capacitive biomass storage ($\mathbf{C}$) through skew-symmetric trophic circulation ($\boldsymbol{\Omega}$) synthesizes an equivalent reactive inductance ($L_{\mathrm{eq}}$). Consumer-resource pairs behave as damped $RLC$ tank circuits that exchange availability between prey and predator compartments while dissipative conductances $\mathbf{D}_{\mathrm{sym}}$ damp oscillation amplitudes.

## 6.2 Information Geometry and Riemannian Phase Space

On the extensive state-space manifold $\mathcal{M} = \mathbb{R}_{>0}^n$, the stationary fluctuation covariance defines a Riemannian Fisher information metric:

$$g_{ij}(\mathbf{x}) = [\mathbf{C}^{-1}]_{ij} = \frac{\partial^2 U(\mathbf{x})}{\partial x_i \partial x_j}$$

Under this metric, the non-equilibrium Helmholtz–Hodge decomposition partitions any smooth demographic vector field $\mathbf{f}(\mathbf{x})$ into orthogonal potential gradient descent and solenoidal curl circulation:

$$\mathbf{f}(\mathbf{x}) = -\mathbf{D}(\mathbf{x})\nabla U(\mathbf{x}) + \mathbf{v}_{\mathrm{curl}}(\mathbf{x}), \qquad \nabla U(\mathbf{x}) \cdot \mathbf{v}_{\mathrm{curl}}(\mathbf{x}) = 0$$

This geometric structure explains the historical limits of classical ecological extremum principles:

- **Symmetric Competition**: In pure Lotka–Volterra resource competition where interaction matrices are symmetric, probability circulation vanishes identically ($\mathbf{v}_{\mathrm{curl}} \equiv \mathbf{0}$). MacArthur's variational principle succeeds in these systems because the dynamics reduce to pure gradient descent on a Riemannian potential surface.
- **Trophic Circulation**: In food webs with active predation and nutrient recycling, asymmetric trophic throughput breaks detailed balance, generating non-zero solenoidal curl ($\mathbf{v}_{\mathrm{curl}} \ne \mathbf{0}$). This non-conservative circulation drives perpetual cyclic probability currents along closed loops, rendering single-potential variational optimization inapplicable.

## 6.3 Cybernetic Feedback Control and the Conservation of Sensitivity

The empirical Resistance–Resilience trade-off continuum ($B_{\mathrm{tot}} \times \mathcal{R} \approx \text{const}$) can be derived from the fundamental theorems of cybernetic feedback control theory.

In control engineering, the sensitivity function $S(i\omega) = [1 + L_{\mathrm{loop}}(i\omega)]^{-1}$ measures the closed-loop attenuation of environmental disturbances across angular frequency $\omega$. Bode's Sensitivity Integral theorem dictates that for any open-loop stable dynamic network:

$$\int_0^{\infty} \ln |S(i\omega)|\,d\omega = 0$$

This conservation law, known as the **waterbed effect**, proves that sensitivity cannot be reduced universally across all frequency bands:

$$\int_0^{\omega_{\mathrm{c}}} |\ln |S(i\omega)||\,d\omega = \int_{\omega_{\mathrm{c}}}^{\infty} |\ln |S(i\omega)||\,d\omega$$

In ecological networks:

- **Resistance ($B_{\mathrm{tot}}$)**: Massive standing biomass capacitors act as low-pass filters that suppress low-frequency environmental variance ($|S(i\omega)| \to 0$ as $\omega \to 0$).
- **Resilience ($\mathcal{R}$)**: The asymptotic return rate $\mathcal{R} = |\operatorname{Re}(\lambda_{\max})|$ governs how rapidly high-frequency transient perturbations decay.

Because the total integral of $\ln |S(i\omega)|$ is strictly conserved by network topology, an ecosystem cannot simultaneously maximize low-frequency disturbance rejection ($B_{\mathrm{tot}} \to \infty$) and broadband transient recovery ($\mathcal{R} \to \infty$). Pushing down sensitivity at low frequencies inevitably forces sensitivity up at high frequencies. The hyperbolic trade-off:

$$B_{\mathrm{tot}} \times \mathcal{R} \approx \text{const}$$

is the ecological manifestation of Bode's sensitivity integral in frequency space.
