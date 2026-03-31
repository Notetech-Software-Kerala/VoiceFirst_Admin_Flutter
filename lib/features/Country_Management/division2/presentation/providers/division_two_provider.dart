import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'division_two_notifier.dart';
import 'division_two_state.dart';

final divisionTwoProvider =
    NotifierProvider.family<DivisionTwoNotifier, DivisionTwoState, int>(
      DivisionTwoNotifier.new,
    );
