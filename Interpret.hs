module Interpret where
-- The top-level FORTH interpreter: tokenises source and drives evaluation

import Val
import Eval
import Flow

-- | Fold-step: apply one FORTH word (or push a literal) to the current state.
--   State is (stack, outputAccumulator).
step :: ([Val], String) -> Val -> ([Val], String)
step state (Id word) = evalOut word state   -- dispatch operator / word
step (stk, acc) literal = (literal : stk, acc)  -- push literal value

-- | Parse and evaluate a complete FORTH source string.
--   Returns the final (stack, output) pair.
interpret :: String -> ([Val], String)
interpret src =
    src
    |> words          -- split into tokens
    |> map strToVal   -- parse each token to Val
    |> foldl step ([], "")  -- fold over tokens, threading state