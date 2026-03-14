module Eval where
-- Built-in FORTH operators and functions

import Val
import Data.Char (chr)

-- | Evaluate a FORTH operator or built-in word against the current stack.
--   Returns the updated stack; raises an error for underflow or bad types.
eval :: String -> [Val] -> [Val]

-- ── Multiplication ──────────────────────────────────────────────────────────
eval "*" (Integer b : Integer a : rest) = Integer (a * b) : rest
eval "*" (top : sec : rest)             = Real (toFloat sec * toFloat top) : rest
eval "*" _                              = error "Stack underflow"

-- ── Addition ─────────────────────────────────────────────────────────────────
eval "+" (Integer b : Integer a : rest) = Integer (a + b) : rest
eval "+" (top : sec : rest)             = Real (toFloat sec + toFloat top) : rest
eval "+" _                              = error "Stack underflow"

-- ── Subtraction  (FORTH order: y - x, where x is top) ───────────────────────
eval "-" (Integer top : Integer sec : rest) = Integer (sec - top) : rest
eval "-" (top : sec : rest)                 = Real (toFloat sec - toFloat top) : rest
eval "-" _                                  = error "Stack underflow"

-- ── Division (y / x; integer div when both Integers) ────────────────────────
eval "/" (Integer top : Integer sec : rest)
    | top == 0  = error "Division by zero"
    | otherwise = Integer (sec `div` top) : rest
eval "/" (top : sec : rest)
    | toFloat top == 0 = error "Division by zero"
    | otherwise        = Real (toFloat sec / toFloat top) : rest
eval "/" _ = error "Stack underflow"

-- ── Exponentiation (y ^ x) ──────────────────────────────────────────────────
eval "^" (Integer exp_ : Integer base_ : rest) = Integer (base_ ^ exp_) : rest
eval "^" (exp_ : base_ : rest)                 = Real (toFloat base_ ** toFloat exp_) : rest
eval "^" _                                     = error "Stack underflow"

-- ── Stack manipulation ───────────────────────────────────────────────────────
eval "DUP" (v : rest) = v : v : rest
eval "DUP" []         = error "Stack underflow"

eval "DROP" (_ : rest) = rest
eval "DROP" []         = error "Stack underflow"

eval "SWAP" (a : b : rest) = b : a : rest
eval "SWAP" _              = error "Stack underflow"

-- ── Type conversion ──────────────────────────────────────────────────────────
eval "STR" (v : rest) = Id (valToStr v) : rest
eval "STR" []         = error "Stack underflow"

-- ── String concatenation ─────────────────────────────────────────────────────
-- CONCAT2: pops x then y, pushes y ++ x
eval "CONCAT2" (Id x : Id y : rest) = Id (y ++ x) : rest
eval "CONCAT2" (_ : _ : _)          = error "CONCAT2: arguments must be strings"
eval "CONCAT2" _                    = error "Stack underflow"

-- CONCAT3: pops x, y, z; pushes z ++ y ++ x
eval "CONCAT3" (Id x : Id y : Id z : rest) = Id (z ++ y ++ x) : rest
eval "CONCAT3" (_ : _ : _ : _)             = error "CONCAT3: arguments must be strings"
eval "CONCAT3" _                           = error "Stack underflow"

-- ── Catch-all: push unknown token as a string literal ────────────────────────
eval token stk = Id token : stk


-- | Variant of 'eval' that also threads an output accumulator.
--   State is a (stack, outputString) pair.
evalOut :: String -> ([Val], String) -> ([Val], String)

-- Print top of stack without a newline
evalOut "." (Id s   : rest, acc) = (rest, acc ++ s)
evalOut "." (Integer n : rest, acc) = (rest, acc ++ show n)
evalOut "." (Real r    : rest, acc) = (rest, acc ++ show r)
evalOut "." ([], _)                 = error "Stack underflow"

-- EMIT: pop an integer, emit the corresponding ASCII character
evalOut "EMIT" (Integer n : rest, acc) = (rest, acc ++ [chr n])
evalOut "EMIT" (_ : _, _)              = error "EMIT: argument must be an integer"
evalOut "EMIT" ([], _)                 = error "Stack underflow"

-- CR: append a newline to the output buffer
evalOut "CR" (stk, acc) = (stk, acc ++ "\n")

-- Fall through to pure eval, preserving the output accumulator
evalOut op (stk, acc) = (eval op stk, acc)