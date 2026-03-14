-- Unit tests for Interpret.hs
-- Run with: runhaskell InterpretSpec.hs

import Test.Hspec
import Control.Exception (evaluate)
import Val
import Eval
import Interpret

main :: IO ()
main = hspec $ do

  describe "step" $ do

    it "pushes a numeric literal onto the stack without touching output" $
        step ([], "x") (Real 3.0) `shouldBe` ([Real 3.0], "x")

    it "dispatches an operator Id and updates the stack" $
        step ([Real 2.2, Integer 2], "") (Id "*") `shouldBe` ([Real 4.4], "")

    it "dispatches a print operator and updates the output buffer" $
        step ([Integer 2], "") (Id ".") `shouldBe` ([], "2")

  describe "interpret" $ do

    context "arithmetic (RPN)" $ do

      it "evaluates a simple integer multiplication" $
          interpret "2 3 *" `shouldBe` ([Integer 6], "")

      it "handles mixed integer/float multiplication" $
          interpret "2 2.2 3.4 * *" `shouldBe` ([Real 14.960001], "")

    context "output" $ do

      it "computes and prints a product" $
          interpret "2 6 * ." `shouldBe` ([], "12")