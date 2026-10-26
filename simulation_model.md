# Onsager Networks in Ecology: A Non-Equilibrium Thermodynamic Framework

**Authors:** Consolidated research notes (thermodynamics_onsager project)
**Date:** 2026

---

## Abstract

This document separates ecological population dynamics from physical thermodynamic
response. The implementation includes transparent biomass-weighted interaction
summaries, a raw biomass-rate Jacobian diagnostic, a reduced-form VAR, and a
conditional OU covariance-weighted drift estimator. None of these is a physical
Onsager conductivity: that requires measured conjugate process fluxes and thermodynamic
forces, consistent units, and near-equilibrium assumptions. The code also includes a
heuristic agent simulation, a demographic jump model, and a generic three-coordinate
linear relaxation example. Unsupported eigenvalue clipping, synthetic entropy
production values, and the misleading conductivity labels have been removed.

---

## 1. Introduction

Ecological models can be analyzed alongside thermodynamic ideas, but an open,
fluctuating ecosystem does not automatically satisfy the assumptions of classical
near-equilibrium linear response. This document therefore distinguishes the
implemented ecological model diagnostics from physical thermodynamic quantities.
Local normalization is useful for comparing composition, but neither a small volume
element nor biomass normalization removes boundary exchanges or establishes local
equilibrium.

**Contributions.**
1. An explicit, reproducible Jacobian-weighted matrix diagnostic, with its
   assumptions distinguished from physical Onsager theory.
2. An optional allometric parameterization whose exponent can be varied.
3. A matrix-asymmetry measure that describes non-reciprocity but does not by
   itself identify a mechanism or predict a tipping point.
4. A description of the simulation routines actually implemented in
   `src/onsagernetwork.jl`.

---

## 2. Theoretical Framework

### 2.1 Macroscopic vs. Microscopic Thermodynamics

Classical thermodynamics (Carnot, Clausius) tracks extensive state variables
across rigid boundaries; statistical mechanics (Boltzmann, Gibbs) counts
microstates. Open ecosystems complicate both: boundaries are permeable, transformations
are numerous, and total biomass can fluctuate by orders of magnitude.
Schrödinger's order taxonomy resolves the apparent paradox of biological order:

- **Order \(\to\) Disorder:** entropic decay (Second Law).
- **Order \(\to\) Order:** dissipative structures maintaining local order by
  exporting entropy.
- **Disorder \(\to\) Order:** self-organization and evolutionary complexification.

### 2.2 Local Linear-Response Assumption

For an open system, entropy change is conventionally separated into internal
production and exchange across the boundary:

\[
dS = d_i S + d_e S,
\]

where \(d_i S\ge 0\) for the complete physical system and \(d_e S\) may have either
sign. Applying a local linear-response model additionally assumes a suitable local
reference state and sufficiently small perturbations. Choosing a small volume or
normalizing by biomass does not, on its own, guarantee local equilibrium or remove
boundary effects.

### 2.3 Onsager Relations and Conjugate Effects

Near a local stationary state, forces \(X\) (entropy gradients) drive fluxes \(J\)
(rates of transport) linearly:

\[
J_i = \sum_{j=1}^{n} L_{ij} X_j \quad\Longleftrightarrow\quad \mathbf J = \mathbf L\mathbf X,
\]

with \(\mathbf L\) the phenomenological conductivity matrix (\(\mathbf R=\mathbf L^{-1}\)
resistivity). Microscopic reversibility gives reciprocity

\[
L_{ij}=L_{ji}.
\]

Under the assumptions of Onsager's reciprocal relations, the coefficients for
specified conjugate processes obey reciprocity (with Onsager–Casimir modifications
when variables have different time-reversal parity or relevant fields are present).
Symmetry of an arbitrary ecological interaction matrix is neither required for
ecological coupling nor sufficient evidence that the matrix represents conjugate
thermodynamic processes or causal interactions.

For \(\mathbf J=\mathbf L\mathbf X\), the quadratic entropy-production expression
is \(\sigma=\mathbf X^{\mathsf T}\mathbf L\mathbf X=\mathbf X^{\mathsf T}\mathbf L_s\mathbf X\),
where \(\mathbf L_s=(\mathbf L+\mathbf L^{\mathsf T})/2\). Nonnegative production
for all forces requires \(\mathbf L_s\) to be positive semidefinite; it does not
require the full matrix to be symmetric or positive definite. Onsager reciprocity
is an additional assumption applicable to specified conjugate variables near
equilibrium. Positive diagonal entries alone do not ensure nonnegative production.

### 2.4 Optional Allometric Parameterization

The parameterization may include a mass factor \(M_i^{-k}\), with \(k=0.25\) as a
commonly used illustrative exponent. This factor changes the scale of the model's
weighted Jacobian; it does not, without a specified metabolic flux and unit
conversion, imply a conductivity, resilience, or resistance law. The exponent is
not universal, and outputs that include it should be checked across a stated range
(e.g. \(k\in[0.2,0.33]\)). The code's `sensitivity_allometry` performs this
parameterization sensitivity calculation; it does not validate the biological
interpretation.

### 2.5 Schrödinger's Order Principles

Biological systems operate as dissipative structures:
\((\text{local order}\Leftrightarrow\text{local order})\to(\text{global disorder})\),
maintaining internal structure by exporting degraded entropy.

---

## 3. Mathematical Formulation

### 3.0 Notation

| Symbol | Meaning |
|---|---|
| \(N_i, N_i^*\) | Abundance and reference abundance of class \(i\) |
| \(M_i\) | Individual body mass of class \(i\) (kg or stated model mass unit) |
| \(B_i=M_i N_i\) | Biomass of class \(i\), in the same mass unit |
| \(B_{\rm tot}=\sum_i B_i\) | Total biomass |
| \(b_i=B_i/B_{\rm tot}\) | Biomass fraction (\(\sum b_i=1\)) |
| \(\mathcal V\) | Physical volume in the stochastic jump model |
| \(\tilde N_i=N_i/N_i^*\) | Dimensionless abundance relative to its reference value |
| \(x_i\) | Selected dimensionless population coordinate (e.g. \(\log(N_i/N_i^*)\)) |
| \(\mathbf A_B\) | Jacobian of biomass rates with respect to biomass states |
| \(\mathbf W\) | Explicitly weighted interaction diagnostic; not a conductivity |
| \(\mathbf A,\mathbf C\) | OU drift matrix and stationary state covariance |
| \(\Delta t\) | Equal observation interval for population time series |
| \(\mathbf K_{\rm cov}\) | Covariance-weighted population drift matrix, \(-AC\), under the OU model |
| \(k\) | Allometric mass exponent; default 0.25 in the code |
| \(\epsilon\) | Dimensionless conversion efficiency in the jump model |
| \(\mathcal A_F\) | Frobenius asymmetry index |

### 3.1 Biomass-Fraction Normalization

For \(n\) species/size classes with individual mass \(M_i\) and abundance \(N_i(t)\),
the total biomass and fractions are

\[
B_{\rm tot}(t)=\sum_{i=1}^n M_i N_i(t),\qquad
b_i(t)=\frac{M_i N_i(t)}{B_{\rm tot}(t)},\qquad \sum_i b_i(t)=1.
\]

The fraction \(b_i\) is unchanged if all biomasses are multiplied by the same positive
factor. It is undefined when total biomass is zero; `normalize_biomass` rejects that
state. Here \(B_{\rm tot}\) is total biomass, not the physical volume \(\mathcal V\)
used by the stochastic jump model.

### 3.2 No Biomass-Derived Entropy Metric

The implementation does not infer an entropy Hessian or thermodynamic force from
biomass fractions. In particular, \(\operatorname{Diag}(1/b_i)\) is not used as a
physical metric: the fractions are constrained to a simplex, zero components are
possible, and the biomass-rate Jacobian is not expressed in conjugate entropy
coordinates. The population time-series estimator uses covariance as a statistical
weight within an OU model; it does not define an entropy, information measure, or
thermodynamic force.

### 3.3 Raw Interaction Diagnostics

`weighted_interaction_matrix` reports the explicit model parameterization

\[
\mathbf W=-\operatorname{Diag}(M_i^{-k})\,\mathbf A_{\rm raw}\,
          \operatorname{Diag}(b_i),\qquad
b_i=\frac{M_iN_i}{B_{\rm tot}}.
\]

`biomass_jacobian_diagnostic` separately computes \(\mathbf A_B=\partial f/\partial\mathbf B\)
and reports \(\mathbf W_B=-\mathbf A_B\operatorname{Diag}(b)\). Both return raw
matrices and asymmetry summaries only. No eigenvalues are clipped, no symmetric
matrix is substituted for the observed matrix, and neither weighting is derived
from Onsager theory. Values depend on the chosen state units and parameterization.

### 3.4 Population Deviations

Population deviations are state variables, not automatically thermodynamic forces.
The time-series estimator returns a covariance-weighted drift matrix under an OU
model (Section 3.6.2); it does not infer forces from the population coordinates.
The biomass-weighted interaction diagnostics do not produce an entropy or quadratic
dissipation measure.

### 3.5 Matrix Asymmetry

For a square matrix \(M\), `matrix_asymmetry` reports

\[
\mathcal A_F=\frac{\|M-M^{\mathsf T}\|_F}{\|M\|_F},
\]
with value zero for a symmetric matrix and for the zero matrix. The pairwise
asymmetry is zero when its denominator vanishes. This is a generic matrix summary;
its value does not establish reciprocity, causality, or a regime shift unless \(M\)
is independently shown to represent a thermodynamic response matrix.

### 3.6 Scope of the Jacobian Construction

The `biomass_jacobian_diagnostic` output \(W_B=-A_B\operatorname{Diag}(b)\) is a
weighted Jacobian summary. It is not an Onsager estimator because no thermodynamic
forces or conjugate fluxes are supplied. Its asymmetry is descriptive only; neither
symmetry nor asymmetry establishes spurious interactions, causality, or regime
change. `weighted_interaction_matrix` is a separate allometric parameterization.

### 3.6.1 Proposed Thermodynamic Mapping: Reaction Fluxes and Affinities

A more defensible ecological application would estimate a response matrix for a
specified biochemical or transport network, rather than relabel a species-abundance
Jacobian. The population-level mapping is not yet calibrated or implemented for an
ecological system in this repository. The reversible Gillespie mocks in Sections 5.4
and 5.5 demonstrate the estimator mechanics, not an empirical ecological conductivity;
nor do they make an entire ecosystem a near-equilibrium system.

1. **Specify the control volume and processes.** Choose a local, approximately
   isothermal subsystem and enumerate its biochemical reactions and transport
   processes. Include relevant external reservoirs (for example, carbon substrate
   and oxygen) in the stoichiometry or account for their exchange explicitly.
   Measured metabolite pools, activities, and reaction rates are preferable to
   species biomass as the state and flux variables. Biomass can be included only
   when its elemental composition and chemical-potential reference are defined.
2. **Define process fluxes.** For reaction \(r\), let \(v_r\) be its signed extent
   rate per unit volume (mol m\(^{-3}\) s\(^{-1}\)), positive in the chosen forward
   direction. Measure process-specific rates; net species growth \(\dot B_i\) is
   generally a stoichiometric combination of multiple processes and does not
   identify their individual fluxes.
3. **Derive conjugate forces.** Let \(\nu_{sr}\) be the stoichiometric coefficient
   of chemical species \(s\) in process \(r\) (products positive), and \(\mu_s\)
   its chemical potential (J mol\(^{-1}\)). Define
   \[
   \Delta_r G=\sum_s\nu_{sr}\mu_s,\qquad X_r=-\frac{\Delta_r G}{T}.
   \]
   With this sign convention, the chemical contribution to internal entropy
   production density is
   \[
   \dot s_i=\sum_r v_r X_r
   =-\frac{1}{T}\sum_r v_r\Delta_r G\ge 0,
   \]
   for a thermodynamically consistent complete reaction accounting. Additional
   transport or heat-transfer processes require their own conjugate flux-force
   terms. Boundary exchange must not be mistaken for internal production.
4. **Estimate local response.** Around an equilibrium or demonstrably near-equilibrium
   reference, perturb the affinities independently and measure the corresponding
   flux responses. Use an independent process basis; stoichiometrically dependent
   reactions otherwise make the response underidentified. For
   centered observations arranged as columns of \(X_c\) and \(J_c\), fit
   \[
   J_c\simeq L X_c,\qquad
   \widehat L=J_cX_c^{\mathsf T}(X_cX_c^{\mathsf T})^{-1},
   \]
   when the perturbation design has full row rank. In noisy experiments, use a
   regression or likelihood that accounts for uncertainty in both forces and
   fluxes; report uncertainty and check identifiability. Do not impose symmetry
   during the initial diagnostic fit.
5. **Check the regime before interpreting reciprocity.** Onsager reciprocity
   (with Onsager–Casimir modifications where appropriate) and a positive-semidefinite
   dissipative response apply under specified near-equilibrium and microscopic
   reversibility assumptions. Ecosystem metabolism is often strongly driven, so a
   local derivative \(\partial v/\partial X\) measured far from equilibrium may
   be useful as a kinetic response matrix but is not thereby an Onsager matrix.

This construction makes the matrix dimension equal to the number of defined
processes, not the number of species. If only abundance time series and a community
Jacobian are available, the conjugate chemical forces and process-specific fluxes
are missing; a physical chemical Onsager conductivity is therefore not identifiable
from those data alone. A conditional OU covariance-weighted drift matrix can be
estimated under stronger stochastic assumptions (Section 3.6.2), but it is neither
a conductivity nor a force-flux relation. The code's `-A_B\operatorname{Diag}(b)` remains an
exploratory weighted-Jacobian diagnostic, not that population response.

**Relation to the ecological “Conjugate effects” intuition.** The broader argument
in `thermodynamics_onsager.md`—that processes such as photosynthesis, growth,
respiration, and evapotranspiration may be coupled—is a useful source of hypotheses
for selecting processes and perturbations. In a measured local linear-response
model, those cross-effects would be represented by off-diagonal coefficients
\(L_{rs}\): changing force \(X_s\) is associated with a response in flux \(J_r\).
Onsager reciprocity is a more specific prediction: under its near-equilibrium
assumptions, the paired coefficients should agree (subject to Onsager–Casimir
conditions). It does not mean the processes mutually benefit, that the effects have
opposite signs, or that a population-level feedback or coevolutionary effect has
been demonstrated. Correlation, long-term adaptation, and a causal reciprocal
response are distinct claims. Testing the latter requires controlled perturbations
of the relevant forces, measurement of both flux responses at matched scales, and
control of shared drivers. Cross-scale “dissipation cascade” and evolutionary
arguments can motivate such tests, but are not implied by a local Onsager matrix.

#### From Process Conductivity to the Community Matrix

A process conductivity can generate a community matrix under a specific physical
model; the community matrix is not itself the conductivity. Let
\(\mathbf{x}=(x_1,x_2)^{\mathsf T}\) be carbon amounts in two biomass pools, in
\(\mathrm{mol\,m^{-3}}\), and let \(\mathbf{j}\) be signed molar process fluxes.
The projected stoichiometric matrix \(\mathbf{B}\) maps those process fluxes to
pool changes, \(\dot{\mathbf{x}}=\mathbf{B}\mathbf{j}\). Reservoir exchanges must
also be accounted for, even if reservoir states are not included in \(\mathbf{x}\).
Near a reference state \(\mathbf{x}^*\), write the free-energy density as
\[
G(\mathbf{x})=G_*+\boldsymbol{\mu}_*^{\mathsf T}\delta\mathbf{x}
 +\tfrac12\delta\mathbf{x}^{\mathsf T}\mathbf{H}\delta\mathbf{x}
 +o(\|\delta\mathbf{x}\|^2),\qquad
\delta\mathbf{x}=\mathbf{x}-\mathbf{x}^*,
\]
where \(\mathbf{H}=\nabla_{\mathbf{x}}^2G|_{\mathbf{x}^*}\). The process forces
include the fixed reservoir free-energy contributions \(\mathbf{g}_{\rm res}\):
\[
\mathbf{X}=-\left(\mathbf{B}^{\mathsf T}\nabla_{\mathbf{x}}G+
\mathbf{g}_{\rm res}\right)/T.
\]
At a zero-affinity reference and under local detailed balance, near-equilibrium
linear response has \(\mathbf{j}=\mathbf{L}\mathbf{X}\), with \(\mathbf{L}\)
symmetric positive semidefinite under the applicable time-reversal assumptions.
The internal entropy-production rate is
\[
\dot{s}_i=\mathbf{j}^{\mathsf T}\mathbf{X}
 =\mathbf{X}^{\mathsf T}\mathbf{L}\mathbf{X}\geq0.
\]
Linearizing the state dynamics gives
\[
\mathbf{A}\equiv\left.\frac{\partial\dot{\mathbf{x}}}
 {\partial\mathbf{x}}\right|_{\mathbf{x}^*}
 =-\frac{1}{T}\mathbf{B}\mathbf{L}\mathbf{B}^{\mathsf T}\mathbf{H},
\qquad
- T\mathbf{A}\mathbf{H}^{-1}=\mathbf{B}\mathbf{L}\mathbf{B}^{\mathsf T}.
\]
The right-hand side is symmetric positive semidefinite under these assumptions,
although the raw community matrix \(\mathbf{A}\) need not be symmetric. If
\(\mathbf{B}=\mathbf{I}\), this reduces to
\(\mathbf{L}=-T\mathbf{A}\mathbf{H}^{-1}\). With a rectangular or rank-deficient
\(\mathbf{B}\), state dynamics identify at most the projected matrix
\(\mathbf{B}\mathbf{L}\mathbf{B}^{\mathsf T}\); process-level coefficients
cannot generally be recovered without event-level flux and force measurements.

For a small algebraic example, use standardized coordinates with \(T=1\),
\(\mathbf{B}=\mathbf{I}\), \(\mathbf{H}=\mathbf{I}\), and
\[
\mathbf{L}=\begin{bmatrix}2&0.5\\0.5&1\end{bmatrix},\qquad
\mathbf{A}=-\mathbf{L}=\begin{bmatrix}-2&-0.5\\-0.5&-1\end{bmatrix}.
\]
The eigenvalues of \(\mathbf{L}\) are \((3\pm\sqrt{2})/2>0\). The off-diagonal
terms represent reciprocal cross-response between the specified process fluxes
and forces. They are not automatically predator-prey coefficients, nor evidence
that any observed species interaction is causal. These standardized values are
illustrative, not fitted ecological data.

#### Statistical Entropy and Physical Dissipation

The statistical and thermodynamic descriptions can converge when the statistical
states have a physical interpretation. Let \(p_i\) be the probability of a
coarse-grained container state and \(\Omega_i\) the number of physical microstates
represented by it. If microstates within each container are equally probable, the
Gibbs entropy is
\[
S=-k_{\rm B}\sum_i p_i\ln p_i
  +k_{\rm B}\sum_i p_i\ln\Omega_i.
\]
The first term is the Shannon/Gibbs entropy of the container distribution; the
second accounts for within-container multiplicity. For nonuniform conditional
microstate distributions, it is replaced by their conditional entropy. An observed
relative-abundance vector can be used as a distribution over species labels for a
chosen sampling scheme, but that alone does not specify the physical microstates,
within-container multiplicities, or thermodynamic entropy.

For a Markov jump model satisfying local detailed balance, the log probability
ratio of a trajectory and its time reverse (with the reverse ensemble and boundary
terms defined consistently) is related to total stochastic entropy production of
the system plus its environment, in units of \(k_{\rm B}\). Thus probability
statistics become a physical entropy account when transition rates represent
physical processes and their energy and matter exchanges with reservoirs. This is
a conditional convergence, not a blanket identity: coarse-graining can hide
exchanges or create memory, and distribution entropy by itself is not an
entropy-production rate. The same physical qualification applies to the mapping
from process conductivity to a community matrix above.

For a slowly changing meta-state, this mapping may hold conditionally as
\(\mathbf{A}(\theta)=-(1/T)\mathbf{B}(\theta)\mathbf{L}(\theta)
\mathbf{B}(\theta)^{\mathsf T}\mathbf{H}(\theta)\) when fast mixing, response
measurement, and meta-state evolution are separated in time (Section 3.6.5). It
does not establish detailed balance for the full evolving process.

### 3.6.2 Conditional Covariance-Weighted Drift from Population Time Series

Population time series alone do not determine physical chemical affinities or
process fluxes. Under an explicit stationary Gaussian Ornstein–Uhlenbeck (OU) model,
they can support an estimate of the drift matrix \(A\) and stationary state
covariance \(C\). The derived matrix \(K_{\rm cov}=-AC\) is a covariance-weighted
drift summary in the selected state coordinates. It is coordinate- and model-dependent;
it is not itself an information-entropy measure, physical entropy, thermodynamic force,
conductivity, or force-flux relation.

Choose nonredundant dimensionless population coordinates \(x\), center them at the
stationary mean, and estimate their covariance \(C\). The coordinates may be
correlated; the estimator requires the resulting covariance to be positive
definite. For positive absolute abundances, one possible coordinate is
\(x_i=\log(N_i/N_i^*)\). For compositional abundances constrained to sum to one,
use a nonredundant set of \(n-1\) log-ratio coordinates instead; the full composition
covariance is singular. Zero counts require an explicit observation/count model
rather than an arbitrary pseudocount.

Assume a stationary Ornstein–Uhlenbeck model

\[
 d\mathbf x = \mathbf A\mathbf x\,dt + \mathbf G\,d\mathbf W,
\]

with stable drift \(\mathbf A\), stationary covariance \(\mathbf C\succ0\), and
no unmodeled deterministic forcing. Define the derived matrix by

\[
 \mathbf K_{\rm cov}\equiv-\mathbf A\mathbf C.
\]

This is an algebraic covariance-weighted drift summary, not a constitutive equation
of the form flux = conductivity × thermodynamic force. Under the OU detailed-balance
condition \(\mathbf A\mathbf C=\mathbf C\mathbf A^{\mathsf T}\),
\(\mathbf K_{\rm cov}\) is symmetric. For an exactly stationary OU process with
diffusion covariance \(\mathbf D=\mathbf G\mathbf G^{\mathsf T}\), its symmetric
part satisfies \((\mathbf K_{\rm cov}+\mathbf K_{\rm cov}^{\mathsf T})/2=\mathbf D/2\).
These are statistical model properties, not Onsager reciprocity or entropy-production
claims. Do not force symmetry or clip eigenvalues; the implementation reports the
observed asymmetry and minimum symmetric eigenvalue as diagnostics only.

For equally spaced observations with interval \(\Delta t\), fit a VAR(1) transition
matrix \(\mathbf\Phi\) and use \(\mathbf A=\log(\mathbf\Phi)/\Delta t\) when a
numerically real matrix logarithm exists. `estimate_population_covariance_weighted_drift`
implements this conditional estimator and returns the raw matrix (field
`covariance_weighted_drift`), its symmetric part, drift stability, asymmetry, minimum
symmetric eigenvalue, and a roundoff-only positive-semidefiniteness flag. For this
matrix, the asymmetry equals the normalized detailed-balance residual; it is not a
formal statistical test. The estimator does not propagate uncertainty through the
covariance and matrix-log estimates. The approximation requires uniform sampling
and adequate stationary observations. Irregular sampling,
compositional constraints, latent environmental forcing, and non-equilibrium
probability currents require an appropriately specified state-space model.

For a physically calibrated conductivity, use process-specific fluxes and chemical
affinities as in Section 3.6.1. The covariance-weighted drift estimate is a model-
based summary of stationary abundance fluctuations, not a physical conductivity.

### 3.6.3 Reversible Gillespie Models as Onsager Estimators

A continuous-time Markov jump model can estimate an Onsager matrix when its event
channels are thermodynamically specified. Gillespie simulation is then a way to
sample reaction traffic and its response to controlled forces; it is not a formula
that turns arbitrary event propensities into conductivity. Each channel needs a
physical stoichiometry, an identified conjugate flux and affinity, forward and
reverse transitions, and rate ratios consistent with local detailed balance.

For reaction channel \(r\), let \(\boldsymbol\nu_r\) be its stoichiometric change
(products positive), and let \(a_r^+(\mathbf n)\) and \(a_r^-(\mathbf n+\boldsymbol\nu_r)\)
be the forward and reverse propensities on the corresponding pair of states. At
equilibrium, detailed balance requires the stationary probability flow along each
edge to equal its reverse. Away from equilibrium, local detailed balance relates the
forward/reverse propensity ratio to the system free-energy change and entropy
exchange with specified reservoirs. These relations—not the propensity magnitudes
alone—identify the thermodynamic force.

Let \(J_r\) be the signed molar reaction-extent flux per control volume, and let
\(X_r=-\Delta_r G/T\) be its conjugate force in \(\mathrm{J\,mol^{-1}\,K^{-1}}\).
With this sign convention, \(\dot s_i=\sum_r J_r X_r\). Around an equilibrium
reference, the stochastic response matrix is

\[
L_{rs}=\left.\frac{\partial \langle J_r\rangle_{\mathrm{ss}}}
{\partial X_s}\right|_{\mathbf X=0},\qquad
\mathbf J_{\mathrm{ss}}\simeq\mathbf L\mathbf X.
\]

Here the mean is taken in the perturbed stationary state. A direct simulation
estimator perturbs one independent affinity at a time by \(\pm\delta X_s\), runs
Gillespie trajectories to steady state, measures signed reaction counts over a
fixed observation window, converts counts to physical flux units, and computes
\[
\widehat L_{rs}=\frac{\widehat J_r(+\delta X_s)-
                         \widehat J_r(-\delta X_s)}{2\delta X_s}.
\]
Use replicate trajectories or time-block uncertainty estimates, check convergence
as the perturbation shrinks and the observation window grows, and report the raw
matrix before testing reciprocity and the positive-semidefinite condition on its
symmetric part. Do not symmetrize or project the estimate to positive semidefinite
before those diagnostics. A Green–Kubo estimator from equilibrium current
correlations is another option, but its normalization must match the stated flux,
force, and volume conventions.

A practical implementation plan for applying this to population processes is:

1. **Define the physical subsystem and accounting.** Choose the control volume,
temperature, time scale, and measured chemical species. Enumerate organism-level
processes together with the resource, waste, and heat exchanges they entail. Define
stoichiometric columns and signed event currents; abundance or biomass change alone
does not identify process-specific reaction fluxes.
2. **Supply reversible channels and thermodynamic parameters.** Specify forward and
reverse propensity laws, chemical potentials or reaction free energies, and the
reservoir activities. Verify local detailed balance and units. Include a resource
supply/removal mechanism that permits a nonzero, stable reference population; do
not use extinction conditioning as a substitute for equilibrium.
3. **Establish the reference regime.** Verify the intended equilibrium distribution
or near-equilibrium steady state, stationarity, ergodicity, and detailed balance at
zero imposed affinity. Identify independent reaction or cycle coordinates; a
stoichiometrically redundant force basis gives a singular, non-identifiable matrix.
4. **Measure response.** Apply controlled, small, independent affinity perturbations
around the reference, record each channel's forward and reverse event counts, and
convert event extents using Avogadro's constant and the physical volume (or another
explicit amount convention). Repeat simulations to quantify Monte Carlo error.
5. **Diagnose before interpretation.** Estimate the unsymmetrized derivative matrix,
its uncertainty, reciprocity residual, and symmetric-part eigenvalues. Test force
step and sampling-duration sensitivity. Onsager symmetry is expected only for the
specified near-equilibrium, time-reversal-compatible variables and microscopic
reversibility assumptions; otherwise report a local kinetic response matrix.
6. **Calibrate against observations.** Replace mock rates and site concentrations
with measured values, validate event and energy balances, and compare predicted
response with controlled perturbation data. Only then describe the result as a
physical conductivity for that process basis and control volume.

The existing `PopulationJumpParams` model does not meet these conditions. Its birth,
death, competition, and predation parameters define demographic hazards, but it has
no reservoir chemical potentials, energy accounting, or local-detailed-balance
constraints; predation and competition lack reverse channels, and the all-zero
population is absorbing. Its `conversion_efficiency` is not an energetic affinity.
Thus its propensities cannot currently yield an Onsager conductivity. They can
motivate a future thermodynamic reaction-network model, but the latter must be a
separate specification rather than a reinterpretation of the current jump rates.

### 3.6.4 Deep Assessment: What the Stochastic Approach Establishes

**The central claim is conditional, but useful.** Gillespie propensities can support
a true Onsager estimate when they are the rates of a physically specified Markov
reaction model with conjugate event currents, thermodynamic affinities, and local
detailed balance. The estimate is then a derivative of a measured stochastic
current with respect to a controlled physical force. This is a defensible route
from microscopic event data to macroscopic linear response; it is not a generic
conversion from rates, noise, or a population Jacobian to conductivity. Assigning
physical units to an otherwise phenomenological rate does not supply the missing
thermodynamic structure.

**What the mock demonstrates.** The two-pathway example establishes that the
procedure can recover a known near-equilibrium response from simulated event
counts. It has a finite, well-defined stationary distribution; reversible channels;
an explicit force perturbation; and an analytic matrix for comparison. At zero
force, each channel satisfies detailed balance. The mock therefore verifies the
estimation mechanics—Gillespie event accounting, finite-difference response, and
Monte Carlo uncertainty—against a controlled reference. Its exact coefficient is a
valid Onsager matrix for this defined toy process, in the declared basis and units.
It is not an estimate of conductivity in an organism, ecosystem, or the existing
`PopulationJumpParams` model.

**The toy's singularity is informative, not a defect.** Both channels make the same
state change, so their net stationary currents must sum to zero. Only the difference
between their affinities drives a cycle. The two-channel matrix therefore has rank
one and a null direction for a common shift of both forces. This shows why reaction
and cycle coordinates must be checked before regression or inversion. In an
application, choose an identifiable independent process basis. If a redundant
basis is retained for reporting, explain its null modes; do not treat a singular
matrix as failed thermodynamics or invert it without justification. Under an
invertible change of process basis, fluxes and forces must transform dually so that
the entropy-production pairing is unchanged; numerical coefficients are not
basis-free scalars.

**Local detailed balance is the decisive boundary between a physical and a
phenomenological jump model.** An arbitrary continuous-time Markov chain has
trajectory-probability ratios, but those ratios are not automatically physical
entropy production. The event channels must correspond to actual chemical,
transport, or other specified processes, with reverse paths and exchanges with
identified reservoirs. Their rate ratios must agree with the free-energy change
and reservoir entropy. A propensities-only fit may still provide a useful stochastic
population model, but without those conditions its inferred response is a kinetic
sensitivity, not a thermodynamic conductivity. A coarse-grained process whose
hidden variables create memory or whose rates omit relevant states may also fail to
retain local detailed balance, even when its simulated trajectories look plausible.

**Equilibrium and nonequilibrium must not be conflated.** Classical Onsager
reciprocity is an equilibrium linear-response statement (with the appropriate
Onsager–Casimir form for time-reversal parity and external fields). A stable
nonequilibrium steady state can have a well-defined local derivative
\(\partial\langle J\rangle/\partial X\), but that derivative need not be symmetric
or positive semidefinite and should not automatically be called an Onsager matrix.
For an equilibrium reference, detailed balance, ergodicity, and stationarity must
be established in the relevant state space. The existing ecological jump model has
an absorbing all-zero state; conditioning on long-lived populations produces a
quasi-stationary ensemble, not equilibrium. A resource-reservoir extension could
create a nonzero reference population, but its uptake and loss reactions must be
specified thermodynamically rather than added solely to prevent extinction.

**The force perturbation is part of the model.** Local detailed balance constrains
the forward/reverse rate ratio. It does not, by itself, specify every kinetic
prefactor or how a real experimental intervention changes transition barriers.
The mock explicitly holds the symmetric kinetic prefactor fixed while applying
\(\exp(\pm X_r/(2R))\). For real processes, perturbations must correspond to
measurable changes in reservoir chemical potentials, imposed gradients, or other
physical forces, and the resulting rate law must be justified. If force and flux
calibration are uncertain, propagate that uncertainty into \(\mathbf L\); do not
hide it in the Gillespie sampling error.

**The estimator has both statistical and design limitations.** Central finite
differences have a force-step bias that typically decreases with the square of the
step, while Monte Carlo error increases as the step shrinks. Repeat the estimate
across several small perturbation sizes and longer measurement windows. Allow
adequate equilibration after every perturbation, check stationarity and mixing, and
use independent replicates or autocorrelation-aware block methods; individual
Gillespie events are not independent samples. A full-rank perturbation design is
needed for all independent forces. If experimental forces are measured with error,
ordinary least squares on estimated currents and forces can be biased; use a
likelihood or errors-in-variables method. Report confidence intervals for matrix
entries and for reciprocity and eigenvalue diagnostics.

At equilibrium, reciprocity should be assessed against uncertainty, not by
symmetrizing the estimate. Nonnegative entropy production requires the symmetric
part of \(\mathbf L\) to be positive semidefinite under the stated force-flux
convention. Finite-sample eigenvalues near zero can have either sign, as in the
rank-deficient mock. A small negative estimate is not evidence against the theory
unless it is distinguishable from sampling and calibration error; conversely,
clipping it to zero would conceal a diagnostic failure. Agreement of a fitted matrix
with symmetry and semidefiniteness is necessary under the model assumptions but
does not independently prove that the chosen forces, fluxes, or reaction scheme
are physically correct.

**Overall assessment.** This is a principled and promising way to use probabilistic
propensities: simulate or observe controlled stochastic event currents, then
estimate the conjugate response. The mock validates that workflow in a deliberately
small system and exposes rank and uncertainty issues. The main scientific work for
an ecological application is not choosing a Gillespie solver; it is defining
measurable process fluxes, thermodynamic forces, reservoir exchanges, reversible
mechanisms, and a valid near-equilibrium reference. Until those are supplied, keep
results from the demographic jump model labeled as population dynamics or kinetic
response, not Onsager conductivity.

### 3.6.5 Scale-Dependent Balance and Evolving Processes

Detailed balance is always a statement about a specified state space, transition
process, and time scale. It is not an unqualified property of an organism, species,
or ecosystem. Organisms and species here are biological containers and accounting
units for physical processes; the relevant question is which process transitions and
exchanges are represented at the chosen level of description. A coarse-grained or
conditional model may be balanced even when a larger model that includes omitted,
changing processes is not.

Let \(x\) denote the fast state and \(\theta\) a slowly changing meta-state that
controls vital-process rates or free energies. At fixed \(\theta\), write the fast
Markov generator as \(Q_\theta\) and its stationary distribution as
\(\pi_\theta\). Conditional detailed balance means
\[
\pi_\theta(x)q_\theta(x,y)=\pi_\theta(y)q_\theta(y,x)
\]
for every represented transition pair, at that frozen \(\theta\) and under the
specified reference forces. The conditional Onsager response is then
\[
L_{rs}(\theta)=\left.
\frac{\partial\langle J_r\rangle_{\mathrm{ss},\theta}}
     {\partial X_s}\right|_{\mathbf X=0}.
\]
It is local to that generator, process basis, and operating state. As \(\theta\)
changes, both \(Q_\theta\) and \(\mathbf L(\theta)\) may change: balance can hold
within each fast snapshot without implying one static equilibrium for the entire
history.

A quasi-static interpretation requires a measurable scale separation such as
\[
\tau_{\mathrm{mix}}(\theta)\ll T_{\mathrm{obs}}\ll\tau_{\mathrm{evo}},
\]
where the fast process mixes within the response window while \(\theta\) changes
little during that window. Then one may estimate a sequence of local matrices
\(\mathbf L(\theta_t)\) and report their evolution, rather than pool them into a
single stationary conductivity. The window must also be long enough to estimate
currents with useful precision. If no such window exists, the frozen-state estimate
is not justified: use a transient/nonstationary response analysis or model the fast
and slow states jointly. A lag of the observed fast state behind
\(\pi_{\theta_t}\) is a useful warning of insufficient separation or rapid
meta-state changes.

This conditional claim does not confer detailed balance on the full evolving
process. In principle, a joint state \((x,\theta)\) could have its own generator and
thermodynamic accounting, but that requires explicit forward and reverse
meta-state transitions, their physical driving and work/reservoir exchanges, and
local detailed balance for those transitions too. If meta-state changes are imposed
externally or are irreversible at the modeled scale, the joint process generally is
not an equilibrium detailed-balanced process. Do not call its evolving local
coefficients a global equilibrium Onsager matrix; they are conditional response
properties indexed by the changing process state.

`examples/evolving_onsager_mock.jl` demonstrates this distinction. A scalar trait
\(\theta\) sets \(\kappa_1=\kappa_0e^\theta\),
\(\kappa_2=\kappa_0e^{-\theta}\), and
\(\Delta G(\theta)=RT\theta\). For each frozen trait, the two-state fast process is
detailed-balanced at zero applied force, with occupied fraction
\(p_{\mathrm{occ}}(\theta)=1/(1+e^\theta)\). The mock's conditional response is
\[
\mathbf L(\theta)=\frac{c_s}{2R}\operatorname{sech}(\theta/2)
\left[\operatorname{Diag}(\boldsymbol\kappa(\theta))-
\frac{\boldsymbol\kappa(\theta)\boldsymbol\kappa(\theta)^{\mathsf T}}
     {\sum_r\kappa_r(\theta)}\right].
\]
The trait is updated by an imposed mutation-selection-like rule; this is not a
thermodynamic or detailed-balanced evolutionary model. The code carries the fast
occupancy between epochs to expose tracking/lag, while estimating each local response
from separate trajectories at frozen \(\theta\). Thus its changing \(\mathbf L\)
illustrates the proposed scale-indexed quantity, not a global conductivity of the
coupled trait-plus-population process.

### 3.7 Dimensional Analysis and Input Checklist

A common source of error is mixing abundance, biomass, and normalized (dimensionless)
state variables. The following checklist and dimensional analysis keep the
quantities consistent.

**State variable choice.** Pick one and do not mix:
- Abundance \(N_i\) (individuals), or
- Biomass \(B_i = M_i N_i\) (kg), or
- Normalized (dimensionless) \(\tilde N_i = N_i/N_i^*\).

**Checklist.**
1. Choose whether a vector contains abundance \(N\), biomass \(B\), or a
   dimensionless relative state; do not treat their Jacobians as interchangeable.
2. Calculate \(b_i=B_i/\sum_j B_j\) only when total biomass is positive. The
   fractions are dimensionless and sum to one.
3. No entropy metric is inferred from biomass fractions.
4. `biomass_jacobian_diagnostic` computes \(A_B=\partial f/\partial B\) and the
   explicitly weighted diagnostic \(W_B=-A_B\operatorname{Diag}(b)\). If \(f\)
   has biomass/time units, \(A_B\) and \(W_B\) have units [1/time].
5. `weighted_interaction_matrix` adds a mass factor \(M_i^{-k}\); its numerical
   value depends on the chosen mass unit and it is not interchangeable with \(W_B\).
6. `estimate_population_covariance_weighted_drift` returns \(K_{\rm cov}=-AC\) under a
   stationary OU assumption. It has units [1/time] for dimensionless coordinates
   and is a coordinate-dependent statistical summary, not a conductivity.
7. Physical conductivity interpretation requires measured conjugate fluxes and
   forces, a physical entropy balance, and consistent units.

**Dimensional summary.**

| Quantity | Symbol | Units | Notes |
|---|---|---|---|
| Abundance | \(N_i\) | individuals (count) | distinct from biomass |
| Body mass | \(M_i\) | kg or stated model mass unit | use the same unit throughout |
| Total biomass | \(B_{\rm tot}\) | same mass unit | \(\sum_i M_i N_i\) |
| Biomass fraction | \(b_i\) | dimensionless | \(M_i N_i/B_{\rm tot}\), sums to 1 |
| Jump-model volume | \(\mathcal V\) | volume | used in density-dependent event rates |
| Biomass Jacobian | \((A_B)_{ij}\) | 1/time | if biomass rates are differentiated by biomass |
| Weighted Jacobian | \((W_B)_{ij}\) | 1/time | \(-A_B\operatorname{Diag}(b)\) |
| Population coordinates | \(x_i\) | dimensionless | chosen log or log-ratio coordinates |
| Covariance-weighted drift | \((K_{\rm cov})_{ij}\) | 1/time | \(-AC\) for dimensionless coordinates; OU summary only |

The code's matrices are model diagnostics. Their asymmetry index is dimensionless
under common scalar rescaling, but the underlying matrix and its biological
interpretation still depend on state units, rate units, normalization, and
parameterization. Do not compare values across inconsistent definitions.

## 4. Empirical Estimation

### 4.1 Data Ingestion

Given census counts and individual masses, one can calculate
\(b_i=M_iN_i/B_{\rm tot}\) at times with positive total biomass. Zero-count handling
is a modeling decision and
must be documented; this repository does not implement data ingestion or imputation.

### 4.2 Bayesian State-Space Models

A state-space model could estimate latent composition and interaction parameters,
but no Turing.jl model, observation likelihood, prior specification, or sampling
routine is implemented in this repository. Such a model must preserve the simplex
constraint (for example, by modeling log-ratios) and distinguish process noise from
observation noise. It must also define the force-flux variables before interpreting
any parameter as a conductivity.

### 4.3 Time-Series Diagnostics

`fit_var` estimates a reduced-form VAR(p) by ordinary least squares and returns
lag matrices, residuals, residual covariance, fitted values, and coefficient standard
errors. Standard errors are arranged by design coefficient (rows) and response
variable (columns).
`rolling_var_asymmetry` reports the asymmetry of the first-lag coefficient matrix
in each window. `bootstrap_var_asymmetry` supplies an approximate percentile
interval using a moving-block bootstrap. `estimate_population_covariance_weighted_drift` estimates the conditional OU
covariance-weighted drift matrix in Section 3.6.2. VAR coefficients alone
are discrete-time propagators, not continuous-time physical conductivities; their
asymmetry is not a reciprocity test. Bootstrap intervals depend on stationarity and
block-length assumptions. `asymmetry_null` remains a simple independent row/column
permutation reference, not a time-series-aware null or tipping-point test.

### 4.4 Limitations of Inference

The OLS standard errors rely on the ordinary regression assumptions and are not
robust to arbitrary serial correlation or heteroskedasticity. The moving-block
bootstrap only approximates sampling uncertainty under its stationarity and block
assumptions. These routines do not address latent forcing, measurement error,
causality, model selection, or regime-shift detection; no Bayesian state-space or
comprehensive inference pipeline is implemented.

---

## 5. Computational Models

The file `src/onsagernetwork.jl` contains the routines described below. The
population-response diagnostics are conditional statistical quantities, not
validation of a physical entropy model.

### 5.1 Linear Relaxation and Biomass/Agent Simulations

`simulate_three_state_relaxation` gives the exact solution of the generic three-state
system \(\dot x=-Kx\) for symmetric positive-semidefinite \(K\). Small negative
eigenvalues within a documented floating-point tolerance are accepted but are not
clipped; the returned quadratic diagnostic is also unmodified. It is a linear
relaxation example, not a predator–prey model. `ecosystem_simulation` advances a
heuristic agent-based biomass model. Its options explicitly name initial biomasses,
reference masses, carrying capacities, interaction matrix, duration, time step, and
output interval; pass an `rng` to make parameter generation and simulation
reproducible. It records the initial state, then every
`max(1, round(output_interval / time_step))` integration steps, and always records
the exact requested endpoint. If the duration is not an integer multiple of the time
step, the final integration step is shortened. Defaults use an initial biomass
uniformly sampled up to half the carrying capacity. The supported
`ecosystem_type` values are `boreal`, `tropical`, `temperate`, `high trophic
level`, and `low trophic level`. `ibm_biomass_rate`
supplies the deterministic rate function, and `biomass_jacobian_diagnostic` returns
its raw Jacobian and explicitly weighted diagnostic. Model constants are grouped in
`AGENT_MODEL_DEFAULTS` and `INTERACTION_MATRIX_DEFAULTS`; generated parameters are
heuristic, not empirically calibrated, and expressed in arbitrary model units rather
than calibrated physical units.

### 5.2 Stochastic Jump Process

`PopulationJumpParams` uses descriptive keyword parameters: `birth_rates`,
`death_rates`, `competition_coefficients`, `predation_coefficients`, `body_masses`,
`volume`, and `conversion_efficiency`. In `predation_coefficients[i,j]`, row \(i\) is
the predator and column \(j\) the prey. With the implemented allometric mass
exponent \(k=0.25\), the event propensities are
\[
\lambda_i^{\rm birth}=r_i M_i^{-k}N_i,\quad
\lambda_i^{\rm death}=d_iN_i+\frac{c_i}{\mathcal V}N_i(N_i-1),\quad
\lambda_{ij}^{\rm pred}=\frac{\gamma_{ij}}{\mathcal V}M_i^{-k}N_iN_j.
\]
A predation event adds one predator and removes
\(\max(1,\lceil M_i/(\epsilon M_j)\rceil)\) prey. For counts treated as
dimensionless, the coefficient units under this formula are \([r_i]=[M]^k/[T]\),
\([d_i]=1/[T]\), \([c_i]=[\mathcal V]/[T]\), and
\([\gamma_{ij}]=[\mathcal V][M]^k/[T]\). `conversion_efficiency` is restricted
to \((0,1]\). `run_gillespie_population` returns a named result containing
event times, count vectors, biomass densities, event count, and stop reason; it also
accepts an `rng` and a `max_events` limit.

These are demographic model assumptions; the jump process does not demonstrate
mass/energy conservation or establish a link between demographic noise and early
warning. The previous tau-leaping routine was removed because clipping negative
counts silently changed reaction stoichiometry. No Bayesian filter, nonlinear
population-response model, or spatial lattice solver is currently implemented.

### 5.3 Reproducible Mock Population-Response Example

`examples/population_response_mock.jl` generates a stationary three-coordinate
Gaussian OU process with known covariance \(C\) and drift \(A\), then defines the
symmetric covariance-weighted drift matrix \(K_{\rm cov}=-AC\). It derives the exact
discrete transition and innovation covariance for the selected sampling interval,
and simulates abundance as \(N_i=N_i^*\exp(x_i)\). Applying the estimator to
\(\log(N_i/N_i^*)\) demonstrates recovery of \(K_{\rm cov}=-AC\) in finite data. The
script uses a fixed random seed and prints the generating and estimated matrices
and diagnostics. For seed `20261026` and 20,000 observations, the estimate is
approximately
\[
\widehat K_{\rm cov}=\begin{bmatrix}
0.7907 & -0.1180 & 0.0375\\
-0.0863 & 0.6050 & -0.0947\\
0.0652 & -0.0570 & 0.5116
\end{bmatrix},
\]
with Frobenius error 0.0434, asymmetry 0.0702, and minimum symmetric eigenvalue
0.4691. The estimated drift is stable and its symmetric part is positive definite
in this sample. These are reproducible software
outputs, not empirical findings. OU stationarity, Gaussian log-coordinate dynamics,
positive absolute abundances, and the chosen scaling are known by construction;
the example does not validate those assumptions for empirical populations or yield
a physical conductivity.

### 5.4 Reversible Gillespie Onsager Mock

`examples/reversible_onsager_mock.jl` implements a minimal two-pathway model to
exercise the response-estimation procedure. A finite number of independent sites
switch between vacant and occupied states. Either of two reaction channels can
produce the forward transition, and either channel can reverse it. For each site,
channel \(r\) has rates \(\kappa_r\exp(\pm X_r/(2R))\), where \(R\) is the molar gas
constant and \(X_r=\mathcal A_r/T\) is a molar thermodynamic force. The Gillespie
propensities multiply these rates by the number of vacant or occupied sites.
At zero force the two-state process obeys detailed balance; its force-dependent
rate ratio implements local detailed balance. Channel currents are estimated from
signed event counts and scaled by the stated site concentration.

The two pathways share the same state change, so only their force difference drives
a stationary cycle current. The conductivity is therefore singular in the
redundant two-channel basis. For per-site rates \(\boldsymbol\kappa\) and site
concentration \(c_s\), the exact derivative is
\[
\mathbf L_{\mathrm{mock}}=\frac{c_s}{2R}\left[
\operatorname{Diag}(\boldsymbol\kappa)-
\frac{\boldsymbol\kappa\boldsymbol\kappa^{\mathsf T}}
{\sum_r\kappa_r}\right].
\]
It is symmetric positive semidefinite with a null direction corresponding to a
common shift in both channel forces. With a nonzero occupied-minus-vacant free-energy
gap \(\Delta G\), multiply this zero-gap expression by
\(\operatorname{sech}(\Delta G/(2RT))\); the evolving-trait example uses this
extension. This is a model-level molar conductivity
with units \(\mathrm{mol^2\,K\,J^{-1}\,m^{-3}\,s^{-1}}\), given the declared
site concentration and force convention; its parameter values are mock, not
empirical. The example estimates each column by independent \(\pm\) force
perturbations and reports Monte Carlo standard errors rather than imposing
symmetry or positive semidefiniteness.

With seed `20261027`, rates \([2,3]\ \mathrm{s^{-1}}\), site concentration
\(0.2\ \mathrm{mol\,m^{-3}}\), force step \(1\ \mathrm{J\,mol^{-1}\,K^{-1}}\),
1,000 sites, four replicates, and 400 s measurement windows, the estimated matrix
is approximately
\[
\widehat{\mathbf L}=\begin{bmatrix}
0.014490 & -0.014449\\
-0.014492 & 0.014446
\end{bmatrix},
\qquad
\mathrm{SE}\approx\begin{bmatrix}
0.000101 & 0.000080\\
0.000102 & 0.000083
\end{bmatrix}.
\]
The exact matrix has diagonal entries \(0.014433\) and off-diagonal entries
\(-0.014433\); the relative reciprocity residual in this run is 0.00211. The
estimated symmetric part has a minimum eigenvalue of \(-2.45\times10^{-6}\), small
relative to the Monte Carlo uncertainty; because the exact model has a zero mode,
finite sampling does not guarantee a positive estimated eigenvalue. This illustrates
why uncertainty and rank must be considered when testing semidefiniteness. The
example validates the estimator against a known reversible mock process; it does
not establish calibrated ecological conductivities or show that the existing
demographic jump model is thermodynamic.

### 5.5 Evolving Trait and Conditional Onsager Response

`examples/evolving_onsager_mock.jl` holds the scale distinction explicit. At each
epoch it advances the fast reversible Gillespie process for 200 s at zero applied
force, carrying the occupied-site count into the next epoch. It records that realized
occupancy alongside the equilibrium occupancy predicted by the current frozen trait.
It then estimates the local matrix from independently initialized, force-perturbed
trajectories at that same fixed trait; the 40 s response window and 2 s burn-in are
not a response estimate of the nonstationary trait trajectory itself.

The illustrative trait update is
\[
\theta_{k+1}=\theta_k+s(\theta_*-\theta_k)+\sigma\xi_k,
\qquad \xi_k\sim\mathcal N(0,1),
\]
with \(s=0.05\), \(\theta_*=0.8\), and \(\sigma=0.005\). It is an imposed slow
meta-process, not a mechanistic evolutionary or thermodynamic model. Here the frozen
fast relaxation rate is \(\sum_r\kappa_r\,2\cosh(\theta/2)\), above 10 s\(^{-1}\)
over the displayed trait range (relaxation time below 0.1 s). The nominal trait
e-folding time from the deterministic update is about 20 epochs, or 4,000 s. These
mock scales make \(\tau_{\rm mix}\ll40\,\mathrm{s}\ll\tau_{\rm evo}\) plausible;
they do not demonstrate that real biological processes have this separation.

For seed `20261028`, 12 epochs, 600 sites, site concentration
\(0.2\,\mathrm{mol\,m^{-3}}\), three response replicates, and a force step of
\(1\,\mathrm{J\,mol^{-1}\,K^{-1}}\), the run produced the following local estimates.
Conductivity entries and standard errors are in
\(\mathrm{mol^2\,K\,J^{-1}\,m^{-3}\,s^{-1}}\):

| Epoch | Trait | Realized occupancy | Frozen equilibrium occupancy | Estimated L11 | Exact frozen L11 | MC SE(L11) |
|---:|---:|---:|---:|---:|---:|---:|
| 1 | -0.8000 | 0.6700 | 0.6900 | 0.010814 | 0.010398 | 0.000344 |
| 2 | -0.7206 | 0.6733 | 0.6727 | 0.011068 | 0.011099 | 0.000627 |
| 3 | -0.6436 | 0.6550 | 0.6556 | 0.011550 | 0.011766 | 0.000625 |
| 4 | -0.5675 | 0.6317 | 0.6382 | 0.012613 | 0.012398 | 0.000552 |
| 5 | -0.4976 | 0.6150 | 0.6219 | 0.012762 | 0.012945 | 0.000312 |
| 6 | -0.4253 | 0.5817 | 0.6048 | 0.013901 | 0.013464 | 0.000869 |
| 7 | -0.3728 | 0.5950 | 0.5921 | 0.013940 | 0.013806 | 0.000531 |
| 8 | -0.3137 | 0.6200 | 0.5778 | 0.013328 | 0.014149 | 0.000515 |
| 9 | -0.2601 | 0.6217 | 0.5647 | 0.014849 | 0.014417 | 0.000654 |
| 10 | -0.2022 | 0.5333 | 0.5504 | 0.015285 | 0.014657 | 0.000514 |
| 11 | -0.1528 | 0.5867 | 0.5381 | 0.014594 | 0.014817 | 0.000602 |
| 12 | -0.1086 | 0.5083 | 0.5271 | 0.015181 | 0.014924 | 0.000980 |

The estimated response changes with the trait and broadly follows the analytic
frozen-state value within its replicate Monte Carlo error. Realized occupancy
fluctuates around (and occasionally departs visibly from) the conditional equilibrium
fraction; this is a finite-site stochastic diagnostic, not evidence for or against
global balance. The imposed trait update has no reverse thermodynamic transitions or
energy/work accounting, so the combined evolution is expressly not claimed to obey
detailed balance. The example demonstrates how to express an evolving conditional
conductivity and what scale-separation assumptions to inspect, not how to infer a
biological evolutionary conductivity from population counts alone.

---

## 6. Results and Case Studies

### 6.1 Body-Size Trade-offs

The code can vary an allometric exponent in a parameterization, but it does not
simulate or establish general size-spectrum trade-offs. Such hypotheses require
specified metabolic data and empirical testing.

### 6.2 Northwest Atlantic Cod Collapse

The Northwest Atlantic cod collapse is a historical ecological case, but this
repository contains no cod time series, fitted model, or estimated \(\mathcal A\).
The proposed relationship between cod depletion and reciprocity loss is therefore
a hypothesis requiring data and independent testing, not a result established by
this implementation.

---

## 7. Discussion

The implementation now distinguishes raw interaction diagnostics from a
conditional OU covariance-weighted drift estimate. Neither is automatically a physical
conductivity or entropy-production estimate. The stochastic and agent simulations
are simplified models; their outputs require input checks, extinction handling,
and sensitivity analysis before ecological interpretation.

---

## 7.1 Sensitivity and Limitations

**Sensitivity.** `sensitivity_allometry` explores how one parameterization changes
when the exponent \(k\) varies. It does not estimate \(k\), establish an allometric
law, or support resilience/resistance conclusions.

**Limitations.**
1. No physical entropy Hessian is inferred from biomass composition.
2. Weighted interaction and biomass-Jacobian matrices are descriptive diagnostics,
   not empirically validated Onsager conductivities.
3. The population response estimate depends on the stationary Gaussian OU model;
   detailed-balance diagnostics are not a formal test and uncertainty is not yet
   propagated through the matrix logarithm.
4. Reciprocity/asymmetry alone does not establish causality or identify a tipping
   point.
5. The agent model and stochastic event channels are simplified assumptions; the
   code does not prove conservation laws or biological realism.
6. Bayesian state-space estimation, nonlinear population response, and spatial
   models in earlier project notes are not implemented in this source file.

## 8. Conclusion

The current implementation provides biomass-based ecological simulations and
matrix diagnostics. The fraction-weighted Jacobian and allometric variants are
explicit model choices; they should not be interpreted as physical Onsager
conductivities or entropy production without further derivation and validation.
The routines that are implemented, and the larger set of methods that remain
proposals, are distinguished above.

---

## References

Consolidated from project notes; primary sources include Onsager (1931),
Prigogine, Landsberg (1972), Choi & Hansell (2023/2024), Kleiber (1947),
May (1972), Neutel et al. (2002), Ulanowicz (1986), Patten (1978/1985),
Mikulecky (1993), Oster, Perelson & Katchalsky (1973), Jaynes (1957),
Dewar (2010), England (2013), Crooks (1999), Nicolis & Prigogine (1989),
Watson & Lovelock (1983), Halbach (1973), Schrödinger (1944).
