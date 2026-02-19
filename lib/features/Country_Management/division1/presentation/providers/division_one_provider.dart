import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'division_one_notifier.dart';
import 'division_one_state.dart';
import 'package:voice_first_admin/features/Country_Management/division1/division1_service/division1_service.dart';

final divisionOneProvider =
    StateNotifierProvider.family<DivisionOneNotifier, DivisionOneState, int>(
      (ref, countryId) {
        return DivisionOneNotifier(
          countryId: countryId,
          service: DivisionOneService(),
        );
      },
    );
