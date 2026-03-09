import 'dart:convert';
import 'dart:io';

void main() async {
  final url = Uri.parse('https://voicefirst.admin.notetech.com/api/menu');
  final payload = {
    "menuName": "test 98",
    "icon": "demo",
    "route": "",
    "plateFormId": 1,
    "programIds": [
      {"programId": 0, "primary": true},
    ],
    "web": true,
    "app": true,
  };

  final client = HttpClient()
    ..badCertificateCallback = ((X509Certificate cert, String host, int port) =>
        true);

  final request = await client.postUrl(url);
  request.headers.set('Content-Type', 'application/json');
  request.headers.set('accept', 'application/json');

  request.write(jsonEncode(payload));
  final response = await request.close();

  final responseBody = await response.transform(utf8.decoder).join();
  print('Status: ${response.statusCode}');
  print('Body: $responseBody');
}
