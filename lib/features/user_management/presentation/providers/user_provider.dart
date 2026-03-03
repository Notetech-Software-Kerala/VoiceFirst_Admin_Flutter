import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/models/user_filter_model.dart';
import '../../data/repositories/user_repository.dart';

class UserState {
  final bool isLoading;
  final List<UserModel> users;
  final int totalCount;
  final String? errorMessage;
  final UserFilterModel filter;

  UserState({
    this.isLoading = false,
    this.users = const [],
    this.totalCount = 0,
    this.errorMessage,
    this.filter = const UserFilterModel(),
  });

  UserState copyWith({
    bool? isLoading,
    List<UserModel>? users,
    int? totalCount,
    String? errorMessage,
    UserFilterModel? filter,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
    );
  }
}

final userRepositoryProvider = Provider((ref) => UserRepository());

final userProvider = NotifierProvider<UserNotifier, UserState>(() {
  return UserNotifier();
});

class UserNotifier extends Notifier<UserState> {
  late final UserRepository _repository;

  @override
  UserState build() {
    _repository = ref.watch(userRepositoryProvider);
    // Fetch initial data
    Future.microtask(() => fetchUsers());
    return UserState();
  }

  Future<void> fetchUsers({int? page}) async {
    if (page != null) {
      state = state.copyWith(filter: state.filter.copyWith(pageNumber: page));
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _repository.getUsers(state.filter);

      final dataWrapper = response['data'];
      final List<dynamic> items = dataWrapper['items'] ?? [];
      final totalCount =
          dataWrapper['totalCount'] ?? dataWrapper['totalItems'] ?? 0;

      final mappedItems = items
          .map((json) => UserModel.fromJson(json))
          .toList();

      state = state.copyWith(
        isLoading: false,
        users: mappedItems,
        totalCount: totalCount,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setSearch(String query) {
    if (state.filter.searchText == query) return;
    state = state.copyWith(
      filter: state.filter.copyWith(searchText: query, pageNumber: 1),
    );
    fetchUsers();
  }

  void setRoleFilter(String? role) {
    if (state.filter.role == role) return;
    state = state.copyWith(
      filter: state.filter.copyWith(role: role, pageNumber: 1),
    );
    fetchUsers();
  }

  void setPage(int page) {
    fetchUsers(page: page);
  }

  /// Unified save method for Create (POST) or Update (PATCH)
  Future<void> saveUser({
    int? id, // null means Create, otherwise Update
    required String firstName,
    required String lastName,
    required String gender,
    required String birthYear,
    required String email,
    required String mobileNo,
    required int dialCodeId,
    required List<int> roleIds,
    required bool active,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final payload = {
      "firstName": firstName,
      "lastName": lastName,
      "gender": gender, // Ensure it's passed consistently (e.g. lowercase)
      "birthYear": int.tryParse(birthYear) ?? 0,
      "email": email,
      "mobileNo": mobileNo,
      "dialCodeId": dialCodeId,
      "roleIds": roleIds,
      "active": active,
    };

    try {
      if (id == null) {
        // Create
        await _repository.createUser(payload);
      } else {
        // Update (PATCH expects the same payload structure typically)
        await _repository.updateUser(id, payload);
      }

      // Refresh list after successful save
      await fetchUsers(page: state.filter.pageNumber);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow; // Re-throw so the UI can show a specific error SnackBar
    }
  }

  Future<void> deleteUser(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.deleteUser(id);
      // Refresh list after successful delete
      await fetchUsers(page: state.filter.pageNumber);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> recoverUser(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.recoverUser(id);
      // Refresh list after successful recovery
      await fetchUsers(page: state.filter.pageNumber);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }
}
