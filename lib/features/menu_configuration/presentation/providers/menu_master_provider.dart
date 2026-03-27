import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/menu_master_model.dart';
import '../../data/models/platform_model.dart';
import '../../data/repositories/menu_repository.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';

final menuMasterRepositoryProvider = Provider((ref) => MenuRepository(ref.read(dioClientProvider)));

// State to hold filter criteria
class MenuMasterFilterState {
  final String? searchText;
  final int pageNumber;
  final int limit;

  MenuMasterFilterState({
    this.searchText,
    this.pageNumber = 1,
    this.limit = 10,
  });

  MenuMasterFilterState copyWith({
    String? searchText,
    int? pageNumber,
    int? limit,
  }) {
    return MenuMasterFilterState(
      searchText: searchText ?? this.searchText,
      pageNumber: pageNumber ?? this.pageNumber,
      limit: limit ?? this.limit,
    );
  }
}

class MenuMasterFilterNotifier extends Notifier<MenuMasterFilterState> {
  @override
  MenuMasterFilterState build() => MenuMasterFilterState();

  void updateSearch(String query) {
    state = state.copyWith(
      searchText: query,
      pageNumber: 1,
    ); // Reset to page 1 on search
  }

  void setPage(int page) {
    state = state.copyWith(pageNumber: page);
  }
}

final menuMasterFilterProvider =
    NotifierProvider<MenuMasterFilterNotifier, MenuMasterFilterState>(
      MenuMasterFilterNotifier.new,
    );

final menuMasterProvider = FutureProvider<PaginatedMenuMasterResponse>((
  ref,
) async {
  final repository = ref.read(menuMasterRepositoryProvider);
  final filters = ref.watch(menuMasterFilterProvider);

  return repository.getMenuMaster(
    searchText: filters.searchText,
    pageNumber: filters.pageNumber,
    limit: filters.limit,
  );
});

final platformLookupProvider = FutureProvider<List<PlatformModel>>((ref) async {
  final repository = ref.read(menuMasterRepositoryProvider);
  return repository.getPlatformLookup();
});
