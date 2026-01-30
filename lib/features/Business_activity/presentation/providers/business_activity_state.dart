import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';
import 'business_activity_query.dart';

class BusinessActivityState {
  /// Data returned from API
  final List<BusinessActivity> items;

  /// Current API query (filters + pagination)
  final BusinessActivityQuery query;

  /// Pagination
  final int totalCount;
  final int currentPage;
  final bool hasMoreData;

  /// UI states
  final bool isLoading;
  final bool isMultiSelect;
  final Set<int> selectedIds;

  BusinessActivityState({
    required this.items,
    required this.query,
    required this.totalCount,
    required this.currentPage,
    required this.hasMoreData,
    required this.isLoading,
    required this.isMultiSelect,
    required this.selectedIds,
  });

  /// Initial state
  factory BusinessActivityState.initial() {
    return BusinessActivityState(
      items: const [],
      query: BusinessActivityQuery.initial(),
      totalCount: 0,
      currentPage: 1,
      hasMoreData: true,
      isLoading: false,
      isMultiSelect: false,
      selectedIds: const {},
    );
  }

  BusinessActivityState copyWith({
    List<BusinessActivity>? items,
    BusinessActivityQuery? query,
    int? totalCount,
    int? currentPage,
    bool? hasMoreData,
    bool? isLoading,
    bool? isMultiSelect,
    Set<int>? selectedIds,
  }) {
    return BusinessActivityState(
      items: items ?? this.items,
      query: query ?? this.query,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoading: isLoading ?? this.isLoading,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}
