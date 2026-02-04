import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/standard_list_card.dart';
import 'package:voice_first_admin/core/widgets/standard_page_layout.dart';
import 'package:voice_first_admin/core/widgets/arrow_breadcrumb.dart';
import 'package:voice_first_admin/features/Country%20Management/country/models/country_model.dart';
import 'package:voice_first_admin/features/Country%20Management/division1/models/division1_model.dart';
import 'package:voice_first_admin/features/Country%20Management/division2/models/DivisionTwoModel';
import 'package:voice_first_admin/features/Country%20Management/division3/presentation/pages/division3_detail_view.dart';
import 'package:voice_first_admin/features/Country%20Management/division3/presentation/providers/division_three_provider.dart';

class DivisionThreeView extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(divisionThreeProvider(divisionTwo.id));
    final notifier = ref.read(divisionThreeProvider(divisionTwo.id).notifier);

    final theme = Theme.of(context);
    final label = country.divisionThreeLabel ?? 'Division 3';

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
                label: country.country,
                onTap: () => Navigator.pop(context),
              ),
              BreadcrumbItem(
                label: country.divisionOneLabel ?? 'Division 1',
                onTap: () => Navigator.pop(context),
              ),
              BreadcrumbItem(
                label: country.divisionTwoLabel ?? 'Division 2',
                onTap: () => Navigator.pop(context),
              ),
              BreadcrumbItem(label: label, isActive: true),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              onChanged: notifier.search,
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
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Division3DetailPage(
                          country: country,
                          divisionOne: divisionOne,
                          divisionTwo: divisionTwo,
                          divisionThree: d,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: StandardListCard(
                    title: d.name,
                    subtitle: '',
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
                              builder: (_) => Division3DetailPage(
                                country: country,
                                divisionOne: divisionOne,
                                divisionTwo: divisionTwo,
                                divisionThree: d,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              }, childCount: state.items.length),
            ),
          ),
      ],
      bottomNavigationBar: state.items.isEmpty
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
                        ? () => notifier.fetchPage(state.currentPage - 1)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Builder(
                    builder: (_) {
                      final totalPages = (state.totalCount / state.pageSize)
                          .ceil();
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
                      final totalPages = (state.totalCount / state.pageSize)
                          .ceil();
                      final safeTotalPages = totalPages > 0 ? totalPages : 1;
                      return state.currentPage < safeTotalPages
                          ? () => notifier.fetchPage(state.currentPage + 1)
                          : null;
                    })(),
                  ),
                ],
              ),
            ),
    );
  }
}
