import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/standard_list_card.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import 'package:voice_first_admin/core/widgets/arrow_breadcrumb.dart';
import 'package:voice_first_admin/features/Country%20Management/country/models/country_model.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/models/division1_model.dart';
import 'package:voice_first_admin/features/Country%20Management/division2/models/DivisionTwoModel';
import 'package:voice_first_admin/features/Country%20Management/division2/models/division2_filter.dart';
import 'package:voice_first_admin/features/Country%20Management/division3/presentation/pages/view_division3.dart';
import 'package:voice_first_admin/features/Country%20Management/division2/presentation/pages/division2_detail_view.dart';
import '../providers/division_two_provider.dart';

class DivisionTwoView extends ConsumerStatefulWidget {
  final CountryModel country;
  final DivisionOneModel divisionOne;

  const DivisionTwoView({
    super.key,
    required this.country,
    required this.divisionOne,
  });

  @override
  ConsumerState<DivisionTwoView> createState() => _DivisionTwoViewState();
}

class _DivisionTwoViewState extends ConsumerState<DivisionTwoView> {
  final TextEditingController _searchController = TextEditingController();
  static const int _pageSize = 10;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    final notifier = ref.read(
      divisionTwoProvider(widget.divisionOne.id).notifier,
    );
    notifier.loadAll(
      filter: DivisionTwoFilter(
        divisionOneId: widget.divisionOne.id,
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
    final state = ref.watch(divisionTwoProvider(widget.divisionOne.id));
    final notifier = ref.read(
      divisionTwoProvider(widget.divisionOne.id).notifier,
    );

    final theme = Theme.of(context);
    final label = widget.country.divisionTwoLabel ?? 'Division 2';

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
              BreadcrumbItem(label: label, isActive: true),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) => notifier.search(value),
              decoration: InputDecoration(
                hintText: 'Search $label...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
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
        else if (state.filtered.isEmpty)
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
                final DivisionTwoModel d = state.filtered[index];
                final bool selected = state.selectedIds.contains(d.id);

                return InkWell(
                  onLongPress: () => notifier.toggleSelection(d.id),
                  onTap: () {
                    if (state.isMultiSelect) {
                      notifier.toggleSelection(d.id);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DivisionThreeView(
                            country: widget.country,
                            divisionOne: widget.divisionOne,
                            divisionTwo: d,
                          ),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: StandardListCard(
                    title: d.name,
                    subtitle: '',
                    leading: const SizedBox.shrink(),
                    trailing: selected
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Selected',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : null,
                    actions: [
                      PopupMenuButton<int>(
                        itemBuilder: (context) => const [
                          PopupMenuItem<int>(
                            value: 1,
                            child: Text('View Details'),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Division2DetailPage(
                                  country: widget.country,
                                  divisionOne: widget.divisionOne,
                                  divisionTwo: d,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              }, childCount: state.filtered.length),
            ),
          ),
      ],
      bottomNavigationBar: state.filtered.isEmpty
          ? null
          : Container(
              height: 60,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: state.currentPage > 1
                        ? () => _goToPage(state.currentPage - 1)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Builder(
                    builder: (_) {
                      final totalPages = (state.totalCount / _pageSize).ceil();
                      final safeTotalPages = totalPages > 0 ? totalPages : 1;
                      return Text(
                        'Page ${state.currentPage} of $safeTotalPages',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: (() {
                      final totalPages = (state.totalCount / _pageSize).ceil();
                      final safeTotalPages = totalPages > 0 ? totalPages : 1;
                      return state.currentPage < safeTotalPages
                          ? () => _goToPage(state.currentPage + 1)
                          : null;
                    })(),
                  ),
                ],
              ),
            ),
    );
  }
}
