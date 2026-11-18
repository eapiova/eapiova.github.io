{-# OPTIONS --safe #-}

-- Facts about the site, checked whenever it is built.

module Site.Properties where

open import Data.List.Base using (List; map)
open import Data.List.Membership.Propositional using (_∈_)
open import Data.List.Relation.Unary.All using (All)
open import Data.List.Relation.Unary.Any using (here; there)
open import Data.List.Relation.Unary.Linked using (Linked; linked?)
open import Data.Maybe.Base using (just)
open import Data.Maybe.Properties using (just-injective)
open import Data.Nat.Base using (_≥_)
open import Data.Nat.Properties using (_≥?_)
open import Data.String.Properties using (_≟_)
open import Data.Sum.Base using (_⊎_; inj₁; inj₂)
open import Data.List.Membership.DecPropositional _≟_ using (_∈?_)
open import Data.List.Relation.Unary.Unique.DecPropositional _≟_ using (Unique; unique?)
open import Function.Base using (_∘_)
open import Relation.Nullary.Decidable using (from-yes)
open import Relation.Binary.PropositionalEquality using (_≡_; refl; sym; trans; cong)

open import Html.Escape using (Inert; escapeChars; escape-inert)
open import Html.Render using (anchors; refAnchor)
open import Site.Date
open import Site.Ids
open import Site.Types using (Talk)
open import Site.Bibliography using (label)
open import Site.Pages using (body)
open import Content.Talks using (allTalks)

------------------------------------------------------------------------
-- Every page is generated, and every page but home is in the navigation.

pages-complete : ∀ p → p ∈ allPages
pages-complete home         = here refl
pages-complete research     = there (here refl)
pages-complete publications = there (there (here refl))
pages-complete notes        = there (there (there (here refl)))
pages-complete talks        = there (there (there (there (here refl))))
pages-complete teaching     = there (there (there (there (there (here refl)))))
pages-complete software     = there (there (there (there (there (there (here refl))))))
pages-complete cv           = there (there (there (there (there (there (there (here refl)))))))
pages-complete contact      = there (there (there (there (there (there (there (there (here refl))))))))

nav-complete : ∀ p → p ≡ home ⊎ p ∈ navigation
nav-complete home         = inj₁ refl
nav-complete research     = inj₂ (here refl)
nav-complete publications = inj₂ (there (here refl))
nav-complete notes        = inj₂ (there (there (here refl)))
nav-complete talks        = inj₂ (there (there (there (here refl))))
nav-complete teaching     = inj₂ (there (there (there (there (here refl)))))
nav-complete software     = inj₂ (there (there (there (there (there (here refl))))))
nav-complete cv           = inj₂ (there (there (there (there (there (there (here refl)))))))
nav-complete contact      = inj₂ (there (there (there (there (there (there (there (here refl))))))))

------------------------------------------------------------------------
-- Distinct pages are written to distinct files.

fromPath-path : ∀ p → fromPath (path p) ≡ just p
fromPath-path home         = refl
fromPath-path research     = refl
fromPath-path publications = refl
fromPath-path notes        = refl
fromPath-path talks        = refl
fromPath-path teaching     = refl
fromPath-path software     = refl
fromPath-path cv           = refl
fromPath-path contact      = refl

path-injective : ∀ {p q} → path p ≡ path q → p ≡ q
path-injective {p} {q} e =
  just-injective (trans (sym (fromPath-path p)) (trans (cong fromPath e) (fromPath-path q)))

------------------------------------------------------------------------
-- Every citation link resolves, on every build date: the publications
-- page defines the anchor of each publication.

citations-resolve : ∀ today i → refAnchor i ∈ anchors (body today publications)
citations-resolve today glivenko = from-yes (refAnchor glivenko ∈? anchors (body today publications))
citations-resolve today namor    = from-yes (refAnchor namor    ∈? anchors (body today publications))
citations-resolve today ictcs    = from-yes (refAnchor ictcs    ∈? anchors (body today publications))
citations-resolve today jlc      = from-yes (refAnchor jlc      ∈? anchors (body today publications))

-- Bibliography labels are distinct.
labels-unique : Unique (map label allPubIds)
labels-unique = from-yes (unique? (map label allPubIds))

------------------------------------------------------------------------
-- No page defines an anchor twice, whatever the build date.

anchors-unique : ∀ today p → Unique (anchors (body today p))
anchors-unique today home         = from-yes (unique? (anchors (body today home)))
anchors-unique today research     = from-yes (unique? (anchors (body today research)))
anchors-unique today publications = from-yes (unique? (anchors (body today publications)))
anchors-unique today notes        = from-yes (unique? (anchors (body today notes)))
anchors-unique today talks        = from-yes (unique? (anchors (body today talks)))
anchors-unique today teaching     = from-yes (unique? (anchors (body today teaching)))
anchors-unique today software     = from-yes (unique? (anchors (body today software)))
anchors-unique today cv           = from-yes (unique? (anchors (body today cv)))
anchors-unique today contact      = from-yes (unique? (anchors (body today contact)))

------------------------------------------------------------------------
-- The talks are listed newest first.

talks-newest-first : Linked _≥_ (map (ordinal ∘ start ∘ Talk.when) allTalks)
talks-newest-first = from-yes (linked? _≥?_ (map (ordinal ∘ start ∘ Talk.when) allTalks))

------------------------------------------------------------------------
-- Every static file is checked for existence by the build.

assets-complete : ∀ x → x ∈ allAssets
assets-complete cvPdf      = here refl
assets-complete sstt26     = there (here refl)
assets-complete pacman26   = there (there (here refl))
assets-complete dagstuhl26 = there (there (there (here refl)))
assets-complete overlay25  = there (there (there (there (here refl))))
assets-complete ictcs25    = there (there (there (there (there (here refl)))))
assets-complete serifRegular  = there (there (there (there (there (there (here refl))))))
assets-complete serifItalic   = there (there (there (there (there (there (there (here refl)))))))
assets-complete serifSemibold = there (there (there (there (there (there (there (there (here refl))))))))
assets-complete mono          = there (there (there (there (there (there (there (there (there (here refl)))))))))

------------------------------------------------------------------------
-- Escaped text cannot open a tag or end an attribute.

text-inert : ∀ cs → All Inert (escapeChars cs)
text-inert = escape-inert
