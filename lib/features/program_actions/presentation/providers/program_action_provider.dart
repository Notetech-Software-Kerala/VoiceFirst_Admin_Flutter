import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/program_actions/presentation/providers/program_action_notifier.dart';
import 'package:voice_first_admin/features/program_actions/presentation/providers/program_action_state.dart';


final programActionProvider =
    NotifierProvider<ProgramActionNotifier, ProgramActionState>(
  ProgramActionNotifier.new,
);
