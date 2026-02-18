import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/advanced_search_header.dart';
import 'package:voice_first_admin/core/widgets/global_filter_bottom_sheet.dart';
import '../widgets/post_office_location_filter.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/standard_icon_box.dart';
import 'package:voice_first_admin/core/widgets/standard_list_card.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import '../providers/post_office_provider.dart';
import 'add_post_office_page.dart';
import 'post_office_details_page.dart';

import 'package:voice_first_admin/core/widgets/standard_pagination_controls.dart';

// --- MAIN SCREEN ---
class PostOfficeListScreen extends ConsumerStatefulWidget {
  const PostOfficeListScreen({super.key});

  @override
  ConsumerState<PostOfficeListScreen> createState() =>
      _PostOfficeListScreenState();
}

class _PostOfficeListScreenState extends ConsumerState<PostOfficeListScreen> {
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- ACTIONS ---

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(postOfficeProvider.notifier).setSearch(query);
    });
  }

  Future<void> _deletePostOffice(int id, String name) async {
    showDeleteBottomSheet(
      context: context,
      itemName: name,
      title: "DELETE POST OFFICE?",
      onDelete: () async {
        final success = await ref
            .read(postOfficeProvider.notifier)
            .deletePostOffice(id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Post office deleted successfully"),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Watch Provider
    final state = ref.watch(postOfficeProvider);
    final postOffices = state.postOffices;
    final totalItems = state.totalCount;
    final isLoading = state.isLoading;

    // Check for errors
    ref.listen(postOfficeProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // Pagination Info
    final totalPages = (totalItems / state.limit).ceil();
    final safeTotalPages = totalPages > 0 ? totalPages : 1;

    return StandardPageLayout(
      title: "Post Office Management",
      onRefresh: () => ref.read(postOfficeProvider.notifier).fetchPostOffices(),
      bottom: AdvancedSearchHeader(
        searchController: _searchController,
        onSearchChanged: _onSearchChanged,
        onFilterTap: () {
          final provider = ref.read(postOfficeProvider);
          final notifier = ref.read(postOfficeProvider.notifier);

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => GlobalFilterBottomSheet(
              currentFilter: provider.filter.toBase(),
              onApply: (baseFilter) {
                // Merge base filter changes back into PostOfficeFilterModel
                notifier.setFilter(provider.filter.copyWithBase(baseFilter));
              },
              searchOptions: const {
                'PostOfficeName': 'Post Office Name',
                'CountryName': 'Country Name',
                'DivOneName': 'State / Region',
                'DivTwoName': 'District / City',
                'DivThreeName': 'Division Three',
                'ZipCode': 'Zip Code',
                'CreatedUser': 'Created By',
                'UpdatedUser': 'Updated By',
                'DeletedUser': 'Deleted By',
              },
              sortOptions: const {
                'postOfficeName': 'Name',
                'createdDate': 'Created Date',
              },
              extraContent: const PostOfficeLocationFilter(),
            ),
          );
        },
        hintText: "Search Post Offices...",
        onRefresh: () =>
            ref.read(postOfficeProvider.notifier).fetchPostOffices(),
      ),
      slivers: [
        if (isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (postOffices.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: theme.disabledColor),
                  const SizedBox(height: 16),
                  Text(
                    "No post offices found",
                    style: TextStyle(color: theme.disabledColor),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final office = postOffices[index];
                return StandardListCard(
                  title: office.name,
                  subtitle:
                      "${office.flag} ${office.countryName}\n${(() {
                        final activeZips = office.zipCodes.where((z) => z.active).toList();
                        if (activeZips.isEmpty) return "No active zip codes";
                        return activeZips.take(3).map((z) => z.code).join(", ") + (activeZips.length > 3 ? " +${activeZips.length - 3} more" : "");
                      })()}",
                  leading: StandardIconBox(
                    icon: Icons.local_post_office,
                    color: theme.primaryColor,
                  ),
                  actions: [
                    StandardActionButton(
                      icon: Icons.edit,
                      color: theme.disabledColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddPostOfficePage(postOffice: office),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    StandardActionButton(
                      icon: Icons.delete,
                      color: theme.disabledColor,
                      onTap: () => _deletePostOffice(office.id, office.name),
                    ),
                  ],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PostOfficeDetailsPage(postOffice: office),
                      ),
                    );
                  },
                );
              }, childCount: postOffices.length),
            ),
          ),
      ],
      bottomNavigationBar: StandardPaginationControls(
        currentPage: state.pageNumber,
        totalPages: safeTotalPages,
        onPageChanged: (page) =>
            ref.read(postOfficeProvider.notifier).fetchPostOffices(page: page),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "post_office_fab", // Unique tag to prevent conflicts
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPostOfficePage()),
          );
        },
        backgroundColor: theme.primaryColor,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
