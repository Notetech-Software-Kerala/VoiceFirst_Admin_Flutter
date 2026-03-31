import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Business_activity/data/business_activity_service/business_activity_service.dart';
import 'business_activity_provider.dart';
import '../../data/models/custom_field_lookup_model.dart';
// import '../../services/user_custom_field_service.dart';

class CustomFieldLookupNotifier extends AsyncNotifier<List<CustomFieldLookup>> {
  late final BusinessActivityService _service;

  @override
  Future<List<CustomFieldLookup>> build() async {
    _service = ref.read(businessActivityServiceProvider);
    return load();
  }

  Future<List<CustomFieldLookup>> load() async {
    return await _service.getCustomFieldLookup();
  }
}

//provider

final customFieldLookupProvider =
    AsyncNotifierProvider<CustomFieldLookupNotifier, List<CustomFieldLookup>>(
      CustomFieldLookupNotifier.new,
    );
