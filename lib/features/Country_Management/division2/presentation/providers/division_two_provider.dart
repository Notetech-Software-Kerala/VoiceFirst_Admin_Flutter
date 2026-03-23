import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'division_two_notifier.dart';
import 'division_two_state.dart';
import 'package:voice_first_admin/features/Country_Management/division2/data/division2_service/division2_service.dart';

final divisionTwoProvider =
    StateNotifierProvider.family<DivisionTwoNotifier, DivisionTwoState, int>(
      (ref, divisionOneId) {
        return DivisionTwoNotifier(
          divisionOneId: divisionOneId,
          service: DivisionTwoService(),
        );
      },
    );
