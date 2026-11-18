{-# OPTIONS --safe #-}

-- The closed universes the site talks about: its pages, its publications,
-- its static files, and the link targets built from them.  Every internal
-- link is a value of `Target`, so a link to a page, a citation, or a file
-- that does not exist cannot be written.

module Site.Ids where

open import Data.Bool.Base using (if_then_else_)
open import Data.List.Base using (List; []; _∷_)
open import Data.Maybe.Base using (Maybe; just; nothing)
open import Data.String.Base using (String)

open import Site.Util using (_==_)

------------------------------------------------------------------------
-- Pages

data Page : Set where
  home research publications notes talks teaching software cv contact : Page

allPages : List Page
allPages = home ∷ research ∷ publications ∷ notes ∷ talks ∷ teaching
         ∷ software ∷ cv ∷ contact ∷ []

-- The primary navigation; the site name links home.
navigation : List Page
navigation = research ∷ publications ∷ notes ∷ talks ∷ teaching
           ∷ software ∷ cv ∷ contact ∷ []

path : Page → String
path home         = "index.html"
path research     = "research.html"
path publications = "publications.html"
path notes        = "notes.html"
path talks        = "talks.html"
path teaching     = "teaching.html"
path software     = "software.html"
path cv           = "cv.html"
path contact      = "contact.html"

-- A left inverse of `path`, used to prove that pages never share a file.
fromPath : String → Maybe Page
fromPath s =
  if s == "index.html"        then just home         else
  if s == "research.html"     then just research     else
  if s == "publications.html" then just publications else
  if s == "notes.html"        then just notes        else
  if s == "talks.html"        then just talks        else
  if s == "teaching.html"     then just teaching     else
  if s == "software.html"     then just software     else
  if s == "cv.html"           then just cv           else
  if s == "contact.html"      then just contact      else
  nothing

navLabel : Page → String
navLabel home         = "Home"
navLabel research     = "Research"
navLabel publications = "Publications"
navLabel notes        = "Notes"
navLabel talks        = "Talks"
navLabel teaching     = "Teaching"
navLabel software     = "Software"
navLabel cv           = "CV"
navLabel contact      = "Contact"

pageTitle : Page → String
pageTitle home         = "Riccardo Borsetto"
pageTitle research     = "Research"
pageTitle publications = "Publications"
pageTitle notes        = "Notes"
pageTitle talks        = "Talks"
pageTitle teaching     = "Teaching"
pageTitle software     = "Software / Formalizations"
pageTitle cv           = "Curriculum vitae"
pageTitle contact      = "Contact"

description : Page → String
description home         = "Academic website of Riccardo Borsetto, PhD student in computer science at the University of Verona."
description research     = "Research by Riccardo Borsetto in type theory, proof theory, constructive mathematics, and formalization."
description publications = "Publications by Riccardo Borsetto, with status and formalization links."
description notes        = "Expository notes by Riccardo Borsetto."
description talks        = "Talks and presentation materials by Riccardo Borsetto."
description teaching     = "Teaching experience of Riccardo Borsetto."
description software     = "Proof-assistant developments, research software, and formalizations by Riccardo Borsetto."
description cv           = "Curriculum vitae of Riccardo Borsetto."
description contact      = "Academic contact details and scholarly identifiers for Riccardo Borsetto."

------------------------------------------------------------------------
-- Publications

data PubId : Set where
  glivenko namor ictcs jlc : PubId

allPubIds : List PubId
allPubIds = glivenko ∷ namor ∷ ictcs ∷ jlc ∷ []

pubKey : PubId → String
pubKey glivenko = "borsetto-fellin-uustalu-wan-2026-glivenko"
pubKey namor    = "borsetto-zorzi-2025-namor"
pubKey ictcs    = "borsetto-zorzi-2025-ictcs"
pubKey jlc      = "borsetto-zorzi-s4dot2-jlc"

------------------------------------------------------------------------
-- Static files (checked to exist under static/ when the site is built)

data Asset : Set where
  cvPdf sstt26 pacman26 dagstuhl26 overlay25 ictcs25 : Asset
  serifRegular serifItalic serifSemibold mono : Asset   -- referenced by style.css

allAssets : List Asset
allAssets = cvPdf ∷ sstt26 ∷ pacman26 ∷ dagstuhl26 ∷ overlay25 ∷ ictcs25
          ∷ serifRegular ∷ serifItalic ∷ serifSemibold ∷ mono ∷ []

assetPath : Asset → String
assetPath cvPdf      = "files/cv.pdf"
assetPath sstt26     = "files/slides/sstt-2026.pdf"
assetPath pacman26   = "files/slides/pacman-2026.pdf"
assetPath dagstuhl26 = "files/slides/dagstuhl-26121.pdf"
assetPath overlay25  = "files/slides/overlay-2025.pdf"
assetPath ictcs25    = "files/slides/ictcs-2025.pdf"
assetPath serifRegular  = "fonts/LibertinusSerif-Regular.woff2"
assetPath serifItalic   = "fonts/LibertinusSerif-Italic.woff2"
assetPath serifSemibold = "fonts/LibertinusSerif-Semibold.woff2"
assetPath mono          = "fonts/JuliaMono-RegularLatin.woff2"

------------------------------------------------------------------------
-- Link targets

data Target : Set where
  page   : Page → Target     -- another page of the site
  ref    : PubId → Target    -- an entry of the bibliography
  asset  : Asset → Target    -- a static file
  bibtex : Target            -- the generated BibTeX file
  bibOf  : PubId → Target    -- the BibTeX of one publication
  ext    : String → Target   -- an external URL
  mail   : String → Target   -- an e-mail address
