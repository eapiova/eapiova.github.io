{-# OPTIONS --safe #-}

-- Escaping text for HTML, with a proof that escaped text is inert:
-- it contains no character that could open or close a tag (< >) or
-- end an attribute value (").

module Html.Escape where

open import Data.Bool.Base using (Bool; true; false; _∨_)
open import Data.Char.Base using (Char; toℕ) renaming (_≈ᵇ_ to _==_)
open import Data.List.Base using (List; []; _∷_; _++_)
open import Data.List.Relation.Unary.All using (All; []; _∷_)
open import Data.List.Relation.Unary.All.Properties using (++⁺)
open import Data.Nat.Show using (show)
open import Data.String.Base as String using (String; toList; fromList)
open import Function.Base using (_∘_)
open import Relation.Binary.PropositionalEquality using (_≡_; refl; cong₂)

escapeChar : Char → List Char
escapeChar x with x == '<' | x == '>' | x == '&' | x == '"'
... | true  | _     | _     | _     = toList "&lt;"
... | false | true  | _     | _     = toList "&gt;"
... | false | false | true  | _     = toList "&amp;"
... | false | false | false | true  = toList "&quot;"
... | false | false | false | false = x ∷ []

escapeChars : List Char → List Char
escapeChars []       = []
escapeChars (x ∷ xs) = escapeChar x ++ escapeChars xs

escape : String → String
escape = fromList ∘ escapeChars ∘ toList

-- Every character as a numeric character reference (for e-mail addresses).
entities : String → String
entities = String.concat ∘ go ∘ toList
  where
  go : List Char → List String
  go []       = []
  go (x ∷ xs) = ("&#" String.++ show (toℕ x) String.++ ";") ∷ go xs

------------------------------------------------------------------------
-- Safety

Inert : Char → Set
Inert x = ((x == '<') ∨ (x == '>') ∨ (x == '"')) ≡ false

escapeChar-inert : ∀ x → All Inert (escapeChar x)
escapeChar-inert x with x == '<' in e₁ | x == '>' in e₂ | x == '&' in e₃ | x == '"' in e₄
... | true  | _     | _     | _     = refl ∷ refl ∷ refl ∷ refl ∷ []
... | false | true  | _     | _     = refl ∷ refl ∷ refl ∷ refl ∷ []
... | false | false | true  | _     = refl ∷ refl ∷ refl ∷ refl ∷ refl ∷ []
... | false | false | false | true  = refl ∷ refl ∷ refl ∷ refl ∷ refl ∷ refl ∷ []
... | false | false | false | false = cong₂ _∨_ e₁ (cong₂ _∨_ e₂ e₄) ∷ []

escape-inert : ∀ xs → All Inert (escapeChars xs)
escape-inert []       = []
escape-inert (x ∷ xs) = ++⁺ (escapeChar-inert x) (escape-inert xs)
