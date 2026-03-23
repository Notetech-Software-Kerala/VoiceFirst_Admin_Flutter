import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/custom_field/data/models/custom_field_model.dart';
import 'package:voice_first_admin/features/custom_field/data/service/custom_field_service.dart';
import 'custom_field_notifier.dart';
import 'custom_field_state.dart';

final customFieldProvider =
    NotifierProvider<CustomFieldNotifier, CustomFieldState>(
  CustomFieldNotifier.new,
);

final customFieldDetailProvider = FutureProvider.autoDispose.family<CustomFieldModel, int>((ref, id) async {
  final service = CustomFieldService();
  return await service.getById(id);
});
