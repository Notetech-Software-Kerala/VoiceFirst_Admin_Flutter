import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:voice_first_admin/features/Country%20Management/division3/division3_service/division3_service.dart';
import 'package:voice_first_admin/features/Country%20Management/division3/models/division_three_model.dart';
import 'package:voice_first_admin/features/Country%20Management/division3/models/division3_filter.dart';
import 'package:voice_first_admin/features/Country%20Management/division3/presentation/providers/division_three_state.dart';

class DivisionThreeNotifier extends StateNotifier<DivisionThreeState> {
  final String divisionTwoId;
  final _service = DivisionThreeService();

  late DivisionThreeFilter _filter;

  DivisionThreeNotifier(this.divisionTwoId)
    : super(DivisionThreeState.initial()) {
    _filter = DivisionThreeFilter(divisionTwoId: divisionTwoId);
    fetchPage(1);
  }

  Future<void> fetchPage(int page) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      _filter = _filter.copyWith(pageNumber: page, search: state.search);
      final response = await _service.getAll(_filter);
      state = state.copyWith(
        items: response.items,
        currentPage: response.pageNumber,
        totalPages: response.totalPages,
        totalCount: response.totalCount,
        pageSize: response.pageSize,
        isLoading: false,
        hasMoreData: response.pageNumber < response.totalPages,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void search(String query) {
    state = state.copyWith(search: query);
    fetchPage(1);
  }
}
