// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:voice_first_admin/core/config/api_endpoints.dart';
// import '../../models/program_action_link_lookup.dart';
// import '../../plan_service/plan_service.dart';

// final programActionLinkLookupProvider =
//     FutureProvider<List<ProgramActionLinkProgram>>((ref) async {
//       final service = PlanService(baseUrl: ApiEndpoints.baseUrl);
//       return service.getProgramActionLinkLookup();
//     });
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import '../../data/models/program_action_link_lookup.dart';
import '../../data/plan_service/plan_service.dart';

////////////////////////////////////////////////////////////
/// STATE
////////////////////////////////////////////////////////////

class ProgramLookupState {
  final List<ProgramActionLinkProgram> programs;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final int totalPages;
  final Set<int> loadedPages;
  final String searchText;

  const ProgramLookupState({
    this.programs = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.totalPages = 1,
    this.loadedPages = const {},
    this.searchText = '',
  });

  ProgramLookupState copyWith({
    List<ProgramActionLinkProgram>? programs,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    int? totalPages,
    Set<int>? loadedPages,
    String? searchText,
  }) {
    return ProgramLookupState(
      programs: programs ?? this.programs,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      loadedPages: loadedPages ?? this.loadedPages,
      searchText: searchText ?? this.searchText,
    );
  }
}

////////////////////////////////////////////////////////////
/// NOTIFIER
////////////////////////////////////////////////////////////

class ProgramLookupNotifier extends Notifier<ProgramLookupState> {
  late final PlanService _service;

  @override
  ProgramLookupState build() {
    _service = PlanService(baseUrl: ApiEndpoints.baseUrl);

    // loadNextPage(); // initial load
    Future.microtask(() => loadNextPage());
    return const ProgramLookupState();
  }

  // void reset({String? searchText}) {
  //   state = ProgramLookupState(searchText: searchText ?? '');
  //   loadNextPage();
  // }

  // void reset({required String searchText}) {
  //   state = state.copyWith(
  //     searchText: searchText,
  //     currentPage: 0,
  //     totalPages: 1,
  //     hasMore: true,
  //     loadedPages: {},
  //   );

  //   loadNextPage();
  // }

  // void reset({required String searchText}) {
  //   state = ProgramLookupState(
  //     programs: [], // clear old results
  //     isLoading: false,
  //     hasMore: true,
  //     currentPage: 0,
  //     totalPages: 1,
  //     loadedPages: {},
  //     searchText: searchText,
  //   );

  //   loadNextPage();
  // }
  // void reset({required String searchText}) {
  //   state = state.copyWith(
  //     searchText: searchText,
  //     currentPage: 0,
  //     hasMore: true,
  //     totalPages: 1,
  //   );

  //   loadNextPage();
  // }

  void reset({required String searchText}) {
    state = ProgramLookupState(
      programs: [], // CLEAR OLD RESULTS
      isLoading: false,
      hasMore: true,
      currentPage: 0,
      totalPages: 1,
      loadedPages: {},
      searchText: searchText,
    );

    loadNextPage();
  }

  Future<void> loadNextPage() async {
    // if (state.isLoading) return;

    // final nextPage = state.currentPage + 1;

    // if (nextPage > state.totalPages) return;
    if (state.isLoading || !state.hasMore) return;
    final nextPage = state.currentPage + 1;
    // if (state.loadedPages.contains(nextPage)) return;

    state = state.copyWith(isLoading: true);

    try {
      final response = await _service.getProgramActionLinkLookupPaginated(
        page: nextPage,
        pageSize: 10,
        search: state.searchText.isEmpty ? null : state.searchText,
      );

      state = state.copyWith(
        // programs: [...state.programs, ...response.items],
        programs: nextPage == 1
            ? response.items
            : [...state.programs, ...response.items],
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        hasMore: response.currentPage < response.totalPages,
        isLoading: false,
        loadedPages: {...state.loadedPages, nextPage},
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
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
