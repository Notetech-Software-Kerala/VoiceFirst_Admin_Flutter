import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Applications/data/application%20service/application_service.dart';
import '../data/models/application_model.dart';

final applicationProvider = FutureProvider<List<ApplicationModel>>((ref) async {
  final service = ApplicationService();
  return service.getAll();
});
