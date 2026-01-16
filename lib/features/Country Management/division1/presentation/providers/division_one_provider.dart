// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import 'division_one_notifier.dart';
// import 'division_one_state.dart';

// final divisionOneProvider = StateNotifierProvider.family<
//     DivisionOneNotifier,
//     DivisionOneState,
//     String>((ref, countryId) {
//   return DivisionOneNotifier(countryId);
// });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'division_one_notifier.dart';
import 'division_one_state.dart';

final divisionOneProvider =
    StateNotifierProvider.family<DivisionOneNotifier, DivisionOneState, String>(
  (ref, countryId) => DivisionOneNotifier(countryId),
);
