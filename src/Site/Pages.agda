{-# OPTIONS --safe #-}

-- The site: for a build date, the content of every page and the
-- document it is rendered to.

module Site.Pages where

open import Data.Bool.Base using (Bool; if_then_else_)
open import Data.List.Base as L using (List; []; _∷_; [_]; map; concatMap)
open import Data.Maybe.Base using (Maybe; just; nothing; maybe)
open import Data.Nat.Base using (ℕ; _≡ᵇ_)
open import Data.Nat.Show using (show)
open import Data.Product.Base using (_×_; _,_)
open import Data.String.Base as S using (String; _++_; unlines)
open import Function.Base using (_∘_)

open import Html
open import Html.Escape using (escape)
open import Html.Render using (render)
open import Site.Date
open import Site.Ids
open import Site.Types
open import Site.Util using (_==_; andList; sortBy; filterᵇ)
open import Site.Bibliography
open import Content.Talks using (allTalks)
open import Content.Software using (projects; archive)
open import Content.Prose

------------------------------------------------------------------------
-- Talks

module _ (today : Date) (x : Talk) where
  open Talk x

  upcoming : Bool
  upcoming = today ≤ᵈ start when

  -- Built as a record expression, so that its heading is known without
  -- knowing the build date (Site.Properties relies on this).
  talkEntry : Entry
  talkEntry = entry (stamp (iso (start when)) (showWhenShort when)) nothing (just (t title)) line []
    where
    joint : List Person → Inlines
    joint [] = []
    joint ps = t (" Joint work with " ++ andList (map fullName ps) ++ ".")
    line =
      event · maybe (t ", " ·_) [] detail · t (", " ++ place) · maybe (t ", " ·_) [] remark · t "."
      · (if upcoming then t " " · it "Upcoming." else [])
      · joint coauthors
      · maybe (λ s → t (" " ++ s)) [] credit
      · maybe (λ f → t " " · a (asset f) "Slides" · t ".") [] slides

  -- The sentence for the home page, in the right tense.
  talkNews : News
  talkNews = news (start when) sentence
    where
    inCity = maybe (λ c → t (" in " ++ c)) [] city
    sentence =
      if upcoming
      then t "Speaking at " · event · inCity · t (" on " ++ topic ++ ". ") · it "Upcoming."
      else t "Spoke at " · event · inCity · t (" on " ++ topic ++ ".")

-- Consecutive talks grouped by year.
byYear : List Talk → List (ℕ × List Talk)
byYear [] = []
byYear (x ∷ xs) with byYear xs
... | (y , ys) ∷ gs = if yr ≡ᵇ y then (y , x ∷ ys) ∷ gs else (yr , [ x ]) ∷ (y , ys) ∷ gs
  where yr = year (start (Talk.when x))
... | [] = (year (start (Talk.when x)) , [ x ]) ∷ []

talksBody : Date → List Block
talksBody today =
  concatMap (λ (y , ts) → h2 (t (show y)) ∷ entries (map (talkEntry today) ts) ∷ []) (byYear allTalks)

------------------------------------------------------------------------
-- Home

otherNews : List News
otherNews = news (20 jul 2026) (appeared glivenko) ∷ []

-- Everything from the last twelve months, and everything still to come.
recent : Date → List (Margin × Inlines)
recent today =
  map (λ n → stamp (iso (News.at n)) (showShortYear (News.at n)) , News.body n)
    (sortBy (λ m n → News.at n ≤ᵈ News.at m)
      (filterᵇ (λ n → today ≤ᵈ oneYearAfter (News.at n))
        (map (talkNews today) allTalks L.++ otherNews)))

homeBody : Date → List Block
homeBody today =
  intro L.++ ( h2 (t "Recent") ∷ timeline (recent today)
             ∷ h2 (t "Contact") ∷ inlineList contactItems ∷ [])

------------------------------------------------------------------------
-- Publications

publicationsBody : List Block
publicationsBody =
    para (t "Each entry links to its formal artifacts and its BibTeX; the "
          · a bibtex "complete BibTeX file" · t " has them all.")
  ∷ section "Published" isPublished L.++ section "Under review" isSubmitted L.++ reports
  where
  section : String → (PubId → Bool) → List Block
  section heading keep with filterᵇ keep byLabel
  ... | [] = []
  ... | is = h2 (t heading) ∷ entries (map pubEntry is) ∷ []

------------------------------------------------------------------------
-- Software

softwareBody : List Block
softwareBody =
  h2 (t "Active projects")
  ∷ concatMap (λ p → h3 (a (ext (Project.repo p)) (Project.name p)) ∷ para (Project.about p) ∷ []) projects
  L.++ h2 (t "Archived or superseded")
  ∷ ul (map item archive)
  ∷ []
  where
  item : Archived → Inlines
  item x = bold (a (ext (Archived.repo x)) (Archived.name x) · t ":")
         · t (" " ++ Archived.note x ++ ", superseded by ")
         · tt (Project.name (Archived.successor x)) · t "."

------------------------------------------------------------------------
-- The site

body : Date → Page → List Block
body today home         = homeBody today
body today research     = researchBody
body today publications = publicationsBody
body today notes        = notesBody
body today talks        = talksBody today
body today teaching     = teachingBody
body today software     = softwareBody
body today cv           = cvBody
body today contact      = contactBody

-- The home page's title is set as an inference rule:
-- research areas above the line, the name below, the affiliation as its label.
premisesOf : Page → List String
premisesOf home = premises
premisesOf _    = []

siteName siteUrl : String
siteName = "Riccardo Borsetto"
siteUrl  = "https://eapiova.github.io"

fullTitle : Page → String
fullTitle home = siteName
fullTitle p    = pageTitle p ++ " · " ++ siteName

document : Date → Page → String
document today p = unlines (
    "<!doctype html>"
  ∷ "<html lang=\"en\">"
  ∷ "<head>"
  ∷ "  <meta charset=\"utf-8\">"
  ∷ "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
  ∷ ("  <title>" ++ escape (fullTitle p) ++ "</title>")
  ∷ ("  <meta name=\"author\" content=\"" ++ siteName ++ "\">")
  ∷ ("  <meta name=\"description\" content=\"" ++ escape (description p) ++ "\">")
  ∷ ("  <link rel=\"canonical\" href=\"" ++ canonical ++ "\">")
  ∷ ("  <meta property=\"og:url\" content=\"" ++ canonical ++ "\">")
  ∷ "  <meta property=\"og:type\" content=\"website\">"
  ∷ ("  <meta property=\"og:title\" content=\"" ++ escape (fullTitle p) ++ "\">")
  ∷ ("  <meta property=\"og:description\" content=\"" ++ escape (description p) ++ "\">")
  ∷ ("  <meta property=\"og:site_name\" content=\"" ++ siteName ++ "\">")
  ∷ ("  <link rel=\"preload\" href=\"" ++ assetPath serifRegular ++ "\" as=\"font\" type=\"font/woff2\" crossorigin>")
  ∷ "  <link rel=\"stylesheet\" href=\"style.css\">"
  ∷ "</head>"
  ∷ "<body>"
  ∷ "  <a class=\"skip-link\" href=\"#content\">Skip to main content</a>"
  ∷ "  <header class=\"site-header\">"
  ∷ ("    <a class=\"site-name\" href=\"" ++ path home ++ "\">" ++ siteName ++ "</a>")
  ∷ "    <nav aria-label=\"Primary navigation\">"
  ∷ "      <ul>"
  ∷ map navItem navigation L.++
    "      </ul>"
  ∷ "    </nav>"
  ∷ "  </header>"
  ∷ ""
  ∷ "  <main id=\"content\" tabindex=\"-1\">"
  ∷ pageHeader (premisesOf p) L.++
    map ("    " ++_) (render (body today p)) L.++
    "  </main>"
  ∷ ""
  ∷ "  <footer class=\"site-footer\">"
  ∷ ("    <p>Generated by a total Agda program, which checks that every internal link resolves. <a href=\"" ++ path contact ++ "\">Contact</a>.</p>")
  ∷ "  </footer>"
  ∷ "</body>"
  ∷ "</html>"
  ∷ [])
  where
  canonical = siteUrl ++ "/" ++ path p
  pageHeader : List String → List String
  pageHeader [] =
      "    <header class=\"page-header\">"
    ∷ ("      <h1>" ++ escape (pageTitle p) ++ "</h1>")
    ∷ "    </header>" ∷ []
  pageHeader ps =
      "    <header class=\"page-header judgement\">"
    ∷ ("      <ul class=\"premises\">" ++ S.concat (map (λ x → "<li>" ++ escape x ++ "</li>") ps) ++ "</ul>")
    ∷ ("      <h1>" ++ escape (pageTitle p) ++ "</h1>")
    ∷ ("      <p class=\"rule-label\">" ++ escape ruleLabel ++ "</p>")
    ∷ "    </header>" ∷ []
  navItem : Page → String
  navItem q = "        <li><a href=\"" ++ path q ++ "\""
            ++ (if path q == path p then " aria-current=\"page\"" else "")
            ++ ">" ++ navLabel q ++ "</a></li>"
