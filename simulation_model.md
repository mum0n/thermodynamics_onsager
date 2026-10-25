# Onsager Networks in Ecology: A Non-Equilibrium Thermodynamic Framework

**Authors:** Consolidated research notes (thermodynamics_onsager project)
**Date:** 2026

---

## Abstract

This paper develops a physics-based framework for ecological dynamics grounded in
non-equilibrium thermodynamics. By adopting an intensive local approach within an
arbitrarily small biovolume element (\(\ddagger\)), we resolve the boundary and
volume ambiguities that plague extensive ecological thermodynamics. Thermodynamic
forces \(X\) and fluxes \(J\) are coupled through a phenomenological conductivity
matrix \(L\) (Onsager relations), unifying population ecology and thermodynamics
via \(\mathbf L=-\mathbf A\,\mathbf g^{-1}\). Its symmetry (\(L_{ij}=L_{ji}\))
is a necessary (but not sufficient) consistency condition for mechanistic
coupling and its breaking signals regime shifts. Allometric scaling
(\(R/B \propto M^{-0.25}\)) anchors conductivities to body size, producing a
resilience–resistance trade-off. We present mathematical derivations, empirical
estimation procedures (Bayesian state-space and time-lagged VAR), and
computational implementations (linear/non-linear simulators, agent-based models,
stochastic simulation, spatiotemporal lattices). All runnable code is consolidated
in `src/onsagernetwork.jl`.

---

## 1. Introduction

Ecology has long lacked a unifying physical framework. Traditional models rely on
phenomenological regression or isolated Lotka–Volterra formulations, while
thermodynamic attempts (Lindeman, Odum, Kay, Aoki) applied extensive,
whole-system accounting that fails for open ecosystems with ill-defined boundaries
and fluctuating biovolumes (Meysman & Bruers, 2010).

This work adopts the intensive local formulation of Prigogine and Landsberg's 4th
Law: restrict analysis to an arbitrarily small volume element \(\ddagger\) where a
local semi-stable equilibrium holds. Within this element, linear Onsager
relations become applicable, and entropy production is evaluated per unit
biovolume, removing extensive boundary artifacts.

**Contributions.**
1. A rigorous mapping from ecological community matrices \(A\) to thermodynamic
   conductivity matrices \(L\).
2. An allometric anchoring of conductivities to body size.
3. A reciprocity/asymmetry diagnostic (necessary but not sufficient) for
   mechanistic coupling and tipping points.
4. Consolidated computational implementations in `src/onsagernetwork.jl`.

---

## 2. Theoretical Framework

### 2.1 Macroscopic vs. Microscopic Thermodynamics

Classical thermodynamics (Carnot, Clausius) tracks extensive state variables
across rigid boundaries; statistical mechanics (Boltzmann, Gibbs) counts
microstates. Open ecosystems break both: boundaries are permeable, transformations
are uncountably many, and biovolume fluctuates by orders of magnitude.
Schrödinger's order taxonomy resolves the apparent paradox of biological order:

- **Order \(\to\) Disorder:** entropic decay (Second Law).
- **Order \(\to\) Order:** dissipative structures maintaining local order by
  exporting entropy.
- **Disorder \(\to\) Order:** self-organization and evolutionary complexification.

### 2.2 Intensive Local Approach (\(\ddagger\)) and Landsberg's 4th Law

For a local biovolume element, total entropy change decomposes as

\[
dS^{\ddagger} = d_i S^{\ddagger} + d_e S^{\ddagger},
\]

where \(d_i S^{\ddagger}\ge 0\) is internal production and \(d_e S^{\ddagger}\) is
exchange across the boundary. Landsberg's 4th Law asserts well-defined intensive
(density) variables for near-equilibrium non-equilibrium states, so that within a
small element forward/backward rates are locally balanced, justifying linearization.

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

Reciprocity is a *necessary but not sufficient* condition for mechanistic
coupling: it holds only near equilibrium under microscopic reversibility, and
satisfying it does not by itself establish causality (physiological perturbation
experiments are still required).

Internal entropy production

\[
\sigma^{\ddagger} = \sum_i J_i X_i = \mathbf X^{\mathsf T}\mathbf L\mathbf X \ge 0
\]

requires \(\mathbf L\) positive definite, hence \(L_{ii}>0\) (self-damping, Le
Chatelier–Braun). Off-diagonal \(L_{ij}\) are conjugate effects: a force in
process \(j\) drives flux in process \(i\), dissipating perturbations through
cross-coupling.

### 2.4 Allometric Scaling and the Resilience–Resistance Trade-off

Mass-specific metabolism scales as \(R/B \propto M^{-k}\) with \(k\approx 0.25\)
(Kleiber, 1947). Thus specific entropy production per unit biovolume,
\(\sigma^{\ddagger}/V\), is high for small organisms and low for large ones. This
creates a fundamental trade-off:

**Caveat.** The exponent is not universal: empirical estimates range from
\(k\approx 0.2\) to \(0.33\) depending on taxon, temperature, and activity
(White & Seymour, 2003; Glazier, 2005, 2010). Results that depend on
\(M^{-k}\) (conductivity magnitudes, resilience rankings) are sensitive to this
choice; sensitivity analysis over \(k\in[0.2,0.33]\) is recommended. The
structural (resistance) conclusions are less sensitive because they depend on
\(b_i\), not on \(k\).

- **Small-bodied (high \(R/B\)):** high conductivity \(L\), high resilience, low
  resistance (e.g., plankton, microbes).
- **Large-bodied (low \(R/B\)):** low conductivity, high resistance (biomass
  buffer), low resilience (e.g., forests, apex predators).

Net primary production (NPP) sets a lower bound \(R \gg \mathrm{NPP}\) for
community respiration.

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
| \(M_i\) | Individual body mass of class \(i\) (kg) |
| \(B_i=M_i N_i\) | Biomass of class \(i\) |
| \(V=\sum_i B_i\) | Total biovolume (biomass) |
| \(b_i=B_i/V\) | Intensive biovolume concentration (\(\sum b_i=1\)) |
| \(\alpha_i=\tilde N_i-1\) | Normalized fluctuation (\(\tilde N_i=N_i/N_i^*\)) |
| \(X_i=\alpha_i\) | Deviation force (positive above equilibrium) |
| \(\mathcal X_i=-X_i\) | Thermodynamic (restoring) force |
| \(\mathbf g\) | Entropic stiffness proxy (\(\mathrm{Diag}(1/b_i)\)) |
| \(\mathbf A\) | Community (Jacobian) matrix |
| \(\mathbf L,\mathbf L_{\rm raw}\) | Conductivity (pd part) and raw ecological conductivity |
| \(\sigma^{\ddagger}\) | Specific entropy production rate |
| \(\mathcal A_F\) | Frobenius asymmetry index |
| \(\ddagger\) | Intensive local volume element |

### 3.1 Dynamic Biovolume Normalization

For \(n\) species/size classes with individual mass \(M_i\) and abundance \(N_i(t)\),
the dynamic biovolume is

\[
V(t)=\sum_{i=1}^n M_i N_i(t),\qquad
b_i(t)=\frac{M_i N_i(t)}{V(t)},\qquad \sum_i b_i(t)=1.
\]

The intensive concentration \(b_i\) is invariant to spatial expansion/contraction.

### 3.2 Entropic Stiffness

\[
\mathbf g(t)=\mathrm{Diag}\!\left(\frac{1}{b_1(t)},\dots,\frac{1}{b_n(t)}\right).
\]

As \(b_i\to 0\), \(g_{ii}\to\infty\), imposing extreme resistance to further
deviation.

**Physical entropy and Hessian.** The natural physical entropy for the biovolume
composition is the mixing entropy

\[
S_{\rm mix} = -\sum_{i=1}^{n} b_i\ln b_i,
\qquad \sum_i b_i = 1.
\]

In fraction coordinates \(b_i\) (constrained to the simplex), its Hessian is
\(\partial^2 S/\partial b_i\partial b_j = -\delta_{ij}/b_i\), so

\[
g_{ii}= -\frac{\partial^2 S}{\partial b_i^2}= \frac{1}{b_i}
\]

is *exact* (diagonal), not an approximation. The earlier off-diagonal caveat
applies only when the state variables are raw counts \(N_i\) with a variable
total \(N_{\rm tot}\). Note that because the \(b_i\) are constrained
(\(\sum b_i=1\)), the Hessian is singular; Onsager's construction requires
independent coordinates (e.g. drop one species), and the diagonal form is the
pseudo-inverse/coordinate form used here. The code labels this quantity
\texttt{entropic\_stiffness}.

**Dimension.** Because \(b_i\) is dimensionless (\(\sum b_i=1\)), \(g_{ii}=1/b_i\)
is dimensionless. If the state variable is biomass (units kg), a physical
\(g\) would carry units \(1/\text{kg}\); the dimensionless form here is a
normalized proxy and the conductivity \(L=-A\,g^{-1}\) inherits its units from
\(A\) ([1/time]). Interpret magnitudes only in relative terms.

### 3.3 Allometrically Scaled Conductivity Matrix

Given raw interaction matrix \(A_{\mathrm{raw}}\),

\[
A_{\mathrm{intensive}}=\mathrm{Diag}(M_i^{-0.25})\,A_{\mathrm{raw}},\qquad
L_{ij}(t)=M_i^{-0.25}\,A_{\mathrm{raw},ij}\,b_j(t).
\]

Equivalently \(\mathbf L = A_{\mathrm{intensive}}\,\mathbf g^{-1}\). Here column
\(j\)'s concentration \(b_j\) weights flux origin, and row \(i\)'s mass sets
processing rate.

**Note on reciprocity units.** The quantities above are in *ecological* units
(biomass, individuals, mass-specific rates). Strict Onsager reciprocity
\(L_{ij}=L_{ji}\) is only expected after nondimensionalisation to *entropy*
units (i.e. after expressing fluxes and forces in terms of specific entropy
production per unit biovolume). In raw ecological units \(L\) is therefore only
*approximately* symmetric; the departure is quantified by the asymmetry index
\(\mathcal A_F\) (Section 3.5). The code exposes both the raw ecological
conductivity (\texttt{L\_raw}) and its positive-definite symmetric part
(\texttt{L\_matrix}) for diagnostics and dynamics respectively.

### 3.4 Thermodynamic Forces and Entropy Production

Reference abundances \(\mathbf N^*\). Dimensionless deviation (force)

\[
X_i(t)=\frac{N_i(t)-N_i^*}{N_i^*}.
\]

Let \(\mathcal X=-\mathbf X\) be the thermodynamic (restoring) force. Then
\(\dot{\mathbf N}=\mathbf L\mathcal X=-\mathbf L\mathbf X\) with \(\mathbf L\succ 0\),
and specific entropy production

\[
\sigma^{\ddagger}(t)=\mathcal X^{\mathsf T}\mathbf L\mathcal X
=\mathbf X^{\mathsf T}\mathbf L\mathbf X
=\sum_{i,j} L_{ij}X_i X_j \ge 0.
\]

(Here \(\mathbf X\) is the positive deviation; \(\mathcal X\) is the
thermodynamic force.) Near equilibrium, \(\sigma^{\ddagger}\) is minimized (least
specific dissipation).

### 3.5 Conductivity Asymmetry

The **Matrix Asymmetry Index**

\[
\mathcal A_F = \frac{\|\mathbf L-\mathbf L^{\mathsf T}\|_F}{\|\mathbf L\|_F}\in[0,2],
\]

with \(\mathcal A_F=0\) at reciprocity and \(\mathcal A_F\to 2\) when
\(\mathbf L\) is fully skew-symmetric (extreme non-reciprocity). Pairwise:

\[
a_{ij}=\frac{L_{ij}-L_{ji}}{|L_{ij}|+|L_{ji}|}\in[-1,1].
\]

Decomposition \(\mathbf L=\mathbf L_{\mathrm{sym}}+\mathbf L_{\mathrm{skew}}\)
separates dissipative (symmetric) from circulatory (skew-symmetric) dynamics;
skew eigenvalues are purely imaginary \(\pm i\omega\).

### 3.6 Mapping Community Matrix \(A\) to \(L\) (canonical estimator)

Standard Jacobian community matrix \(\mathbf A\) (\(d\boldsymbol\alpha/dt=\mathbf A\boldsymbol\alpha\))
maps to conductivity via

\[
\mathbf L = -\mathbf A\,\mathbf g^{-1}.
\]

(negative sign under the convention \(X=-(N-N^*)/N^*\), \(L\succ 0\)).
Equivalently \(\mathbf g=\mathbf L^{-1}\mathbf A\). **This Jacobian route is the
canonical, empirically estimable definition of \(L\).** If no valid \(\mathbf g\)
symmetrizes \(\mathbf A\), the interactions are non-conjugate (spurious or in
regime shift).

A second, *parameterization-only* route appears in `intensive_thermodynamics`,
where \(L\) is built from a raw interaction matrix \(A_{\rm raw}\) as
\(L=-\mathrm{Diag}(M^{-0.25})A_{\rm raw}\mathrm{Diag}(b)\). This is a
simulation convenience for generating synthetic conductivities and is **not** the
empirical estimator; the two should not be conflated.

### 3.8 Spectral Relationships

\(L=AD\) (with \(D=\mathrm{diag}(B)\)) is similar to \(D^{1/2}AD^{1/2}\),
preserving eigenvalue signs. Biomass acts as a spectral filter weighting
high-biomass interactions. Eigenvalues of \(L\) are principal conductivities;
eigenvectors are metabolic guilds/channels.

---

### 3.7 Dimensional Analysis and Normalization Checklist

A common source of error is mixing abundance, biomass, and normalized (dimensionless)
state variables. The following checklist and dimensional analysis keep the
quantities consistent.

**State variable choice.** Pick one and do not mix:
- Abundance \(N_i\) (individuals), or
- Biomass \(B_i = M_i N_i\) (kg), or
- Normalized (dimensionless) \(\tilde N_i = N_i/N_i^*\).

**Checklist.**
1. Normalize abundances by reference: \(\tilde N_i = N_i/N_i^*\), so
   \(\alpha_i = \tilde N_i - 1\) and \(X_i = \alpha_i\) are dimensionless
    (positive deviation; \(\mathcal X=-X_i\) is the thermodynamic force).
2. Community matrix \(\mathbf A = \partial \dot{\tilde N}_i/\partial \tilde N_j\)
   must have units [1/time]. If using raw counts, divide through by \(N_i^*\).
3. Biovolume concentration \(b_i = B_i/\sum_k B_k\) is dimensionless and
   \(\sum_i b_i = 1\); mass units cancel.
4. Stiffness proxy \(g_{ii}=1/b_i\) is dimensionless (proxy, not a physical
   Hessian unless derived).
5. Conductivity \(\mathbf L = -\mathbf A\,\mathbf g^{-1}\) has units [1/time];
   \(J_i = \dot{\tilde N}_i = L_{ij}X_j\) is [1/time], consistent.
6. Entropy production \(\sigma = X^{\mathsf T} L X\) has units [1/time]; for
   *specific* (per unit biovolume) production divide by \(V\) or use intensive
   variables.
7. Allometric factor \(M_i^{-0.25}\) must be applied **once** — either inside
   \(\mathbf A\) or inside \(\mathbf L\), never both.
8. Body masses \(M_i\) must use consistent units (kg) throughout; they cancel in
   \(b_i\) but not in the allometric factor.

**Dimensional summary.**

| Quantity | Symbol | Units | Notes |
|---|---|---|---|
| Abundance | \(N_i\) | individuals | or biomass |
| Body mass | \(M_i\) | kg | consistent units |
| Biovolume | \(V\) | kg (biomass) | \(\sum M_i N_i\) |
| Concentration | \(b_i\) | dimensionless | \(M_i N_i/V\), sums to 1 |
| Stiffness (proxy) | \(g_{ii}\) | dimensionless | \(1/b_i\) |
| Community matrix | \(A_{ij}\) | 1/time | Jacobian of normalized state |
| Conductivity | \(L_{ij}\) | 1/time | \(-A\,g^{-1}\) |
| Force (deviation) | \(X_i\) | dimensionless | \((N_i-N_i^*)/N_i^*\) |
| Flux | \(J_i\) | 1/time | \(\dot{\tilde N}_i\) |
| Entropy production | \(\sigma\) | 1/time | \(X^{\mathsf T} L X\) |

Failure to normalize (e.g., using raw counts in \(A\) while using dimensionless
\(X\)) produces conductivities with mixed units and invalidates the asymmetry
index \(\mathcal A_F\).

## 4. Empirical Estimation

### 4.1 Data Ingestion

Raw census counts \(N_i(t)\) convert to intensive density \(b_i=M_i N_i/V\).
Zero counts are imputed via temporal neighbors.

### 4.2 Bayesian State-Space (Turing.jl)

Latent biovolume \(\mathbf b(t)\) propagates as

\[
\log \mathbf b(t+1)\sim \mathcal N(\log[\mathbf b(t)+\mathbf L\mathbf X(t)],\mathbf Q),
\]

with LogNormal observations \(y(t)\). Diagonal \(L_{ii}>0\) (exponential priors)
enforces self-dampening; off-diagonals normal priors. NUTS (HMC) samples the
posterior. Matérn 3/2 GP kernels interpolate spatial fields.

### 4.3 Time-Lagged VAR Reconstruction

Fit VAR(\(p\)) to force series \(\mathbf X(t)\); reconstruct \(L(\tau)\) and
compute \(\mathcal A(\tau)\) via Frobenius norms. **Proxy caveat.** The mapping
\(\Phi\mapsto L(\tau)=\mathrm{Diag}(M^{-0.25})\Phi\,\mathrm{Diag}(b)\) is an
*empirical proxy*, not a derived identity: \(\Phi\) is a discrete-time
propagator, not a continuous-time force-flux derivative, and the allometric
weighting is heuristic. Treat \(L(\tau)\) as a monitoring indicator, not a
quantitative conductivity estimate. For quantitative estimation prefer
continuous-time SDE/state-space methods (Section 4.2). Because spikes can arise
from sampling noise, time-lag mismatch, or non-stationarity as well as from
genuine regime shifts, \(\mathcal A(\tau)\) must be reported with confidence
intervals and compared against an empirical null (permutation) distribution, and
a tipping signal requires persistence across multiple consecutive windows (see
\texttt{persistent\_asymmetry}, \texttt{asymmetry\_null} in
\texttt{src/onsagernetwork.jl}).

### 4.4 Asymmetry Remediation

Vulnerabilities (sampling noise, latent forcing, over-parameterization,
far-from-equilibrium non-linearities) are addressed via high-frequency sensing,
GP forcing terms, regularizing priors (Horseshoe), and physics-informed Neural
ODEs with entropic loss penalties.

---

## 5. Computational Models

All code is in `src/onsagernetwork.jl`.

### 5.1 Linear Three-Species Simulator

Three species (two prey, one predator) near a stationary state; \(L\) symmetrized
to enforce reciprocity; tracks biomass, forces, fluxes, and
\(\sigma^{\ddagger}\) toward minimum.

### 5.2 Non-Linear Simulator

Introduces state-dependent saturation \(L\propto 1/(1+0.05\|X\|)\) and a
threshold breaking of reciprocity (\(\|X\|>15\)) producing asymmetric feedback
and regime shift ("order through fluctuation").

### 5.3 Individual-Based Model (IBM)

Agents carry mass; metabolic dissipation \(M^{0.75}\); aggregation into
size-class cohorts yields Jacobian \(A\), entropy metric \(g\), and \(L\).
Turing.jl state-space filters observation noise.

### 5.4 Stochastic Simulation (Gillespie SSA)

Discrete jump Markov processes with mass-conserving predation stoichiometry

\[
k_{\text{prey}}=\left\lceil \frac{M_i}{\epsilon M_j}\right\rceil.
\]

Demographic noise \(\propto 1/\sqrt{N_i}\) drives extinction in low-density
classes and early tipping before deterministic thresholds.

### 5.5 Spatiotemporal Lattice

2D reaction-diffusion grid coupling local thermodynamic reactions with spatial
diffusion; computes spatial \(\mathcal A(x,y)\) fields revealing thermodynamic
hotspots.

---

## 6. Results and Case Studies

### 6.1 Body-Size Trade-offs

Size spectra stratify conductivities: small organisms are high-throughput
dissipative channels (high-frequency fluctuations), large organisms are
structural reservoirs (low-frequency pulses).

### 6.2 Northwest Atlantic Cod Collapse

Pre-collapse: symmetric reciprocity, high \(g\), \(\mathcal A\approx 0\).
Overharvesting of large cod truncated the size spectrum, broke conjugate
self-dampening, inverted feedbacks, spiked \(\mathcal A\), and drove a
non-equilibrium transition (1992) to a small-pelagic/invertebrate alternative
state that has not recovered despite moratoriums.

---

## 7. Discussion

**Unification of biological and thermodynamic descriptions.** The central
unification is the map \(\mathbf L=-\mathbf A\,\mathbf g^{-1}\): a biological
community matrix \(\mathbf A\) (population Jacobian) is converted into a
thermodynamic conductivity matrix \(\mathbf L\) by the entropy metric
\(\mathbf g\). In one step, population ecology's interaction coefficients become
energy-transformation conductivities, and the Le Chatelier–Braun principle
becomes quantitative Onsager reciprocity. This bridges "counting individuals"
and "measuring the conductivity of a power grid"; all other results (size
trade-offs, asymmetry diagnostics, tipping-point signals) follow from it.

The framework offers a mechanistic consistency check beyond correlation:
reciprocity is a necessary (but not sufficient) condition for conjugate coupling,
to be combined with physiological perturbation experiments; it is not by itself
proof of causality. Intensive local analysis
resolves boundary ambiguity; allometry provides a physical anchor (analogous to
Boltzmann's constant). Early-warning metrics (\(\mathcal A\) spikes, perturbation
spectra) enable pre-emptive management. Far-from-equilibrium, linear \(L\) fails
and non-linear/Neural-ODE frameworks are required.

---

## 7.1 Sensitivity, Hybrid Solvers, and Limitations

**Sensitivity.** Conductivity magnitudes and resilience rankings depend on the
allometric exponent \(k\); Section 2.4 recommends sensitivity analysis over
\(k\in[0.2,0.33]\) (see `sensitivity_allometry` in `src/onsagernetwork.jl`).
Structural (resistance) conclusions depend on \(b_i\) and are less sensitive.
The stiffness proxy \(g\) and the choice of entropy function (mixing entropy vs.
alternatives) also affect magnitudes.

**Limitations.**
1. **Linear regime only.** Onsager relations and minimum entropy production apply
   near local stationary states; far-from-equilibrium dynamics require non-linear
   frameworks (Neural ODEs, variational methods).
2. **Information vs. physical entropy.** The \(g\)-matrix is a proxy; a physical
   entropy function must be specified for quantitative claims.
3. **Causality not proven.** Reciprocity is necessary but not sufficient; physiological
   perturbation experiments are required.
4. **Biological interpretations are hypotheses.** Case studies (cod collapse,
   Gaia) are illustrative, not quantitative validations.
5. **Scalability.** Exact SSA is costly for large systems; hybrid/tau-leaping
   approximations are provided but introduce approximation error.
6. **Parameterization vs. estimation.** The interaction-matrix route is a
   simulation convenience, not an empirical estimator.

## 8. Conclusion

Non-equilibrium thermodynamics, allometric scaling, and computational modeling
transform ecology into a predictive physical science. Key pillars: intensive
local state (\(\ddagger\)), Onsager reciprocity, allometric anchoring, asymmetry
diagnostics, and biomass-normalized conductivities. All implementations reside in
`src/onsagernetwork.jl`.

---

## References

Consolidated from project notes; primary sources include Onsager (1931),
Prigogine, Landsberg (1972), Choi & Hansell (2023/2024), Kleiber (1947),
May (1972), Neutel et al. (2002), Ulanowicz (1986), Patten (1978/1985),
Mikulecky (1993), Oster, Perelson & Katchalsky (1973), Jaynes (1957),
Dewar (2010), England (2013), Crooks (1999), Nicolis & Prigogine (1989),
Watson & Lovelock (1983), Halbach (1973), Schrödinger (1944).
