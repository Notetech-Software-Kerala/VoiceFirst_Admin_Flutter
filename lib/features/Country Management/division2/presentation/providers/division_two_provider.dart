import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'division_two_notifier.dart';
import 'division_two_state.dart';

final divisionTwoProvider =
    StateNotifierProvider.family<DivisionTwoNotifier, DivisionTwoState, String>(
      (ref, divisionOneId) => DivisionTwoNotifier(divisionOneId),
    );
