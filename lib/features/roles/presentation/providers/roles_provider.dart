import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/role_model.dart';
import '../../data/repositories/roles_repository.dart';

// --- State ---
class RolesState {
  final List<RoleModel> roles;
  final bool isLoading;
  final String? error;

  RolesState({this.roles = const [], this.isLoading = false, this.error});

  RolesState copyWith({
    List<RoleModel>? roles,
    bool? isLoading,
    String? error,
  }) {
    return RolesState(
      roles: roles ?? this.roles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// --- Notifier ---
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
      final roles = await _repository.getRoles();
      state = state.copyWith(roles: roles, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
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
