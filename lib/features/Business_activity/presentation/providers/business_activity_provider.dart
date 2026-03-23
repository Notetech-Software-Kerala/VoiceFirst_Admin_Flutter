import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      final service = BusinessActivityService();
      return service.getActivityById(id);
    });
