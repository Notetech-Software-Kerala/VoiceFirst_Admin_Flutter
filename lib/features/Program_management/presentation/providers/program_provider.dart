import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:voice_first_admin/features/Program_management/presentation/providers/program_notifier.dart';
import 'package:voice_first_admin/features/Program_management/presentation/providers/program_state.dart';

final programProvider = StateNotifierProvider<ProgramNotifier, ProgramState>(
  (ref) => ProgramNotifier(),
);
