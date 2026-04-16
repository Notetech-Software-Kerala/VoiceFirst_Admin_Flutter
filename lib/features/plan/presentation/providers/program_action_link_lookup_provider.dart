import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/plan/data/models/program_action_link_lookup.dart';
import 'package:voice_first_admin/features/plan/data/repositories/plan_repository.dart';

////////////////////////////////////////////////////////////
/// STATE
////////////////////////////////////////////////////////////

class ProgramLookupState {
  final List<ProgramActionLinkProgram> programs;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final int totalPages;
  final String searchText;

  const ProgramLookupState({
    this.programs = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.totalPages = 1,

    this.searchText = '',
  });

  ProgramLookupState copyWith({
    List<ProgramActionLinkProgram>? programs,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    int? totalPages,
    String? searchText,
  }) {
    return ProgramLookupState(
      programs: programs ?? this.programs,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,

      searchText: searchText ?? this.searchText,
    );
  }
}

////////////////////////////////////////////////////////////
/// NOTIFIER
////////////////////////////////////////////////////////////

class ProgramLookupNotifier extends Notifier<ProgramLookupState> {
  late final PlanRepository _repository;

  @override
  ProgramLookupState build() {
    _repository = ref.read(planRepositoryProvider);
    // UI triggers loading; do not auto-load here.
    return const ProgramLookupState();
  }

  void reset({required String searchText}) {
    state = ProgramLookupState(
      programs: [], // CLEAR OLD RESULTS
      isLoading: false,
      hasMore: true,
      currentPage: 0,
      totalPages: 1,
      searchText: searchText,
    );

    loadNextPage();
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    // Prevent duplicate fetch when already at or past last page (except initial state)
    if (state.currentPage >= state.totalPages && state.currentPage != 0) return;

    final nextPage = state.currentPage + 1;

    state = state.copyWith(isLoading: true);

    try {
      final response = await _repository.getProgramActionLinkLookupPaginated(
        page: nextPage,
        pageSize: 10,
        search: state.searchText.isEmpty ? null : state.searchText,
      );

      state = state.copyWith(
        programs: nextPage == 1
            ? response.items
            : [...state.programs, ...response.items],
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        hasMore: response.currentPage < response.totalPages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // use debugPrint instead of print
      // ignore: avoid_print
      debugPrint('[ProgramLookup] loadNextPage error: $e');
    }
  }
}

////////////////////////////////////////////////////////////
/// PROVIDER
////////////////////////////////////////////////////////////

final programLookupProvider =
    NotifierProvider<ProgramLookupNotifier, ProgramLookupState>(
      ProgramLookupNotifier.new,
    );
