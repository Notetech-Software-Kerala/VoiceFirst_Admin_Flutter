/// Global API Configuration
class ApiEndpoints {
  // Private constructor to prevent instantiation
  ApiEndpoints._();

  /// Base URL for all API calls
  static const String baseUrl = "http://192.168.0.202:8010/api";

  /// Common headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };
}
