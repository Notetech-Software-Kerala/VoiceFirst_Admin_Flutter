import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/config/api_endpints.dart';
import 'package:voice_first_admin/features/Plan%20management/models/plan_model.dart';
import 'package:voice_first_admin/features/Plan%20management/plan_service/plan_service.dart';

class PlanListState {
  final List<PlanModel> plans;
  final bool isLoading;
  final int currentPage;
  final int totalCount;
  final int totalPages;
  final String search;

  PlanListState({
    required this.plans,
    required this.isLoading,
    required this.currentPage,
    required this.totalCount,
    required this.totalPages,
    required this.search,
  });

  factory PlanListState.initial() => PlanListState(
    plans: [],
    isLoading: false,
    currentPage: 1,
    totalCount: 0,
    totalPages: 1,
    search: '',
  );

  PlanListState copyWith({
    List<PlanModel>? plans,
    bool? isLoading,
    int? currentPage,
    int? totalCount,
    int? totalPages,
    String? search,
  }) {
    return PlanListState(
      plans: plans ?? this.plans,
      isLoading: isLoading ?? this.isLoading,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      search: search ?? this.search,
    );
  }
}

class PlanListNotifier extends Notifier<PlanListState> {
  late final PlanService _service;

  @override
  PlanListState build() {
    _service = PlanService(baseUrl: ApiEndpoints.baseUrl);
    return PlanListState.initial();
  }

  Future<void> loadAll({
    int page = 1,
    int pageSize = 10,
    String? search,
  }) async {
    state = state.copyWith(isLoading: true);
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
      state = state.copyWith(isLoading: false);
    }
  }
}

final planListProvider = NotifierProvider<PlanListNotifier, PlanListState>(
  PlanListNotifier.new,
);
