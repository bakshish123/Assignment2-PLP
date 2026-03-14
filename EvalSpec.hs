-- Unit tests for Eval.hs
-- Run with: runhaskell EvalSpec.hs

import Test.Hspec
import Control.Exception (evaluate)
import Val
import Eval

main :: IO ()
main = hspec $ do

  describe "eval" $ do

    -- ── Multiplication ──────────────────────────────────────────────────────
    context "*" $ do
      it "multiplies two integers" $
          eval "*" [Integer 2, Integer 3] `shouldBe` [Integer 6]

      it "promotes to Real when either operand is a float" $ do
          eval "*" [Integer 2, Real 3.0]  `shouldBe` [Real 6.0]
          eval "*" [Real 3.0, Integer 3]  `shouldBe` [Real 9.0]
          eval "*" [Real 4.0, Real 3.0]   `shouldBe` [Real 12.0]

      it "raises Stack underflow with fewer than two operands" $ do
          evaluate (eval "*" [])          `shouldThrow` errorCall "Stack underflow"
          evaluate (eval "*" [Integer 2]) `shouldThrow` errorCall "Stack underflow"

    -- ── Addition ────────────────────────────────────────────────────────────
    context "+" $ do
      it "adds two integers" $
          eval "+" [Integer 3, Integer 4] `shouldBe` [Integer 7]

      it "promotes to Real when a float is involved" $ do
          eval "+" [Real 1.5, Integer 2]  `shouldBe` [Real 3.5]
          eval "+" [Integer 2, Real 1.5]  `shouldBe` [Real 3.5]
          eval "+" [Real 1.0, Real 2.0]   `shouldBe` [Real 3.0]

      it "raises Stack underflow with fewer than two operands" $ do
          evaluate (eval "+" [])          `shouldThrow` errorCall "Stack underflow"
          evaluate (eval "+" [Integer 1]) `shouldThrow` errorCall "Stack underflow"

    -- ── Subtraction ─────────────────────────────────────────────────────────
    context "-" $ do
      it "computes y - x (FORTH operand order) for integers" $
          eval "-" [Integer 3, Integer 10] `shouldBe` [Integer 7]

      it "computes y - x for floats" $
          eval "-" [Real 1.0, Real 4.0] `shouldBe` [Real 3.0]

      it "raises Stack underflow with fewer than two operands" $ do
          evaluate (eval "-" [])          `shouldThrow` errorCall "Stack underflow"
          evaluate (eval "-" [Integer 1]) `shouldThrow` errorCall "Stack underflow"

    -- ── Division ────────────────────────────────────────────────────────────
    context "/" $ do
      it "performs integer division when both operands are integers" $
          eval "/" [Integer 3, Integer 9] `shouldBe` [Integer 3]

      it "performs float division when a float is involved" $
          eval "/" [Real 2.0, Real 6.0] `shouldBe` [Real 3.0]

      it "raises Division by zero for a zero divisor" $
          evaluate (eval "/" [Integer 0, Integer 5])
              `shouldThrow` errorCall "Division by zero"

      it "raises Stack underflow with fewer than two operands" $ do
          evaluate (eval "/" [])          `shouldThrow` errorCall "Stack underflow"
          evaluate (eval "/" [Integer 2]) `shouldThrow` errorCall "Stack underflow"

    -- ── Exponentiation ──────────────────────────────────────────────────────
    context "^" $ do
      it "raises an integer base to an integer power" $
          eval "^" [Integer 3, Integer 2] `shouldBe` [Integer 8]

      it "raises a float base to a float power" $
          eval "^" [Real 2.0, Real 3.0] `shouldBe` [Real 9.0]

      it "raises Stack underflow with fewer than two operands" $ do
          evaluate (eval "^" [])          `shouldThrow` errorCall "Stack underflow"
          evaluate (eval "^" [Integer 2]) `shouldThrow` errorCall "Stack underflow"

    -- ── Stack words ─────────────────────────────────────────────────────────
    context "DUP" $ do
      it "duplicates the top element for each Val variant" $ do
          eval "DUP" [Integer 2] `shouldBe` [Integer 2, Integer 2]
          eval "DUP" [Real 2.2]  `shouldBe` [Real 2.2, Real 2.2]
          eval "DUP" [Id "x"]    `shouldBe` [Id "x", Id "x"]

      it "raises Stack underflow on an empty stack" $
          evaluate (eval "DUP" []) `shouldThrow` errorCall "Stack underflow"

    context "DROP" $ do
      it "removes the top element" $ do
          eval "DROP" [Integer 1, Integer 2] `shouldBe` [Integer 2]
          eval "DROP" [Id "a"]               `shouldBe` []

      it "raises Stack underflow on an empty stack" $
          evaluate (eval "DROP" []) `shouldThrow` errorCall "Stack underflow"

    context "SWAP" $ do
      it "exchanges the top two elements" $ do
          eval "SWAP" [Integer 1, Integer 2] `shouldBe` [Integer 2, Integer 1]
          eval "SWAP" [Id "a", Id "b"]       `shouldBe` [Id "b", Id "a"]

      it "raises Stack underflow with fewer than two elements" $ do
          evaluate (eval "SWAP" [])          `shouldThrow` errorCall "Stack underflow"
          evaluate (eval "SWAP" [Integer 1]) `shouldThrow` errorCall "Stack underflow"

    -- ── Type conversion ──────────────────────────────────────────────────────
    context "STR" $ do
      it "converts an Integer to its decimal string" $
          eval "STR" [Integer 42] `shouldBe` [Id "42"]

      it "converts a Real to its string representation" $
          eval "STR" [Real 3.14] `shouldBe` [Id "3.14"]

      it "leaves an Id unchanged" $
          eval "STR" [Id "hello"] `shouldBe` [Id "hello"]

      it "raises Stack underflow on an empty stack" $
          evaluate (eval "STR" []) `shouldThrow` errorCall "Stack underflow"

    -- ── String concatenation ─────────────────────────────────────────────────
    context "CONCAT2" $ do
      it "concatenates two string values as y ++ x" $
          eval "CONCAT2" [Id "world", Id "hello"] `shouldBe` [Id "helloworld"]

      it "raises an error when operands are not strings" $
          evaluate (eval "CONCAT2" [Integer 1, Id "hi"])
              `shouldThrow` errorCall "CONCAT2: arguments must be strings"

      it "raises Stack underflow with fewer than two operands" $
          evaluate (eval "CONCAT2" [Id "a"]) `shouldThrow` errorCall "Stack underflow"

    context "CONCAT3" $ do
      it "concatenates three string values as z ++ y ++ x" $
          eval "CONCAT3" [Id "!", Id "world", Id "hello"] `shouldBe` [Id "helloworld!"]

      it "raises an error when any operand is not a string" $
          evaluate (eval "CONCAT3" [Integer 1, Id "y", Id "z"])
              `shouldThrow` errorCall "CONCAT3: arguments must be strings"

      it "raises Stack underflow with fewer than three operands" $
          evaluate (eval "CONCAT3" [Id "a", Id "b"]) `shouldThrow` errorCall "Stack underflow"

  -- ── evalOut ─────────────────────────────────────────────────────────────────
  describe "evalOut" $ do

    context "." $ do
      it "pops and appends the top element to the output buffer" $ do
          evalOut "." ([Id "x"],    "")     `shouldBe` ([], "x")
          evalOut "." ([Integer 2], "")     `shouldBe` ([], "2")
          evalOut "." ([Real 2.2],  "")     `shouldBe` ([], "2.2")

      it "appends to an existing output string" $
          evalOut "." ([Integer 5], "val=") `shouldBe` ([], "val=5")

      it "raises Stack underflow on an empty stack" $
          evaluate (evalOut "." ([], "")) `shouldThrow` errorCall "Stack underflow"

    context "EMIT" $ do
      it "converts an ASCII code to the corresponding character" $ do
          evalOut "EMIT" ([Integer 65], "") `shouldBe` ([], "A")
          evalOut "EMIT" ([Integer 72], "") `shouldBe` ([], "H")
          evalOut "EMIT" ([Integer 33], "") `shouldBe` ([], "!")

      it "appends to an existing output string" $
          evalOut "EMIT" ([Integer 66], "say: ") `shouldBe` ([], "say: B")

      it "raises an error for a non-integer argument" $
          evaluate (evalOut "EMIT" ([Real 65.0], ""))
              `shouldThrow` errorCall "EMIT: argument must be an integer"

      it "raises Stack underflow on an empty stack" $
          evaluate (evalOut "EMIT" ([], "")) `shouldThrow` errorCall "Stack underflow"

    context "CR" $ do
      it "appends a newline when the stack is empty" $
          evalOut "CR" ([], "") `shouldBe` ([], "\n")

      it "appends a newline without touching the stack" $
          evalOut "CR" ([Integer 1], "hello") `shouldBe` ([Integer 1], "hello\n")

    it "delegates non-output ops to eval while preserving the output buffer" $
        evalOut "*" ([Real 2.0, Integer 2], "blah") `shouldBe` ([Real 4.0], "blah")