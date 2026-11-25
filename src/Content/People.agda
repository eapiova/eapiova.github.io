{-# OPTIONS --safe #-}

-- People named on the site, with their homepages when they have one.

module Content.People where

open import Data.Maybe.Base using (Maybe; just; nothing; maybe)
open import Data.List.Base using (List; []; _∷_)
open import Html using (Inlines; t; a; _·_)
open import Site.Ids using (ext)
open import Site.Types using (Person; person; fullName)

borsetto molena turekGrzybowski zorzi fellin uustalu wan schuster masini mastroeni maietti baldan altenkirch petrakis lumsdaine : Person
borsetto         = person "Riccardo" "Borsetto" nothing
molena           = person "Lorenzo" "Molena" (just "https://github.com/LorenzoMolena")
turekGrzybowski  = person "Marcin Jan" "Turek-Grzybowski" nothing
zorzi            = person "Margherita" "Zorzi" (just "https://www.di.univr.it/?ent=persona&id=3616&lang=en")
fellin           = person "Giulio" "Fellin" (just "https://fellin.ga/")
uustalu          = person "Tarmo" "Uustalu" (just "https://cs.ioc.ee/~tarmo/")
wan              = person "Cheng-Syuan" "Wan" (just "https://cswphilo.github.io/")
schuster         = person "Peter M." "Schuster" (just "https://www.di.univr.it/?ent=persona&id=21404&lang=en")
masini           = person "Andrea" "Masini" (just "https://www.di.univr.it/?ent=persona&id=126&lang=en")
mastroeni        = person "Isabella" "Mastroeni" (just "https://www.di.univr.it/?ent=persona&id=181&lang=en")
maietti          = person "Maria Emilia" "Maietti" (just "https://www.math.unipd.it/~maietti/")
baldan           = person "Paolo" "Baldan" (just "https://www.math.unipd.it/~baldan/")
altenkirch       = person "Thorsten" "Altenkirch" (just "https://people.cs.nott.ac.uk/psztxa/")
petrakis         = person "Iosif" "Petrakis" (just "https://www.di.univr.it/?ent=persona&id=42498&lang=en")
lumsdaine        = person "Peter" "LeFanu Lumsdaine" (just "http://peterlefanulumsdaine.com/")

-- Editors of proceedings.
brattka fernau galeotti moscardelli scozzari montanari orlandini saccomanno tonetta : Person
brattka     = person "Vasco" "Brattka" nothing
fernau      = person "Henning" "Fernau" nothing
galeotti    = person "Lorenzo" "Galeotti" nothing
moscardelli = person "Luca" "Moscardelli" nothing
scozzari    = person "Francesca" "Scozzari" nothing
montanari   = person "Angelo" "Montanari" nothing
orlandini   = person "Andrea" "Orlandini" nothing
saccomanno  = person "Nicola" "Saccomanno" nothing
tonetta     = person "Stefano" "Tonetta" nothing

-- A name, linked to the person's homepage when there is one.
who : Person → Inlines
who p = maybe (λ u → a (ext u) (fullName p)) (t (fullName p)) (Person.homepage p)

-- "A", "A and B", "A, B and C", with links.
andWho : List Person → Inlines
andWho []           = []
andWho (p ∷ [])     = who p
andWho (p ∷ q ∷ []) = who p · t " and " · who q
andWho (p ∷ q ∷ r ∷ rs) = who p · t ", " · andWho (q ∷ r ∷ rs)
