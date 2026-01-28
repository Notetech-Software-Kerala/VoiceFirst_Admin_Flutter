import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:voice_first_admin/features/Country%20Management/country/models/country_model.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/presentation/pages/view_division1.dart';
import '../providers/country_provider.dart';
import '../providers/country_state.dart';
import 'package:voice_first_admin/core/widgets/pagination_controls.dart';
import 'package:voice_first_admin/features/Country%20Management/country/models/country_filter.dart';
import 'country_detail_view.dart';
// Only listing + navigation to Division 1 required

// Local search state (UI-only)
final countrySearchQueryProvider = StateProvider<String>((ref) => '');

class CountryView extends ConsumerStatefulWidget {
  const CountryView({super.key});

  @override
  ConsumerState<CountryView> createState() => _CountryViewState();
}

class _CountryViewState extends ConsumerState<CountryView> {
  final ScrollController _scrollController = ScrollController();
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(countryProvider);
    final searchQuery = ref.watch(countrySearchQueryProvider);

    final primaryColor = const Color(0xFF0D7FF2);

    return Scaffold(
      backgroundColor: Colors.white,

      // ───────────────── AppBar ─────────────────
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text('Countries', style: const TextStyle(color: Colors.white)),
      ),

      // ───────────────── Body ─────────────────
      body: Column(
        children: [
          // 🔍 Search
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(20),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: TextField(
              onChanged: (value) {
                ref.read(countrySearchQueryProvider.notifier).state = value;
                ref.read(countryProvider.notifier).search(value);
              },
              decoration: InputDecoration(
                hintText: 'Search countries...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // 📋 List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Error: ${state.error}',
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.red),
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
                  )
                : Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 12,
                          top: 12,
                          bottom: 60,
                        ),
                        itemCount: state.filtered.length,
                        itemBuilder: (context, index) {
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

                          return ListTile(
                            title: Text(c.country),
                            subtitle: divisions.isNotEmpty
                                ? Text(divisions)
                                : null,
                            trailing: TextButton.icon(
                              icon: const Icon(Icons.visibility),
                              label: const Text('View'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CountryDetailPage(countryId: c.id),
                                  ),
                                );
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DivisionOneView(country: c),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      if (state.filtered.isNotEmpty)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
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
                                      final start =
                                          (state.currentPage - 1) * _pageSize +
                                          1;
                                      final end =
                                          start + state.filtered.length - 1;

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
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
