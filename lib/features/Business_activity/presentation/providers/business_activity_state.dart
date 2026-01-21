import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';

class BusinessActivityState {
  final List<BusinessActivity> activities;
  final List<BusinessActivity> filtered;
  final Set<int> selectedIds;
  final bool isMultiSelect;
  final String search;
  final bool isLoading;
  final bool hasMoreData;
  final int currentPage;
  final int totalCount;

  BusinessActivityState({
    required this.activities,
    required this.filtered,
    required this.selectedIds,
    required this.isMultiSelect,
    required this.search,
    required this.isLoading,
    required this.hasMoreData,
    required this.currentPage,
    required this.totalCount,
  });

  factory BusinessActivityState.initial() {
    return BusinessActivityState(
      activities: [],
      filtered: [],
      selectedIds: <int>{},
      isMultiSelect: false,
      search: '',
      isLoading: false,
      hasMoreData: true,
      currentPage: 0,
      totalCount: 0,
    );
  }

  BusinessActivityState copyWith({
    List<BusinessActivity>? activities,
    List<BusinessActivity>? filtered,
    Set<int>? selectedIds,
    bool? isMultiSelect,
    String? search,
    bool? isLoading,
    bool? hasMoreData,
    int? currentPage,
    int? totalCount,
  }) {
    return BusinessActivityState(
      activities: activities ?? this.activities,
      filtered: filtered ?? this.filtered,
      selectedIds: selectedIds ?? this.selectedIds,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      search: search ?? this.search,
      isLoading: isLoading ?? this.isLoading,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}
