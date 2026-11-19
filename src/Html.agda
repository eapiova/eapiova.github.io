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
open import Data.Maybe.Base using (Maybe)
open import Data.Product.Base using (_×_)

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

-- What hangs in the left margin of an entry: a date or a citation label.
data Margin : Set where
  stamp : (iso shown : String) → Margin    -- <time datetime="iso">shown</time>
  tag   : String → Margin
  blank : Margin

-- An item of a chronological or labelled list.  `anchor` makes the entry
-- the target of citations of that publication.
record Entry : Set where
  constructor entry
  field
    margin  : Margin
    anchor  : Maybe PubId
    heading : Maybe Inlines
    body    : Inlines
    links   : List Inlines

data Block : Set where
  para     : Inlines → Block
  h2       : Inlines → Block
  h3       : Inlines → Block
  ul       : List Inlines → Block
  inlineList : List Inlines → Block               -- a short list set on one line
  entries  : List Entry → Block                   -- headed entries with a margin
  timeline : Inlines → List (Margin × Inlines) → Block   -- one-line entries with a margin;
                                                       -- the text is shown when there are none

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
