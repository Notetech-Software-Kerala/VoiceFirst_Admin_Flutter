import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'division_one_notifier.dart';
import 'division_one_state.dart';

final divisionOneProvider =
    NotifierProvider.family<DivisionOneNotifier, DivisionOneState, int>(
      DivisionOneNotifier.new,
    );
