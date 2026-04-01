import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/business_activity/data/models/custom_field_lookup_model.dart';
import 'package:voice_first_admin/features/business_activity/data/repositories/business_activity_repository.dart';
import 'package:voice_first_admin/features/business_activity/presentation/providers/business_activity_provider.dart';

class CustomFieldLookupNotifier extends AsyncNotifier<List<CustomFieldLookup>> {
  late final BusinessActivityRepository _repository;

  @override
  Future<List<CustomFieldLookup>> build() async {
    _repository = ref.read(businessActivityRepositoryProvider);
    return load();
  }

  Future<List<CustomFieldLookup>> load() async {
    return await _repository.getCustomFieldLookup();
  }
}

//provider

final customFieldLookupProvider =
    AsyncNotifierProvider<CustomFieldLookupNotifier, List<CustomFieldLookup>>(
      CustomFieldLookupNotifier.new,
    );
