#!/bin/bash

allPassed=true

for i in {1..10}
do
  echo "=============================="
  echo "Running t$i..."
  echo ""

  actual=$(cabal run FORTH -- tests/t$i.4TH)
  expected=$(cat tests/t$i.out)

  echo "EXPECTED OUTPUT:"
  echo "$expected"
  echo ""

  echo "ACTUAL OUTPUT:"
  echo "$actual"
  echo ""

  if [ "$actual" != "$expected" ]; then
    echo "RESULT: t$i FAILED"
    allPassed=false
  else
    echo "RESULT: t$i PASSED"
  fi

  echo ""
done

echo "=============================="

if [ "$allPassed" = true ]; then
  echo "All tests matched expected output."
else
  echo "Some tests failed."
fi
