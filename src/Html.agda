{-# OPTIONS --safe #-}

-- A fragment of HTML whose content model is enforced by typing:
--
--  * block content (paragraphs, headings, lists) never occurs inside
--    phrasing content, because `Block` and `Inline` are separate types;
--  * links never nest, because the text of a link has mode `inert`,
--    and `link` only produces `Inline flow`;
--  * there is no constructor for raw markup: every string is text and
--    is escaped when rendered (see Html.Escape).

module Html where

open import Data.List.Base using (List; []; _∷_; [_]; _++_)
open import Data.String.Base using (String)

open import Site.Ids using (Target; PubId)

data Mode : Set where
  flow  : Mode   -- phrasing content that may contain links
  inert : Mode   -- phrasing content without interactive content

data Inline : Mode → Set where
  text   : ∀ {m} → String → Inline m
  em     : ∀ {m} → List (Inline m) → Inline m
  strong : ∀ {m} → List (Inline m) → Inline m
  code   : ∀ {m} → String → Inline m
  br     : ∀ {m} → Inline m
  link   : Target → List (Inline inert) → Inline flow

Inlines : Set
Inlines = List (Inline flow)

-- One entry of a bibliography, anchored at the publication it describes.
record Reference : Set where
  constructor reference
  field
    entry : PubId
    label : String
    body  : Inlines

data Block : Set where
  para : Inlines → Block
  h2   : Inlines → Block
  h3   : Inlines → Block
  ul   : List Inlines → Block
  refs : List Reference → Block

------------------------------------------------------------------------
-- Writing content

infixr 5 _·_

_·_ : ∀ {m} → List (Inline m) → List (Inline m) → List (Inline m)
_·_ = _++_

t : ∀ {m} → String → List (Inline m)          -- text
t s = [ text s ]

b : ∀ {m} → String → List (Inline m)          -- bold text
b s = [ strong (t s) ]

it : ∀ {m} → String → List (Inline m)         -- italic text
it s = [ em (t s) ]

tt : ∀ {m} → String → List (Inline m)         -- code
tt s = [ code s ]

bold : ∀ {m} → List (Inline m) → List (Inline m)
bold xs = [ strong xs ]

nl : ∀ {m} → List (Inline m)                  -- line break
nl = [ br ]

a : Target → String → Inlines                 -- link with plain text
a x s = [ link x (t s) ]

a′ : Target → List (Inline inert) → Inlines   -- link with rich text
a′ x xs = [ link x xs ]
