#!/usr/bin/env bash
# Test Runner Script for Voice First Admin Flutter App

echo "🧪 Running automated tests for Voice First Admin..."
echo ""

# Run all tests with coverage
echo "📊 Running tests with coverage..."
flutter test --coverage

# Check if tests passed
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ All tests passed successfully!"
    echo ""
    
    # Generate HTML coverage report (if lcov is installed)
    if command -v genhtml &> /dev/null; then
        echo "📈 Generating HTML coverage report..."
        genhtml coverage/lcov.info -o coverage/html
        echo "Coverage report generated at: coverage/html/index.html"
    else
        echo "💡 Tip: Install lcov to generate HTML coverage reports"
        echo "   Ubuntu/Debian: sudo apt-get install lcov"
        echo "   macOS: brew install lcov"
    fi
else
    echo ""
    echo "❌ Tests failed. Please check the output above."
    exit 1
fi
