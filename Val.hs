module Val where
-- Definitions for the Val type and helper functions used by the FORTH interpreter

import Data.Maybe (isJust)
import Text.Read (readMaybe)

-- Algebraic data type representing values on the FORTH stack
data Val
    = Integer Int
    | Real Float
    | Id String
    deriving (Show, Eq)

-- Parse a raw token string into the appropriate Val
-- Priority: try Int first, then Float, fall back to Id
strToVal :: String -> Val
strToVal token =
    case readMaybe token :: Maybe Int of
        Just n  -> Integer n
        Nothing ->
            case readMaybe token :: Maybe Float of
                Just f  -> Real f
                Nothing -> Id token

-- Coerce any numeric Val to Float; used internally by arithmetic ops
toFloat :: Val -> Float
toFloat (Real r)    = r
toFloat (Integer n) = fromIntegral n
toFloat (Id _)      = error "Not convertible to float"

-- Render a Val as a human-readable String (used by STR)
valToStr :: Val -> String
valToStr (Integer n) = show n
valToStr (Real r)    = show r
valToStr (Id s)      = s