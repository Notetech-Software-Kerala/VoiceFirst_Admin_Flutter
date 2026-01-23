import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Country%20Management/country/models/country_model.dart';
import 'country_state.dart';
import 'country_mock_data.dart';

final countryProvider = NotifierProvider<CountryNotifier, CountryState>(
  CountryNotifier.new,
);

class CountryNotifier extends Notifier<CountryState> {
  @override
  CountryState build() {
    return CountryState.initial(mockCountries);
  }

  // 🔍 Search
  void search(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filtered: state.countries);
    } else {
      state = state.copyWith(
        filtered: state.countries
            .where((c) => c.country.toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );
    }
  }

  //Enter selection mode
  void enterSelectionMode({bool selectAll = false}) {
    if (selectAll) {
      state = state.copyWith(
        selectedIds: state.filtered.map((e) => e.id).toSet(),
        isMultiSelect: true,
      );
    } else {
      state = state.copyWith(isMultiSelect: true);
    }
  }

  // ❌ Exit selection mode
  void exitSelectionMode() {
    state = state.copyWith(selectedIds: {}, isMultiSelect: false);
  }

  // ✅ Check if all visible items are selected
  bool get allVisibleSelected =>
      state.filtered.isNotEmpty &&
      state.selectedIds.length == state.filtered.length;

  // ✅ Selection
  void toggleSelection(String id) {
    final selected = {...state.selectedIds};

    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.add(id);
    }

    state = state.copyWith(
      selectedIds: selected,
      isMultiSelect: selected.isNotEmpty,
    );
  }

  void selectAllVisible() {
    state = state.copyWith(
      selectedIds: state.filtered.map((e) => e.id).toSet(),
      isMultiSelect: true,
    );
  }

  void clearSelection() {
    state = state.copyWith(selectedIds: {}, isMultiSelect: false);
  }

  // 🗑 Delete
  void deleteSelected() {
    final remaining = state.countries
        .where((c) => !state.selectedIds.contains(c.id))
        .toList();

    state = state.copyWith(
      countries: remaining,
      filtered: remaining,
      selectedIds: {},
      isMultiSelect: false,
    );
  }

  // 🔄 Status Toggle
  void toggleStatus(String id, bool value) {
    final updated = state.countries.map((c) {
      if (c.id == id) {
        return CountryModel(
          id: c.id,
          country: c.country,
          countryCode: c.countryCode,
          countryIsoCode: c.countryIsoCode,
          divisionOneLabel: c.divisionOneLabel,
          divisionTwoLabel: c.divisionTwoLabel,
          divisionThreeLabel: c.divisionThreeLabel,
          status: value,
        );
      }
      return c;
    }).toList();

    state = state.copyWith(countries: updated, filtered: updated);
  }

  // ✏️ Update
  void update(CountryModel updatedCountry) {
    final updated = state.countries.map((c) {
      if (c.id == updatedCountry.id) {
        return updatedCountry;
      }
      return c;
    }).toList();

    state = state.copyWith(countries: updated, filtered: updated);
  }

  // 🗑 Delete
  void delete(String id) {
    final remaining = state.countries.where((c) => c.id != id).toList();
    state = state.copyWith(countries: remaining, filtered: remaining);
  }
}
