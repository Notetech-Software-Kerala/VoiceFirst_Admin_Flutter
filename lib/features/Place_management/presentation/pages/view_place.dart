import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/advanced_search_header.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/global_filter_bottom_sheet.dart';
import 'package:voice_first_admin/core/models/base_filter_model.dart';
import 'package:voice_first_admin/core/widgets/standard_icon_box.dart';
import 'package:voice_first_admin/core/widgets/standard_list_card.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import 'package:voice_first_admin/core/widgets/standard_pagination_controls.dart';
import 'package:voice_first_admin/features/Place_management/presentation/pages/edit_place_page.dart';
import '../../data/models/place_requests.dart';
import '../providers/place_provider.dart';
import 'add_place_page.dart';
import 'place_detail_page.dart';

class ViewPlacePage extends ConsumerStatefulWidget {
  const ViewPlacePage({super.key});

  @override
  ConsumerState<ViewPlacePage> createState() => _ViewPlacePageState();
}

class _ViewPlacePageState extends ConsumerState<ViewPlacePage> {
  late final TextEditingController _searchController;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(placeProvider.notifier).loadPlaces(page: 1, pageSize: _pageSize);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    final currentSearch = ref.read(placeProvider).search;
    ref
        .read(placeProvider.notifier)
        .loadPlaces(page: page, pageSize: _pageSize, search: currentSearch);
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GlobalFilterBottomSheet(
        currentFilter: const BaseFilterModel(),
        onApply: (filter) {
          // Apply filter logic here
          Navigator.pop(context);
        },
        searchOptions: const {'name': 'Place Name', 'status': 'Status'},
        sortOptions: const {
          'newest': 'Newest',
          'oldest': 'Oldest',
          'name_asc': 'Name (A-Z)',
          'name_desc': 'Name (Z-A)',
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(placeProvider);
    final notifier = ref.read(placeProvider.notifier);
    final theme = Theme.of(context);

    final totalPages = (state.totalCount / _pageSize).ceil();
    final safeTotalPages = totalPages > 0 ? totalPages : 1;

    if (_searchController.text != state.search) {
      _searchController.text = state.search;
    }

    return StandardPageLayout(
      title: 'Places',
      bottom: AdvancedSearchHeader(
        searchController: _searchController,
        hintText: 'Search places...',
        onSearchChanged: (q) {
          notifier.loadPlaces(page: 1, pageSize: _pageSize, search: q);
        },
        onFilterTap: _openFilterSheet,
        onRefresh: () {
          notifier.loadPlaces(
            page: state.currentPage,
            pageSize: _pageSize,
            search: state.search,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'place_fab',
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPlacePage()),
          ).then((_) {
            notifier.loadPlaces(
              page: state.currentPage,
              pageSize: _pageSize,
              search: state.search,
            );
          });
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: (state.isLoading || state.places.isEmpty)
          ? null
          : StandardPaginationControls(
              currentPage: state.currentPage,
              totalPages: safeTotalPages,
              onPageChanged: _goToPage,
            ),
      slivers: [
        if (state.isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (state.places.isEmpty)
          const SliverFillRemaining(
            child: Center(child: Text('No places found')),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final place = state.places[index];
                final isDeleted = place.deleted;

                final actions = <Widget>[];
                actions.addAll([
                  Transform.scale(
                    scale: 0.75,
                    child: Switch(
                      value: place.active,
                      onChanged: isDeleted
                          ? null
                          : (val) async {
                              final success = await notifier.updatePlace(
                                place.placeId,
                                UpdatePlaceRequest(active: val),
                              );
                              if (!context.mounted) return;
                              CustomSnackbar.show(
                                context,
                                message: success
                                    ? (val
                                          ? 'Place activated successfully'
                                          : 'Place deactivated successfully')
                                    : 'Failed to update place status',
                                type: success
                                    ? SnackBarType.success
                                    : SnackBarType.error,
                              );
                            },
                      activeThumbColor: Colors.green[400],
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      inactiveThumbColor: isDeleted
                          ? Colors.grey.withAlpha(102)
                          : null,
                    ),
                  ),
                  StandardActionButton(
                    icon: Icons.edit,
                    color: isDeleted
                        ? Colors.grey.withAlpha(102)
                        : Colors.blueAccent,
                    onTap: () {
                      if (isDeleted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditPlacePage(place: place),
                        ),
                      );
                    },
                  ),
                  StandardActionButton(
                    icon: Icons.delete,
                    color: isDeleted ? Colors.red.withAlpha(102) : Colors.red,

                    onTap: () {
                      if (isDeleted) return;

                      showDeleteBottomSheet(
                        context: context,
                        itemName: place.placeName,
                        onDelete: () async {
                          final success = await notifier.deletePlace(
                            place.placeId,
                          );
                          if (!context.mounted) return;

                          CustomSnackbar.show(
                            context,
                            message: success
                                ? 'Place deleted successfully'
                                : 'Failed to delete place',
                            type: success
                                ? SnackBarType.success
                                : SnackBarType.error,
                          );
                        },
                      );
                    },
                  ),
                ]);

                return StandardListCard(
                  key: ValueKey(place.placeId),
                  leading: const StandardIconBox(
                    icon: Icons.location_on,
                    color: Colors.blue,
                  ),
                  title: place.placeName,
                  actions: actions,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaceDetailPage(
                          placeId: place.placeId,
                          initialPlace: place,
                        ),
                      ),
                    );
                  },
                );
              }, childCount: state.places.length),
            ),
          ),
      ],
    );
  }
}

class _EmptyPlaces extends StatelessWidget {
  final ThemeData theme;
  const _EmptyPlaces({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.primaryColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox,
              size: 40,
              color: theme.primaryColor.withAlpha(128),
            ),
          ),
          const SizedBox(height: 16),
          const Text('No places found'),
        ],
      ),
    );
  }
}

String _fmtDate(DateTime? dt) {
  if (dt == null) return 'N/A';
  final day = dt.day.toString().padLeft(2, '0');
  final month = dt.month.toString().padLeft(2, '0');
  final year = dt.year.toString();
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}
