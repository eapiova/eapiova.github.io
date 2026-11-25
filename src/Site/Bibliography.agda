{-# OPTIONS --safe #-}

-- Everything derived from the publication records: AMS-style labels,
-- bibliography entries, the status list, and the BibTeX file.

module Site.Bibliography where

open import Data.Bool.Base using (Bool; true; false; if_then_else_)
open import Data.Char.Base using (fromℕ; toℕ)
open import Data.List.Base as L using (List; []; _∷_; map; take; length; intersperse; concat)
open import Data.Maybe.Base using (Maybe; just; nothing; maybe)
open import Data.Nat.Base using (ℕ; suc; _+_; _∸_; _%_; _≤ᵇ_)
open import Data.Nat.Show using (show)
open import Data.Product.Base using (_×_; _,_)
open import Data.String.Base as S using (String; _++_; toList; fromList; fromChar; padLeft; unlines)
open import Function.Base using (_∘_)

open import Html
open import Site.Ids
open import Site.Types
open import Site.Util using (_==_; _≤ˢ_; sortBy; filterᵇ; andList)
open import Content.Publications using (pub)

open Publication

------------------------------------------------------------------------
-- Labels:  Borsetto, Zorzi 2025 ↦ BoZo25;  four authors ↦ BFUW26

private
  prefix : ℕ → String → String
  prefix n = fromList ∘ take n ∘ toList

  family = Person.family

  authorPart : List Person → String
  authorPart (p ∷ [])     = prefix 4 (family p)
  authorPart (p ∷ q ∷ []) = prefix 2 (family p) ++ prefix 2 (family q)
  authorPart ps           = S.concat (map (prefix 1 ∘ family) (take 4 ps))

  indexOf : PubId → List PubId → ℕ
  indexOf i []       = 0
  indexOf i (j ∷ js) = if pubKey i == pubKey j then 0 else suc (indexOf i js)

baseLabel : PubId → String
baseLabel i = authorPart (authors (pub i)) ++ padLeft '0' 2 (show (year (pub i) % 100))

-- Entries sharing a base label are told apart by a, b, … in order of title.
label : PubId → String
label i = baseLabel i ++ suffix
  where
  clash  = sortBy (λ j k → title (pub j) ≤ˢ title (pub k))
                  (filterᵇ (λ j → baseLabel j == baseLabel i) allPubIds)
  suffix = if length clash ≤ᵇ 1 then ""
           else fromChar (fromℕ (toℕ 'a' + indexOf i clash))

-- Bibliography order: by label.
byLabel : List PubId
byLabel = sortBy (λ i j → label i ≤ˢ label j) allPubIds

------------------------------------------------------------------------
-- Entries

private
  inverted : Person → String
  inverted p = Person.family p ++ ", " ++ Person.given p

  comma : Maybe String → Inlines
  comma = maybe (λ s → t (", " ++ s)) []

  range : String → ℕ × ℕ → String
  range sep (m , n) = show m ++ sep ++ show n

  statusText : Publication → String
  statusText p with status p
  ... | published   = "Published, " ++ show (year p)
  ... | submitted v = "Submitted to " ++ v ++ ", " ++ show (year p)

-- Where the title links to: the DOI if there is one, else the URL.
landing : Publication → Maybe Target
landing p with doi p | url p
... | just d  | _       = just (ext ("https://doi.org/" ++ d))
... | nothing | just u  = just (ext u)
... | nothing | nothing = nothing

-- Authors. Title. Where, publisher volume, pages, year.
citation : Publication → Inlines
citation p =
  t (andList (map fullName (authors p)) ++ ". ")
  · maybe (λ x → a x (title p)) (t (title p)) (landing p) · t ". "
  · whereabouts (status p)
  where
  whereabouts : Status → Inlines
  whereabouts (submitted v) = t ("Submitted to " ++ v ++ ", " ++ show (year p) ++ ".")
  whereabouts published =
    t "In " · it (venue p) · comma (address p)
    · comma (maybe (λ s → just (s ++ maybe (" " ++_) "" (volume p))) nothing (publisher p))
    · maybe (λ r → t (", pages " ++ range "–" r)) [] (pages p)
    · t (", " ++ show (year p) ++ ".")

pubLinks : PubId → List Inlines
pubLinks i = doiLink L.++ paperLink L.++ map (λ (l , u) → a (ext u) l) (artifacts p)
             L.++ a (bibOf i) "BibTeX" ∷ []
  where
  p = pub i
  doiLink   = maybe (λ d → a (ext ("https://doi.org/" ++ d)) ("doi:" ++ d) ∷ []) [] (doi p)
  paperLink = maybe (λ u → a (ext u) "paper" ∷ []) [] (url p)

pubEntry : PubId → Entry
pubEntry i = entry (tag ("[" ++ label i ++ "]")) (just i) nothing (citation (pub i)) (pubLinks i)

isPublished isSubmitted : PubId → Bool
isPublished i with status (pub i)
... | published   = true
... | submitted _ = false
isSubmitted i with status (pub i)
... | published   = false
... | submitted _ = true

-- "The paper … appeared in …", for the home page.
appeared : PubId → Inlines
appeared i = t "The paper " · b ("“" ++ title p ++ "”") · t " appeared in " · maybe (λ u → a′ (ext u) (it (venue p))) (it (venue p)) (venueSite p)
           · comma (maybe (λ s → just (s ++ maybe (" " ++_) "" (volume p))) nothing (publisher p))
           · maybe (λ r → t (", pages " ++ range "–" r)) [] (pages p) · t "."
  where p = pub i

------------------------------------------------------------------------
-- BibTeX

bibEntry : PubId → String
bibEntry i =
  "@" ++ kindName (kind p) ++ "{" ++ pubKey i ++ ",\n"
  ++ S.intersperse ",\n" (fields p) ++ "\n}"
  where
  p = pub i
  kindName : Kind → String
  kindName inproceedings = "inproceedings"
  kindName article       = "article"

  field′ : String → String → String
  field′ k v = "  " ++ padRight k ++ " = {" ++ v ++ "}"
    where padRight : String → String
          padRight s = s ++ fromList (L.replicate (9 ∸ S.length s) ' ')

  opt : String → Maybe String → List String
  opt k = maybe (λ v → field′ k v ∷ []) []

  fields : Publication → List String
  fields p =
    field′ "author" (S.intersperse " and " (map inverted (authors p)))
    ∷ field′ "title" ("{" ++ title p ++ "}")
    ∷ field′ (venueField (kind p)) ("{" ++ venue p ++ "}")
    ∷ opt "address" (address p)
    L.++ opt "publisher" (publisher p)
    L.++ opt "series" (series p)
    L.++ opt "volume" (volume p)
    L.++ opt "pages" (maybe (just ∘ range "--") nothing (pages p))
    L.++ field′ "year" (show (year p))
    ∷ opt "doi" (doi p)
    L.++ opt "url" (url p)
    L.++ field′ "pubstate" (statusText p) ∷ []
    where
    venueField : Kind → String
    venueField inproceedings = "booktitle"
    venueField article       = "journal"

bibFile : String
bibFile = S.intersperse "\n\n" (map bibEntry byLabel) ++ "\n"

bibFileOf : PubId → String
bibFileOf i = bibEntry i ++ "\n"
