// import 'package:dio/dio.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:voice_first_admin/core/network/dio_client.dart';

// void main() {
//   group('ApiClient', () {
//     late ApiClient apiClient;

//     setUp(() {
//       apiClient = ApiClient();
//     });

//     test('should be a singleton', () {
//       final instance1 = ApiClient();
//       final instance2 = ApiClient();
//       expect(instance1, same(instance2));
//     });

//     test('should have dio instance configured', () {
//       expect(apiClient.dio, isNotNull);
//       expect(apiClient.dio, isA<Dio>());
//     });

//     test('should have correct base options', () {
//       final options = apiClient.dio.options;
//       expect(options.connectTimeout, const Duration(seconds: 15));
//       expect(options.receiveTimeout, const Duration(seconds: 15));
//       expect(options.headers['Content-Type'], 'application/json');
//     });

//     test('should have interceptors configured', () {
//       expect(apiClient.dio.interceptors, isNotEmpty);
//     });
//   });
// }
