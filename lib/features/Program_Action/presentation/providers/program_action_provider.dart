import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'program_action_notifier.dart';
import 'program_action_state.dart';

final programActionProvider =
    StateNotifierProvider<ProgramActionNotifier, ProgramActionState>(
      (ref) => ProgramActionNotifier(),
    );
