<div class="main">

# Note of Michael Artin "Algebra" Chapter 6 "Symmetry" (to complete)


# 6.1 SYMMETRY OF PLANE FIGURES

Bilateral, rotational, translational, glide symmetry, and their combinations.

# 6.2 ISOMETRIES

## 6.2.1 Def. (Distance, Isometry)

The distance between points of $\mathbb{R}^n$ is the length $|u-v|$ of the vector $u-v$. An **isometry** of $n$-dimensional space $\mathbb{R}^n$ is a distance-preserving map $f$ from $\mathbb{R}^n$ to itself, a map such that, $\forall u \in \mathbb{R}^n$,
$$
|f(u) - f(v)|=|u-v|.
$$
An isometry will map a figure to a congruent figure.

## 6.2.2. Examples. 
- **(a)** Orthogonal liear operators are isometries.
  - Orthogonal operator preserve dot product $\rightarrow$ distance.
- **(b)** Translation $t_a(x) = x + a$ by vector $a$ is isometry.
- **(c)** The composition of isometries is an isometry.

## 6.2.3 Theo.
The following conditions on a map $\mathbb{R}^n \to \mathbb{R}^n$ are equivalent:
- **(a)** $\varphi$ is an isometry that fixes the origin: $\varphi(0)=0$,
- **(b)** $\varphi$ preserves dot products: $(\varphi(v)\cdot \varphi(w)) = (v \cdot w), \forall v,w$,
- **(c)** $\varphi$ is an orthogonal linear operator.

## 6.2.4 Lemma.
$$
x,y \in \mathbb{R}^n, (x \cdot x) = (y\cdot y) = (x\cdot y) \rightarrow x=y
$$

## 6.2.7 Cor.
Every isometry $f$ of $\mathbb{R}^n$ is the composition of an orthogonal linear operator and a translation.
If $f$ is an isometry and if $f(0)=a$, then $f = t_a\varphi$, where $t_a$ is a translation and $\phi$ is an orthogoal linear operator, and this expression for $f$ is unique.

## 6.2.9 Cor.
The set of all isometries of $\mathbb{R}^n$ forms a group that we denote by $M_n$, with composition of functions as its law of composition.

**The Homomorphism** $\pi: M_n \to O_n$, defined by dropping the translation part of an isometry $f$.

## 6.2.10 Prop.
The map $pi$ is a surjective homomorphism. Its kernel is the set $T=\{t_v\}$ of translations, which is a normal subgroup of $M_n$.

## 6.2.11 Change of Coordinates
Our change in coordinates will be given by some isometry, let's denote it by $\eta$. Let the new cooirdinate vectors of $p$ and $q$ be $x'$ and $y'$. The new formula $m'$ for $f$ is the one such that $m'(x')=y'$. We also have the formula $\eta(x') = x$ analogous to the change of basis formula $PX'=X$.
$$
m' = \eta^{-1} m\eta
$$

## 6.2.12 Cor. 
The homomorphism $\pi$ does not change when the origin is shifted by a translation.

## 6.2.13 Orientation
The determinant of an orthogonal operator $\varphi$ on $\mathbb{R}^n$ is $\pm 1$. There are 2 orientations, **orientation-preserving** and **orientation-reversing**. The map
$$
\sigma: M_n \to \{ \pm 1\}
$$
is a group homomorphism.

# 6.3 ISOMETRIES OF THE PLANE


</div>