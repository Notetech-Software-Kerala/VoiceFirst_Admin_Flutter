import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:voice_first_admin/features/Country_Management/division3/presentation/providers/division_three_state.dart';
import 'division_three_notifier.dart';

final divisionThreeProvider =
    StateNotifierProvider.family<
      DivisionThreeNotifier,
      DivisionThreeState,
      int
    >((ref, divisionTwoId) => DivisionThreeNotifier(divisionTwoId));
