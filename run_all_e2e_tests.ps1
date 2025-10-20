#!/usr/bin/env pwsh
# PowerShell script to run all E2E integration tests
# Usage: .\run_all_e2e_tests.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  E2E INTEGRATION TESTS - ALL FEATURES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "🔍 Checking prerequisites..." -ForegroundColor Yellow
Write-Host ""

# 1. Check Flutter
try {
    $flutterVersion = flutter --version 2>&1 | Select-String "Flutter" | Select-Object -First 1
    Write-Host "✅ Flutter: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter not found! Please install Flutter." -ForegroundColor Red
    exit 1
}

# 2. Check backend (port 3000)
$backendRunning = Get-NetTCPConnection -LocalPort 3000 -State Listen -ErrorAction SilentlyContinue
if ($backendRunning) {
    Write-Host "✅ Backend running on port 3000" -ForegroundColor Green
} else {
    Write-Host "❌ Backend NOT running! Start with: cd kanji-web-be && yarn start:dev" -ForegroundColor Red
    exit 1
}

# 3. Check AI model (port 8000) - optional for most tests
$aiModelRunning = Get-NetTCPConnection -LocalPort 8000 -State Listen -ErrorAction SilentlyContinue
if ($aiModelRunning) {
    Write-Host "✅ AI Model running on port 8000" -ForegroundColor Green
} else {
    Write-Host "⚠️  AI Model NOT running (only needed for Recognition tests)" -ForegroundColor Yellow
}

# 4. Check emulator
$devices = flutter devices 2>&1 | Out-String
if ($devices -match "emulator-5554") {
    Write-Host "✅ Emulator running (emulator-5554)" -ForegroundColor Green
} else {
    Write-Host "❌ Emulator NOT running! Start an Android emulator first." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "All prerequisites met! Starting tests..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test results tracking
$testResults = @()
$totalTests = 0
$passedTests = 0
$failedTests = 0
$startTime = Get-Date

# Define test suites
$testSuites = @(
    @{
        Name = "Auth"
        File = "auth_integration_test.dart"
        ExpectedTests = 25
        EstimatedTime = "5 minutes"
    },
    @{
        Name = "Kanji"
        File = "kanji_integration_test.dart"
        ExpectedTests = 30
        EstimatedTime = "7 minutes"
    },
    @{
        Name = "Kanji List"
        File = "kanji_list_integration_test.dart"
        ExpectedTests = 55
        EstimatedTime = "12 minutes"
    },
    @{
        Name = "Flashcard"
        File = "flashcard_integration_test.dart"
        ExpectedTests = 28
        EstimatedTime = "7 minutes"
    },
    @{
        Name = "Quiz"
        File = "quiz_integration_test.dart"
        ExpectedTests = 23
        EstimatedTime = "6 minutes"
    },
    @{
        Name = "Kanji Recognition"
        File = "kanji_recognition_integration_test.dart"
        ExpectedTests = 23
        EstimatedTime = "8 minutes"
    }
)

# Run each test suite
foreach ($suite in $testSuites) {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host "📝 Running: $($suite.Name) Tests" -ForegroundColor Blue
    Write-Host "   File: $($suite.File)" -ForegroundColor Gray
    Write-Host "   Expected: $($suite.ExpectedTests) tests" -ForegroundColor Gray
    Write-Host "   Estimated: $($suite.EstimatedTime)" -ForegroundColor Gray
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host ""
    
    $suiteStartTime = Get-Date
    
    # Run test
    $testOutput = flutter test "integration_test/$($suite.File)" -d emulator-5554 --timeout=15m 2>&1 | Out-String
    $exitCode = $LASTEXITCODE
    
    $suiteEndTime = Get-Date
    $suiteDuration = $suiteEndTime - $suiteStartTime
    
    # Parse results
    if ($testOutput -match '\+(\d+).*-(\d+)') {
        $passed = [int]$matches[1]
        $failed = [int]$matches[2]
        $total = $passed + $failed
    } elseif ($testOutput -match '\+(\d+)') {
        $passed = [int]$matches[1]
        $failed = 0
        $total = $passed
    } else {
        $passed = 0
        $failed = $suite.ExpectedTests
        $total = $suite.ExpectedTests
    }
    
    $totalTests += $total
    $passedTests += $passed
    $failedTests += $failed
    
    # Store result
    $result = @{
        Suite = $suite.Name
        Total = $total
        Passed = $passed
        Failed = $failed
        Duration = $suiteDuration
        ExitCode = $exitCode
    }
    $testResults += $result
    
    # Display result
    if ($exitCode -eq 0 -and $failed -eq 0) {
        Write-Host "✅ $($suite.Name): ALL PASSED ($passed/$total)" -ForegroundColor Green
    } elseif ($passed -gt 0) {
        Write-Host "⚠️  $($suite.Name): PARTIAL ($passed passed, $failed failed)" -ForegroundColor Yellow
    } else {
        Write-Host "❌ $($suite.Name): FAILED ($failed failed)" -ForegroundColor Red
    }
    Write-Host "   Duration: $($suiteDuration.ToString('mm\:ss'))" -ForegroundColor Gray
}

# Final summary
$endTime = Get-Date
$totalDuration = $endTime - $startTime

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "           FINAL SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📊 Test Results:" -ForegroundColor White
Write-Host "   Total Tests:   $totalTests" -ForegroundColor White
Write-Host "   ✅ Passed:     $passedTests" -ForegroundColor Green
Write-Host "   ❌ Failed:     $failedTests" -ForegroundColor Red
Write-Host "   Success Rate:  $([math]::Round(($passedTests / $totalTests) * 100, 2))%" -ForegroundColor White
Write-Host ""
Write-Host "⏱️  Total Duration: $($totalDuration.ToString('hh\:mm\:ss'))" -ForegroundColor White
Write-Host ""

# Detailed breakdown
Write-Host "📋 Detailed Breakdown:" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
foreach ($result in $testResults) {
    $status = if ($result.Failed -eq 0) { "✅" } elseif ($result.Passed -gt 0) { "⚠️ " } else { "❌" }
    $color = if ($result.Failed -eq 0) { "Green" } elseif ($result.Passed -gt 0) { "Yellow" } else { "Red" }
    
    Write-Host "$status $($result.Suite.PadRight(20)) | " -NoNewline -ForegroundColor $color
    Write-Host "$($result.Passed)/$($result.Total) passed | " -NoNewline
    Write-Host "$($result.Duration.ToString('mm\:ss'))" -ForegroundColor Gray
}
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

# Exit code
if ($failedTests -eq 0) {
    Write-Host "🎉 ALL TESTS PASSED! 🎉" -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠️  Some tests failed. Review the output above." -ForegroundColor Yellow
    exit 1
}
