import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse(
    'https://voicefirst.admin.notetech.com/api/employee?PageNumber=1&Limit=10',
  );
  final response = await http.get(
    url,
    headers: {'Content-Type': 'application/json'},
  );
  print("Status: ${response.statusCode}");
  if (response.statusCode >= 200 && response.statusCode < 300) {
    final body = jsonDecode(response.body);
    print("Body keys: ${body.keys.toList()}");
    if (body['data'] != null && body['data'] is Map) {
      final data = body['data'];
      print("data keys: ${data.keys.toList()}");
      print("data['totalCount']: ${data['totalCount']}");
      print("data['totalPages']: ${data['totalPages']}");
      print("data['totalItems']: ${data['totalItems']}");
    } else {
      print("data is not a Map: ${body['data']}");
    }
  } else {
    print("Error: ${response.body}");
  }
}
