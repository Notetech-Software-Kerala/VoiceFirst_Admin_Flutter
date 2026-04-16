import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';
import 'package:voice_first_admin/features/business_activity_management/data/models/business_activity_model.dart';
import 'package:voice_first_admin/features/business_activity_management/data/repositories/business_activity_repository.dart';
import 'package:voice_first_admin/features/business_activity_management/presentation/providers/business_activity_notifier.dart';
import 'package:voice_first_admin/features/business_activity_management/presentation/providers/business_activity_state.dart';


final businessActivityProvider =
    NotifierProvider<BusinessActivityNotifier, BusinessActivityState>(
      BusinessActivityNotifier.new,
    );

/// Provider to fetch a single BusinessActivity by id
final businessActivityByIdProvider =
    FutureProvider.family<BusinessActivity, int>((ref, id) async {
      final repository = ref.read(businessActivityRepositoryProvider);
      return repository.getActivityById(id);
    });

/// Provider that constructs the repository using the centralized Dio client.
final businessActivityRepositoryProvider = Provider<BusinessActivityRepository>((
  ref,
) {
  return BusinessActivityRepository(ref.read(dioClientProvider));
});
