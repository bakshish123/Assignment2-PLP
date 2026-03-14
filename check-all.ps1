$allPassed = $true

for ($i = 1; $i -le 10; $i++) {

    Write-Host "Running t$i..." -ForegroundColor Cyan

    $actual = cabal run FORTH -- "tests/t$i.4TH"
    $expected = Get-Content "tests/t$i.out"

    $diff = Compare-Object $actual $expected

    if ($diff) {
        Write-Host "t$i FAILED" -ForegroundColor Red
        $diff
        $allPassed = $false
    }
    else {
        Write-Host "t$i PASSED" -ForegroundColor Green
    }

    Write-Host ""
}

if ($allPassed) {
    Write-Host "All tests matched expected output." -ForegroundColor Green
}
else {
    Write-Host "Some tests failed." -ForegroundColor Red
}