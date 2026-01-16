// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import 'package:voice_first_admin/features/Country%20Management/country/models/country_model.dart';
// import 'package:voice_first_admin/features/Country%20Management/division1/models/division1_model.dart';

// class Division1State {
//   final List<DivisionOneModel> divisions;
//   final List<DivisionOneModel> filtered;
//   final List<String> selectedIds;
//   final bool isMultiSelect;
//   final String searchQuery;

//   Division1State({
//     required this.divisions,
//     required this.filtered,
//     required this.selectedIds,
//     required this.isMultiSelect,
//     required this.searchQuery,
//   });

//   Division1State copyWith({
//     List<DivisionOneModel>? divisions,
//     List<DivisionOneModel>? filtered,
//     List<String>? selectedIds,
//     bool? isMultiSelect,
//     String? searchQuery,
//   }) {
//     return Division1State(
//       divisions: divisions ?? this.divisions,
//       filtered: filtered ?? this.filtered,
//       selectedIds: selectedIds ?? this.selectedIds,
//       isMultiSelect: isMultiSelect ?? this.isMultiSelect,
//       searchQuery: searchQuery ?? this.searchQuery,
//     );
//   }
// }

// class Division1Notifier extends StateNotifier<Division1State> {
//   Division1Notifier(List<DivisionOneModel> initialDivisions)
//     : super(
//         Division1State(
//           divisions: initialDivisions,
//           filtered: initialDivisions,
//           selectedIds: [],
//           isMultiSelect: false,
//           searchQuery: '',
//         ),
//       );

//   // 🔍 Search divisions
//   void search(String query) {
//     final filtered = state.divisions
//         .where(
//           (d) =>
//               // (d.divisionOneLabel?.toLowerCase() ?? '').contains(
//               //   query.toLowerCase(),
//               // ) ||
//               (d.divisionTwoLabel?.toLowerCase() ?? '').contains(
//                 query.toLowerCase(),
//               ),
//           // ) ||
//           // (d.divisionThreeLabel?.toLowerCase() ?? '').contains(
//           //   query.toLowerCase(),
//           // ),
//         )
//         .toList();

//     state = state.copyWith(searchQuery: query, filtered: filtered);
//   }

//   // ☑️ Enter selection mode
//   void enterSelectionMode({bool selectAll = false}) {
//     if (selectAll) {
//       state = state.copyWith(
//         isMultiSelect: true,
//         selectedIds: state.filtered.map((d) => d.id).toList(),
//       );
//     } else {
//       state = state.copyWith(isMultiSelect: true);
//     }
//   }

//   // ❌ Exit selection mode
//   void exitSelectionMode() {
//     state = state.copyWith(isMultiSelect: false, selectedIds: []);
//   }

//   // ☑️ Toggle selection
//   void toggleSelection(String divisionId) {
//     final updated = List<String>.from(state.selectedIds);
//     if (updated.contains(divisionId)) {
//       updated.remove(divisionId);
//     } else {
//       updated.add(divisionId);
//     }
//     state = state.copyWith(selectedIds: updated);
//   }

//   // Check if all visible are selected
//   bool get allVisibleSelected {
//     if (state.filtered.isEmpty) return false;
//     return state.filtered.every((d) => state.selectedIds.contains(d.id));
//   }

//   // 🔄 Toggle status
//   void toggleStatus(String divisionId, bool newStatus) {
//     final updated = state.divisions.map((d) {
//       if (d.id == divisionId) {
//         return null;
//       }
//       return d;
//     }).toList();

//     final filteredUpdated = state.filtered.map((d) {
//       if (d.id == divisionId) {
//         return null;
//       }
//       return d;
//     }).toList();

//     // state = state.copyWith(divisions: updated, filtered: filteredUpdated);
//   }

//   // 🗑️ Delete division
//   void deleteDivision(String divisionId) {
//     final updated = state.divisions.where((d) => d.id != divisionId).toList();

//     final filteredUpdated = state.filtered
//         .where((d) => d.id != divisionId)
//         .toList();

//     state = state.copyWith(
//       divisions: updated,
//       filtered: filteredUpdated,
//       selectedIds: List<String>.from(state.selectedIds)..remove(divisionId),
//     );
//   }

//   // 🗑️ Delete selected divisions
//   void deleteSelected() {
//     final updated = state.divisions
//         .where((d) => !state.selectedIds.contains(d.id))
//         .toList();

//     final filteredUpdated = state.filtered
//         .where((d) => !state.selectedIds.contains(d.id))
//         .toList();

//     state = state.copyWith(
//       divisions: updated,
//       filtered: filteredUpdated,
//       selectedIds: [],
//       isMultiSelect: false,
//     );
//   }

//   // ✏️ Update division
//   void updateDivision(DivisionOneModel updatedDivision) {
//     final updated = state.divisions.map((d) {
//       if (d.id == updatedDivision.id) {
//         return updatedDivision;
//       }
//       return d;
//     }).toList();

//     final filteredUpdated = state.filtered.map((d) {
//       if (d.id == updatedDivision.id) {
//         return updatedDivision;
//       }
//       return d;
//     }).toList();

//     state = state.copyWith(divisions: updated, filtered: filteredUpdated);
//   }
// }

// // Provider
// final division1Provider =
//     StateNotifierProvider<Division1Notifier, Division1State>((ref) {
//       return Division1Notifier([]);
//     });
