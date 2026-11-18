{-# OPTIONS --safe #-}

-- Small total helpers on lists and strings.

module Site.Util where

open import Agda.Builtin.String using (primStringEquality)
open import Data.Bool.Base using (Bool; true; false; if_then_else_; _∨_)
open import Data.Char.Base using (Char) renaming (toℕ to code)
open import Data.List.Base using (List; []; _∷_; [_]; foldr)
open import Data.Nat.Base using (_≡ᵇ_; _<ᵇ_)
open import Data.String.Base using (String; toList; _++_)

infix 4 _==_ _≤ˢ_ _∈ˢ_

_==_ : String → String → Bool
_==_ = primStringEquality

_∈ˢ_ : String → List String → Bool
x ∈ˢ []       = false
x ∈ˢ (y ∷ ys) = (x == y) ∨ (x ∈ˢ ys)

-- Lexicographic order on character codes.
lexLeq : List Char → List Char → Bool
lexLeq []       _        = true
lexLeq (_ ∷ _)  []       = false
lexLeq (x ∷ xs) (y ∷ ys) =
  if code x <ᵇ code y then true
  else if code x ≡ᵇ code y then lexLeq xs ys
  else false

_≤ˢ_ : String → String → Bool
s ≤ˢ t = lexLeq (toList s) (toList t)

-- Stable insertion sort: `le x y` means x may precede y.
insertBy : ∀ {A : Set} → (A → A → Bool) → A → List A → List A
insertBy le x []       = [ x ]
insertBy le x (y ∷ ys) = if le x y then x ∷ y ∷ ys else y ∷ insertBy le x ys

sortBy : ∀ {A : Set} → (A → A → Bool) → List A → List A
sortBy le = foldr (insertBy le) []

filterᵇ : ∀ {A : Set} → (A → Bool) → List A → List A
filterᵇ p []       = []
filterᵇ p (x ∷ xs) = if p x then x ∷ filterᵇ p xs else filterᵇ p xs

-- "A", "A and B", "A, B, and C"
andList : List String → String
andList []           = ""
andList (x ∷ [])     = x
andList (x ∷ y ∷ []) = x ++ " and " ++ y
andList (x ∷ y ∷ z ∷ zs) = x ++ ", " ++ andList′ (y ∷ z ∷ zs)
  where
  andList′ : List String → String
  andList′ []           = ""
  andList′ (x ∷ [])     = "and " ++ x
  andList′ (x ∷ y ∷ ys) = x ++ ", " ++ andList′ (y ∷ ys)
