import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/advanced_search_header.dart';
import 'package:voice_first_admin/core/widgets/arrow_breadcrumb.dart';
import 'package:voice_first_admin/core/widgets/global_filter_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/standard_icon_box.dart';
import 'package:voice_first_admin/core/widgets/standard_list_card.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import 'package:voice_first_admin/core/widgets/standard_pagination_controls.dart';
import 'package:voice_first_admin/features/country_management/country/data/models/country_model.dart';
import 'package:voice_first_admin/features/country_management/division1/data/models/division1_model.dart';
import 'package:voice_first_admin/features/country_management/division1/data/models/division1_filter.dart';
import 'package:voice_first_admin/features/country_management/division1/presentation/pages/division1_detail_view.dart';
import 'package:voice_first_admin/features/country_management/division1/presentation/providers/division_one_provider.dart';
import 'package:voice_first_admin/features/country_management/division2/presentation/pages/view_division2.dart';

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
    final state = ref.read(divisionOneProvider(widget.country.id));
    notifier.loadAll(
      filter: DivisionOneFilter(
        countryId: widget.country.id,
        pageNumber: page,
        pageSize: _pageSize,
        searchText: state.filter.searchText,
      ),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final state = ref.read(divisionOneProvider(widget.country.id));
        final notifier = ref.read(
          divisionOneProvider(widget.country.id).notifier,
        );
        return GlobalFilterBottomSheet(
          currentFilter: state.filter,
          onApply: (base) {
            Navigator.pop(context);
            try {
              final b = base;
              notifier.loadAll(
                filter: DivisionOneFilter(
                  countryId: widget.country.id,
                  pageNumber: 1,
                  pageSize: _pageSize,
                  searchText: b.searchText,
                  searchBy: b.searchBy,
                  sortBy: b.sortBy,
                  sortOrder: b.sortOrder,
                  active: b.active,
                  deleted: b.deleted,
                  createdFromDate: b.createdFromDate,
                  createdToDate: b.createdToDate,
                  updatedFromDate: b.updatedFromDate,
                  updatedToDate: b.updatedToDate,
                  deletedFromDate: b.deletedFromDate,
                  deletedToDate: b.deletedToDate,
                ),
              );
            } catch (_) {}
          },
          searchOptions: const {'name': 'Name', 'status': 'Status'},
          sortOptions: const {
            'newest': 'Newest',
            'oldest': 'Oldest',
            'name_asc': 'Name (A-Z)',
            'name_desc': 'Name (Z-A)',
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(divisionOneProvider(widget.country.id));
    final notifier = ref.read(divisionOneProvider(widget.country.id).notifier);

    final theme = Theme.of(context);
    final label = widget.country.divisionOneLabel ?? 'Division';
    final totalPages = (state.totalCount / _pageSize).ceil();
    final safeTotalPages = totalPages > 0 ? totalPages : 1;

    return StandardPageLayout(
      title: state.isMultiSelect
          ? '${state.selectedIds.length} selected'
          : label,
      leading: InkWell(
        onTap: state.isMultiSelect
            ? notifier.exitSelectionMode
            : () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          margin: const EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.brightness == Brightness.dark
                ? Colors.white.withAlpha(13)
                : Colors.grey[100],
          ),
          child: Icon(
            state.isMultiSelect ? Icons.close : Icons.arrow_back_ios_new,
            size: 20,
          ),
        ),
      ),
      actions: [
        if (!state.isMultiSelect)
          TextButton(
            onPressed: notifier.enterSelectionMode,
            child: const Text('Select'),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ArrowBreadcrumb(
              items: [
                BreadcrumbItem(
                  label: widget.country.country,
                  onTap: () => Navigator.pop(context),
                ),
                BreadcrumbItem(label: label, isActive: true),
              ],
            ),
            AdvancedSearchHeader(
              searchController: _searchController,
              hintText: 'Search $label...',
              onSearchChanged: notifier.search,
              onFilterTap: _openFilterSheet,
              onRefresh: () => _goToPage(state.currentPage),
            ),
          ],
        ),
      ),
      onRefresh: () async {
        _goToPage(state.currentPage);
      },
      slivers: [
        if (state.isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (state.error != null)
          SliverFillRemaining(child: Center(child: Text(state.error!)))
        else if (state.items.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: theme.disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text('No $label found', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Try changing search or filters',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final DivisionOneModel d = state.items[index];
                final bool selected = state.selectedIds.contains(d.id);

                final leadingWidget = state.isMultiSelect
                    ? Checkbox(
                        value: selected,
                        onChanged: (_) => notifier.toggleSelection(d.id),
                      )
                    : StandardIconBox(
                        icon: Icons.account_tree_outlined,
                        color: theme.colorScheme.primary,
                      );

                return InkWell(
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
                  borderRadius: BorderRadius.circular(12),
                  child: StandardListCard(
                    title: d.name,
                    subtitle: widget.country.country,
                    leading: leadingWidget,
                    actions: [
                      StandardActionButton(
                        icon: Icons.info_outline,
                        color: theme.colorScheme.primary,
                        onTap: () {
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
                    ],
                  ),
                );
              }, childCount: state.items.length),
            ),
          ),
      ],
      bottomNavigationBar: state.items.isEmpty
          ? null
          : StandardPaginationControls(
              currentPage: state.currentPage,
              totalPages: safeTotalPages,
              onPageChanged: _goToPage,
            ),
    );
  }
}
