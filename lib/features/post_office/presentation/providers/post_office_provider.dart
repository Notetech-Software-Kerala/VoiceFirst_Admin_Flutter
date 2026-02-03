import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/post_office_model.dart';
import '../../data/repositories/post_office_repository.dart';

class PostOfficeState {
  final bool isLoading;
  final List<PostOffice> postOffices;
  final int totalCount;
  final String? errorMessage;
  final int pageNumber;
  final int limit;
  final String searchText;

  PostOfficeState({
    this.isLoading = false,
    this.postOffices = const [],
    this.totalCount = 0,
    this.errorMessage,
    this.pageNumber = 1,
    this.limit = 10,
    this.searchText = '',
  });

  PostOfficeState copyWith({
    bool? isLoading,
    List<PostOffice>? postOffices,
    int? totalCount,
    String? errorMessage,
    int? pageNumber,
    int? limit,
    String? searchText,
  }) {
    return PostOfficeState(
      isLoading: isLoading ?? this.isLoading,
      postOffices: postOffices ?? this.postOffices,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: errorMessage,
      pageNumber: pageNumber ?? this.pageNumber,
      limit: limit ?? this.limit,
      searchText: searchText ?? this.searchText,
    );
  }
}

final postOfficeRepositoryProvider = Provider((ref) => PostOfficeRepository());

final postOfficeProvider =
    NotifierProvider<PostOfficeNotifier, PostOfficeState>(() {
      return PostOfficeNotifier();
    });

class PostOfficeNotifier extends Notifier<PostOfficeState> {
  late final PostOfficeRepository _repository;

  @override
  PostOfficeState build() {
    _repository = ref.watch(postOfficeRepositoryProvider);
    // Fetch initial data
    Future.microtask(() => fetchPostOffices());
    return PostOfficeState();
  }

  Future<void> fetchPostOffices({int? page}) async {
    if (page != null) {
      state = state.copyWith(pageNumber: page);
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _repository.getPostOffices(
        pageNumber: state.pageNumber,
        limit: state.limit,
        searchText: state.searchText,
      );

      final dataWrapper = response['data'];
      final List<dynamic> items = dataWrapper['items'] ?? [];
      final totalCount =
          dataWrapper['totalCount'] ?? dataWrapper['totalItems'] ?? 0;

      final mappedItems = items
          .map((json) => PostOffice.fromJson(json))
          .toList();

      state = state.copyWith(
        isLoading: false,
        postOffices: mappedItems,
        totalCount: totalCount,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearch(String query) {
    if (state.searchText == query) return;
    state = state.copyWith(searchText: query, pageNumber: 1);
    fetchPostOffices();
  }

  Future<bool> deletePostOffice(int id) async {
    try {
      await _repository.deletePostOffice(id);
      fetchPostOffices();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: "Delete failed: $e");
      return false;
    }
  }

  Future<bool> createPostOffice(Map<String, dynamic> data) async {
    try {
      await _repository.createPostOffice(data);
      fetchPostOffices();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: "Create failed: $e");
      return false;
    }
  }

  Future<bool> updatePostOffice(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updatePostOffice(id, data);
      fetchPostOffices();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: "Update failed: $e");
      return false;
    }
  }

  Future<PostOffice?> getPostOfficeById(int id) async {
    try {
      final data = await _repository.getPostOfficeById(id);
      return PostOffice.fromJson(data['data']);
    } catch (e) {
      return null;
    }
  }
}
