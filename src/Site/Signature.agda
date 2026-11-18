{-# OPTIONS --safe #-}

-- `signature x` is the string "x : <the type of x>", produced by Agda's
-- reflection at compile time, so a signature shown on the site is the
-- definition's actual type and cannot drift from the source.

module Site.Signature where

open import Agda.Builtin.Reflection
open import Agda.Builtin.List using (List; _∷_; [])
open import Agda.Builtin.Unit using (⊤)

-- Print a Π-type's spine as arrows, as written in the source.  Each
-- domain is printed on its own; this is sound for the closed,
-- non-dependent types the site shows.
spine : Term → List ErrorPart
spine (pi (arg _ a) (abs _ b)) = termErr a ∷ strErr " → " ∷ spine b
spine t                        = termErr t ∷ []

macro
  signature : Name → Term → TC ⊤
  signature n hole =
    bindTC (getType n) λ ty →
    bindTC (formatErrorParts (nameErr n ∷ strErr " : " ∷ spine ty)) λ s →
    unify hole (lit (string s))
