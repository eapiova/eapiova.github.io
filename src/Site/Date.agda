{-# OPTIONS --safe #-}

-- Calendar dates, written in content as  26 nov 2026.

module Site.Date where

open import Data.Bool.Base using (Bool; _∧_; if_then_else_)
open import Data.Nat.Base using (ℕ; suc; _+_; _*_; _≤ᵇ_; _≡ᵇ_)
open import Data.Nat.Show using (show)
open import Data.String.Base using (String; _++_; padLeft)

data Month : Set where
  January February March April May June July
    August September October November December : Month

monthIndex : Month → ℕ
monthIndex January   = 1
monthIndex February  = 2
monthIndex March     = 3
monthIndex April     = 4
monthIndex May       = 5
monthIndex June      = 6
monthIndex July      = 7
monthIndex August    = 8
monthIndex September = 9
monthIndex October   = 10
monthIndex November  = 11
monthIndex December  = 12

monthName : Month → String
monthName January   = "January"
monthName February  = "February"
monthName March     = "March"
monthName April     = "April"
monthName May       = "May"
monthName June      = "June"
monthName July      = "July"
monthName August    = "August"
monthName September = "September"
monthName October   = "October"
monthName November  = "November"
monthName December  = "December"

record Date : Set where
  constructor date
  field
    year  : ℕ
    month : Month
    day   : ℕ
open Date public

infix 30 _jan_ _feb_ _mar_ _apr_ _may_ _jun_ _jul_ _aug_ _sep_ _oct_ _nov_ _dec_

_jan_ _feb_ _mar_ _apr_ _may_ _jun_ _jul_ _aug_ _sep_ _oct_ _nov_ _dec_ : ℕ → ℕ → Date
d jan y = date y January   d
d feb y = date y February  d
d mar y = date y March     d
d apr y = date y April     d
d may y = date y May       d
d jun y = date y June      d
d jul y = date y July      d
d aug y = date y August    d
d sep y = date y September d
d oct y = date y October   d
d nov y = date y November  d
d dec y = date y December  d

-- An order-embedding of dates into ℕ (months < 32 days, years < 13 months).
ordinal : Date → ℕ
ordinal d = (year d * 13 + monthIndex (month d)) * 32 + day d

infix 4 _≤ᵈ_
_≤ᵈ_ : Date → Date → Bool
d ≤ᵈ e = ordinal d ≤ᵇ ordinal e

oneYearAfter : Date → Date
oneYearAfter d = record d { year = suc (year d) }

showDate : Date → String
showDate d = show (day d) ++ " " ++ monthName (month d) ++ " " ++ show (year d)

monthShort : Month → String
monthShort January   = "Jan"
monthShort February  = "Feb"
monthShort March     = "Mar"
monthShort April     = "Apr"
monthShort May       = "May"
monthShort June      = "Jun"
monthShort July      = "Jul"
monthShort August    = "Aug"
monthShort September = "Sep"
monthShort October   = "Oct"
monthShort November  = "Nov"
monthShort December  = "Dec"

-- 2026-11-26, for <time datetime="…">
iso : Date → String
iso d = show (year d) ++ "-" ++ two (monthIndex (month d)) ++ "-" ++ two (day d)
  where
  two : ℕ → String
  two n = padLeft '0' 2 (show n)

-- 26 Nov  and  26 Nov 2026
showShort showShortYear : Date → String
showShort d     = show (day d) ++ " " ++ monthShort (month d)
showShortYear d = showShort d ++ " " ++ show (year d)

showMonthYear : Date → String
showMonthYear d = monthName (month d) ++ " " ++ show (year d)

-- When something happens: on one day, or over consecutive days.
data When : Set where
  on       : Date → When
  from_to_ : Date → Date → When

start : When → Date
start (on d)        = d
start (from d to _) = d

showWhen : When → String
showWhen (on d) = showDate d
showWhen (from d to e) =
  if sameMonth then show (day d) ++ "-" ++ showDate e
  else showDate d ++ " - " ++ showDate e
  where
  sameMonth = (year d ≡ᵇ year e) ∧ (monthIndex (month d) ≡ᵇ monthIndex (month e))

-- 26 Nov,  10–12 Jun,  30 Jun – 2 Jul
showWhenShort : When → String
showWhenShort (on d) = showShort d
showWhenShort (from d to e) =
  if (year d ≡ᵇ year e) ∧ (monthIndex (month d) ≡ᵇ monthIndex (month e))
  then show (day d) ++ "–" ++ showShort e
  else showShort d ++ " – " ++ showShort e
