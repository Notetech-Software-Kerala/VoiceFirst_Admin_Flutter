import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import 'package:voice_first_admin/core/widgets/standard_list_card.dart';
import 'package:voice_first_admin/core/widgets/pagination_controls.dart';
import 'add_plan.dart';
import '../providers/plan_list_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(planListProvider.notifier).loadAll(page: 1, pageSize: _pageSize);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    ref
        .read(planListProvider.notifier)
        .loadAll(
          page: page,
          pageSize: _pageSize,
          search: ref.read(planListProvider).search,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(planListProvider);
    final notifier = ref.read(planListProvider.notifier);
    final theme = Theme.of(context);

    // Keep search controller in sync (if provider persists search)
    if (_searchController.text != (state.search)) {
      _searchController.text = state.search;
    }

    return StandardPageLayout(
      title: 'Plans',
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddPlanPage()),
            ).then((_) {
              notifier.loadAll(
                page: state.currentPage,
                pageSize: _pageSize,
                search: state.search,
              );
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Plan'),
        ),
      ],
      leading: InkWell(
        onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
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
      searchController: _searchController,
      onSearchChanged: (q) =>
          notifier.loadAll(page: 1, pageSize: _pageSize, search: q),
      searchHint: 'Search plans...',
      onRefresh: () async {
        await notifier.loadAll(
          page: state.currentPage,
          pageSize: _pageSize,
          search: state.search,
        );
      },
      bottomNavigationBar: (state.isLoading || state.plans.isEmpty)
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
                      final totalPages = state.totalPages;
                      final safeTotalPages =
                          totalPages > 0 ? totalPages : 1;
                      return Text(
                        'Page ${state.currentPage} of $safeTotalPages',
                        style:
                            const TextStyle(fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: state.currentPage < state.totalPages
                        ? () => _goToPage(state.currentPage + 1)
                        : null,
                  ),
                ],
              ),
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
                final PlanModel plan = state.plans[index];

                final leading = const StandardIconBox(
                  icon: Icons.assignment,
                  color: Colors.blue,
                );

                final statusChip = Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (plan.active == true)
                        ? Colors.green.withAlpha(38)
                        : Colors.red.withAlpha(38),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (plan.active == true) ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: (plan.active == true) ? Colors.green : Colors.red,
                    ),
                  ),
                );

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlanDetailPage(plan: plan),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: StandardListCard(
                    title: plan.planName,
                    subtitle: 'Created by ${plan.createdUser ?? 'N/A'}',
                    leading: leading,
                    trailing: statusChip,
                  ),
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
