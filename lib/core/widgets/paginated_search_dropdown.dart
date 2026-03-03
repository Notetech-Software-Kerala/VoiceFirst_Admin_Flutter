import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaginatedSearchDropdown<T> extends ConsumerStatefulWidget {
  final String id;
  final ValueNotifier<String?>? openGroup;

  final String label;
  final String hintText;

  final AsyncValue<List<T>> asyncItems;
  final T? selectedItem;

  final String Function(T item) displayText;
  final int Function(T item) itemId;

  final void Function(T item) onItemSelected;
  final void Function(String searchText) onSearch;
  final VoidCallback onLoadMore;

  /// Optional custom builder for each list item inside the
  /// bottom sheet. When provided, this completely controls
  /// the row UI (and tap behavior) for each item.
  final Widget Function(
    BuildContext context,
    ThemeData theme,
    T item,
    bool isSelected,
  )?
  itemBuilder;

  const PaginatedSearchDropdown({
    super.key,
    required this.id,
    this.openGroup,
    required this.label,
    required this.hintText,
    required this.asyncItems,
    required this.selectedItem,
    required this.displayText,
    required this.itemId,
    required this.onItemSelected,
    required this.onSearch,
    required this.onLoadMore,
    this.itemBuilder,
  });

  @override
  ConsumerState<PaginatedSearchDropdown<T>> createState() =>
      _PaginatedSearchDropdownState<T>();
}

class _PaginatedSearchDropdownState<T>
    extends ConsumerState<PaginatedSearchDropdown<T>> {
  bool _isSheetOpen = false;

  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  Timer? _debounce;
  bool _isRequestingMore = false;

  /// Simple version counter to trigger bottom-sheet rebuilds
  /// when the parent asyncItems changes (e.g., new pages loaded).
  late final ValueNotifier<int> _itemsVersion;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _itemsVersion = ValueNotifier(0);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _itemsVersion.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PaginatedSearchDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // After each update, bump the version so the bottom sheet
    // rebuilds with the latest asyncItems (including new pages
    // and search results), without updating during the build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _itemsVersion.value++;
      _isRequestingMore = false;
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 150) {
      if (!_isRequestingMore) {
        _isRequestingMore = true;
        widget.onLoadMore();
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onSearch(value.trim());
      _isRequestingMore = false;
    });
  }

  Future<void> _openBottomSheet() async {
    setState(() => _isSheetOpen = true);
    _searchController.clear();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        final theme = Theme.of(context);

        return Consumer(
          builder: (context, ref, _) {
            return FractionallySizedBox(
              heightFactor: 0.65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Field
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  // Results
                  Expanded(
                    child: ValueListenableBuilder<int>(
                      valueListenable: _itemsVersion,
                      builder: (context, _, __) {
                        final asyncItems = widget.asyncItems;
                        return asyncItems.when(
                          loading: () => _buildLoading(),
                          error: (_, __) => _buildError(theme),
                          data: (items) => _buildList(theme, items),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (!mounted) return;
    setState(() => _isSheetOpen = false);
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              widget.onSearch(_searchController.text.trim());
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildList(ThemeData theme, List<T> items) {
    if (items.isEmpty) {
      return const Center(child: Text("No items found"));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        final isSelected =
            widget.selectedItem != null &&
            widget.itemId(item) == widget.itemId(widget.selectedItem as T);

        // Allow callers to fully control the row UI when
        // a custom builder is provided.
        if (widget.itemBuilder != null) {
          return widget.itemBuilder!(context, theme, item, isSelected);
        }

        return InkWell(
          onTap: () {
            widget.onItemSelected(item);
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.08)
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.displayText(item),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check, color: theme.colorScheme.primary),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSelection = widget.selectedItem != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),

        InkWell(
          onTap: _openBottomSheet,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasSelection
                        ? widget.displayText(widget.selectedItem as T)
                        : widget.hintText,
                    style: hasSelection
                        ? theme.textTheme.bodyMedium
                        : theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                  ),
                ),
                Icon(
                  _isSheetOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
