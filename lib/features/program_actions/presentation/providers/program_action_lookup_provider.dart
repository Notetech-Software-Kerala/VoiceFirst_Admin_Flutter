import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/program_actions/data/models/program_action_model.dart';
import 'package:voice_first_admin/features/program_actions/data/repositories/program_action_repository.dart';

final programActionLookupProvider = FutureProvider<List<ProgramActionModel>>((
  ref,
) async {
  final repository = ref.read(programActionRepositoryProvider);
  return repository.getLookup();
});
