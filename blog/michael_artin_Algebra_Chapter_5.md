<div class="main">

# Note of Michael Artin "Algebra" Chapter 5 "Applications of Linear Operators" (to complete)

# 题记
说实话这一部分看起来和抽象代数关系不大。但是这一部分涉及了一元向量函数和“矩阵函数”的连续性、求导和常微分方程的计算。常微分方程北航的数学分析使用的是北大伍胜健的教材，是不教微分方程的。另外有刚刚接触的群论在正交变换上的应用和数形结合，因此值得一看。

# 5.1  ORTHOGONAL MATRICES AND ROTATIONS

## 5.1.1 Def. (Dot Product) (Skipped)
- The square of the length of a vector $X$ is $(X\cdot X) = X^TX$.
- A vector $X$ is **orthogonal** to another vector $Y$, written $X \perp Y$ if and only if $X^TY = 0$.

## 5.1.5 Theo. (Pythagoras) 
If $X\perp Y$ and $Z = X+Y$, then $|Z|^2=|X|^2 + |Y|^2$.

## 5.1.7 Lemma. 
Any set $(v_1,\cdots,v_n)$ of orthogonal nonzero vectors in $\mathbb{R}^n$ is independent.

## 5.1.9 Def. 
A real $n\times n$ matrix $A$ is **orthogonal** if $A^TA=I$, which is to say, $A$ is invertible and its inverse is $A^T$.

## 5.1.10 Lemma.
An $n\times n$ matrix $A$ is orthogonal if and only if ites columns form an orthogonal basis of $\mathbb{R}^n$.

## 5.1.11 Prop.
- The product, inverse, transpose of orthogonal matrices is orthogonal. The orthogonal matrices form a subgroup $O_n$ of $GL_n$, the **orthogonal group**.
- $\det (o) = \pm 1, o \in O_n$. The orthogonal matrices with determinant $1$ form a subgroup $SO_n$ of $O_n$ of index $2$, the **special orthogonal group**.

## 5.1.12 Def. (Orthogonal Operator)
An orthogonal operator $T$ on $\mathbb{R}^n$ is a linear operator that preserves the dot product: 
$$
(TX \cdot TY) = (X\cdot Y), \forall X,Y \in \mathbb{R}^n
$$

## 5.1.13 Prop.
A linear operator $T$ on $\mathbb{R}^n$ is orthogonal if and only if $\forall X, (TX\cdot TX) = (X\cdot X)$.

## 5.1.14 Prop. 
A linear operator $T$ on $\mathbb{R}^n$ is orthogonal if and only if its matrix $A$ with respect to the standard basis is an orthogonal matrix.

## 5.1.15 Lemma.
Let $M$ be an $n\times n$ matrix, If $X^TMY=0$ for all column vectors $X$ and $Y$, then $M=0$.

## 5.1.17 Theo.
- **(a)** The orthogonal $2\times 2$ matrices with determinant $1$ are the matrices 

$$
R = \begin{bmatrix}
c  & -s\\
s & c
\end{bmatrix}
$$

- **(b)** The orthogonal $2\times 2$ matrices with determinant $-1$ are the matrices 
$$
S = \begin{bmatrix}
c  & s\\
s & -c
\end{bmatrix} = RS_0
$$
  - The matrix $S$ reflects the plane about the one-dimensional subspace of $\mathbb{R}^2$ that makes an angle $\frac{1}{2}\theta$ with the $e_1$-axis.

## 5.1.22 Def. (Rotation of $\mathbb{R}^3$)
A **rotation** of $\mathbb{R}^3$ about the origin is a linear operator $\rho$ with these properties:

- $\rho$ fixes a unit vector $u$, called a **pole** of $\rho$, and 
- $\rho$ rotates the two-dimensional subspace $W$ orthogonal to $u$.

The angle $\theta$ perpendicular to the pole $u$ follows the "Right Hand Rule".
When $u$ is the $e_1$, the set $(e_2,e_3)$ will be a basis for $W$, and the matrix of $\rho$ woll have the form
$$
M = \begin{bmatrix}
1 & 0 & 0 \\
0 & c & -s \\
0 & s & c
\end{bmatrix} 
$$
A rotation is not the identity is described bt the pair $(u, \theta)$, called a **spin**, that consists of a pole $u$ and a nonzero angle of rotation $\theta$.

## 5.1.25 Theo. (Euler's Theorem)
The $3\times 3$ rotation matrices are the orthogonal $3\times 3$ matrices with determinant $1$, the elements of the special orthogonal group $SO_3$ (three-dimensional **rotation groups**).

## 5.1.26 Cor.
The composition of rotations about any two axes is a rotation about some other axis.

## 5.1.28 Cor.
Let $M$ be the matrix in $SO_3$ that represents the rotation $\rho_{(u,\alpha)}$ with spin $(u,\alpha)$.
- **(a)** The trace of $M$ is $1+2\cos \alpha$.
  - PS: The matrices are communicative in trace.
- **(b)** Let $B \in SO_3$, and let $u' = Bu$, The conjugate $M' = BMB^T$ represents the rotation $\rho(u', \alpha)$ with spin $(u', \alpha)$.

## 5.1.29 Lemma.
A $3\times 3$ orthogonal matrix $M$ with determinant $1$ has an  eigenvalue equal to $1$.



# 5.2 USING CONTINUITY

## 5.2.1 Prop. (Continuity of Roots)
Let $p_k(t)$ be a sequence of monic polynomials of degree $\leq n$, and let $p(t)$ be another monic polynomial of degree $n$. Let $\alpha_{k,1},\cdots ,\alpha_{k,n}$ and $a_1,\cdots ,a_n$ denote the roots of these polynomials.

- **(a)** If $\alpha_{k,v} \to \alpha_v$ for $v = 1,\cdots ,n$, then $p_k\to p$.

- **(b)** Conversely, if $p_k\to p$, the roots $\alpha_{k,v}$ of $p_k$ can be numbered in such a way that $\alpha_{k,v}\to \alpha_v$ for each $v=1,\cdots ,n$.

## 5.2.2 Prop.
Let $A$ be an $n\times n$ complex matrix.

- **(a)** There is a sequance of matrix $A_k$ that converges to $A$, and such that for all $k$ the characteristic polynomial $p_k(t)$ of $A$.

- **(b)** If a subsequence $A_k$ of matrices converges to $A$, the sequence $p_k(t)$ of its characteristic polynomials converges to the characteristic polynomial $p(t)$ of $A$.

- **(c)** Let $\lambda_i$ be the roots of the characteristic polynomial $p$. If $A_k \to A$, the roots $\lambda_{k,i}$ of $p_k$ can be numbered so that $\lambda_{k,i} \to \lambda_i$ for each $i$.

## 5.2.3 Theo. (Cayley-Hamilton Theorem) (Skipped)
特征多项式代入原矩阵后是零化多项式。


# 5.3 SYSTEMS OF DIFFERENTIAL EQUATIONS
这一张是单元向量函数和矩阵函数的常微分方程的有解性，并给出了矩阵可对角化时求解方式。

## 5.3.7 
A system of homogeneous linear, first-order, contant coefficient differential equations is a matrix equation of the form
$$
\frac{\mathrm{d}X}{\mathrm{d}t}=AX
$$

## 5.3.11~5.3.13
If $A = \mathrm{diag}(\lambda_1, \cdots, \lambda_n)$, we have
$$
x_i = c_ie^{\lambda_i t}
$$
Therefore, if $V$ is an eigenvector for $A$ with eigenvalue $\lambda$, i.e., if $AV=\lambda V$, then
$$
X=e^{\lambda t}V
$$
is a particular solution of (5.3.7). Here it is interpreted as the product of the variable scalar $e^{\lambda t}$ and the constant vector $V$.
$$
\frac{\mathrm{d}}{\mathrm{d}t} e^{\lambda t} V = \lambda e^{\lambda t}V = A e^{\lambda t} V
$$
This observation allows us ti solve (5.3.7) whenever the matrix $A$ has distinct real eigenvalues. In that case every solution will be a linear combination of the special solutions (5.3.13).
To work out this, it is convenient to diagonalize.

## 5.3.15 Prop.
Let $A_{n\times n}$ be a matrix, and $P$ be an invertible matrix such that $\Lambda = P^{-1}AP = \mathrm{diag} (\lambda_1, \cdots, \lambda_n)$. The general solution to $\frac{\mathrm{d}X}{\mathrm{d}t} =AX$ is $X=P\widetilde{X}$, where $\widetilde{X}=(c_1 e^{\lambda_1 t}, \cdots, c_n e^{\lambda_n t})^T$ solves the equation $\frac{\mathrm{d}\widetilde{X}}{\mathrm{d}t} =\Lambda \widetilde{X}$.

</div>