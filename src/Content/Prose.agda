{-# OPTIONS --safe #-}

-- Pages and passages that are prose rather than records.

module Content.Prose where

open import Data.List.Base using (List; []; _∷_; map)
open import Data.String.Base using (String)

open import Html
open import Site.Ids

------------------------------------------------------------------------
-- Shared facts

email : String
email = "riccardo.borsetto@univr.it"

logicGroup : Target
logicGroup = ext "https://www.logicverona.it/"

identifiers : List Inlines
identifiers =
    a (ext "https://orcid.org/0009-0001-4751-1516") "ORCID 0009-0001-4751-1516"
  ∷ a (ext "https://github.com/eapiova") "GitHub"
  ∷ a (ext "https://scholar.google.com/citations?user=9rLY-WgAAAAJ") "Google Scholar"
  ∷ []

dagstuhlTitle : Inlines
dagstuhlTitle = b "‘Proof Systems in Actual Practice: Reasoning and Computation’"

------------------------------------------------------------------------
-- Home

-- The home page title as an inference rule.
premises : List String
premises = "type theory" ∷ "constructive mathematics" ∷ "formalisation" ∷ []

ruleLabel : String
ruleLabel = "PhD student, University of Verona"

intro : List Block
intro =
    para (t "I am a PhD student at the Department of Computer Science of the University of Verona, where I started in October 2024. I am a member of the "
          · a logicGroup "Logic group"
          · t " led by Peter M. Schuster, supervised by Margherita Zorzi and Isabella Mastroeni.")
  ∷ para (t "I work on formalised proof theory for modal logic, constructive and computable real analysis, nuclei for substructural logics and categorical logic. A fuller introduction is on the "
          · a (page research) "research page" · t ".")
  ∷ []

contactItems : List Inlines
contactItems = a (mail email) email ∷ identifiers

------------------------------------------------------------------------
-- Research

researchBody : List Block
researchBody =
    para (t "My research concerns type theory, constructive mathematics, proof theory and machine-checked formalisation.")
  ∷ h2 (t "Formalised proof theory of modal logic")
  ∷ para (t "Together with Margherita Zorzi, I study proof systems for modal logic through formalisation. One line uses position-based, or 2-sequent, proof systems for S4.2 and establishes cut elimination via Mix, the subformula property, consistency, completeness and the finite model property. The NAMOR framework treats modal logics through systems parameterised by mode theories, including the axioms D, T, B, 4, 5, .2, .3 and .4.")
  ∷ h2 (t "Constructive and computable real analysis")
  ∷ para (t "In Cubical Agda, I work on constructive and computable real analysis: Cauchy completion, signed-digit representations, premetric spaces and Lipschitz maps. This is joint work with Lorenzo Molena and Marcin Jan Turek-Grzybowski. The signed-digit and coinductive part builds on work with Thorsten Altenkirch.")
  ∷ h2 (t "Nuclei for substructural logics")
  ∷ para (t "Another line concerns conservation theorems for nuclei over substructural entailment relations, with Full Lambek logic as the setting. The results are formalised in Cubical Agda and connect to the CiE 2026 paper with Giulio Fellin, Tarmo Uustalu and Cheng-Syuan Wan.")
  ∷ h2 (t "Categorical logic and normal forms")
  ∷ para (t "In categorical logic, I work on a canonical normal form theorem for the type theory of regular categories, within the modular correspondence of Maria Emilia Maietti, with whom this work is joint. The result has a complete Tait-style Agda formalisation.")
  ∷ h2 (t "Research interests")
  ∷ para (t "Type theory, category theory, proof theory, constructive mathematics, computable real analysis, strong negation and apartness, proof assistants, minimal logic, modal logic, separation logic.")
  ∷ []

------------------------------------------------------------------------
-- Publications: the part that is not a publication record

reports : List Block
reports =
    h2 (t "Reports")
  ∷ para (t "Editorial collector for the report from Dagstuhl Seminar 26121, " · dagstuhlTitle
          · t ", " · it "Dagstuhl Reports"
          · t " Vol. 16 Issue 3, in production (doi: 10.4230/DagRep.16.3.1, not yet active).")
  ∷ []

------------------------------------------------------------------------
-- Teaching, CV, contact

teachingBody : List Block
teachingBody =
    h2 (t "University of Verona")
  ∷ ul ( (b "Teaching Assistant" · t ", 2024-2025: Foundations of Mathematics.")
       ∷ (b "Teaching Assistant" · t ", 2024-2025: Mathematical Logic.")
       ∷ [])
  ∷ h2 (t "Earlier teaching")
  ∷ ul ( (b "Teaching Assistant" · t ", University of Padua, September 2021 - May 2023: Logic and Computability.")
       ∷ (b "Mathematics and Physics teacher" · t ", Liceo (Veneto), 2019-2020.")
       ∷ [])
  ∷ []

cvBody : List Block
cvBody =
    para (a (asset cvPdf) "PDF version")
  ∷ h2 (t "Education")
  ∷ ul ( (b "PhD in Computer Science" · t ", University of Verona, October 2024 - present. Logic group; supervisors: Margherita Zorzi and Isabella Mastroeni. Thesis topic: proof theory for modal logic, formalised in Cubical Agda.")
       ∷ (b "MSc in Computer Science" · t ", University of Padua, April 2023, 110/110 summa cum laude (Erasmus+ exchange at Radboud University Nijmegen). Thesis: "
          · it "A canonical normal form theorem for the type theory of regular categories" · t ".")
       ∷ (b "MSc in Mathematics" · t ", University of Padua, April 2019, 110/110. Thesis: "
          · it "Hedberg’s Theorem in the Minimalist Foundation" · t ".")
       ∷ [])
  ∷ h2 (t "Publications and talks")
  ∷ ul ( (t "See the complete " · a (page publications) "publications" · t " list.")
       ∷ (t "See the complete " · a (page talks) "talks" · t " list.")
       ∷ [])
  ∷ h2 (t "Teaching")
  ∷ ul ( t "Teaching Assistant, University of Verona, 2024-2025: Foundations of Mathematics; Mathematical Logic."
       ∷ t "Teaching Assistant, University of Padua, September 2021 - May 2023: Logic and Computability."
       ∷ t "Mathematics and Physics teacher, Liceo (Veneto), 2019-2020."
       ∷ [])
  ∷ h2 (t "Service")
  ∷ ul ((t "Editorial collector, " · it "Dagstuhl Reports" · t " Vol. 16 (Seminar 26121).") ∷ [])
  ∷ h2 (t "Schools and meetings")
  ∷ ul (map t ( "TPP 2026"
              ∷ "‘Proof and Computation’ Autumn School 2026"
              ∷ "Dagstuhl Seminar 26121"
              ∷ "TYPES 2026"
              ∷ "CSL 2026"
              ∷ "HoTT/UF 2025"
              ∷ "EuroProofNet WG6"
              ∷ "‘Proof and Computation’ Autumn School 2025"
              ∷ "LFPSI School 2025"
              ∷ []))
  ∷ h2 (t "Skills")
  ∷ ul ( (b "Proof assistants:" · t " Cubical Agda, Agda, Lean 4, Coq/Rocq.")
       ∷ (b "Programming:" · t " Haskell, PureScript, F#, OCaml, Python, SQL.")
       ∷ (b "Tools:" · t " Git, LaTeX, Typst, Nix.")
       ∷ [])
  ∷ h2 (t "Languages")
  ∷ para (t "Italian (native), English (C1, IELTS 7.0), basic Japanese and Korean.")
  ∷ []

contactBody : List Block
contactBody =
    h2 (t "Email")
  ∷ para (a (mail email) email)
  ∷ h2 (t "Affiliation")
  ∷ para (t "Department of Computer Science" · nl · t "University of Verona" · nl
          · t "Strada le Grazie 15" · nl · t "37134 Verona, Italy")
  ∷ para (a logicGroup "Logic group")
  ∷ h2 (t "Scholarly identifiers")
  ∷ ul identifiers
  ∷ []
