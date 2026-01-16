import 'package:voice_first_admin/features/Country%20Management/country/models/country_model.dart';

class CountryState {
  final List<CountryModel> countries;
  final List<CountryModel> filtered;
  final bool isMultiSelect;
  final Set<String> selectedIds;

  CountryState({
    required this.countries,
    required this.filtered,
    required this.isMultiSelect,
    required this.selectedIds,
  });

  factory CountryState.initial(List<CountryModel> mockData) {
    return CountryState(
      countries: mockData,
      filtered: mockData,
      isMultiSelect: false,
      selectedIds: {},
    );
  }

  CountryState copyWith({
    List<CountryModel>? countries,
    List<CountryModel>? filtered,
    bool? isMultiSelect,
    Set<String>? selectedIds,
  }) {
    return CountryState(
      countries: countries ?? this.countries,
      filtered: filtered ?? this.filtered,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}
