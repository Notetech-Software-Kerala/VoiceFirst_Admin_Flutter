import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/role_model.dart';
import '../../models/role_filter_model.dart';
import '../../data/repositories/roles_repository.dart';

// --- State ---
class RolesState {
  final List<RoleModel> roles;
  final bool isLoading;
  final String? error;
  final RoleFilterModel filter;
  final int totalCount;
  final int totalPages;

  RolesState({
    this.roles = const [],
    this.isLoading = false,
    this.error,
    this.filter = const RoleFilterModel(),
    this.totalCount = 0,
    this.totalPages = 0,
  });

  RolesState copyWith({
    List<RoleModel>? roles,
    bool? isLoading,
    String? error,
    RoleFilterModel? filter,
    int? totalCount,
    int? totalPages,
  }) {
    return RolesState(
      roles: roles ?? this.roles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filter: filter ?? this.filter,
      totalCount: totalCount ?? this.totalCount,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

// --- Notifier ---
class RolesNotifier extends Notifier<RolesState> {
  @override
  RolesState build() {
    // Initial load
    Future.microtask(() => loadRoles());
    return RolesState();
  }

  RolesRepository get _repository => ref.read(rolesRepositoryProvider);

  Future<void> loadRoles() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.getRoles(state.filter);
      final data = response['data'];
      final List items = data['items'] ?? [];
      final roles = items.map((e) => RoleModel.fromJson(e)).toList();

      state = state.copyWith(
        roles: roles,
        isLoading: false,
        totalCount: data['totalCount'] ?? 0,
        totalPages: data['totalPages'] ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(RoleFilterModel filter) {
    state = state.copyWith(filter: filter);
    loadRoles();
  }

  void updateSearchText(String query) {
    // Debouncing could be handled here or in UI
    state = state.copyWith(
      filter: state.filter.copyWith(searchText: query, pageNumber: 1),
    );
    loadRoles();
  }

  void updatePage(int page) {
    if (page < 1 || (state.totalPages > 0 && page > state.totalPages)) return;
    state = state.copyWith(filter: state.filter.copyWith(pageNumber: page));
    loadRoles();
  }

  Future<void> addRole(RoleModel role) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.createRole(role);
      await loadRoles(); // Refresh list
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateRole(RoleModel role) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.updateRole(role);
      await loadRoles();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteRole(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.deleteRole(id);
      await loadRoles();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

// --- Providers ---
final rolesProvider = NotifierProvider<RolesNotifier, RolesState>(
  RolesNotifier.new,
);
