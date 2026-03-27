import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/app_menu_model.dart';
import '../../data/repositories/menu_repository.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';

final menuRepositoryProvider = Provider((ref) => MenuRepository(ref.read(dioClientProvider)));

final menuProvider = AsyncNotifierProvider<MenuNotifier, List<AppMenuModel>>(
  MenuNotifier.new,
);

class MenuNotifier extends AsyncNotifier<List<AppMenuModel>> {
  MenuRepository get _repository => ref.read(menuRepositoryProvider);

  @override
  Future<List<AppMenuModel>> build() async {
    return _fetchMenu();
  }

  Future<List<AppMenuModel>> _fetchMenu() async {
    final flatList = await _repository.getAppMenu();
    return buildMenuTree(flatList);
  }

  // --- LOGIC ---

  void reorderParent(int oldIndex, int newIndex) {
    state.whenData((items) {
      if (oldIndex < newIndex) newIndex -= 1;
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
      state = AsyncValue.data([...items]);
    });
  }

  void reorderChild(int parentIndex, int oldIndex, int newIndex) {
    state.whenData((items) {
      var parent = items[parentIndex];
      var children = parent.children;
      if (oldIndex < newIndex) newIndex -= 1;
      final item = children.removeAt(oldIndex);
      children.insert(newIndex, item);
      // Trigger update
      state = AsyncValue.data([...items]);
    });
  }

  void moveChild(AppMenuModel item, int fromParentId, int toParentId) {
    state.whenData((items) {
      // 1. Find and Remove from Source
      // The source could be at root level (fromParentId == 0) or nested
      if (fromParentId == 0) {
        items.removeWhere((e) => e.appMenuId == item.appMenuId);
      } else {
        // Find the parent in the list (assuming 1 level deep for now, or recursive scan)
        // Since our UI is currently 2-level (Parent -> Child), let's assume `items` are the parents.
        // We might need a helper to find parent by ID if we go deeper.
        try {
          final sourceParent = items.firstWhere(
            (e) => e.appMenuId == fromParentId,
          );
          sourceParent.children.removeWhere(
            (child) => child.appMenuId == item.appMenuId,
          );
        } catch (e) {
          // Verify if it was a root item that we thought was nested?
          // If fromParentId is not 0, it must be in the list.
        }
      }

      // 2. Add to Destination
      if (toParentId == 0) {
        // Moving to Root
        // We need to insert it at the end? or specific index?
        // For now appends to root list
        items.add(item);
      } else {
        try {
          final destParent = items.firstWhere((e) => e.appMenuId == toParentId);
          // Validation removed to unblock user. Accepting all drops.
          destParent.children.add(item);
        } catch (e) {
          // Destination parent not found
        }
      }

      state = AsyncValue.data([...items]);
    });
  }

  Future<void> saveChanges() async {
    final currentState = state.value;
    if (currentState == null) return;

    List<Map<String, dynamic>> moveAndReorder = [];
    List<Map<String, dynamic>> reorders = [];

    // Helper to process a list of items for a given parent ID
    void processList(List<AppMenuModel> items, int currentParentId) {
      // 1. Reorders Payload (Initially add for ALL, filtering later)
      if (items.isNotEmpty) {
        reorders.add({
          "parentAppMenuId": currentParentId,
          "orderedIds": items.map((e) => e.appMenuId).toList(),
        });
      }

      // 2. Move Detection
      for (var item in items) {
        if (item.parentId != currentParentId) {
          moveAndReorder.add({
            "appMenuId": item.appMenuId,
            "parentAppMenuId": currentParentId,
            "newOrderUnderToParent": items.map((e) => e.appMenuId).toList(),
          });
        }
        if (item.children.isNotEmpty) {
          processList(item.children, item.appMenuId);
        }
      }
    }

    // Start processing from Root (parentId = 0)
    processList(currentState, 0);

    // FILTER: If a parent has a 'move' targeting it, assume 'moveAndReorder' handles the sort.
    // Remove it from 'reorders' to avoid redundancy/backend conflict.
    final parentsWithMoves = moveAndReorder
        .map((e) => e['parentAppMenuId'] as int)
        .toSet();

    reorders.removeWhere(
      (e) => parentsWithMoves.contains(e['parentAppMenuId']),
    );

    await _repository.updateMenuBulk(
      moveAndReorder: moveAndReorder,
      reorders: reorders,
      statusUpdate: [],
    );

    // Refresh to ensure sync and update local 'parentId's via fetch
    ref.invalidateSelf();
  }
}
