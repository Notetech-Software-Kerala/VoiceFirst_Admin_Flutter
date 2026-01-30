import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/plan_list_provider.dart';
import '../../models/plan_model.dart';

class ViewPlanPage extends ConsumerStatefulWidget {
  const ViewPlanPage({super.key});

  @override
  ConsumerState<ViewPlanPage> createState() => _ViewPlanPageState();
}

class _ViewPlanPageState extends ConsumerState<ViewPlanPage> {
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(planListProvider.notifier).loadAll(page: 1, pageSize: _pageSize);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(planListProvider);
    final notifier = ref.read(planListProvider.notifier);
    final primaryColor = const Color(0xFF0D7FF2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Plans', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Back to Dashboard',
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: Column(
        children: [
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
                notifier.loadAll(page: 1, pageSize: _pageSize, search: value);
              },
              decoration: InputDecoration(
                hintText: 'Search plans...',
                prefixIcon: Icon(Icons.search, color: primaryColor),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor.withAlpha(77)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.plans.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: primaryColor.withAlpha(26),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inbox,
                            size: 40,
                            color: primaryColor.withAlpha(128),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('No plans found'),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: state.plans.length,
                    itemBuilder: (context, index) {
                      final plan = state.plans[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(plan.planName),
                          subtitle: Text('ID: \\${plan.planId ?? '-'}'),
                          trailing: plan.active == true
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : const Icon(Icons.cancel, color: Colors.red),
                          onTap: () {
                            // TODO: Navigate to plan detail or edit
                          },
                        ),
                      );
                    },
                  ),
          ),
          if (!state.isLoading && state.totalPages > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: state.currentPage > 1
                        ? () => _goToPage(state.currentPage - 1)
                        : null,
                  ),
                  Text('Page \\${state.currentPage} of \\${state.totalPages}'),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: state.currentPage < state.totalPages
                        ? () => _goToPage(state.currentPage + 1)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
