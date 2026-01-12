import 'package:flutter_riverpod/legacy.dart';
import 'business_activity_notifier.dart';
import 'business_activity_state.dart';

final businessActivityProvider =
    StateNotifierProvider<BusinessActivityNotifier, BusinessActivityState>(
      (ref) => BusinessActivityNotifier(),
    );
