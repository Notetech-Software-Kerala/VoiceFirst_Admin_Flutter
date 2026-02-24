import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/advanced_search_header.dart';
import 'package:voice_first_admin/core/widgets/custom_snackbar.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/core/widgets/global_filter_bottom_sheet.dart';
import 'package:voice_first_admin/core/models/base_filter_model.dart';
import 'package:voice_first_admin/core/widgets/standard_icon_box.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import 'package:voice_first_admin/core/widgets/standard_list_card.dart';
import 'package:voice_first_admin/core/widgets/standard_pagination_controls.dart';
import 'add_plan.dart';
import '../providers/plan_provider.dart';
import 'plan_detail_page.dart';
import '../../models/plan_model.dart';

class ViewPlanPage extends ConsumerStatefulWidget {
  const ViewPlanPage({super.key});

  @override
  ConsumerState<ViewPlanPage> createState() => _ViewPlanPageState();
}

class _ViewPlanPageState extends ConsumerState<ViewPlanPage> {
  late final TextEditingController _searchController;
  static const int _pageSize = 10;
  final Map<int, bool> _localStatus = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(planProvider.notifier).loadPlans(page: 1, pageSize: _pageSize);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    final currentSearch = ref.read(planProvider).search;

    ref
        .read(planProvider.notifier)
        .loadPlans(page: page, pageSize: _pageSize, search: currentSearch);
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
        searchOptions: const {'name': 'Plan Name', 'status': 'Status'},
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
    final state = ref.watch(planProvider);
    final notifier = ref.read(planProvider.notifier);
    final theme = Theme.of(context);

    final totalPages = state.totalPages;
    final safeTotalPages = totalPages > 0 ? totalPages : 1;

    // Keep search controller in sync (if provider persists search)
    if (_searchController.text != (state.search)) {
      _searchController.text = state.search;
    }

    return StandardPageLayout(
      title: 'Plans',
      actions: const [],
      bottom: AdvancedSearchHeader(
        searchController: _searchController,
        hintText: 'Search plans...',
        onSearchChanged: (q) =>
            notifier.loadPlans(page: 1, pageSize: _pageSize, search: q),
        onFilterTap: _openFilterSheet,
        onRefresh: () => notifier.loadPlans(
          page: state.currentPage,
          pageSize: _pageSize,
          search: state.search,
        ),
      ),
      onRefresh: () async {
        await notifier.loadPlans(
          page: state.currentPage,
          pageSize: _pageSize,
          search: state.search,
        );
      },
      floatingActionButton: FloatingActionButton(
        heroTag: 'plan_fab',
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPlanPage()),
          ).then((_) {
            notifier.loadPlans(
              page: state.currentPage,
              pageSize: _pageSize,
              search: state.search,
            );
          });
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: (state.isLoading || state.plans.isEmpty)
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
        else if (state.plans.isEmpty)
          SliverFillRemaining(child: _EmptyPlans(theme: theme))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final Plan plan = state.plans[index];

                final leading = const StandardIconBox(
                  icon: Icons.assignment,
                  color: Colors.blue,
                );

                final bool isDeleted = plan.deleted == true;

                final actions = <Widget>[];
                actions.add(
                  Transform.scale(
                    scale: 0.85,
                    child: Switch(
                      value: _localStatus[plan.planId] ?? (plan.active ?? true),
                      activeThumbColor: Colors.green,
                      onChanged: isDeleted
                          ? null
                          : (val) {
                              setState(() {
                                _localStatus[plan.planId] = val;
                              });
                              CustomSnackbar.show(
                                context,
                                message: val
                                    ? '${plan.planName} activated (UI only)'
                                    : '${plan.planName} deactivated (UI only)',
                                type: SnackBarType.info,
                              );
                            },
                      inactiveThumbColor: isDeleted
                          ? Colors.grey.withAlpha(102)
                          : null,
                    ),
                  ),
                );
                actions.add(const SizedBox(width: 4));
                actions.add(
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
                          builder: (_) => PlanDetailPage(plan: plan),
                        ),
                      );
                    },
                  ),
                );
                actions.add(
                  StandardActionButton(
                    icon: Icons.delete,
                    color: isDeleted ? Colors.red.withAlpha(102) : Colors.red,
                    onTap: () {
                      if (isDeleted) return;

                      showDeleteBottomSheet(
                        context: context,
                        itemName: plan.planName,
                        onDelete: () async {
                          final success = await notifier.deletePlan(
                            plan.planId,
                          );
                          if (!context.mounted) return;

                          CustomSnackbar.show(
                            context,
                            message: success
                                ? 'Plan deleted successfully'
                                : 'Failed to delete plan',
                            type: success
                                ? SnackBarType.success
                                : SnackBarType.error,
                          );
                        },
                      );
                    },
                  ),
                );
                return StandardListCard(
                  leading: leading,
                  title: plan.planName,
                  actions: actions,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlanDetailPage(plan: plan),
                      ),
                    ).then((_) {
                      notifier.loadPlans(
                        page: state.currentPage,
                        pageSize: _pageSize,
                        search: state.search,
                      );
                    });
                  },
                );
              }, childCount: state.plans.length),
            ),
          ),
      ],
    );
  }
}

// ───────────────── EMPTY ─────────────────
class _EmptyPlans extends StatelessWidget {
  final ThemeData theme;
  const _EmptyPlans({required this.theme});

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
          const Text('No plans found'),
        ],
      ),
    );
  }
}
