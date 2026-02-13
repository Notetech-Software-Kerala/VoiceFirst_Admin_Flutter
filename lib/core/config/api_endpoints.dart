/// Global API Configuration
class ApiEndpoints {
  // Private constructor to prevent instantiation
  ApiEndpoints._();

  /// Base URL for all API calls
  // static const String baseUrl = "http://192.168.0.202:8010/api";
  static const String baseUrl = "https://voicefirst.admin.notetech.com/api";

  /// Common headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };
}
