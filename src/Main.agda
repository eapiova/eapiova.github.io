{-# OPTIONS --guardedness #-}

-- The only effectful module: read the build date, check that the static
-- files exist, and write `document today p` for every page.
-- Usage: site YYYY-MM-DD   (run from the repository root)

module Main where

open import Data.Bool.Base using (true; if_then_else_)
open import Data.Char.Base using (_≈ᵇ_)
open import Data.List.Base using (List; []; _∷_; length)
open import Data.Maybe.Base using (Maybe; just; nothing) renaming (_>>=_ to _>>=ᴹ_)
open import Data.Nat.Base using (ℕ)
open import Data.Nat.Show using (show; readMaybe)
open import Data.String.Base using (String; _++_; wordsByᵇ)
open import Data.Unit.Polymorphic.Base using (⊤)
open import IO
open import System.Directory using (doesFileExist; createDirectoryIfMissing)
open import System.Environment using (getArgs)
open import System.Exit using (die)
open import System.FilePath.Posix using (mkFilePath)

open import Site.Date
open import Site.Ids
open import Site.Pages using (document)
open import Site.Bibliography using (bibFile; bibFileOf)
import Site.Properties   -- the build does not proceed unless these proofs check

toMonth : ℕ → Maybe Month
toMonth 1  = just January
toMonth 2  = just February
toMonth 3  = just March
toMonth 4  = just April
toMonth 5  = just May
toMonth 6  = just June
toMonth 7  = just July
toMonth 8  = just August
toMonth 9  = just September
toMonth 10 = just October
toMonth 11 = just November
toMonth 12 = just December
toMonth _  = nothing

parseDate : String → Maybe Date
parseDate s with wordsByᵇ ('-' ≈ᵇ_) s
... | y ∷ m ∷ d ∷ [] =
  readMaybe 10 y >>=ᴹ λ y′ →
  (readMaybe 10 m >>=ᴹ toMonth) >>=ᴹ λ m′ →
  readMaybe 10 d >>=ᴹ λ d′ →
  just (date y′ m′ d′)
... | _ = nothing

checkAsset : Asset → IO ⊤
checkAsset x = do
  ok ← doesFileExist (mkFilePath ("static/" ++ assetPath x))
  if ok then pure _ else die ("missing static file: static/" ++ assetPath x)

build : Date → IO ⊤
build today = do
  List.mapM′ checkAsset allAssets
  createDirectoryIfMissing true (mkFilePath "public/bib")
  List.mapM′ (λ p → writeFile ("public/" ++ path p) (document today p)) allPages
  writeFile "public/bib/publications.bib" bibFile
  List.mapM′ (λ i → writeFile ("public/bib/" ++ pubKey i ++ ".bib") (bibFileOf i)) allPubIds
  putStrLn ("Built " ++ show (length allPages) ++ " pages for " ++ showDate today ++ ".")

main : Main
main = run do
  args ← getArgs
  go args
  where
  go : List String → IO ⊤
  go (s ∷ []) with parseDate s
  ... | just today = build today
  ... | nothing    = die "site: expected a date YYYY-MM-DD"
  go _ = die "usage: site YYYY-MM-DD"
