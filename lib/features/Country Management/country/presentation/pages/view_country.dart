import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/presentation/pages/view_division1.dart';
import '../providers/country_provider.dart';
import 'package:voice_first_admin/core/widgets/standard_list_card.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import 'package:voice_first_admin/features/Country%20Management/country/models/country_filter.dart';
import 'country_detail_view.dart';
import 'package:voice_first_admin/core/widgets/standard_pagination_controls.dart';
// Only listing + navigation to Division 1 required

// Local search state (UI-only)
final countrySearchQueryProvider = StateProvider<String>((ref) => '');

class CountryView extends ConsumerStatefulWidget {
  const CountryView({super.key});

  @override
  ConsumerState<CountryView> createState() => _CountryViewState();
}

class _CountryViewState extends ConsumerState<CountryView> {
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(countryProvider.notifier)
          .loadAll(
            filter: const CountryFilter(pageNumber: 1, pageSize: _pageSize),
          );
    });
  }

  void _goToPage(int page) {
    ref
        .read(countryProvider.notifier)
        .loadAll(
          filter: CountryFilter(
            pageNumber: page,
            pageSize: _pageSize,
            searchText: ref.read(countrySearchQueryProvider),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(countryProvider);
    final searchQuery = ref.watch(countrySearchQueryProvider);
    final theme = Theme.of(context);

    final totalPages = (state.totalCount / _pageSize).ceil();
    final safeTotalPages = totalPages > 0 ? totalPages : 1;

    return StandardPageLayout(
      title: 'Countries',
      bottom: Container(
        padding: const EdgeInsets.all(12),
        child: TextField(
          onChanged: (value) {
            ref.read(countrySearchQueryProvider.notifier).state = value;
            ref.read(countryProvider.notifier).search(value);
          },
          decoration: InputDecoration(
            hintText: 'Search countries...',
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
      onRefresh: () async {
        await ref
            .read(countryProvider.notifier)
            .loadAll(
              filter: CountryFilter(
                pageNumber: state.currentPage,
                pageSize: _pageSize,
                searchText: searchQuery,
              ),
            );
      },
      slivers: [
        if (state.isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (state.error != null)
          SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Error: ${state.error}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(countryProvider.notifier)
                        .loadAll(
                          filter: CountryFilter(
                            pageNumber: state.currentPage,
                            pageSize: _pageSize,
                            searchText: searchQuery,
                          ),
                        );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
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
                  Text(
                    'No countries found',
                    style: theme.textTheme.titleMedium,
                  ),
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
                final c = state.filtered[index];

                final d1 = (c.divisionOneLabel ?? '').trim();
                final d2 = (c.divisionTwoLabel ?? '').trim();
                final d3 = (c.divisionThreeLabel ?? '').trim();

                String divisions = '';
                if (d1.isNotEmpty) divisions = d1;
                if (d2.isNotEmpty) {
                  divisions += (divisions.isEmpty ? '' : ' > ') + d2;
                }
                if (d3.isNotEmpty) {
                  divisions += (divisions.isEmpty ? '' : ' > ') + d3;
                }

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DivisionOneView(country: c),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: StandardListCard(
                    title: c.country,
                    subtitle: divisions.isNotEmpty ? divisions : '',
                    leading: const SizedBox.shrink(),
                    trailing: PopupMenuButton<int>(
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
                              builder: (_) =>
                                  CountryDetailPage(countryId: c.id),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              }, childCount: state.filtered.length),
            ),
          ),
      ],
      bottomNavigationBar: state.filtered.isEmpty
          ? null
          : StandardPaginationControls(
              currentPage: state.currentPage,
              totalPages: safeTotalPages,
              onPageChanged: _goToPage,
            ),
    );
  }
}
