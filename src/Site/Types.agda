{-# OPTIONS --safe #-}

-- The kinds of facts the site records.

module Site.Types where

open import Data.List.Base using (List; [])
open import Data.Maybe.Base using (Maybe; nothing)
open import Data.Nat.Base using (ℕ)
open import Data.Product.Base using (_×_)
open import Data.String.Base using (String; _++_)

open import Html using (Inlines)
open import Site.Date
open import Site.Ids using (Asset)

record Person : Set where
  constructor person
  field
    given    : String
    family   : String
    homepage : Maybe String

fullName : Person → String
fullName p = Person.given p ++ " " ++ Person.family p

------------------------------------------------------------------------
-- Talks

record Talk : Set where
  field
    title     : String
    event     : String           -- "SSTT 2026"
    site      : Maybe String     -- the event's web page
    detail    : Maybe Inlines    -- shown after the event on the talks page
    place     : String           -- "Ljubljana, Slovenia"
    city      : Maybe String     -- used in sentences: "… in Ljubljana"
    remark    : Maybe Inlines    -- "co-located with MFPS 2026"
    when      : When
    topic     : String           -- used in sentences: "… on <topic>"
    coauthors : List Person
    credit    : Maybe Inlines
    slides    : Maybe Asset

-- Defaults for the optional fields; content overrides the rest.
talk : Talk
talk = record
  { title = ""; event = ""; site = nothing; detail = nothing; place = ""; city = nothing
  ; remark = nothing; when = on (1 jan 1970); topic = ""; coauthors = []
  ; credit = nothing; slides = nothing }

------------------------------------------------------------------------
-- Publications

data Kind : Set where
  inproceedings article : Kind

-- The volume a paper appeared in and the event it belongs to, as the
-- bibliography files need them (official names, not display text).
record Proceedings : Set where
  field
    booktitle  : String
    editors    : List Person
    publisher  : String
    series     : Maybe String
    number     : Maybe String       -- volume within the series
    eventtitle : Maybe String       -- when the book title does not already name it
    place      : String
    eventdate  : When

data Status : Set where
  published : Status
  submitted : String → Status    -- submitted to the named venue

record Publication : Set where
  field
    kind      : Kind
    authors   : List Person
    title     : String
    venue     : String           -- booktitle or journal
    venueSite : Maybe String     -- the conference's web page
    address   : Maybe String
    publisher : Maybe String
    series    : Maybe String
    volume    : Maybe String
    pages     : Maybe (ℕ × ℕ)
    year      : ℕ
    url       : Maybe String
    doi       : Maybe String
    status    : Status
    artifacts : List (String × String)   -- label, URL
    proceedings : Maybe Proceedings

publication : Publication
publication = record
  { kind = inproceedings; authors = []; title = ""; venue = ""; venueSite = nothing
  ; address = nothing; publisher = nothing; series = nothing; volume = nothing
  ; pages = nothing; year = 1970; url = nothing; doi = nothing
  ; status = published; artifacts = []; proceedings = nothing }

------------------------------------------------------------------------
-- Software

record Project : Set where
  constructor project
  field
    name  : String
    repo  : String
    about : Inlines

record Archived : Set where
  constructor archived
  field
    name      : String
    repo      : String
    note      : String
    successor : Project

------------------------------------------------------------------------
-- News items on the home page

record News : Set where
  constructor news
  field
    at   : Date
    body : Inlines
