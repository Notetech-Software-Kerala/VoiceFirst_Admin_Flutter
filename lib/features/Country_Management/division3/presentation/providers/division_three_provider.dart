import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/country_management/division3/presentation/providers/division_three_state.dart';
import 'division_three_notifier.dart';

final divisionThreeProvider =
    NotifierProvider.family<DivisionThreeNotifier, DivisionThreeState, int>(
      DivisionThreeNotifier.new,
    );
