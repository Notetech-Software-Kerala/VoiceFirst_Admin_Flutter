# Voice First Admin - Automated Testing

## Overview
This project includes comprehensive automated unit tests covering core functionality, business logic, state management, and data models.

## Test Structure

```
test/
├── test_helpers.dart              # Shared test utilities
├── widget_test.dart               # Main app widget tests
├── core/
│   ├── theme/
│   │   └── app_theme_test.dart   # Theme configuration tests
│   └── network/
│       └── dio_client_test.dart  # API client tests
└── features/
    ├── business_activity/
    │   ├── models/
    │   │   └── business_activity_model_test.dart
    │   └── providers/
    │       └── business_activity_state_test.dart
    ├── country_management/
    │   ├── models/
    │   │   └── country_model_test.dart
    │   └── providers/
    │       └── country_state_test.dart
    ├── program_management/
    │   ├── models/
    │   │   └── program_management_model_test.dart
    │   └── providers/
    │       └── program_state_test.dart
    └── profile/
        └── providers/
            └── profile_provider_test.dart
```

## Running Tests

### Run All Tests
```bash
# Using Flutter CLI
flutter test

# Using test scripts
./run_tests.sh       # Linux/macOS
.\run_tests.ps1      # Windows PowerShell
```

### Run Specific Test File
```bash
flutter test test/core/theme/app_theme_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Run Tests in Watch Mode
```bash
flutter test --watch
```

## Test Coverage

The test suite covers:

### 1. **Core Layer**
- ✅ Theme configuration (light/dark modes)
- ✅ API client initialization
- ✅ Dio interceptor setup

### 2. **Business Activity Feature**
- ✅ BusinessActivity model serialization
- ✅ State management (add, update, delete, search)
- ✅ Multi-select functionality

### 3. **Country Management Feature**
- ✅ CountryModel serialization
- ✅ Country state management
- ✅ Division hierarchy

### 4. **Program Management Feature**
- ✅ ProgramManagementModel serialization
- ✅ Program state management
- ✅ Action associations

### 5. **Profile Feature**
- ✅ Profile state management
- ✅ Settings toggles (notifications, alerts)
- ✅ Profile updates

## Test Conventions

### Model Tests
- Constructor validation
- JSON serialization/deserialization
- copyWith functionality
- Edge cases and null handling

### State Tests
- Initial state validation
- State transitions
- Immutability verification
- copyWith behavior

### Provider Tests
- Initial values
- State mutations
- Side effects
- Business logic

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

## Viewing Coverage Reports

### Option 1: VS Code Extension
Install the [Coverage Gutters](https://marketplace.visualstudio.com/items?itemName=ryanluker.vscode-coverage-gutters) extension to view inline coverage.

### Option 2: Generate HTML Report
```bash
# Install lcov
brew install lcov  # macOS
sudo apt-get install lcov  # Ubuntu/Debian

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Option 3: Online Tools
Upload `coverage/lcov.info` to services like:
- [Codecov](https://codecov.io/)
- [Coveralls](https://coveralls.io/)

## Writing New Tests

### Example Test Template
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_package/your_file.dart';

void main() {
  group('YourClass', () {
    test('should do something', () {
      // Arrange
      final instance = YourClass();
      
      // Act
      final result = instance.doSomething();
      
      // Assert
      expect(result, expectedValue);
    });
  });
}
```

## Best Practices

1. **Arrange-Act-Assert**: Structure tests clearly
2. **Descriptive Names**: Use clear test descriptions
3. **Isolation**: Each test should be independent
4. **Mock External Dependencies**: Use mockito for external services
5. **Test Edge Cases**: Include null, empty, and boundary conditions
6. **Keep Tests Fast**: Avoid unnecessary delays
7. **One Assertion per Test**: Focus on single behavior

## Troubleshooting

### Tests Not Running
```bash
flutter clean
flutter pub get
flutter test
```

### Import Errors
Ensure all dependencies are in `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.14
```

### Coverage Not Generated
```bash
flutter test --coverage --coverage-path=coverage/lcov.info
```

## Continuous Testing

Consider setting up:
- Pre-commit hooks to run tests
- CI/CD pipelines for automated testing
- Code review requirements for test coverage
- Minimum coverage thresholds

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Riverpod Testing](https://riverpod.dev/docs/essentials/testing)
