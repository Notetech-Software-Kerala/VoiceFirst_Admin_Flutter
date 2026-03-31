import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Applications/data/application%20service/application_service.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';
import '../data/models/application_model.dart';

final applicationProvider = FutureProvider<List<ApplicationModel>>((ref) async {
  final service = ApplicationService(ref.read(dioClientProvider));
  return service.getAll();
});
