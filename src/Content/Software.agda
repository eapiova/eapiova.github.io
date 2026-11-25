{-# OPTIONS --safe #-}

module Content.Software where

open import Data.List.Base using (List; []; _∷_)

open import Html
open import Content.People
open import Site.Ids
open import Site.Types

s4dot2 nuclear regcat archimedean agdarya cubicalContrib cartmell : Project

s4dot2 = project "s4dot2-cut-elimination" "https://github.com/eapiova/s4dot2-cut-elimination"
  (t "This Cubical Agda development formalises cut elimination and the finite model property for S4.2. It is the formal artefact accompanying the S4.2 papers.")

nuclear = project "nuclear" "https://github.com/eapiova/nuclear"
  (t "This Cubical Agda project proves conservation theorems for nuclei over substructural entailment relations, taking Full Lambek logic as the base system. It is the formal artefact of the CiE 2026 paper and includes contributions by " · who altenkirch · t ". "
   · a (ext "https://eapiova.github.io/nuclear/") "Rendered Agda HTML" · t ".")

regcat = project "regcat-normal-form" "https://github.com/eapiova/regcat-normal-form"
  (t "This Agda development gives a machine-checked canonical normal form theorem for the type theory of regular categories. It contains a complete Tait-style logical-relations proof, and all modules use "
   · tt "--safe" · t ".")

archimedean = project "lean-archimedean-portfolio" "https://github.com/eapiova/lean-archimedean-portfolio"
  (t "This Lean 4 and Mathlib project treats the witness-extraction Archimedean property as a typeclass and proves it equivalent to Mathlib’s Archimedean property. It is a companion to the TYPES 2026 abstract.")

agdarya = project "agdarya" "https://github.com/eapiova/agdarya"
  (t "This OCaml project is a fork of Narya, a higher-dimensional observational type theory proof assistant, with Agda-style syntax and layout-sensitive parsing.")

cubicalContrib = project "Contributions to LorenzoMolena/cubical" "https://github.com/LorenzoMolena/cubical"
  (t "My merged pull requests to this experimental Cubical Agda library concern constructive real analysis: Cauchy completion, premetric spaces, univalence of "
   · tt "PrSpaces" · t " and a domain-specific language.")

cartmell = project "cartmell-thesis" "https://github.com/eapiova/cartmell-thesis"
  (t "A community effort, with " · who lumsdaine · t " and others, to typeset John Cartmell’s PhD thesis, "
   · it "Generalised Algebraic Theories and Contextual Categories" · t ", in TeX.")

projects : List Project
projects = s4dot2 ∷ nuclear ∷ regcat ∷ archimedean ∷ agdarya ∷ cubicalContrib ∷ cartmell ∷ []

-- Superseded repositories point at their successor as a value, not a name.
archive : List Archived
archive =
    archived "S4.2" "https://github.com/eapiova/S4.2" "early prototype" s4dot2
  ∷ archived "canonical-normal-form-regular-categories"
             "https://github.com/eapiova/canonical-normal-form-regular-categories"
             "earlier Rocq iteration" regcat
  ∷ []
