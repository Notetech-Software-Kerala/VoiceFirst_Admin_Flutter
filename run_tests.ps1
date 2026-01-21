# Test Runner Script for Voice First Admin Flutter App (PowerShell)

Write-Host "🧪 Running automated tests for Voice First Admin..." -ForegroundColor Cyan
Write-Host ""

# Run all tests with coverage
Write-Host "📊 Running tests with coverage..." -ForegroundColor Yellow
flutter test --coverage

# Check if tests passed
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ All tests passed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📈 Coverage report generated at: coverage/lcov.info" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "💡 To view detailed coverage:" -ForegroundColor Yellow
    Write-Host "   1. Install the Coverage Gutters extension in VS Code" -ForegroundColor Gray
    Write-Host "   2. Or use online tools to visualize lcov.info" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "❌ Tests failed. Please check the output above." -ForegroundColor Red
    exit 1
}
