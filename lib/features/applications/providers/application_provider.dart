import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/applications/data/models/application_model.dart';
import 'package:voice_first_admin/features/applications/data/repositories/application_repository.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';

final applicationProvider = FutureProvider<List<ApplicationModel>>((ref) async {
  final repository = ApplicationRepository(ref.read(dioClientProvider));
  return repository.getAll();
});
