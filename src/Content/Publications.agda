{-# OPTIONS --safe #-}

-- The publication records.  The bibliography, its labels, the status list,
-- and the BibTeX file are all computed from these.

module Content.Publications where

open import Data.List.Base using (List; []; _∷_)
open import Data.Maybe.Base using (just)
open import Data.Product.Base using (_,_)
open import Data.String.Base using (String)

open import Site.Ids using (PubId; glivenko; namor; ictcs; jlc)
open import Site.Types
open import Content.People

s4dot2Repo : String
s4dot2Repo = "https://github.com/eapiova/s4dot2-cut-elimination"

pub : PubId → Publication
pub glivenko = record publication
  { authors   = borsetto ∷ fellin ∷ uustalu ∷ wan ∷ []
  ; title     = "Glivenko’s theorem underneath structure"
  ; venue     = "CiE 2026 (Computability in Europe)"
  ; address   = just "Trier"
  ; publisher = just "Springer LNCS"
  ; series    = just "Lecture Notes in Computer Science"
  ; volume    = just "16674"
  ; pages     = just (162 , 177)
  ; year      = 2026
  ; doi       = just "10.1007/978-3-032-31348-5_11"
  ; artifacts = ("formalization" , "https://github.com/eapiova/nuclear")
              ∷ ("rendered Agda HTML" , "https://eapiova.github.io/nuclear/")
              ∷ []
  }
pub namor = record publication
  { authors   = borsetto ∷ zorzi ∷ []
  ; title     = "NAMOR: a New Agda Library for Modal Extended Sequents"
  ; venue     = "Proceedings of OVERLAY 2025 (7th Workshop on Artificial Intelligence and fOrmal VERification, Logic, Automata, and sYnthesis)"
  ; address   = just "Bologna"
  ; publisher = just "CEUR Workshop Proceedings Vol-4142"
  ; pages     = just (33 , 40)
  ; year      = 2025
  ; url       = just "https://ceur-ws.org/Vol-4142/paper4.pdf"
  }
pub ictcs = record publication
  { authors   = borsetto ∷ zorzi ∷ []
  ; title     = "An Agda Implementation of the Modal Logic S4.2: First Investigations"
  ; venue     = "Proceedings of ICTCS 2025 (26th Italian Conference on Theoretical Computer Science)"
  ; address   = just "Pescara"
  ; publisher = just "CEUR Workshop Proceedings Vol-4039"
  ; pages     = just (163 , 168)
  ; year      = 2025
  ; url       = just "https://ceur-ws.org/Vol-4039/#paper17"
  ; artifacts = ("formalization" , s4dot2Repo) ∷ []
  }
pub jlc = record publication
  { kind      = article
  ; authors   = borsetto ∷ zorzi ∷ []
  ; title     = "Metamathematics of the Modal Logic S4.2 in the Agda Proof Assistant"
  ; venue     = "Journal of Logic and Computation"
  ; year      = 2026
  ; status    = submitted "the Journal of Logic and Computation"
  ; artifacts = ("formalization" , s4dot2Repo) ∷ []
  }
