{-# OPTIONS --safe #-}

-- Rendering typed HTML to text.  Heading identifiers are computed from
-- the heading text (as Pandoc does) and made distinct.

module Html.Render where

open import Data.Bool.Base using (Bool; if_then_else_; not; _∨_)
open import Data.Char.Base using (Char; isAlpha; isDigit; isSpace; toLower)
  renaming (_≈ᵇ_ to _≈_)
open import Data.List.Base as List using (List; []; _∷_; [_]; _++_; map; length; dropWhileᵇ)
open import Data.Nat.Base using (ℕ; zero; suc)
open import Data.Nat.Show using (show)
open import Data.String.Base as S using (String; toList; fromList; intersperse; words)
open import Function.Base using (_∘_)

open import Html
open import Html.Escape using (escape; entities)
open import Site.Ids
open import Site.Util using (_∈ˢ_; filterᵇ)

infixr 5 _+_
_+_ : String → String → String
_+_ = S._++_

------------------------------------------------------------------------
-- Link targets

refAnchor : PubId → String
refAnchor i = "ref-" + pubKey i

href : Target → String
href (page p)  = path p
href (ref i)   = path publications + "#" + refAnchor i
href (asset x) = assetPath x
href bibtex    = "bib/publications.bib"
href (ext u)   = u
href (mail m)  = "mailto:" + m

------------------------------------------------------------------------
-- Phrasing content

mutual
  inline : ∀ {m} → Inline m → String
  inline (text s)           = escape s
  inline (em xs)            = "<em>" + inlines xs + "</em>"
  inline (strong xs)        = "<strong>" + inlines xs + "</strong>"
  inline (code s)           = "<code>" + escape s + "</code>"
  inline br                 = "<br>\n"
  inline (link (mail m) xs) = "<a href=\"" + entities ("mailto:" + m) + "\" class=\"email\">" + inlines xs + "</a>"
  inline (link x xs)        = "<a href=\"" + escape (href x) + "\">" + inlines xs + "</a>"

  inlines : ∀ {m} → List (Inline m) → String
  inlines []       = ""
  inlines (x ∷ xs) = inline x + inlines xs

-- The text a reader sees, without markup.
mutual
  plain : ∀ {m} → Inline m → String
  plain (text s)    = s
  plain (em xs)     = plains xs
  plain (strong xs) = plains xs
  plain (code s)    = s
  plain br          = " "
  plain (link _ xs) = plains xs

  plains : ∀ {m} → List (Inline m) → String
  plains []       = ""
  plains (x ∷ xs) = plain x + plains xs

------------------------------------------------------------------------
-- Identifiers

-- Pandoc's rule: lower-case, keep letters, digits, _ - . and spaces,
-- join the words with hyphens, drop everything before the first letter.
slug : String → String
slug s with dropWhileᵇ (not ∘ isAlpha)
              (toList (intersperse "-" (words (fromList (filterᵇ keep (map toLower (toList s)))))))
  where
  keep : Char → Bool
  keep c = isAlpha c ∨ isDigit c ∨ (c ≈ '_') ∨ (c ≈ '-') ∨ (c ≈ '.') ∨ isSpace c
... | [] = "section"
... | cs = fromList cs

-- Repeated identifiers get suffixes -1, -2, …
freshen : List String → String → String
freshen seen x = if x ∈ˢ seen then search 1 (length seen) else x
  where
  search : ℕ → ℕ → String
  search n zero    = x + "-" + show n
  search n (suc k) = if (x + "-" + show n) ∈ˢ seen then search (suc n) k else x + "-" + show n

dedupe : List String → List String
dedupe = go []
  where
  go : List String → List String → List String
  go seen []       = []
  go seen (x ∷ xs) = freshen seen x ∷ go (freshen seen x ∷ seen) xs

headingSlugs : List Block → List String
headingSlugs []          = []
headingSlugs (h2 xs ∷ bs) = slug (plains xs) ∷ headingSlugs bs
headingSlugs (h3 xs ∷ bs) = slug (plains xs) ∷ headingSlugs bs
headingSlugs (_ ∷ bs)     = headingSlugs bs

refAnchors : List Block → List String
refAnchors []             = []
refAnchors (refs rs ∷ bs) = "refs" ∷ map (refAnchor ∘ Reference.entry) rs ++ refAnchors bs
refAnchors (_ ∷ bs)       = refAnchors bs

-- Every identifier a page defines ("content" is the main element).
anchors : List Block → List String
anchors bs = "content" ∷ dedupe (headingSlugs bs) ++ refAnchors bs

------------------------------------------------------------------------
-- Flow content, one line per element

private
  heading : String → List String → Inlines → String
  heading h []      xs = "<" + h + ">" + inlines xs + "</" + h + ">"
  heading h (i ∷ _) xs = "<" + h + " id=\"" + escape i + "\">" + inlines xs + "</" + h + ">"

  rest : List String → List String
  rest []       = []
  rest (_ ∷ is) = is

  item : Inlines → String
  item xs = "<li>" + inlines xs + "</li>"

  entry : Reference → List String
  entry (reference i l body) =
      ("<div id=\"" + refAnchor i + "\" class=\"csl-entry\" role=\"listitem\">")
    ∷ ("<div class=\"csl-left-margin\">[" + escape l + "] </div><div class=\"csl-right-inline\">" + inlines body + "</div>")
    ∷ "</div>"
    ∷ []

  blocks : List String → List Block → List String
  blocks ids []             = []
  blocks ids (para xs ∷ bs) = ("<p>" + inlines xs + "</p>") ∷ blocks ids bs
  blocks ids (h2 xs ∷ bs)   = heading "h2" ids xs ∷ blocks (rest ids) bs
  blocks ids (h3 xs ∷ bs)   = heading "h3" ids xs ∷ blocks (rest ids) bs
  blocks ids (ul xs ∷ bs)   = "<ul>" ∷ map item xs ++ "</ul>" ∷ blocks ids bs
  blocks ids (refs rs ∷ bs) =
    "<div id=\"refs\" class=\"references csl-bib-body\" role=\"list\">"
    ∷ List.concatMap entry rs ++ "</div>" ∷ blocks ids bs

render : List Block → List String
render bs = blocks (dedupe (headingSlugs bs)) bs
