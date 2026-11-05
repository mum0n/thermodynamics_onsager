---
title: "Reconciling Ecological Population Dynamics with Non-Equilibrium Thermodynamics: III. Theoretical Extensions and Interdisciplinary Foundations"
author:
- name: Jae S. Choi
  footnote: 1
  corresponding: true
  email: choi.jae.seok@gmail.com
  orcid: 0000-0003-3632-5723
affiliation:
- number: 1
  name: Bedford Institute of Oceanography, Fisheries and Oceans Canada, Dartmouth, Nova Scotia, Canada
date: '\today'
journal: 'biorxiv'
keyword: |
  Keywords: Onsager Reciprocal Relations, Community Matrix, Phenomenological Conductivity, Fluctuation-Dissipation, Probability Circulation, Detailed Balance, Biomass Capacitance, Resistance, Resilience, Energy Dissipation Cascade, Quasi-Potential Landscape, Helmholtz-Hodge Decomposition, Circuit Theory, Information Geometry, Regime Shifts
abstract: |
  We complete the mathematical foundations discussed in Parts I and II: the continuous Lyapunov covariance factorization that decomposes demographic dynamics into irreversible dissipation and cyclic circulation; the coordinate-invariance proofs establishing that all thermodynamic scalars are independent of state-variable parametrization; the extremum dissipation principles governing clamped-force versus clamped-flux boundary conditions; and the explicit derivation of the stationary entropy production trace formula from Fokker-Planck probability currents. Second, we extend the framework into the non-linear regime, developing the quasi-potential landscape formalism, the Helmholtz-Hodge decomposition of non-linear ecological drift, and quantitative early-warning diagnostics for fold and Hopf bifurcations from capacitance stripping. Third, we establish interdisciplinary connections to electrical circuit theory (Tellegen gyrators and RLC oscillators), information geometry (Fisher metric and Helmholtz-Hodge decomposition), cybernetic feedback control (Bode sensitivity integral and waterbed effect), and stochastic thermodynamics.

  Together, Parts II and III demonstrate that ecological communities are not merely analogous to non-equilibrium thermodynamic systems—they *are* non-equilibrium thermodynamic systems, governed by the same principles of dissipation, fluctuation, and stability that govern physical processes far from equilibrium.
---

# Introduction

Choi and Hansell 2026 and Choi 2026 demonstrated that the demographic community matrix of an ecological food web can be decomposed into a symmetric Onsager dissipative conductivity and an antisymmetric probability circulation tensor through continuous Lyapunov covariance factorization. That work established the Resistance-Resilience trade-off continuum across contrasting aquatic biomes—from detritus-buffered benthic cold springs to solar-driven open-ocean plankton communities—and showed how anthropogenic exploitation strips slow biomass capacitance, elevating probability circulation volatility and entropy production toward oscillatory instability.

This paper completes the theoretical architecture that makes this empirical framework coherent. It develops three interconnected strands:

1. **Foundations (Sections 1–4):** The complete mathematical derivation of the Lyapunov covariance factorization, including coordinate-invariance proofs, extremum dissipation principles, and the explicit stationary entropy production trace formula from Fokker-Planck probability currents. These results show that the demographic-to-thermodynamic mapping is not merely an analogy but an exact tensorial identity, invariant under arbitrary linear coordinate transformations.

2. **Non-linear regime (Section 5):** Extension of the linear Onsager framework into non-linear phase space through the quasi-potential landscape formalism, the Helmholtz-Hodge decomposition of non-linear ecological drift, and quantitative early-warning diagnostics for fold and Hopf bifurcations. This provides the theoretical machinery for detecting regime shifts before they occur.

3. **Interdisciplinary connections (Section 6):** Bridging to electrical circuit theory (Tellegen gyrators and RLC oscillators), information geometry (Fisher metric), cybernetic feedback control (Bode sensitivity integral and waterbed effect). These connections demonstrate that ecological stability is governed by the same universal principles that govern physical, chemical, and engineering systems far from equilibrium.

Together, Parts II and III show that ecological communities are not merely analogous to non-equilibrium thermodynamic systems—they *are* non-equilibrium thermodynamic systems, governed by the same principles of dissipation, fluctuation, and stability that govern physical processes far from equilibrium.

# 1. Baseline Constitutive Operators and Lyapunov Factorization

The foundational derivations connecting the demographic community matrix $\mathbf{A}$ to the Onsager conductivity matrix $\mathbf{L}$ and the Le Chatelier-Braun Schur complement are established in the companion paper (Choi and Hansell 2026, Appendices A and B) and are summarized here to fix notation for the extensions that follow. For an open ecological network with $n$ extensive state deviations $\delta\mathbf{x} = \mathbf{x} - \mathbf{x}^*$ around a stationary state $\mathbf{x}^*$, the second-order expansion of total entropy change is $\Delta S_{\mathrm{tot}}(\delta\mathbf{x}) = -\frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{H}\delta\mathbf{x}$, where $\mathbf{H} = -\left.\partial^2\Delta S_{\mathrm{tot}}/\partial\mathbf{x}^2\right|_{\mathbf{x}^*} = \mathbf{H}^{\mathsf{T}} \succ 0$ is the symmetric positive-definite entropy Hessian. Conjugate thermodynamic forces $\mathbf{X} = \nabla_{\delta\mathbf{x}}\Delta S_{\mathrm{tot}} = -\mathbf{H}\delta\mathbf{x}$ are related to the stationary Gaussian fluctuation covariance $\mathbf{C} = \langle\delta\mathbf{x}\delta\mathbf{x}^{\mathsf{T}}\rangle = k_{\mathrm{B}}\mathbf{H}^{-1}$ (with effective grain scale $k_{\mathrm{B}}$; Einstein 1910, Callen 1985). Under linear Ornstein-Uhlenbeck dynamics $d\delta\mathbf{x} = \mathbf{A}\delta\mathbf{x}\,dt + \sqrt{2\mathbf{D}}\,d\mathbf{W}_t$, stationary covariance balance $\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} + 2\mathbf{D} = \mathbf{0}$ yields the unique decomposition $-\mathbf{A}\mathbf{C} = k_{\mathrm{B}}\mathbf{L} = \mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega}$, where $\mathbf{D}_{\mathrm{sym}} = -\frac{1}{2}(\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}}) = \mathbf{D} = k_{\mathrm{B}}\mathbf{L}_s \succ 0$ is the symmetric dissipative operator and $\boldsymbol{\Omega} = \frac{1}{2}(\mathbf{C}\mathbf{A}^{\mathsf{T}} - \mathbf{A}\mathbf{C}) = k_{\mathrm{B}}\mathbf{L}_a = -\boldsymbol{\Omega}^{\mathsf{T}}$ is the skew-symmetric circulation tensor.

Under primary-secondary partitioning of $\mathbf{L}$ into a perturbed process $i$ and secondary coupled processes $-i$, free secondary relaxation ($\delta\mathbf{J}_{-i} = \mathbf{0} \implies \delta\mathbf{X}_{-i} = -\mathbf{L}_{-i,-i}^{-1}\mathbf{L}_{-i,i}\delta X_i$) yields the matrix Schur complement (Schur 1917, Prigogine and Defay 1954, Horn and Johnson 2012; Choi and Hansell 2026, Appendix B):

$$L_{ii,\mathrm{eff}} = L_{ii} - \mathbf{L}_{i,-i}\mathbf{L}_{-i,-i}^{-1}\mathbf{L}_{-i,i} > 0$$

which moderates force perturbations under direct symmetric cross-coupling ($0 < L_{ii,\mathrm{eff}} \le L_{ii}$ for $\mathbf{L}_{s;i,-i} = \mathbf{L}_{s;-i,i}^{\mathsf{T}}$) and reduces stationary compliance under cyclic indirect cross-coupling ($0 < L_{ii,\mathrm{eff}}^{-1} \le L_{ii}^{-1}$ for $\mathbf{L}_{a;i,-i} = -\mathbf{L}_{a;-i,i}^{\mathsf{T}}$). In extensive state space, the quadratic Lyapunov availability functional $V(\delta\mathbf{x}) = \frac{1}{2}\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\delta\mathbf{x} = -\Delta S_{\mathrm{tot}}(\delta\mathbf{x})/k_{\mathrm{B}} > 0$ satisfies $\mathbf{C}^{-1}\mathbf{A} = -\mathbf{C}^{-1}(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{C}^{-1}$ and $\mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} = -\mathbf{C}^{-1}(\mathbf{D}_{\mathrm{sym}} - \boldsymbol{\Omega})\mathbf{C}^{-1}$ (since $\boldsymbol{\Omega}^{\mathsf{T}} = -\boldsymbol{\Omega}$), so the skew-symmetric circulation cancels identically in the sum $\mathbf{C}^{-1}\mathbf{A} + \mathbf{A}^{\mathsf{T}}\mathbf{C}^{-1} = -2\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}$, yielding monotonic downhill relaxation (Lyapunov 1892, Tomita and Tomita 1974):

$$\dot{V}(\delta\mathbf{x}) = -\delta\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}\delta\mathbf{x} < 0 \quad (\forall\,\delta\mathbf{x} \ne \mathbf{0})$$

# 2. Coordinate Invariance Under Linear Transformations

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
- **Riemannian circulation ratio:** Evaluated in the natural Riemannian metric $\mathbf{C}^{-1}$ (standardized coordinates $\delta\tilde{\mathbf{x}} = \mathbf{C}^{-1/2}\delta\mathbf{x}$), the metric-weighted circulation ratio $\tilde{\chi} = \left[\operatorname{tr}(\boldsymbol{\Omega}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}) / \operatorname{tr}(\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1}\mathbf{D}_{\mathrm{sym}}\mathbf{C}^{-1})\right]^{1/2}$ is strictly invariant under any invertible $\mathbf{M}$.

# 3. Extremum Dissipation Principles: Clamped Forces vs. Clamped Fluxes

Following the variational formulations of Onsager (1931a,b), Onsager and Machlup (1953), and Prigogine (1955), whether a linear non-equilibrium steady state maximizes or minimizes entropy production depends on which boundary variables are clamped (Shiner and Sieniutycz 1994, Martyushev and Seleznev 2006, Reis 2014). Under clamped thermodynamic forces $\mathbf{X}$, the Onsager-Machlup functional is (Onsager and Machlup 1953, Ziegler 1983, Dewar 2003):

$$\Phi(\mathbf{J}) = \sigma(\mathbf{J}, \mathbf{X}) - \Psi(\mathbf{J}) = \sum_{i} J_i X_i - \frac{1}{2}\sum_{i,j} R_{s;ij} J_i J_j$$

Setting the first variation with respect to flux $J_k$ to zero gives $\partial \Phi / \partial J_k = X_k - \sum_j R_{s;kj} J_j = 0 \implies \mathbf{J} = \mathbf{L}_s\mathbf{X}$. Because the Hessian with respect to $\mathbf{J}$ is negative definite ($\partial^2 \Phi / \partial \mathbf{J}^2 = -\mathbf{R}_s \prec 0$), the constitutive response maximizes $\Phi(\mathbf{J})$ (and thus boundary dissipation $\sigma = \mathbf{X}^{\mathsf{T}}\mathbf{L}_s\mathbf{X}$) at fixed driving forces.

Conversely, when boundary fluxes are clamped or a subset of internal forces $X_k$ are left unconstrained to relax to zero-flux stationarity ($J_k = 0$), differentiating $\sigma(\mathbf{X}) = \mathbf{X}^{\mathsf{T}}\mathbf{L}_s\mathbf{X}$ with respect to each free internal force $X_k$ yields:

$$\frac{\partial \sigma}{\partial X_k} = 2\sum_j L_{s;kj} X_j = 2 J_{s;k} = 0, \qquad \frac{\partial^2 \sigma}{\partial \mathbf{X}^2} = 2\mathbf{L}_s \succ 0$$

Because the Hessian $2\mathbf{L}_s$ is strictly positive definite, stationary relaxation of unconstrained internal forces minimizes entropy production (Prigogine 1955, 1967, Glansdorff and Prigogine 1971), with the minimized dissipation given directly by the Schur complement $\sigma_{\min} = L_{11,\mathrm{eff}}\,\delta X_1^2 \le L_{11}\,\delta X_1^2$.

# 4. Stationary Entropy Production Trace Formula from Fokker-Planck Probability Currents

Following the stochastic thermodynamics of non-equilibrium stationary states (Tomita and Tomita 1974, Schnakenberg 1976, Tomé 2006, Seifert 2012, Zhang et al. 2012), this section derives the exact stationary entropy production trace formula:

$$\sigma = k_{\mathrm{B}} \operatorname{tr}\left( \boldsymbol{\Omega}^{\mathsf{T}} \mathbf{C}^{-1} \boldsymbol{\Omega} \mathbf{D}^{-1} \right)$$

from the continuous Fokker-Planck probability flux $\mathbf{J}_{\mathrm{prob}}(\mathbf{x}) = \mathbf{M}\mathbf{x} P_{\mathrm{ss}}(\mathbf{x})$.

## Step 1: The Linear Fokker-Planck Equation and Probability Current

Consider an $n$-dimensional ecological system in state space $\mathbf{x} \in \mathbb{R}^n$ (departures from reference steady state $\mathbf{x}^*$) governed by linear drift $\mathbf{A}\mathbf{x}$ and constant symmetric noise diffusion tensor $\mathbf{D} \succ 0$. The probability density $P(\mathbf{x}, t)$ evolves according to:

$$\frac{\partial P(\mathbf{x}, t)}{\partial t} = -\nabla \cdot \mathbf{J}_{\mathrm{prob}}(\mathbf{x}, t)$$

where the probability flux vector field is:

$$\mathbf{J}_{\mathrm{prob}}(\mathbf{x}, t) = \mathbf{A}\mathbf{x} P(\mathbf{x}, t) - \mathbf{D}\nabla P(\mathbf{x}, t)$$

## Step 2: Stationary Distribution and Spatial Log-Gradient

At dynamic stationarity ($\partial P_{\mathrm{ss}} / \partial t = 0$), the unconstrained linear system admits a centered multivariate Gaussian distribution:

$$P_{\mathrm{ss}}(\mathbf{x}) = \frac{1}{(2\pi)^{n/2}(\det \mathbf{C})^{1/2}} \exp\left( -\frac{1}{2}\mathbf{x}^{\mathsf{T}}\mathbf{C}^{-1}\mathbf{x} \right)$$

where $\mathbf{C} = \langle \mathbf{x}\mathbf{x}^{\mathsf{T}} \rangle_{\mathrm{ss}} \succ 0$ is the stationary covariance matrix satisfying the continuous Lyapunov equation:

$$\mathbf{A}\mathbf{C} + \mathbf{C}\mathbf{A}^{\mathsf{T}} + 2\mathbf{D} = \mathbf{0}$$

Differentiating $P_{\mathrm{ss}}(\mathbf{x})$ with respect to state vector $\mathbf{x}$:

$$\nabla P_{\mathrm{ss}}(\mathbf{x}) = -\mathbf{C}^{-1}\mathbf{x} \, P_{\mathrm{ss}}(\mathbf{x})$$

## Step 3: Stationary Current and the Circulation Drift Operator $\mathbf{M}$

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

## Step 4: Phase-Space Integration of Thermodynamic Entropy Production

In stochastic thermodynamics (Tomita and Tomita 1974, Qian 2001, Seifert 2012), the stationary total entropy production rate $\sigma$ measures the thermodynamic irreversibility of probability currents against diffusive friction:

$$\sigma = k_{\mathrm{B}} \int_{\mathbb{R}^n} \frac{\mathbf{J}_{\mathrm{prob}}(\mathbf{x})^{\mathsf{T}} \mathbf{D}^{-1} \mathbf{J}_{\mathrm{prob}}(\mathbf{x})}{P_{\mathrm{ss}}(\mathbf{x})}\, d\mathbf{x}$$

Substituting $\mathbf{J}_{\mathrm{prob}}(\mathbf{x}) = \mathbf{M}\mathbf{x} P_{\mathrm{ss}}(\mathbf{x})$:

$$\sigma = k_{\mathrm{B}} \int_{\mathbb{R}^n} \frac{\left( \mathbf{M}\mathbf{x} P_{\mathrm{ss}}(\mathbf{x}) \right)^{\mathsf{T}} \mathbf{D}^{-1} \left( \mathbf{M}\mathbf{x} P_{\mathrm{ss}}(\mathbf{x}) \right)}{P_{\mathrm{ss}}(\mathbf{x})}\, d\mathbf{x} = k_{\mathrm{B}} \int_{\mathbb{R}^n} \left( \mathbf{x}^{\mathsf{T}}\mathbf{M}^{\mathsf{T}}\mathbf{D}^{-1}\mathbf{M}\mathbf{x} \right) P_{\mathrm{ss}}(\mathbf{x})\, d\mathbf{x}$$

## Step 5: Reduction via Cyclic Trace and Stationary Covariance

Using the cyclic trace identity for quadratic forms $\mathbf{x}^{\mathsf{T}}\mathbf{K}\mathbf{x} = \operatorname{tr}(\mathbf{K}\mathbf{x}\mathbf{x}^{\mathsf{T}})$ where $\mathbf{K} = \mathbf{M}^{\mathsf{T}}\mathbf{D}^{-1}\mathbf{M}$:

$$\sigma = k_{\mathrm{B}} \int_{\mathbb{R}^n} \operatorname{tr}\left( \mathbf{M}^{\mathsf{T}}\mathbf{D}^{-1}\mathbf{M} \, \mathbf{x}\mathbf{x}^{\mathsf{T}} \right) P_{\mathrm{ss}}(\mathbf{x})\, d\mathbf{x} = k_{\mathrm{B}} \operatorname{tr}\left[ \mathbf{M}^{\mathsf{T}}\mathbf{D}^{-1}\mathbf{M} \int_{\mathbb{R}^n} \mathbf{x}\mathbf{x}^{\mathsf{T}} P_{\mathrm{ss}}(\mathbf{x})\, d\mathbf{x} \right]$$

Recognizing the integral as the stationary covariance matrix $\int_{\mathbb{R}^n} \mathbf{x}\mathbf{x}^{\mathsf{T}} P_{\mathrm{ss}}(\mathbf{x})\, d\mathbf{x} = \langle \mathbf{x}\mathbf{x}^{\mathsf{T}} \rangle_{\mathrm{ss}} = \mathbf{C}$:

$$\sigma = k_{\mathrm{B}} \operatorname{tr}\left( \mathbf{M}^{\mathsf{T}}\mathbf{D}^{-1}\mathbf{M} \, \mathbf{C} \right)$$

## Step 6: Expansion in Circulation and Covariance Tensors

Substituting $\mathbf{M} = -\boldsymbol{\Omega}\mathbf{C}^{-1}$ and $\mathbf{M}^{\mathsf{T}} = -\mathbf{C}^{-1}\boldsymbol{\Omega}^{\mathsf{T}}$:

$$\sigma = k_{\mathrm{B}} \operatorname{tr}\left( \left(-\mathbf{C}^{-1}\boldsymbol{\Omega}^{\mathsf{T}}\right) \mathbf{D}^{-1} \left(-\boldsymbol{\Omega}\mathbf{C}^{-1}\right) \mathbf{C} \right) = k_{\mathrm{B}} \operatorname{tr}\left( \mathbf{C}^{-1}\boldsymbol{\Omega}^{\mathsf{T}}\mathbf{D}^{-1}\boldsymbol{\Omega}\mathbf{C}^{-1}\mathbf{C} \right)$$

Because $\mathbf{C}^{-1}\mathbf{C} = \mathbf{I}$:

$$\sigma = k_{\mathrm{B}} \operatorname{tr}\left( \mathbf{C}^{-1}\boldsymbol{\Omega}^{\mathsf{T}}\mathbf{D}^{-1}\boldsymbol{\Omega} \right)$$

Applying the cyclic invariance of the trace ($\operatorname{tr}(\mathbf{U}\mathbf{V}) = \operatorname{tr}(\mathbf{V}\mathbf{U})$) with $\mathbf{U} = \mathbf{C}^{-1}$ and $\mathbf{V} = \boldsymbol{\Omega}^{\mathsf{T}}\mathbf{D}^{-1}\boldsymbol{\Omega}$:

$$\sigma = k_{\mathrm{B}} \operatorname{tr}\left( \boldsymbol{\Omega}^{\mathsf{T}} \mathbf{C}^{-1} \boldsymbol{\Omega} \mathbf{D}^{-1} \right)$$

Using $\boldsymbol{\Omega}^{\mathsf{T}} = -\boldsymbol{\Omega}$, this is identically:

$$\sigma = -k_{\mathrm{B}} \operatorname{tr}\left( \boldsymbol{\Omega} \mathbf{C}^{-1} \boldsymbol{\Omega} \mathbf{D}^{-1} \right)$$

## Step 7: Positivity, Detailed Balance, and Invariance

Strict non-negativity of entropy production follows directly: because $\mathbf{D} \succ 0 \implies \mathbf{D}^{-1} \succ 0$ and $\mathbf{C} \succ 0 \implies \mathbf{C}^{-1} \succ 0$, the matrix $\mathbf{K} = \boldsymbol{\Omega}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega} \succeq 0$ is positive semidefinite. The trace product of two positive semidefinite matrices is non-negative, ensuring $\sigma \ge 0$ unconditionally and satisfying the Second Law. Detailed balance holds if and only if probability circulation vanishes ($\boldsymbol{\Omega} = \mathbf{0}$), in which case $\sigma = 0$; conversely, in any living food web with active trophic cycling, $\boldsymbol{\Omega} \ne \mathbf{0}$ and $\sigma > 0$. Finally, under any linear coordinate transformation $\mathbf{x}_{\mathrm{new}} = \mathbf{M}_{\mathrm{coord}}\mathbf{x}_{\mathrm{old}}$, direct substitution confirms $\sigma_{\mathrm{new}} = \sigma_{\mathrm{old}}$, establishing that $\sigma$ is an exact coordinate-invariant physical scalar.

# 5. Non-Linear Regime — Quasi-Potential Landscapes and Regime-Shifting Dynamics


Quasi-Potential Landscape ($U(\mathbf{x})$) is the non-equilibrium scalar landscape $U(\mathbf{x}) = -\lim_{\mathcal{V} \to \infty}\mathcal{V}^{-1}\ln P_{\mathrm{ss}}(\mathbf{x})$ governing stationary probability basins and escape barriers in non-linear stochastic ecosystems. It defines the topographical stability basin of the community in extensive state space. A deep, steep potential basin corresponds to a well-buffered ecosystem that absorbs disturbances and returns rapidly to its stationary attractor, whereas a shallow, flattened basin indicates an eroded attractor vulnerable to noise-induced transitions across a saddle barrier into an alternative state.

## Non-Equilibrium Helmholtz-Hodge Decomposition in Non-Linear Phase Space

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

Thus any smooth non-linear ecological drift field $\mathbf{f}(\mathbf{x})$ admits a Helmholtz-Hodge decomposition into two orthogonal components:

$$\mathbf{f}(\mathbf{x}) = -\mathbf{D}(\mathbf{x})\nabla U(\mathbf{x}) + \mathbf{v}_{\mathrm{curl}}(\mathbf{x}), \qquad \nabla U(\mathbf{x}) \cdot \mathbf{v}_{\mathrm{curl}}(\mathbf{x}) = 0$$

The first component is the downhill dissipative gradient drift $-\mathbf{D}(\mathbf{x})\nabla U(\mathbf{x})$, governed by the symmetric, positive-definite diffusion tensor $\mathbf{D}(\mathbf{x}) \succ 0$, which draws trajectories down the gradient of $U(\mathbf{x})$ through irreversible metabolic dissipation. The second component is the solenoidal probability circulation velocity $\mathbf{v}_{\mathrm{curl}}(\mathbf{x}) = \mathbf{J}_{\mathrm{prob}}(\mathbf{x}) / P_{\mathrm{ss}}(\mathbf{x}) = \boldsymbol{\Omega}(\mathbf{x})\nabla U(\mathbf{x})$, generated by a state-dependent skew-symmetric circulation tensor $\boldsymbol{\Omega}(\mathbf{x}) = -\boldsymbol{\Omega}(\mathbf{x})^{\mathsf{T}}$. Because $\boldsymbol{\Omega}(\mathbf{x})$ is skew-symmetric, $\mathbf{v}_{\mathrm{curl}}(\mathbf{x})$ is orthogonal to $\nabla U(\mathbf{x})$ everywhere in phase space and circulates along iso-potential contours without performing net work against $U(\mathbf{x})$. Consequently, $U(\mathbf{x})$ serves as a non-equilibrium Lyapunov function within each basin of attraction: deterministic trajectories spiral inward down $U(\mathbf{x})$ while non-equilibrium forcing sustains persistent cyclic currents around the attractor.

As environmental forcing or harvesting pressure pushes an ecosystem toward a bifurcation, the local quadratic curvature of the quasi-potential well ($\mathbf{H} = k_{\mathrm{B}}\mathbf{C}^{-1} \propto \nabla^2 U(\mathbf{x}^*)$) degrades along distinct mechanistic pathways that yield quantitative early-warning diagnostics (Scheffer et al. 2009):

- **Curvature collapse and critical slowing down (fold bifurcation):** When chronic environmental stress weakens dissipative self-regulation ($\lambda_{\min}(\mathbf{D}_{\mathrm{sym}}) \to 0$) or erodes the entropic curvature ($\lambda_{\min}(\mathbf{H}) \to 0$), a real eigenvalue of $\mathbf{A}$ approaches zero ($\lambda_1 \to 0^-$). The restoring force along the soft eigenvector direction vanishes, lengthening recovery times after perturbations and causing stationary variance to diverge ($\mathbf{C}_{11} = k_{\mathrm{B}} / \lambda_{\min}(\mathbf{H}) \to \infty$) prior to a saddle-node transition.

- **Capacitance stripping and oscillatory destabilization (Hopf bifurcation):** When selective exploitation or habitat loss strips slow macroscopic biomass capacitors ($C_{ii} \to 0$) while strong trophic throughput sustains skew-symmetric circulation $\boldsymbol{\Omega}$, the non-equilibrium circulation ratio $\chi = \|\boldsymbol{\Omega}\|_F / \|\mathbf{D}_{\mathrm{sym}}\|_F$ surges, as observed in the exploited NPZD-Fish food web (Paper II, Table 1).

For empirical monitoring and fisheries management, combining these thermodynamic diagnostics distinguishes directional attractor flattening from oscillatory destabilization. Lengthening recovery times and monotone variance inflation along a single trophic axis indicate fold-type curvature collapse ($\det \mathbf{H} \to 0$), whereas simultaneous inflation of the circulation ratio $\chi$, rising entropy production $\sigma$, and rotational phase-space spiraling indicate that apex or detrital storage capacitance has been stripped, providing an operational warning to reduce harvest mortality before a regime shift occurs.

# 6. Interdisciplinary Connections

## Network Thermodynamics and Circuit Theory

The decomposition of asymmetric community matrices into symmetric dissipators and antisymmetric circulators is mathematically isomorphic to multiport electrical circuit theory (Tellegen 1948, 1952, Oster et al. 1971, Mikulecky 1985).

By Tellegen's (1952) theorem, for any network topology obeying Kirchhoff's current and voltage laws, instantaneous power across all branches sums to zero ($\sum_k v_k(t) i_k(t) = 0$). In ecological networks, extensive state deviations $\delta\mathbf{x}$ correspond to generalized capacitor charges, conjugate thermodynamic forces $\mathbf{X} = -\mathbf{H}\delta\mathbf{x} = -k_{\mathrm{B}}\mathbf{C}^{-1}\delta\mathbf{x}$ correspond to generalized node voltages, and compartment standing stocks act as generalized entropic capacitors ($C_i \propto B_i^* / k_{\mathrm{B}}$).

In the constitutive flux-force relation $\mathbf{J} = \mathbf{L}\mathbf{X} = k_{\mathrm{B}}^{-1}(\mathbf{D}_{\mathrm{sym}} + \boldsymbol{\Omega})\mathbf{X}$, the symmetric part $\mathbf{L}_s = \frac{1}{2}(\mathbf{L} + \mathbf{L}^{\mathsf{T}}) = k_{\mathrm{B}}^{-1}\mathbf{D}_{\mathrm{sym}} \succ 0$ represents a passive resistive conductance network governing irreversible entropy production:

$$\sigma = \mathbf{X}^{\mathsf{T}}\mathbf{L}_s\mathbf{X} = k_{\mathrm{B}}^{-1}\mathbf{X}^{\mathsf{T}}\mathbf{D}_{\mathrm{sym}}\mathbf{X} \ge 0$$

Conversely, the skew-symmetric part $\mathbf{L}_a = \frac{1}{2}(\mathbf{L} - \mathbf{L}^{\mathsf{T}}) = k_{\mathrm{B}}^{-1}\boldsymbol{\Omega}$ represents an array of ideal **Tellegen gyrators** (Tellegen 1948). A two-port gyrator with gyration conductance $g$ couples port currents and voltages via a skew-symmetric admittance matrix:

$$\begin{pmatrix} i_1 \\ i_2 \end{pmatrix} = \begin{pmatrix} 0 & g \\ -g & 0 \end{pmatrix} \begin{pmatrix} v_1 \\ v_2 \end{pmatrix}$$

Because $\mathbf{L}_a = -\mathbf{L}_a^{\mathsf{T}}$ is skew-symmetric, net instantaneous power dissipation across every gyrator is identically zero ($\mathbf{X}^{\mathsf{T}}\mathbf{L}_a\mathbf{X} = 0$). When port 2 of a gyrator is terminated by a storage capacitor $C_2$ ($i_2 = -C_2 \dot{v}_2$), substituting $v_2 = i_1 / g$ yields $v_1 = -(1/g)i_2 = (C_2 / g^2)\dot{i}_1$, so the input port behaves as an equivalent reactive inductor with inductance:

$$L_{\mathrm{eq}} = \frac{C_2}{g^2}$$

This circuit duality explains why ecological networks exhibit endogenous oscillations, trophic waves, and limit cycles despite lacking physical magnetic fields: coupling capacitive biomass storage ($\mathbf{C}$) through skew-symmetric trophic circulation ($\boldsymbol{\Omega}$) synthesizes an equivalent reactive inductance ($L_{\mathrm{eq}}$). Coupled consumer-resource pairs therefore act as damped $RLC$ oscillators that exchange availability between prey and predator compartments while dissipative conductances $\mathbf{D}_{\mathrm{sym}}$ damp the oscillation amplitude.

## Information Geometry and Helmholtz-Hodge Decomposition

Following Riemannian information geometry (Amari 1985, 2016), on the state space manifold $\mathcal{M} = \mathbb{R}_{> 0}^K$, the continuous Lyapunov covariance matrix defines a Riemannian Fisher information metric:

$$g_{ij}(\mathbf{x}) = [\mathbf{C}^{-1}]_{ij} = \frac{\partial^2 U(\mathbf{x})}{\partial x_i \partial x_j}$$

Under this metric, any smooth dynamical vector field $\mathbf{f}(\mathbf{x})$ decomposes uniquely into orthogonal potential and solenoidal (curl) components (Helmholtz-Hodge theorem; Helmholtz 1858, Hodge 1941, Amari 1985):

$$\mathbf{f}(\mathbf{x}) = -\mathbf{D}(\mathbf{x})\nabla U(\mathbf{x}) + \mathbf{v}_{\mathrm{curl}}(\mathbf{x}), \qquad \nabla U(\mathbf{x}) \cdot \mathbf{v}_{\mathrm{curl}}(\mathbf{x}) = 0$$

MacArthur's (1970) variational principle succeeded for pure competition precisely because symmetric resource competition generates an exact potential gradient system where $\mathbf{v}_{\mathrm{curl}} \equiv \mathbf{0}$. In contrast, trophic interactions introduce directional non-equilibrium circulation, $\mathbf{v}_{\mathrm{curl}} \ne \mathbf{0}$, which drives perpetual probability currents along closed loops.

## Cybernetic Feedback Control and the Conservation of Sensitivity (Bode Integral)

The Resistance-Resilience trade-off continuum ($B_{\mathrm{tot}} \times \mathcal{R} \approx \text{const}$) can be derived from the fundamental laws of feedback control theory (Bode 1945).

In control engineering, the sensitivity function $S(i\omega) = [1 + L_{\mathrm{loop}}(i\omega)]^{-1}$ measures disturbance attenuation across frequency $\omega$. Bode's (1945) Sensitivity Integral theorem dictates that for any open-loop stable feedback system:

$$\int_0^{\infty} \ln |S(i\omega)|\,d\omega = 0$$

This conservation law, known as the waterbed effect, proves that sensitivity cannot be reduced universally across all frequencies:

$$\int_0^{\omega_{\mathrm{c}}} |\ln |S(i\omega)||\,d\omega = \int_{\omega_{\mathrm{c}}}^{\infty} |\ln |S(i\omega)||\,d\omega$$

In ecological networks, Resistance ($B_{\mathrm{tot}}$) manifests through massive biomass pools acting as low-pass filters that suppress low-frequency environmental variance ($|S(i\omega)| \to 0$ as $\omega \to 0$). Conversely, Resilience ($\mathcal{R}$) is governed by the asymptotic return rate $\mathcal{R} = |\operatorname{Re}(\lambda_{\max})|$, dictating how rapidly high-frequency perturbations decay.

Because the total integral of $\ln |S(i\omega)|$ is strictly conserved by network topology, an ecosystem cannot simultaneously maximize low-frequency disturbance rejection ($B_{\mathrm{tot}} \to \infty$) and broadband transient recovery ($\mathcal{R} \to \infty$). The hyperbolic trade-off $B_{\mathrm{tot}} \times \mathcal{R} \approx \text{const}$ is the ecological manifestation of the Bode sensitivity integral.


# Conclusion

Part III has developed the theoretical extensions that make the non-equilibrium thermodynamic framework for ecological populations fully operational. Section 1 established the baseline constitutive operators and Lyapunov covariance factorization that resolve the demographic community matrix into symmetric dissipative conductivity and antisymmetric probability circulation. Section 2 proved coordinate invariance, showing that all thermodynamic scalars—eigenvalue spectrum, entropy production rate, and circulation ratio—are invariant under any non-singular linear state-space transformation. Section 3 derived the extremum dissipation principles governing clamped-force versus clamped-flux boundary conditions. Section 4 derived the stationary entropy production trace formula $\sigma = k_{\mathrm{B}}\operatorname{tr}(\boldsymbol{\Omega}^{\mathsf{T}}\mathbf{C}^{-1}\boldsymbol{\Omega}\mathbf{D}^{-1})$ from Fokker-Planck probability currents.

Section 5 extended the linear theory into the non-linear regime through the quasi-potential landscape formalism, the Helmholtz-Hodge decomposition of non-linear ecological drift, and quantitative early-warning diagnostics for fold and Hopf bifurcations. This machinery explains how capacitance stripping erodes quasi-potential barriers and drives regime shifts, providing operational early-warning indicators for ecosystem collapse.

Section 6 established interdisciplinary connections showing that ecological systems obey the same universal principles as physical systems: circuit theory (Tellegen gyrators synthesize ecological oscillators), information geometry (Fisher metric and Helmholtz-Hodge decomposition), cybernetic feedback control (Bode sensitivity integral and waterbed effect), and stochastic thermodynamics.

Together, Parts II and III demonstrate that ecological communities are not merely analogous to non-equilibrium thermodynamic systems—they *are* non-equilibrium thermodynamic systems, governed by the same principles of dissipation, fluctuation, capacitance, circulation, and stability that govern physical processes far from equilibrium. The Resistance-Resilience trade-off continuum, the allometric size spectrum, and the quasi-potential landscape together provide a unified physical foundation for understanding ecosystem stability, resilience, and regime shifts across scales from microbes to megaclimate.

# References

Amari, S. (1985). *Differential-Geometrical Methods in Statistics*. Lecture Notes in Statistics, Vol. 28. Springer-Verlag, New York.

Amari, S. (2016). *Information Geometry and Its Applications*. Applied Mathematical Sciences, Vol. 194. Springer, Tokyo.

Ao, P. (2004). Potential in stochastic differential equations: novel construction. *Journal of Physics A: Mathematical and General*, 37(3), pp. L25-L30.

Andersen, K. H. (2019). *Fish Ecology, Evolution, and Exploitation: A New Theoretical Synthesis*. Princeton University Press, Princeton.

Boudreau, P. R. and Dickie, L. M. (1992). Biomass spectra of aquatic ecosystems in relation to fisheries yield. *Canadian Journal of Fisheries and Aquatic Sciences*, 49(8), pp. 1528-1538.

Bode, H. W. (1945). *Network Analysis and Feedback Amplifier Design*. D. Van Nostrand Company, New York.

Choi, J. S. (2023). Reconstructing the decline of Atlantic cod with the help of environmental variability in the Scotian Shelf of Canada. *bioRxiv preprint*. https://doi.org/10.1101/2022.05.05.490753.

Choi, J. S., Frank, K. T., Leggett, W. C. and Drinkwater, K. (2004). Transition to an alternate state in a continental shelf ecosystem. *Canadian Journal of Fisheries and Aquatic Sciences*, 61(4), pp. 505-510.

Choi, J. S. and Hansell, R. I. C. (2026). Reconciling Ecological Population Dynamics with Non-Equilibrium Thermodynamics: I. Onsager Reciprocity, Biomass Capacitance, and Conjugate Stability. *bioRxiv preprint*.

Choi, J. S. and Hansell, R. I. C. (2026). Reconciling Ecological Population Dynamics with Non-Equilibrium Thermodynamics: II. Empirical Validation, Allometric Size Spectra, and Regime Shifts. *bioRxiv preprint*.

Freidlin, M. I. and Wentzell, A. D. (1984). *Random Perturbations of Dynamical Systems*. Springer-Verlag, New York.


Graham, R. (1977). Covariant formulation of non-equilibrium statistical thermodynamics. *Zeitschrift für Physik B Condensed Matter*, 26(4), pp. 397-405.

Helmholtz, H. von. (1858). Über Integrale der hydrodynamischen Gleichungen, welche den Wirbelbewegungen entsprechen. *Journal für die reine und angewandte Mathematik*, 55, pp. 25-55.

Hodge, W. V. D. (1941). *The Theory and Applications of Harmonic Integrals*. Cambridge University Press, Cambridge.

Kleiber, M. (1932). Body size and metabolism. *Hilgardia*, 6(11), pp. 315-353.

Kleiber, M. (1947). Body size and metabolic rate. *Physiological Reviews*, 27(4), pp. 511-541.

Kolmogorov, A. N. (1941). The local structure of turbulence in incompressible viscous fluid for very large Reynolds numbers. *Doklady Akademii Nauk SSSR*, 30, pp. 301-305.

Kuznetsov, Y. A. (1998). *Elements of Applied Bifurcation Theory*. 2nd ed. Springer-Verlag, New York.

MacArthur, R. (1970). Species packing and competitive equilibrium for many species. *Theoretical Population Biology*, 1(1), pp. 1-11.

Mikulecky, D. C. (1985). Network thermodynamics in biology and medicine. *American Journal of Physiology*, 249(3), pp. R317-R330.

Onsager, L. (1931a). Reciprocal relations in irreversible processes. I. *Physical Review*, 37(4), pp. 405-426.

Onsager, L. (1931b). Reciprocal relations in irreversible processes. II. *Physical Review*, 38(12), pp. 2265-2279.

Onsager, L. and Machlup, S. (1953). Fluctuations and irreversible processes. *Physical Review*, 91(6), pp. 1505-1512.

Oster, G. F., Perelson, A. S. and Katchalsky, A. (1971). Network thermodynamics. *Nature*, 234(5329), pp. 393-399.

Prigogine, I. (1947). *Étude Thermodynamique des Phénomènes Irréversibles*. Desoer, Liège.

Prigogine, I. (1955). *Introduction to Thermodynamics of Irreversible Processes*. Charles C Thomas, Springfield, IL.

Prigogine, I. (1967). Structure, dissipation and life. In: Marois, M. (ed.), *Theoretical Physics and Biology*. North-Holland, Amsterdam, pp. 23-52.

Rodriguez, J. and Mullin, M. M. (1986). Relation between biomass and body weight of plankton in a steady state oceanic ecosystem. *Limnology and Oceanography*, 31(2), pp. 361-370.

Scheffer, M., Carpenter, S., Foley, J. A., Folke, C. and Walker, B. (2001). Catastrophic shifts in ecosystems. *Nature*, 413(6856), pp. 591-596.

Schnakenberg, J. (1976). Network theory of microscopic and macroscopic behavior of master equation systems. *Reviews of Modern Physics*, 48(4), pp. 571-585.

Seifert, U. (2012). Stochastic thermodynamics, fluctuation theorems and molecular machines. *Reports on Progress in Physics*, 75(12), p. 126001.

Sheldon, R. W., Prakash, A. and Sutcliffe, W. H. (1972). The size distribution of particles in the ocean. *Limnology and Oceanography*, 17(3), pp. 327-340.

Tomé, T. (2006). Entropy production in nonequilibrium steady states: A Fokker-Planck study. *Brazilian Journal of Physics*, 36(4A), pp. 1285-1289.

Tomita, K. and Tomita, H. (1974). Irreversible circulation of fluctuation. *Progress of Theoretical Physics*, 51(6), pp. 1731-1749.

Zhang, X.-J., Qian, H. and Qian, M. (2012). Stochastic theory of nonequilibrium steady states and its applications: A network perspective. *Physics Reports*, 518(1-2), pp. 1-70.

Zheng, Y., Wang, D., Steinberg, D. K., Bates, N. R. and Carlson, C. A. (2024). BATS: Bermuda Atlantic Time-series Study. *Ocean Science*, 20(3), pp. 893-909.

