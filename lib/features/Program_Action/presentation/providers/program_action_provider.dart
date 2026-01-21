import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'program_action_notifier.dart';
import 'program_action_state.dart';

final programActionProvider =
    NotifierProvider<ProgramActionNotifier, ProgramActionState>(
      ProgramActionNotifier.new,
    );
