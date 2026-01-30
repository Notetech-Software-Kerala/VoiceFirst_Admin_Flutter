import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/standard_list_card.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import '../providers/post_office_provider.dart';
import 'add_post_office_page.dart';

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
      searchController: _searchController,
      onSearchChanged: _onSearchChanged,
      searchHint: "Search by name...",
      onRefresh: () => ref.read(postOfficeProvider.notifier).fetchPostOffices(),
      bottom: SizedBox(
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: const [
            _FilterChip(label: "Active", isSelected: true),
            SizedBox(width: 8),
            _FilterChip(label: "Zip Code", isSelected: false),
            SizedBox(width: 8),
            _FilterChip(label: "Sort: Desc", isSelected: false),
          ],
        ),
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
                );
              }, childCount: postOffices.length),
            ),
          ),
      ],
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: state.pageNumber > 1
                  ? () => ref
                        .read(postOfficeProvider.notifier)
                        .fetchPostOffices(page: state.pageNumber - 1)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              "Page ${state.pageNumber} of $safeTotalPages",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: state.pageNumber < safeTotalPages
                  ? () => ref
                        .read(postOfficeProvider.notifier)
                        .fetchPostOffices(page: state.pageNumber + 1)
                  : null,
            ),
          ],
        ),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _FilterChip({required this.label, required this.isSelected});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.primaryColor
            : (isDark ? const Color(0xFF282E39) : Colors.white),
        borderRadius: BorderRadius.circular(99),
        border: isSelected ? null : Border.all(color: theme.dividerColor),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : theme.textTheme.bodyMedium?.color,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
