{-# OPTIONS --safe #-}

-- Pages and passages that are prose rather than records.

module Content.Prose where

open import Data.List.Base using (List; []; _∷_; map)
open import Data.String.Base using (String)

open import Html
open import Content.People
open import Site.Ids

------------------------------------------------------------------------
-- Shared facts

email personalEmail : String
email         = "riccardo.borsetto@univr.it"
personalEmail = "eapiova@gmail.com"

logicGroup : Target
logicGroup = ext "https://www.logicverona.it/"

-- The group's page on the department website.
logicGroupDept : Target
logicGroupDept = ext "https://www.di.univr.it/?ent=grupporic&id=231&lang=en"

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
          · t " (" · a logicGroupDept "department page" · t ")"
          · t " led by " · who schuster · t " and " · who masini · t ", supervised by " · who zorzi · t " and " · who mastroeni · t ".")
  ∷ para (t "I work on formalised proof theory for modal logic, constructive and computable real analysis, nuclei for substructural logics and categorical logic. A fuller introduction is on the "
          · a (page research) "research page" · t ".")
  ∷ []

contactItems : List Inlines
contactItems = a (mail email) email ∷ a (mail personalEmail) personalEmail ∷ identifiers

------------------------------------------------------------------------
-- Research

researchBody : List Block
researchBody =
    para (t "My research concerns type theory, constructive mathematics, proof theory and machine-checked formalisation.")
  ∷ h2 (t "Formalised proof theory of modal logic")
  ∷ para (t "Together with " · who zorzi · t ", I study proof systems for modal logic through formalisation. One line uses position-based, or 2-sequent, proof systems for S4.2 and establishes cut elimination via Mix, the subformula property, consistency, completeness and the finite model property. The NAMOR framework treats modal logics through systems parameterised by mode theories, including the axioms D, T, B, 4, 5, .2, .3 and .4.")
  ∷ h2 (t "Constructive and computable real analysis")
  ∷ para (t "In Cubical Agda, I work on constructive and computable real analysis: Cauchy completion, signed-digit representations, premetric spaces and Lipschitz maps. This is joint work with " · who molena · t " and Marcin Jan Turek-Grzybowski. The signed-digit and coinductive part builds on work with " · who altenkirch · t ".")
  ∷ h2 (t "Nuclei for substructural logics")
  ∷ para (t "Another line concerns conservation theorems for nuclei over substructural entailment relations, with Full Lambek logic as the setting. The results are formalised in Cubical Agda and connect to the CiE 2026 paper with " · who fellin · t ", " · who uustalu · t " and " · who wan · t ".")
  ∷ h2 (t "Categorical logic and normal forms")
  ∷ para (t "In categorical logic, I work on a canonical normal form theorem for the type theory of regular categories, within the modular correspondence of " · who maietti · t ", with whom this work is joint. The result has a complete Tait-style Agda formalisation.")
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
  ul ( (b "Tutor" · t ", University of Verona, 2025-2026: " · a (ext "https://www.corsi.univr.it/?ent=cs&id=1293&menu=studiare&tab=insegnamenti&aa=2025/2026&codiceCs=S20R&codins=4S02752&discr=&discrCd=&lang=en") "Foundations of Mathematics I"
        · t ", taught by " · who schuster · t ". Exercise classes and marking of submitted exercises.")
     ∷ (b "Tutor" · t ", University of Verona, 2025-2026: " · a (ext "https://www.corsi.univr.it/?ent=cs&id=1352&menu=studiare&tab=insegnamenti&aa=2025/2026&codiceCs=S72R&codins=4S001096&discr=&discrCd=&lang=en") "Mathematical Logic"
        · t ", taught by " · who schuster · t ". Exercise classes.")
     ∷ (b "Tutor" · t ", University of Verona, 2024-2025: " · a (ext "https://www.corsi.univr.it/?ent=cs&id=389&menu=studiare&tab=insegnamenti&aa=2024/2025&codiceCs=S72&codins=4S001104&discr=&discrCd=&lang=en") "Advanced Course in Foundations of Mathematics"
        · t ", taught by " · who schuster · t " and " · who zorzi · t ". Exercise classes.")
     ∷ (b "Tutor" · t ", University of Verona, 2024-2025: " · a (ext "https://www.corsi.univr.it/?ent=cs&id=418&menu=studiare&tab=insegnamenti&aa=2024/2025&codiceCs=S20&codins=4S02752&discr=&discrCd=&lang=en") "Foundations of Mathematics I"
        · t ", taught by " · who schuster · t ". Exercise classes.")
     ∷ (b "Tutor" · t ", University of Padua, 2021-2023: Logic, taught by " · who maietti · t " ("
        · a (ext "https://www.math.unipd.it/~maietti/lez22.html") "2021/22" · t ", "
        · a (ext "https://www.math.unipd.it/~maietti/lez23.html") "2022/23"
        · t "). Exercise classes; also exam invigilation, under a separate contract.")
     ∷ (b "Tutor" · t ", University of Padua, 2021-2023: Computability, taught by " · who baldan · t " ("
        · a (ext "https://web.archive.org/web/20220523022657/http://www.math.unipd.it/~baldan/Computability/") "2021/22" · t ", "
        · a (ext "https://web.archive.org/web/20230206040340/http://www.math.unipd.it/~baldan/Computability/") "2022/23"
        · t "). Exercise classes.")
     ∷ (b "Mathematics and Physics teacher" · t ", Liceo (Veneto), 2019-2020.")
     ∷ [])
  ∷ []

cvBody : List Block
cvBody =
    para (a (asset cvPdf) "PDF version")
  ∷ h2 (t "Education")
  ∷ ul ( (b "PhD in Computer Science" · t ", University of Verona, October 2024 - present. Logic group; supervisors: " · who zorzi · t " and " · who mastroeni · t ". Thesis topic: proof theory for modal logic, formalised in Cubical Agda.")
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
  ∷ ul ( t "Tutor (exercise classes), University of Verona: Foundations of Mathematics I (2024-2026; also marking in 2025-2026), Mathematical Logic (2025-2026), Advanced Course in Foundations of Mathematics (2024-2025)."
       ∷ t "Tutor (exercise classes), University of Padua, 2021-2023: Logic; Computability."
       ∷ t "Exam invigilator, University of Padua, 2021-2023: Logic."
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
  ∷ para (a (mail email) email · t " (university)" · nl · a (mail personalEmail) personalEmail · t " (personal)")
  ∷ h2 (t "Affiliation")
  ∷ para (t "Department of Computer Science" · nl · t "University of Verona" · nl
          · t "Strada le Grazie 15" · nl · t "37134 Verona, Italy")
  ∷ para (t "Logic group: " · a logicGroup "website" · t ", " · a logicGroupDept "department page")
  ∷ h2 (t "Scholarly identifiers")
  ∷ ul identifiers
  ∷ []
