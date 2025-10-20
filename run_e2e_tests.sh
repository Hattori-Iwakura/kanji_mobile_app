#!/bin/bash

# 🧪 E2E Test Suite Runner
# Runs all integration tests and generates summary report

echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                     🧪 E2E TEST SUITE RUNNER                              ║"
echo "║                     Kanji Learning App                                     ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    exit 1
fi

echo "📦 Flutter Version:"
flutter --version | head -n 1
echo ""

# Check if backend is running
echo "🔍 Checking backend server..."
if curl -s http://localhost:3000/api/kanji?page=1&limit=1 > /dev/null; then
    echo "✅ Backend server is running"
else
    echo "⚠️  Backend server is not responding"
    echo "   Please start backend: cd kanji-web-be && npm run start:dev"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                         RUNNING TEST MODULES                               ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Test results tracking
declare -A test_results
total_tests=0
passed_tests=0
failed_tests=0

# Function to run test and track result
run_test() {
    local test_name=$1
    local test_file=$2
    local test_count=$3
    
    echo "─────────────────────────────────────────────────────────────────────────────"
    echo "📝 Running: $test_name ($test_count tests)"
    echo "─────────────────────────────────────────────────────────────────────────────"
    
    if flutter test $test_file; then
        test_results[$test_name]="✅ PASSED"
        passed_tests=$((passed_tests + test_count))
    else
        test_results[$test_name]="❌ FAILED"
        failed_tests=$((failed_tests + test_count))
    fi
    
    total_tests=$((total_tests + test_count))
    echo ""
}

# Run all test modules
run_test "Auth Module" "integration_test/auth_test.dart" 13
run_test "Kanji Module" "integration_test/kanji_test.dart" 8
run_test "Kanji List Module" "integration_test/kanji_list_test.dart" 13
run_test "Kanji Search Module" "integration_test/kanji_search_test.dart" 10
run_test "Kanji Recognition" "integration_test/kanji_recognition_test.dart" 5
run_test "Flashcard Deck" "integration_test/flashcard_deck_test.dart" 23
run_test "Quiz CRUD" "integration_test/quiz_test.dart" 14
run_test "Quiz Questions" "integration_test/quiz_question_test.dart" 12
run_test "Quiz Attempts" "integration_test/quiz_attempt_test.dart" 12
run_test "Quiz Publish" "integration_test/quiz_publish_request_test.dart" 12

# Generate summary report
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                           📊 TEST SUMMARY                                  ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

for test_name in "${!test_results[@]}"; do
    echo "  ${test_results[$test_name]} $test_name"
done

echo ""
echo "─────────────────────────────────────────────────────────────────────────────"
echo "  📈 Total Tests: $total_tests"
echo "  ✅ Passed: $passed_tests"
echo "  ❌ Failed: $failed_tests"

if [ $failed_tests -eq 0 ]; then
    echo "  🎉 Success Rate: 100%"
    echo "─────────────────────────────────────────────────────────────────────────────"
    echo "  🏆 ALL TESTS PASSED!"
    exit 0
else
    success_rate=$((passed_tests * 100 / total_tests))
    echo "  📊 Success Rate: $success_rate%"
    echo "─────────────────────────────────────────────────────────────────────────────"
    echo "  ⚠️  SOME TESTS FAILED"
    echo "  💡 Check logs above for details"
    exit 1
fi
