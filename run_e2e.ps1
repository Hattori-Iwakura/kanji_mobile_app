#!/usr/bin/env pwsh
# Quick E2E test runner - Run individual test suites
# Usage: 
#   .\run_e2e.ps1                    (run all)
#   .\run_e2e.ps1 auth               (run auth tests only)
#   .\run_e2e.ps1 auth kanji         (run multiple)

param(
    [string[]]$TestSuites = @()
)

$ErrorActionPreference = "Stop"

# Define available test suites
$availableTests = @{
    "auth" = @{
        File = "auth_integration_test.dart"
        Name = "Authentication"
        Tests = 25
    }
    "kanji" = @{
        File = "kanji_integration_test.dart"
        Name = "Kanji Feature"
        Tests = 30
    }
    "list" = @{
        File = "kanji_list_integration_test.dart"
        Name = "Kanji List"
        Tests = 55
    }
    "flashcard" = @{
        File = "flashcard_integration_test.dart"
        Name = "Flashcard"
        Tests = 28
    }
    "quiz" = @{
        File = "quiz_integration_test.dart"
        Name = "Quiz"
        Tests = 23
    }
    "recognition" = @{
        File = "kanji_recognition_integration_test.dart"
        Name = "Kanji Recognition"
        Tests = 23
    }
}

# If no arguments, run all
if ($TestSuites.Count -eq 0) {
    $TestSuites = $availableTests.Keys
}

Write-Host "🧪 Running E2E Integration Tests" -ForegroundColor Cyan
Write-Host ""

# Quick checks
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check backend
$backend = Get-NetTCPConnection -LocalPort 3000 -State Listen -ErrorAction SilentlyContinue
if (-not $backend) {
    Write-Host "❌ Backend not running on port 3000!" -ForegroundColor Red
    Write-Host "   Start with: cd d:\workspace\kanji-web-be && yarn start:dev" -ForegroundColor Gray
    exit 1
}
Write-Host "✅ Backend running" -ForegroundColor Green

# Check emulator
$devices = flutter devices 2>&1 | Out-String
if ($devices -notmatch "emulator-5554") {
    Write-Host "❌ Emulator not running!" -ForegroundColor Red
    Write-Host "   Start Android emulator from Android Studio" -ForegroundColor Gray
    exit 1
}
Write-Host "✅ Emulator running" -ForegroundColor Green
Write-Host ""

# Run selected tests
foreach ($suite in $TestSuites) {
    if (-not $availableTests.ContainsKey($suite)) {
        Write-Host "⚠️  Unknown test suite: $suite" -ForegroundColor Yellow
        Write-Host "   Available: $($availableTests.Keys -join ', ')" -ForegroundColor Gray
        continue
    }
    
    $test = $availableTests[$suite]
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host "🧪 $($test.Name) ($($test.Tests) tests)" -ForegroundColor Blue
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host ""
    
    $startTime = Get-Date
    
    # Run test
    flutter test "integration_test/$($test.File)" -d emulator-5554 --timeout=15m
    
    $exitCode = $LASTEXITCODE
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    Write-Host ""
    if ($exitCode -eq 0) {
        Write-Host "✅ $($test.Name) PASSED" -ForegroundColor Green
    } else {
        Write-Host "❌ $($test.Name) FAILED" -ForegroundColor Red
    }
    Write-Host "⏱️  Duration: $($duration.ToString('mm\:ss'))" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "Done! 🎉" -ForegroundColor Cyan
