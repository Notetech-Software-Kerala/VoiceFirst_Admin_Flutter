import 'package:voice_first_admin/features/custom_field/data/models/custom_field_model.dart';

class CustomFieldState {
  final List<CustomFieldModel> items;
  final List<CustomFieldModel> filtered;
  final bool isLoading;
  final bool isSaving;
  final String search;
  final int currentPage;
  final int totalCount;
  final int totalPages;
  final bool hasMoreData;
  final String? error;

  const CustomFieldState({
    required this.items,
    required this.filtered,
    required this.isLoading,
    required this.isSaving,
    required this.search,
    required this.currentPage,
    required this.totalCount,
    required this.totalPages,
    required this.hasMoreData,
    this.error,
  });

  factory CustomFieldState.initial() => const CustomFieldState(
        items: [],
        filtered: [],
        isLoading: false,
        isSaving: false,
        search: '',
        currentPage: 1,
        totalCount: 0,
        totalPages: 1,
        hasMoreData: true,
      );

  CustomFieldState copyWith({
    List<CustomFieldModel>? items,
    List<CustomFieldModel>? filtered,
    bool? isLoading,
    bool? isSaving,
    String? search,
    int? currentPage,
    int? totalCount,
    int? totalPages,
    bool? hasMoreData,
    String? error,
    bool clearError = false,
  }) {
    return CustomFieldState(
      items: items ?? this.items,
      filtered: filtered ?? this.filtered,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      search: search ?? this.search,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      error: clearError ? null : error ?? this.error,
    );
  }
}
