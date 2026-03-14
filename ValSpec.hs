-- Unit tests for Val.hs
-- Run with: runhaskell ValSpec.hs

import Test.Hspec
import Control.Exception (evaluate)
import Val

main :: IO ()
main = hspec $ do

  describe "strToVal" $ do

    it "parses a bare integer token" $
        strToVal "2" `shouldBe` Integer 2

    it "parses a floating-point token" $
        strToVal "2.0" `shouldBe` Real 2.0

    it "treats an alphanumeric token as an identifier" $
        strToVal "x2" `shouldBe` Id "x2"

  describe "toFloat" $ do

    it "leaves a Real value unchanged" $
        toFloat (Real 2.0) `shouldBe` (2.0 :: Float)

    it "widens an Integer to Float" $
        toFloat (Integer 2) `shouldBe` (2.0 :: Float)

    it "raises an error for a non-numeric Id" $
        evaluate (toFloat (Id "x")) `shouldThrow` errorCall "Not convertible to float"