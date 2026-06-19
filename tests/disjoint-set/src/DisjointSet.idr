module DisjointSet

import Data.Linear.Array

-- Follow parent links to the representative of `i`.
findRoot : (1 _ : LinArray Nat) -> Nat -> Res Nat (const (LinArray Nat))
findRoot arr i =
  let parent # arr = mread arr (cast i) in
  case parent of
    Just p  => if p == i then i # arr else findRoot arr p
    Nothing => i # arr

-- Point the representative of `i` at the representative of `j`.
unite : (1 _ : LinArray Nat) -> Nat -> Nat -> LinArray Nat
unite arr i j =
  let ri # arr = findRoot arr i
      rj # arr = findRoot arr j
      _  # arr = write arr (cast ri) rj in
  arr

applyAll : (1 _ : LinArray Nat) -> List (Nat, Nat) -> LinArray Nat
applyAll arr []                = arr
applyAll arr ((a, b) :: rest)  = applyAll (unite arr a b) rest

-- parent[i] := i for i in [lo, n)
seed : (n : Nat) -> (lo : Nat) -> (1 _ : LinArray Nat) -> LinArray Nat
seed n lo arr =
  if lo >= n
    then arr
    else let _ # arr = write arr (cast lo) lo in
         seed n (S lo) arr

-- Pure representative lookup on the immutable snapshot.
findRootI : IArray Nat -> Nat -> Nat
findRootI arr i =
  case read arr (cast i) of
    Just p  => if p == i then i else findRootI arr p
    Nothing => i

-- Count representatives (elements that are their own parent) in [lo, n).
countRoots : (n : Nat) -> (lo : Nat) -> IArray Nat -> Nat
countRoots n lo arr =
  if lo >= n
    then 0
    else let here = if findRootI arr lo == lo then 1 else 0 in
         here + countRoots n (S lo) arr

-- Number of disjoint sets among the elements [0, n) after applying the given
-- union operations (each pair merges its two elements' sets).
public export
countComponents : (n : Nat) -> List (Nat, Nat) -> Nat
countComponents n edges =
  newArray (cast n) $ \arr =>
    let 1 arr = seed n 0 arr
        1 arr = applyAll arr edges in
    toIArray arr (\iarr => countRoots n 0 iarr)
