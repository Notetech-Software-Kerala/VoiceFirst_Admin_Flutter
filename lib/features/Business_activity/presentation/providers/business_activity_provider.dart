import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';
import 'business_activity_notifier.dart';
import 'business_activity_state.dart';
import '../../data/business_activity_service/business_activity_service.dart';
import '../../data/models/business_activity_model.dart';

final businessActivityProvider =
    NotifierProvider<BusinessActivityNotifier, BusinessActivityState>(
      BusinessActivityNotifier.new,
    );

/// Provider to fetch a single BusinessActivity by id
final businessActivityByIdProvider =
    FutureProvider.family<BusinessActivity, int>((ref, id) async {
      final service = ref.read(businessActivityServiceProvider);
      return service.getActivityById(id);
    });

/// Provider that constructs the service using the centralized Dio client.
final businessActivityServiceProvider = Provider<BusinessActivityService>((
  ref,
) {
  return BusinessActivityService(ref.read(dioClientProvider));
});
