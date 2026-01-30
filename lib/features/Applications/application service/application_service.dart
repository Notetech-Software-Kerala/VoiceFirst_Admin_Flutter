import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpints.dart';
import '../models/application_model.dart';

class ApplicationService {
  static const _path = '/platform/lookup';

  Future<List<ApplicationModel>> getAll() async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path');

    final response = await http.get(url, headers: ApiEndpoints.defaultHeaders);

    if (response.statusCode != 200) {
      throw Exception('Failed to load applications');
    }

    final body = jsonDecode(response.body);
    final list = body['data'] as List;

    return list.map((e) => ApplicationModel.fromJson(e)).toList();
  }
}
