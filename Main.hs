module Main where
-- Entry point: reads a .4TH source file and runs the interpreter

import System.Environment (getArgs)
import Interpret
import Val

main :: IO ()
main = do
    (srcFile : _) <- getArgs
    source <- readFile srcFile
    let (remaining, output) = interpret source
    putStr output
    reportLeftovers remaining

-- | Warn the user if the stack was not fully consumed.
reportLeftovers :: [Val] -> IO ()
reportLeftovers [] = return ()
reportLeftovers leftovers = do
    putStrLn ""
    putStrLn "Warning: stack is not empty at end of execution."
    putStrLn $ "Remaining stack: " ++ show leftovers