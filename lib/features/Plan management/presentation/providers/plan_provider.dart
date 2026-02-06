import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'plan_notifier.dart';
import 'plan_state.dart';

final planProvider =
    NotifierProvider<PlanNotifier, PlanState>(
        PlanNotifier.new);
