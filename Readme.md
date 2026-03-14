# FORTH Interpreter (Haskell)

A stack-based FORTH-style interpreter implemented in Haskell using a fold-driven evaluation model.
The interpreter reads FORTH programs written in Reverse Polish Notation (RPN) and executes them using a stack of values.

---

# Quick Start (Recommended)

The following commands will build the interpreter and run all functional tests.

```
cabal update
cabal build
chmod +x check-all.sh
./check-all.sh
```

If all tests pass, the output will indicate that every test case matches its expected output.

---

# Prerequisites

The project requires the Haskell toolchain (GHC and Cabal).
Install the required libraries once before building or running tests.

```
cabal update
cabal install --lib --package-env . QuickCheck
cabal install --lib --package-env . hspec
cabal install --lib --package-env . flow
```

These libraries are used for unit testing and functional verification.

---

# Build the Interpreter

Compile the project with:

```
cabal build
```

This builds the FORTH interpreter defined in the `.cabal` file.

---

# Run the Interpreter

Run the interpreter with a FORTH source file as input:

```
cabal run FORTH -- tests/t1.4TH
```

Replace `t1` with any other test file (`t2`, `t3`, ..., `t10`).

Example:

```
cabal run FORTH -- tests/t5.4TH
```

---

# Run Functional Tests

Functional tests execute full FORTH programs and compare the interpreter output against expected output files.

## Run a Single Test

```
cabal run FORTH -- tests/t1.4TH
```

Compare the output with the expected result:

```
cat tests/t1.out
```

If both outputs match exactly, the test passes.

---

## Run All Tests (macOS / Linux)

```
chmod +x check-all.sh
./check-all.sh
```

This script executes:

```
t1.4TH
t2.4TH
...
t10.4TH
```

and compares each program’s output with its corresponding `.out` file.

---

# Run Unit Tests

Unit tests verify individual modules using the **Hspec** testing framework.

Run them with:

```
runhaskell ValSpec.hs
runhaskell EvalSpec.hs
runhaskell InterpretSpec.hs
```

Each file contains tests targeting a specific interpreter component.

---

# Project Structure

```
Val.hs
    Defines the Val data type and helper functions used throughout the interpreter.

Eval.hs
    Implements built-in FORTH operators and the evalOut evaluation function.

Interpret.hs
    Contains the tokenizer, evaluation step function, and the main interpreter logic.

Main.hs
    Entry point for the program. Reads the input file and runs the interpreter.

tests/
    t1.4TH – t10.4TH
        FORTH source programs used as functional test cases

    t1.out – t10.out
        Expected output for each corresponding test program

ValSpec.hs
    Unit tests for Val.hs

EvalSpec.hs
    Unit tests for Eval.hs

InterpretSpec.hs
    Unit tests for Interpret.hs

check-all.sh
    Bash script for running all functional tests (macOS / Linux)

FORTH.cabal
    Cabal build configuration file
```

---

# Test Case Overview

| File    | Description                                         |
| ------- | --------------------------------------------------- |
| t1.4TH  | Basic arithmetic operations (`+`, `-`, `*`, `/`)    |
| t2.4TH  | Exponentiation (`^`) and compound expressions       |
| t3.4TH  | Stack manipulation (`DUP`, `SWAP`, `DROP`)          |
| t4.4TH  | String operations (`CONCAT2`, `CONCAT3`, `STR`)     |
| t5.4TH  | Character output using `EMIT` and newline with `CR` |
| t6.4TH  | Floating-point arithmetic                           |
| t7.4TH  | Nested RPN expression evaluation                    |
| t8.4TH  | Mixed string and stack operations                   |
| t9.4TH  | Interpreter warning for leftover stack values       |
| t10.4TH | Combined numeric, string, and character operations  |

---

# Issues Encountered

### 1. Cabal `base` Version Conflict

The original `.cabal` file restricted `base` to:

```
base >=4.10 && <4.11
```

Modern versions of GHC include `base` versions above this range.
Removing the upper bound resolved the build failure.

---

### 2. `runhaskell` Ignoring Cabal Dependencies

`runhaskell` does not automatically read dependencies listed in the `.cabal` file.
As a result, `hspec`, `QuickCheck`, and `flow` were not found during unit test execution.

Installing them with:

```
cabal install --lib --package-env .
```

makes them available in the local project environment.

---

### 3. Missing `ChangeLog.md`

The `.cabal` file originally listed `ChangeLog.md` under `extra-source-files`, but the file was not present in the repository.
This caused a build error during packaging.

Removing the entry fixed the issue.

---

### 4. Operand Order in Binary Operations

In FORTH, operands are popped from the stack with the **top element as the right operand**.

For subtraction and division:

```
a b -  => a - b
a b /  => a / b
```

This means the second element popped from the stack becomes the left operand.

All binary operators were implemented with this behavior.

---

### 5. Integer vs Floating-Point Promotion

Arithmetic operators return:

* `Integer` when both operands are integers
* `Real` when either operand is a floating-point value

This behavior is implemented using pattern matching on the `Integer` and `Real` constructors of the `Val` type.
