import 'package:voice_first_admin/core/models/base_filter_model.dart';
import 'package:voice_first_admin/features/business_activity_management/data/models/business_activity_model.dart';

class BusinessActivityState {
  /// Data returned from API
  final List<BusinessActivity> items;

  /// Current API query (filters + pagination)
  final BaseFilterModel filter;

  /// Pagination
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final bool hasMoreData;

  /// UI states
  final bool isLoading;
  final String? error;
  final bool isMultiSelect;
  final Set<int> selectedIds;

  BusinessActivityState({
    required this.items,
    required this.filter,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.hasMoreData,
    required this.isLoading,
    required this.error,
    required this.isMultiSelect,
    required this.selectedIds,
  });

  /// Initial state
  factory BusinessActivityState.initial() {
    return BusinessActivityState(
      items: const [],
      filter: const BaseFilterModel(),
      totalCount: 0,
      totalPages: 1,
      currentPage: 1,
      hasMoreData: true,
      isLoading: false,
      error: null,
      isMultiSelect: false,
      selectedIds: const {},
    );
  }
  BusinessActivityState copyWith({
    List<BusinessActivity>? items,
    BaseFilterModel? filter,
    int? totalCount,
    int? totalPages,
    int? currentPage,
    bool? hasMoreData,
    bool? isLoading,
    String? error,
    bool? isMultiSelect,
    Set<int>? selectedIds,
  }) {
    return BusinessActivityState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}
