import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'business_activity_notifier.dart';
import 'business_activity_state.dart';

final businessActivityProvider =
    NotifierProvider<BusinessActivityNotifier, BusinessActivityState>(
      BusinessActivityNotifier.new,
    );
