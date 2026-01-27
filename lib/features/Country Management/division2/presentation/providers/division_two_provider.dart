import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'division_two_notifier.dart';
import 'division_two_state.dart';
import 'package:voice_first_admin/features/Country Management/division2/division2_service/division2_service.dart';

final divisionTwoProvider =
    StateNotifierProvider.family<DivisionTwoNotifier, DivisionTwoState, String>(
      (ref, divisionOneId) {
        return DivisionTwoNotifier(
          divisionOneId: divisionOneId,
          service: DivisionTwoService(),
        );
      },
    );
