# 🧪 E2E Test Suite Runner (PowerShell)
# Runs all integration tests and generates summary report

Write-Host "╔════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                     🧪 E2E TEST SUITE RUNNER                              ║" -ForegroundColor Cyan
Write-Host "║                     Kanji Learning App                                     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "📦 Flutter Version: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Check if backend is running
Write-Host "🔍 Checking backend server..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/kanji?page=1&limit=1" -TimeoutSec 3 -ErrorAction SilentlyContinue
    Write-Host "✅ Backend server is running" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Backend server is not responding" -ForegroundColor Yellow
    Write-Host "   Please start backend: cd kanji-web-be && npm run start:dev" -ForegroundColor Yellow
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne 'y' -and $continue -ne 'Y') {
        exit 1
    }
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                         RUNNING TEST MODULES                               ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Test results tracking
$testResults = @{}
$totalTests = 0
$passedTests = 0
$failedTests = 0

# Function to run test and track result
function Run-Test {
    param(
        [string]$TestName,
        [string]$TestFile,
        [int]$TestCount
    )
    
    Write-Host "─────────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host "📝 Running: $TestName ($TestCount tests)" -ForegroundColor Cyan
    Write-Host "─────────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
    
    $result = flutter test $TestFile
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        $testResults[$TestName] = "✅ PASSED"
        $script:passedTests += $TestCount
        Write-Host "✅ $TestName PASSED" -ForegroundColor Green
    } else {
        $testResults[$TestName] = "❌ FAILED"
        $script:failedTests += $TestCount
        Write-Host "❌ $TestName FAILED" -ForegroundColor Red
    }
    
    $script:totalTests += $TestCount
    Write-Host ""
}

# Run all test modules
Run-Test -TestName "Auth Module" -TestFile "integration_test/auth_test.dart" -TestCount 13
Run-Test -TestName "Kanji Module" -TestFile "integration_test/kanji_test.dart" -TestCount 8
Run-Test -TestName "Kanji List Module" -TestFile "integration_test/kanji_list_test.dart" -TestCount 13
Run-Test -TestName "Kanji Search Module" -TestFile "integration_test/kanji_search_test.dart" -TestCount 10
Run-Test -TestName "Kanji Recognition" -TestFile "integration_test/kanji_recognition_test.dart" -TestCount 5
Run-Test -TestName "Flashcard Deck" -TestFile "integration_test/flashcard_deck_test.dart" -TestCount 23
Run-Test -TestName "Quiz CRUD" -TestFile "integration_test/quiz_test.dart" -TestCount 14
Run-Test -TestName "Quiz Questions" -TestFile "integration_test/quiz_question_test.dart" -TestCount 12
Run-Test -TestName "Quiz Attempts" -TestFile "integration_test/quiz_attempt_test.dart" -TestCount 12
Run-Test -TestName "Quiz Publish" -TestFile "integration_test/quiz_publish_request_test.dart" -TestCount 12

# Generate summary report
Write-Host "╔════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                           📊 TEST SUMMARY                                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

foreach ($test in $testResults.Keys | Sort-Object) {
    $status = $testResults[$test]
    if ($status -like "*PASSED*") {
        Write-Host "  $status $test" -ForegroundColor Green
    } else {
        Write-Host "  $status $test" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "─────────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  📈 Total Tests: $totalTests" -ForegroundColor White
Write-Host "  ✅ Passed: $passedTests" -ForegroundColor Green
Write-Host "  ❌ Failed: $failedTests" -ForegroundColor Red

if ($failedTests -eq 0) {
    Write-Host "  🎉 Success Rate: 100%" -ForegroundColor Green
    Write-Host "─────────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host "  🏆 ALL TESTS PASSED!" -ForegroundColor Green
    exit 0
} else {
    $successRate = [math]::Round(($passedTests / $totalTests) * 100, 1)
    Write-Host "  📊 Success Rate: $successRate%" -ForegroundColor Yellow
    Write-Host "─────────────────────────────────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host "  ⚠️  SOME TESTS FAILED" -ForegroundColor Yellow
    Write-Host "  💡 Check logs above for details" -ForegroundColor Yellow
    exit 1
}
