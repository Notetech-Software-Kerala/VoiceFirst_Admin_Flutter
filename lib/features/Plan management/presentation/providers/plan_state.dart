import '../../models/plan_model.dart';

class PlanState {
  final List<Plan> plans;
  final Plan? selectedPlan;
  final bool isLoading;
  final String? error;
  final bool isDetailLoading;
  final int currentPage;
  final int totalCount;
  final int totalPages;
  final String search;

  const PlanState({
    this.plans = const [],
    this.selectedPlan,
    this.isLoading = false,
    this.error,
    this.isDetailLoading = false,
    this.currentPage = 1,
    this.totalCount = 0,
    this.totalPages = 1,
    this.search = '',
  });

  PlanState copyWith({
    List<Plan>? plans,
    Plan? selectedPlan,
    bool? isLoading,
    String? error,
    bool? isDetailLoading,
    int? currentPage,
    int? totalCount,
    int? totalPages,
    String? search,
  }) {
    return PlanState(
      plans: plans ?? this.plans,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      search: search ?? this.search,
    );
  }
}
