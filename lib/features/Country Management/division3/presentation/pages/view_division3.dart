import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/pagination_controls.dart';
import 'package:voice_first_admin/features/Business_activity/presentation/widgets/custom_snackbar.dart';
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

    final primaryColor = const Color(0xFF0D7FF2);

    return Scaffold(
      backgroundColor: Colors.white,

      // ───────────────── App Bar ─────────────────
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          country.divisionThreeLabel ?? 'Division 3',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
              onChanged: notifier.search,
              decoration: InputDecoration(
                hintText: 'Search divisions...',
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

          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.items.isEmpty
                ? const Center(child: Text('No divisions found'))
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.items.length,
                          itemBuilder: (context, index) {
                            final d = state.items[index];
                            // No selection in division3, but keep color/shape consistent
                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(
                                  d.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                trailing: TextButton.icon(
                                  icon: const Icon(Icons.visibility),
                                  label: const Text('View'),
                                  onPressed: () {
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
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
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
                                      (state.currentPage - 1) * state.pageSize +
                                      1;
                                  final end = start + state.items.length - 1;
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
                              pageSize: state.pageSize,
                              isLoading: state.isLoading,
                              hasMoreData: state.hasMoreData,
                              onPageChanged: notifier.fetchPage,
                              primaryColor: primaryColor,
                            ),
                          ],
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
