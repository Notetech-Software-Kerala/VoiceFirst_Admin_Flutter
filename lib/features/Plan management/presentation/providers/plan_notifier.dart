import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/config/api_endpints.dart';
import '../../models/plan_model.dart';
import '../../plan_service/plan_service.dart';
import 'plan_state.dart';

class PlanNotifier extends Notifier<PlanState> {
  late final PlanService _service;

  @override
  PlanState build() {
    _service = PlanService(baseUrl: ApiEndpoints.baseUrl);
    return const PlanState();
  }

  //////////////////////////////////////////////////////
  /// LOAD LIST
  //////////////////////////////////////////////////////
  Future<void> loadPlans({
    int page = 1,
    int pageSize = 10,
    String? search,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _service.getPlans(
        page: page,
        pageSize: pageSize,
        search: search,
      );

      state = state.copyWith(
        plans: response.items,
        isLoading: false,
        currentPage: response.currentPage,
        totalCount: response.totalCount,
        totalPages: response.totalPages,
        search: search ?? '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  //////////////////////////////////////////////////////
  /// LOAD DETAIL (SMART CACHE)
  //////////////////////////////////////////////////////


  Future<void> selectPlan(int id) async {
    final existing = state.plans.cast<Plan?>().firstWhere(
      (p) => p?.planId == id,
      orElse: () => null,
    );

    /// ✅ If already detailed — use cache
    if (existing?.programPlanDetails != null) {
      state = state.copyWith(selectedPlan: existing);
      return;
    }

    state = state.copyWith(isDetailLoading: true, error: null);

    try {
      final detail = await _service.getPlanById(id);

      state = state.copyWith(
        selectedPlan: detail,
        isDetailLoading: false,
        plans: state.plans.map((p) => p.planId == id ? detail : p).toList(),
      );
    } catch (e) {
      state = state.copyWith(isDetailLoading: false, error: e.toString());
    }
  }

  //////////////////////////////////////////////////////
  /// DELETE
  //////////////////////////////////////////////////////

  Future<bool> deletePlan(int id) async {
    try {
      final updated = await _service.deletePlan(id);
      _sync(updated);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void insert(Plan plan) {
    state = state.copyWith(plans: [plan, ...state.plans]);
  }

  //////////////////////////////////////////////////////
  /// RECOVER
  //////////////////////////////////////////////////////

  Future<bool> recoverPlan(int id) async {
    try {
      final updated = await _service.recoverPlan(id);
      _sync(updated);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  //////////////////////////////////////////////////////
  /// AUTO SYNC LIST + DETAIL
  //////////////////////////////////////////////////////

  void _sync(Plan updated) {
    state = state.copyWith(
      selectedPlan: updated,
      plans: state.plans
          .map((p) => p.planId == updated.planId ? updated : p)
          .toList(),
    );
  }
}
