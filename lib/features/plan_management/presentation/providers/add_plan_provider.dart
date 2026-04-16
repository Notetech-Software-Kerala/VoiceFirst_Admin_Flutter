import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/plan_management/data/models/plan_model.dart';
import 'package:voice_first_admin/features/plan_management/data/repositories/plan_repository.dart';
import 'package:voice_first_admin/features/plan_management/presentation/providers/plan_provider.dart';


////////////////////////////////////////////////////////////
/// STATE
////////////////////////////////////////////////////////////

class AddPlanState {
  final String planName;
  final List<int> actionIds;
  final bool isSubmitting;
  final String? error;
  final Plan? created;

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
    Plan? created,
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

////////////////////////////////////////////////////////////
/// NOTIFIER
////////////////////////////////////////////////////////////

class AddPlanNotifier extends Notifier<AddPlanState> {
  late final PlanRepository _repository;

  @override
  AddPlanState build() {
    _repository = ref.read(planRepositoryProvider);
    return const AddPlanState();
  }


  ////////////////////////////////////////////////////////////
  /// NAME
  ////////////////////////////////////////////////////////////

  void setName(String name) {
    state = state.copyWith(planName: name, error: null);
  }

  ////////////////////////////////////////////////////////////
  /// ACTION IDS
  ////////////////////////////////////////////////////////////

  void addActionId(int id) {
    if (!state.actionIds.contains(id)) {
      state = state.copyWith(actionIds: [...state.actionIds, id], error: null);
    }
  }

  void removeActionId(int id) {
    state = state.copyWith(
      actionIds: state.actionIds.where((e) => e != id).toList(),
      error: null,
    );
  }

  ////////////////////////////////////////////////////////////
  /// CREATE PLAN
  ////////////////////////////////////////////////////////////

  Future<Plan?> submit() async {
    /// Prevent double submission
    if (state.isSubmitting) return null;
    // Trim once
    final name = state.planName.trim();

    // Validation
    if (name.isEmpty) {
      state = state.copyWith(error: 'Plan name is required');
      return null;
    }

    if (state.actionIds.isEmpty) {
      state = state.copyWith(error: 'Select at least one program action');
      return null;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final created = await _repository.createPlan(
        planName: name,
        actionIds: state.actionIds,
      );

      // AUTO UPDATE MAIN CACHE
      ref.read(planProvider.notifier).insert(created);

      state = state.copyWith(isSubmitting: false, created: created);

      return created;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());

      return null;
    }
  }
}

////////////////////////////////////////////////////////////
/// PROVIDER
////////////////////////////////////////////////////////////

final addPlanProvider = NotifierProvider<AddPlanNotifier, AddPlanState>(
  AddPlanNotifier.new,
);
