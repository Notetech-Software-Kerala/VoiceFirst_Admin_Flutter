import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Program_Action/models/program_action_model.dart';
import 'package:voice_first_admin/features/Program_Action/program_action_service/program_action_service.dart';

final programActionLookupProvider = FutureProvider<List<ProgramActionModel>>((
  ref,
) async {
  final service = ProgramActionService();
  return service.getLookup();
});
