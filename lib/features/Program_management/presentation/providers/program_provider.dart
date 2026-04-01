import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/program_management/presentation/providers/program_notifier.dart';
import 'package:voice_first_admin/features/program_management/presentation/providers/program_state.dart';

final programProvider = NotifierProvider<ProgramNotifier, ProgramState>(
  ProgramNotifier.new,
);
