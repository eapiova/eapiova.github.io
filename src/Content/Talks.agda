{-# OPTIONS --safe #-}

-- Every talk, newest first (checked in Site.Properties).  The talks page,
-- the home page's "Recent" list, and the upcoming/past wording are all
-- computed from this list.

module Content.Talks where

open import Data.List.Base using (List; []; _∷_)
open import Data.Maybe.Base using (just)

open import Html
open import Site.Date
open import Site.Ids
open import Site.Types
open import Content.People

trendsInLogic tpp proofAndComputation pacman sstt dagstuhl overlay ictcsTalk : Talk

trendsInLogic = record talk
  { title  = "Strong inequality in observational type theory"
  ; event  = t "Trends in Logic XXVI"
  ; place  = "Tohoku University, Sendai, Japan"
  ; city   = just "Sendai"
  ; when   = on (26 nov 2026)
  ; topic  = "strong inequality in observational type theory"
  ; credit = just "Based on an idea by Iosif Petrakis."
  }

tpp = record talk
  { title  = "Making injectivity compute in Cubical Agda"
  ; event  = t "TPP 2026"
  ; detail = just (t "the 22nd Theorem Proving and Provers Meeting")
  ; place  = "RIKEN AIP, Tokyo, Japan"
  ; city   = just "Tokyo"
  ; when   = on (17 nov 2026)
  ; topic  = "making injectivity compute in Cubical Agda"
  }

proofAndComputation = record talk
  { title  = "Strong Inequality in Observational Type Theory"
  ; event  = t "Proof and Computation 2026"
  ; detail = just (t "an international autumn school")
  ; place  = "Fischbachau, Germany"
  ; city   = just "Fischbachau"
  ; when   = on (18 sep 2026)
  ; topic  = "strong inequality in observational type theory"
  ; credit = just "Based on an idea by Iosif Petrakis."
  }

pacman = record talk
  { title     = "Kraus’s Magic Trick for Computing with Constructive Reals"
  ; event     = t "PACM∧N 2026"
  ; place     = "Verona, Italy"
  ; city      = just "Verona"
  ; when      = from 10 jun 2026 to 12 jun 2026
  ; topic     = "computing with constructive reals"
  ; coauthors = molena ∷ turekGrzybowski ∷ []
  ; slides    = just pacman26
  }

sstt = record talk
  { title  = "A canonical normal form theorem for the type theory of regular categories"
  ; event  = t "SSTT 2026"
  ; place  = "Ljubljana, Slovenia"
  ; city   = just "Ljubljana"
  ; remark = just (t "co-located with MFPS 2026")
  ; when   = from 4 jun 2026 to 5 jun 2026
  ; topic  = "canonical normal forms for regular categories"
  ; slides = just sstt26
  }

dagstuhl = record talk
  { title  = "Where does ACω hide in constructive reals?"
  ; event  = t "Dagstuhl Seminar 26121"
  ; detail = just (t "“Proof Systems in Actual Practice: Reasoning and Computation”")
  ; place  = "Schloss Dagstuhl, Germany"
  ; when   = on (16 mar 2026)
  ; topic  = "countable choice in constructive reals"
  ; slides = just dagstuhl26
  }

overlay = record talk
  { title     = "NAMOR: a New Agda Library for Modal Extended Sequents"
  ; event     = t "OVERLAY 2025"
  ; place     = "Bologna, Italy"
  ; city      = just "Bologna"
  ; when      = on (26 oct 2025)
  ; topic     = "NAMOR, an Agda library for modal extended sequents"
  ; coauthors = zorzi ∷ []
  ; slides    = just overlay25
  }

ictcsTalk = record talk
  { title     = "An Agda Implementation of the Modal Logic S4.2: First Investigations"
  ; event     = t "ICTCS 2025"
  ; place     = "Pescara, Italy"
  ; city      = just "Pescara"
  ; when      = on (12 sep 2025)
  ; topic     = "an Agda implementation of the modal logic S4.2"
  ; coauthors = zorzi ∷ []
  ; slides    = just ictcs25
  }

allTalks : List Talk
allTalks = trendsInLogic ∷ tpp ∷ proofAndComputation ∷ pacman ∷ sstt
         ∷ dagstuhl ∷ overlay ∷ ictcsTalk ∷ []
