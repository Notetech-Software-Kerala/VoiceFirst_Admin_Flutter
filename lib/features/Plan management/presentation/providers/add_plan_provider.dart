import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/config/api_endpints.dart';
import '../../models/plan_model.dart';
import '../../models/plan_detail_model.dart';
import '../../plan_service/plan_service.dart';

class AddPlanState {
  final String planName;
  final List<int> actionIds;
  final bool isSubmitting;
  final String? error;
  final PlanDetailModel? created;

  const AddPlanState({
    this.planName = '',
    this.actionIds = const [],
    this.isSubmitting = false,
    this.error,
    this.created,
  });

  AddPlanState copyWith({
    String? planName,
    List<int>? actionIds,
    bool? isSubmitting,
    String? error,
    PlanDetailModel? created,
  }) {
    return AddPlanState(
      planName: planName ?? this.planName,
      actionIds: actionIds ?? this.actionIds,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      created: created ?? this.created,
    );
  }
}

class AddPlanNotifier extends Notifier<AddPlanState> {
  late final PlanService _service;

  @override
  AddPlanState build() {
    _service = PlanService(baseUrl: ApiEndpoints.baseUrl);
    return const AddPlanState();
  }

  void setName(String name) {
    state = state.copyWith(planName: name, error: null);
  }

  void addActionId(int id) {
    if (!state.actionIds.contains(id)) {
      final updated = [...state.actionIds, id];
      state = state.copyWith(actionIds: updated, error: null);
    }
  }

  void removeActionId(int id) {
    final updated = state.actionIds.where((e) => e != id).toList();
    state = state.copyWith(actionIds: updated, error: null);
  }

  Future<PlanDetailModel?> submit() async {
    if (state.planName.trim().isEmpty) {
      state = state.copyWith(error: 'Plan name is required');
      return null;
    }
    if (state.actionIds.isEmpty) {
      state = state.copyWith(error: 'Select at least one program action');
      return null;
    }

    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final model = PlanModel(
        planName: state.planName.trim(),
        programActionLinkIds: state.actionIds,
      );
      final created = await _service.createPlan(model);
      state = state.copyWith(isSubmitting: false, created: created);
      return created;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }
}

final addPlanProvider = NotifierProvider<AddPlanNotifier, AddPlanState>(
  AddPlanNotifier.new,
);
