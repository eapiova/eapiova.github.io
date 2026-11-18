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

  talkLine : Inlines
  talkLine =
    event · maybe (t ", " ·_) [] detail · t (", " ++ place) · maybe (t ", " ·_) [] remark
    · t (", " ++ showWhen when) · (if upcoming then t " (upcoming)" else []) · t "."
    · joint coauthors
    · maybe (λ s → t (" " ++ s)) [] credit
    · maybe (λ f → t " " · a (asset f) "Slides" · t ".") [] slides
    where
    joint : List Person → Inlines
    joint [] = []
    joint ps = t (" Joint work with " ++ andList (map fullName ps) ++ ".")

  talkBlocks : List Block
  talkBlocks = h3 (t title) ∷ para talkLine ∷ []

  -- The sentence for the home page, in the right tense.
  talkNews : News
  talkNews = news (start when) sentence
    where
    inCity = maybe (λ c → t (" in " ++ c)) [] city
    sentence =
      if upcoming
      then t "I will speak at " · event · inCity · t (" on " ++ showWhen when ++ " on " ++ topic ++ ".")
      else t "I spoke at " · event · inCity · t (" in " ++ showMonthYear (start when) ++ " on " ++ topic ++ ".")

-- Consecutive talks grouped by year.
byYear : List Talk → List (ℕ × List Talk)
byYear [] = []
byYear (x ∷ xs) with byYear xs
... | (y , ys) ∷ gs = if yr ≡ᵇ y then (y , x ∷ ys) ∷ gs else (yr , [ x ]) ∷ (y , ys) ∷ gs
  where yr = year (start (Talk.when x))
... | [] = (year (start (Talk.when x)) , [ x ]) ∷ []

talksBody : Date → List Block
talksBody today =
  concatMap (λ (y , ts) → h2 (t (show y)) ∷ concatMap (talkBlocks today) ts) (byYear allTalks)

------------------------------------------------------------------------
-- Home

otherNews : List News
otherNews = news (20 jul 2026) (appeared glivenko) ∷ []

-- Everything from the last twelve months, and everything still to come.
recent : Date → List Inlines
recent today =
  map News.body
    (sortBy (λ m n → News.at n ≤ᵈ News.at m)
      (filterᵇ (λ n → today ≤ᵈ oneYearAfter (News.at n))
        (map (talkNews today) allTalks L.++ otherNews)))

homeBody : Date → List Block
homeBody today =
  intro L.++ ( h2 (t "Contact and identifiers") ∷ ul contactItems
             ∷ h2 (t "Recent") ∷ ul (recent today) ∷ [])

------------------------------------------------------------------------
-- Publications

publicationsBody : List Block
publicationsBody =
    para (t "The list below and the " · a bibtex "BibTeX file"
          · t " are generated from the same typed records. The section that follows records the status and formal artifacts of each entry.")
  ∷ h2 (t "Bibliography")
  ∷ refs references
  ∷ h2 (t "Status and artifacts")
  ∷ section "Published" isPublished L.++ section "Under review" isSubmitted L.++ reports
  where
  section : String → (PubId → Bool) → List Block
  section heading keep with filterᵇ keep allPubIds
  ... | [] = []
  ... | is = h3 (t heading) ∷ ul (map statusItem is) ∷ []

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

subtitleOf : Page → Maybe String
subtitleOf home = just subtitle
subtitleOf _    = nothing

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
  ∷ "    <header class=\"page-header\">"
  ∷ ("      <h1>" ++ escape (pageTitle p) ++ "</h1>")
  ∷ maybe (λ s → ("      <p class=\"subtitle\">" ++ escape s ++ "</p>") ∷ []) [] (subtitleOf p) L.++
    "    </header>"
  ∷ map ("    " ++_) (render (body today p)) L.++
    "  </main>"
  ∷ ""
  ∷ "  <footer class=\"site-footer\">"
  ∷ ("    <p>A durable public index, generated by a total Agda program. <a href=\"" ++ path contact ++ "\">Contact " ++ siteName ++ "</a>.</p>")
  ∷ "  </footer>"
  ∷ "</body>"
  ∷ "</html>"
  ∷ [])
  where
  canonical = siteUrl ++ "/" ++ path p
  navItem : Page → String
  navItem q = "        <li><a href=\"" ++ path q ++ "\""
            ++ (if path q == path p then " aria-current=\"page\"" else "")
            ++ ">" ++ navLabel q ++ "</a></li>"
