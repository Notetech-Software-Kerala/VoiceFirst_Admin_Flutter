import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/plan/data/models/plan_filter.dart';
import 'package:voice_first_admin/features/plan/data/models/plan_model.dart';
import 'package:voice_first_admin/features/plan/data/repositories/plan_repository.dart';
import 'package:voice_first_admin/features/plan/presentation/providers/plan_state.dart';

class PlanNotifier extends Notifier<PlanState> {
  late final PlanRepository _repository;

  @override
  PlanState build() {
    _repository = ref.read(planRepositoryProvider);
    return const PlanState();
  }

  //////////////////////////////////////////////////////
  /// LOAD LIST
  //////////////////////////////////////////////////////
  Future<void> loadPlans({PlanFilter? filter}) async {
    if (state.isLoading) return;

    final effectiveFilter = filter ?? state.filter;

    // Prevent duplicate same-request calls when data already present
    final currentSearch = state.filter.searchText ?? '';
    final nextSearch = effectiveFilter.searchText ?? '';
    if (effectiveFilter.pageNumber == state.filter.pageNumber &&
        nextSearch == currentSearch &&
        state.plans.isNotEmpty) {
      return;
    }

    if (state.totalPages > 0 && effectiveFilter.pageNumber > state.totalPages) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.getPlans(
        queryParams: effectiveFilter.toQueryParams(),
      );

      final safePage = min(response.currentPage, response.totalPages);

      state = state.copyWith(
        plans: response.items,
        isLoading: false,
        currentPage: safePage,
        totalCount: response.totalCount,
        totalPages: response.totalPages,
        filter: effectiveFilter.copyWith(pageNumber: safePage),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  //////////////////////////////////////////////////////
  /// LOAD DETAIL (SMART CACHE)
  //////////////////////////////////////////////////////

  Future<void> selectPlan(int id) async {
    final idx = state.plans.indexWhere((p) => p.planId == id);
    final Plan? existing = idx == -1 ? null : state.plans[idx];

    /// ✅ If already detailed — use cache
    if (existing?.programPlanDetails != null) {
      state = state.copyWith(selectedPlan: existing);
      return;
    }

    state = state.copyWith(isDetailLoading: true, error: null);

    try {
      final detail = await _repository.getPlanById(id);

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
      final updated = await _repository.deletePlan(id);
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
      final updated = await _repository.recoverPlan(id);
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
