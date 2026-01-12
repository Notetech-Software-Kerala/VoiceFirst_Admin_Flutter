import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';

class BusinessActivityState {
  final List<BusinessActivity> activities;
  final List<BusinessActivity> filtered;
  final Set<String> selectedIds;
  final bool isMultiSelect;
  final String search;

  BusinessActivityState({
    required this.activities,
    required this.filtered,
    required this.selectedIds,
    required this.isMultiSelect,
    required this.search,
  });

  factory BusinessActivityState.initial() {
    return BusinessActivityState(
      activities: [],
      filtered: [],
      selectedIds: {},
      isMultiSelect: false,
      search: '',
    );
  }

  BusinessActivityState copyWith({
    List<BusinessActivity>? activities,
    List<BusinessActivity>? filtered,
    Set<String>? selectedIds,
    bool? isMultiSelect,
    String? search,
  }) {
    return BusinessActivityState(
      activities: activities ?? this.activities,
      filtered: filtered ?? this.filtered,
      selectedIds: selectedIds ?? this.selectedIds,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      search: search ?? this.search,
    );
  }
}
