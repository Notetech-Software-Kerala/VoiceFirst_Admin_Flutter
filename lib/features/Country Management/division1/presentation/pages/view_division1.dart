import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/pagination_controls.dart';
import 'package:voice_first_admin/features/Country%20Management/country/models/country_model.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/models/division1_model.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/models/division1_filter.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/presentation/providers/division_one_provider.dart';
import 'package:voice_first_admin/features/Country%20Management/division2/presentation/pages/view_division2.dart';
import 'division1_detail_view.dart';

class DivisionOneView extends ConsumerStatefulWidget {
  final CountryModel country;

  const DivisionOneView({super.key, required this.country});

  @override
  ConsumerState<DivisionOneView> createState() => _DivisionOneViewState();
}

class _DivisionOneViewState extends ConsumerState<DivisionOneView> {
  final TextEditingController _searchController = TextEditingController();
  static const int _pageSize = 10;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    final notifier = ref.read(divisionOneProvider(widget.country.id).notifier);
    notifier.loadAll(
      filter: DivisionOneFilter(
        pageNumber: page,
        pageSize: _pageSize,
        searchText: _searchController.text.isEmpty
            ? null
            : _searchController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(divisionOneProvider(widget.country.id));
    final notifier = ref.read(divisionOneProvider(widget.country.id).notifier);

    final primaryColor = const Color(0xFF0D7FF2);
    final label = widget.country.divisionOneLabel ?? 'Division';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          state.isMultiSelect ? '${state.selectedIds.length} selected' : label,
          style: const TextStyle(color: Colors.white),
        ),
        leading: state.isMultiSelect
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: notifier.exitSelectionMode,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
        actions: [
          if (!state.isMultiSelect)
            TextButton(
              onPressed: notifier.enterSelectionMode,
              child: const Text(
                'Select',
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (state.isMultiSelect)
            IconButton(
              onPressed: notifier.exitSelectionMode,
              icon: const Icon(Icons.close, color: Colors.white),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(20),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search $label...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (value) => notifier.search(value),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => notifier.search(_searchController.text),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(child: Text(state.error!))
                : state.filtered.isEmpty
                ? Center(child: Text('No $label found'))
                : ListView.builder(
                    itemCount: state.filtered.length,
                    itemBuilder: (context, index) {
                      final DivisionOneModel d = state.filtered[index];
                      final bool selected = state.selectedIds.contains(d.id);

                      return GestureDetector(
                        onLongPress: () => notifier.toggleSelection(d.id),
                        onTap: () {
                          if (state.isMultiSelect) {
                            notifier.toggleSelection(d.id);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DivisionTwoView(
                                  country: widget.country,
                                  divisionOne: d,
                                ),
                              ),
                            );
                          }
                        },
                        child: Card(
                          color: selected
                              ? primaryColor.withAlpha(20)
                              : Colors.white,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: selected
                                ? BorderSide(color: primaryColor, width: 1.5)
                                : BorderSide.none,
                          ),
                          child: ListTile(
                            title: Text(d.name),
                            trailing: TextButton.icon(
                              icon: const Icon(Icons.visibility),
                              label: const Text('View'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Division1DetailPage(
                                      country: widget.country,
                                      divisionOne: d,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (state.filtered.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Builder(
                      builder: (_) {
                        final start = (state.currentPage - 1) * _pageSize + 1;
                        final end = start + state.filtered.length - 1;
                        return Text(
                          '$start-$end of ${state.totalCount}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                  PaginationControls(
                    currentPage: state.currentPage,
                    totalCount: state.totalCount,
                    pageSize: _pageSize,
                    isLoading: state.isLoading,
                    hasMoreData: state.hasMoreData,
                    onPageChanged: _goToPage,
                    primaryColor: primaryColor,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
