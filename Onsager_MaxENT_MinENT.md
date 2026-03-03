Basic outline:

Onsager's relations begins with the conservation of entropy density $\frac{\partial s}{\partial t}+\nabla\centerdot {\textbf{J}}_{s}=\frac{\partial s_{i}}{\partial t}$, where ${\textbf{J}}_{s}$ is the “entropy flux” and $\frac{\partial s_{i}}{\partial t}$ are the irreversible processes of equilibriation. If $x_{1},x_{2},\dots,x_{n}$ are the fluctuations from equilibrium values of thermodynamic state variables and $S(x_{1},x_{2},\dots,x_{n})$ is the associated entropy for the $X_{1},X_{2},\dots,X_{n}$ extensive variables: the force is $F=\partial S/\partial X_{i}$ and the flow is $J=\partial X_{i}/\partial t$.

Local conservation of mass means that the flow of mass densities must satisfy the continuity equation $\frac{\partial\rho}{\partial t}+\nabla\centerdot {\textbf{J}}_{\rho}=0$, where ${\textbf{J}}_{\rho}$ is the mass flux. If the macroscopic (mechanical) velocity of the fluid is negligible then energy conservation of internal energy density is the internal energy flux: $\frac{\partial u}{\partial t}+\nabla\centerdot {\textbf{J}}_{u}=0$. 

More generally, $\boldsymbol{J_{i=1,\dots N}}$ phenomenological flows are driven by $F_{k=1,\dots N}$ phenomenological forces. These forces are characterised by the gradients of the potentials $\Phi=\{T,P,\mu,\dots, {etc.}\}$ such that $\boldsymbol{F}_{k}=\nabla\Phi_{k}$. The interactions of these forces and flows result in an entropy production rate per unit volume, $\sigma=\sum_{i}\boldsymbol{F}_{i} { {\circ}}\boldsymbol{J}_{i}$, where $\circ$ denotes a dot-product. The flows can be approximated as first order linear functions of the forces via the “kinetic” or “conductivity” coefficients (using the electric circuit analogy) $L$ such that $\boldsymbol{J}_{i}=\sum_{k}L_{ik}\boldsymbol{F}_{k}$; or alternatively, the flows map onto the forces in operation via the first order linear “resistivity” coefficients $L^{-1}$ such that $\boldsymbol{F}_{k}=\sum_{i}L_{ki}^{-1}\boldsymbol{J}_{i}$. Here, $L$ can be inverted because it is symmetric $L=L^{T}$, due to Onsager's “detailed local balance” or “microscopic reversibility” assumption. The “conductivity” and “resistivity” coefficients $L$ and $L^{-1}$ are positive definite as entropy production must be positive with the Second Law of Thermodynamics. This can be seen by expressing $\sigma$ in terms of $F$ when the forces are fixed (i.e., gradients of potentials):

$$\sigma=\sum_{i}\boldsymbol{F}_{i} {{\circ}}\boldsymbol{J}_{i}=\sum_{i,k}\boldsymbol{F}_{i}\circ L_{ik}\boldsymbol{F}_{k} {{>\ }}0,$$

or in terms of $J$ when the flows are fixed:

$$\sigma=\sum_{i}\boldsymbol{F}_{i} {{\circ}}\boldsymbol{J}_{i}=\sum_{i,k}\boldsymbol{J}_{i}\circ L_{ik}^{-1}\boldsymbol{J}_{k} {>\ }0.$$

Following Reis (2014), the first and second differentials of the entropy production rate per unit volume, when the forces are fixed become:

$$d\sigma=\sum_{i,k}\boldsymbol{F}_{i} {{\circ}}(dL_{ik}\boldsymbol{)F}_{k},$$

$$d^{2}\sigma=\sum_{i,k}\boldsymbol{F}_{i} {{\circ}}(d^{2}L_{ik}\boldsymbol{)F}_{k}.$$

Ignoring the trivial cases where all $F$ are $0$, note that $d\sigma\approx0$ when $dL\approx0$ and the sign of $d^{2}\sigma$ is controlled by the sign of $d^{2}L\approx0$. If $dL\approx0$ and $d^{2}L_{ik}<0$ then a maximum can be expected and if $dL\approx0$ and $d^{2}L>0$, then a minimum. Reis (2014) further notes that 

$$dL_{ik}=-\sum_{p,q}L_{ip}(dL_{pq}^{-1})L_{qk}$$

$$d^{2}L_{ik}=\sum_{p,q}L_{ip}(-d^{2}L_{pq}^{-1})L_{qk}.$$

We note that $d^{2}L$ has the opposite sign of $d^{2}L^{-1}$ (see https://en.wikipedia.org/wiki/Matrix_calculus#Identities_in_differential_form). 

Similarly when the flows are fixed:

$$d\sigma=\sum_{i,k}\boldsymbol{J}_{i} {{\circ}}(dL_{ik}^{-1}\boldsymbol{)J}_{k},$$

$$d^{2}\sigma=\sum_{i,k}\boldsymbol{J}_{i} {{\circ}}(d^{2}L_{ik}^{-1}\boldsymbol{)J}_{k}.$$

The first and second order differentials of resistivities control the stability: $dL^{-1}$ and $d^{2}L^{-1}$. If $dL^{-1}\approx0$ and $d^{2}L^{-1}<0$ then a maximum can be expected and if $dL^{-1}\approx0$ and $d^{2}L^{-1}>0$, then a minimum. These, differentials can be decomposed as:

$$dL_{ik}^{-1}=-\sum_{p,q}L_{ip}^{-1}(dL_{pq})L_{qk}^{-1}$$

$$d^{2}L_{ik}^{-1}=\sum_{p,q}L_{ip}^{-1}(-d^{2}L_{pq})L_{qk}^{-1}$$

and we note that $d^{2}L$ **again** has the opposite sign of $d^{2}L^{-1}$ (see https://en.wikipedia.org/wiki/Matrix_calculus#Identities_in_differential_form).

As suggested by Reis (2014), complex systems are generally a mixture of fixed flows and fixed forces, as dynamics cross multiple space-time scales. Thus the specific entropy production can be decomposed into the contributions of those processes with fixed forces ($\sigma_{F}$) and those with fixed flows ($\sigma_{J}$):

$$\sigma=\sigma_{F} { + {\sigma_{J}}>\ }0$$

$$\sigma=\sum_{i,k}\boldsymbol{F}_{i}\circ L_{ik}\boldsymbol{F}_{k} { + {\sum_{m,n}\boldsymbol{J}_{m}\circ L_{mn}^{-1}\boldsymbol{J}_{n}}>\ }0$$

When the first term dominates, then the system will be dominated by Minimum Entropy Production processes while if the latter term dominates, the system will be dominated by Maximum Entropy Production processes. This latter seems esssentially equivalent to Prigogine's Order through fluctuation scenario, where inbalances (or perturbations) in the gradients (forces) 

end