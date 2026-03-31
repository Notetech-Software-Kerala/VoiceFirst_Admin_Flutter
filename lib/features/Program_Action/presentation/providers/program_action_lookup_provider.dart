import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Program_Action/data/models/program_action_model.dart';
import 'package:voice_first_admin/features/Program_Action/data/program_action_service/program_action_service.dart';

final programActionLookupProvider = FutureProvider<List<ProgramActionModel>>((
  ref,
) async {
  final service = ref.read(programActionServiceProvider);
  return service.getLookup();
});
