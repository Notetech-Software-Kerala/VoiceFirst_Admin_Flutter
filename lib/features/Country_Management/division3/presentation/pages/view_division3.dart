import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/advanced_search_header.dart';
import 'package:voice_first_admin/core/models/base_filter_model.dart';
import 'package:voice_first_admin/core/widgets/arrow_breadcrumb.dart';
import 'package:voice_first_admin/core/widgets/global_filter_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/standard_icon_box.dart';
import 'package:voice_first_admin/core/widgets/standard_list_card.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import 'package:voice_first_admin/core/widgets/standard_pagination_controls.dart';
import 'package:voice_first_admin/features/country_management/country/data/models/country_model.dart';
import 'package:voice_first_admin/features/country_management/division1/data/models/division1_model.dart';
import 'package:voice_first_admin/features/country_management/division2/data/models/division_two_model.dart';
import 'package:voice_first_admin/features/country_management/division3/data/models/division3_filter.dart';
import 'package:voice_first_admin/features/country_management/division3/presentation/pages/division3_detail_view.dart';
import 'package:voice_first_admin/features/country_management/division3/presentation/providers/division_three_provider.dart';

class DivisionThreeView extends ConsumerStatefulWidget {
  final CountryModel country;
  final DivisionOneModel divisionOne;
  final DivisionTwoModel divisionTwo;

  const DivisionThreeView({
    super.key,
    required this.country,
    required this.divisionOne,
    required this.divisionTwo,
  });

  @override
  ConsumerState<DivisionThreeView> createState() => _DivisionThreeViewState();
}

class _DivisionThreeViewState extends ConsumerState<DivisionThreeView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final state = ref.read(divisionThreeProvider(widget.divisionTwo.id));
        final notifier = ref.read(
          divisionThreeProvider(widget.divisionTwo.id).notifier,
        );
        return GlobalFilterBottomSheet(
          currentFilter: state.filter,
          onApply: (base) {
            Navigator.pop(context);
            try {
              final b = base;
              notifier.loadAll(
                filter: DivisionThreeFilter(
                  divisionTwoId: widget.divisionTwo.id,
                  pageNumber: 1,
                  pageSize: 10,
                  searchText: b.searchText,
                  searchBy: b.searchBy,
                  sortBy: b.sortBy,
                  sortOrder: b.sortOrder,
                  active: b.active,
                  deleted: b.deleted,
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
    final state = ref.watch(divisionThreeProvider(widget.divisionTwo.id));
    final notifier = ref.read(
      divisionThreeProvider(widget.divisionTwo.id).notifier,
    );

    final theme = Theme.of(context);
    final label = widget.country.divisionThreeLabel ?? 'Division 3';
    final safeTotalPages = state.totalPages > 0 ? state.totalPages : 1;

    return StandardPageLayout(
      title: label,
      leading: InkWell(
        onTap: () => Navigator.pop(context),
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
          child: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
      ),
      bottom: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArrowBreadcrumb(
            items: [
              BreadcrumbItem(
                label: widget.country.country,
                onTap: () => Navigator.pop(context),
              ),
              BreadcrumbItem(
                label: widget.country.divisionOneLabel ?? 'Division 1',
                onTap: () => Navigator.pop(context),
              ),
              BreadcrumbItem(
                label: widget.country.divisionTwoLabel ?? 'Division 2',
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
            onRefresh: () => notifier.loadAll(page: state.currentPage),
          ),
        ],
      ),
      slivers: [
        if (state.isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
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
                final d = state.items[index];
                return StandardListCard(
                  title: d.name,
                  subtitle:
                      '${widget.country.divisionTwoLabel ?? 'Division 2'}: ${widget.divisionTwo.name}',
                  leading: StandardIconBox(
                    icon: Icons.location_on_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  actions: [
                    StandardActionButton(
                      icon: Icons.info_outline,
                      color: theme.colorScheme.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Division3DetailPage(
                              country: widget.country,
                              divisionOne: widget.divisionOne,
                              divisionTwo: widget.divisionTwo,
                              divisionThree: d,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Division3DetailPage(
                          country: widget.country,
                          divisionOne: widget.divisionOne,
                          divisionTwo: widget.divisionTwo,
                          divisionThree: d,
                        ),
                      ),
                    );
                  },
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
              onPageChanged: (p) => notifier.loadAll(page: p),
            ),
    );
  }
}
