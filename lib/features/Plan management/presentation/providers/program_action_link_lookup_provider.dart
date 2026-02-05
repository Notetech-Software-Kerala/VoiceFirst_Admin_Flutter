import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import '../../models/program_action_link_lookup.dart';
import '../../plan_service/plan_service.dart';


final programActionLinkLookupProvider =
    FutureProvider<List<ProgramActionLinkProgram>>((ref) async {
      final service = PlanService(baseUrl: ApiEndpoints.baseUrl);
      return service.getProgramActionLinkLookup();
    });
