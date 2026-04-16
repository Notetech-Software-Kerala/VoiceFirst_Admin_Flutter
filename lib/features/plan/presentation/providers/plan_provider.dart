import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/plan/presentation/providers/plan_notifier.dart';
import 'package:voice_first_admin/features/plan/presentation/providers/plan_state.dart';

final planProvider =
    NotifierProvider<PlanNotifier, PlanState>(
        PlanNotifier.new);
