import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/Place_management/data/models/lookup_models.dart';
import 'package:voice_first_admin/features/Place_management/data/place_service/place_lookup_service.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/editPlaceFormProvider.dart';
import 'package:voice_first_admin/features/Place_management/presentation/providers/lookup/lookup_provider.dart';

class AddMoreZipCodesPage extends ConsumerStatefulWidget {
  final int placeId;

  const AddMoreZipCodesPage({super.key, required this.placeId});

  @override
  ConsumerState<AddMoreZipCodesPage> createState() =>
      _AddMoreZipCodesPageState();
}

class _AddMoreZipCodesPageState extends ConsumerState<AddMoreZipCodesPage> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  bool isLoadingMore = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    Future.microtask(() {
      ref.read(editPlaceFormProvider.notifier).clearHierarchy();
    });

    _scrollController = ScrollController();

_scrollController.addListener(() {
  final filter = ref.read(postOfficeFilterForEditProvider(widget.placeId));
  final asyncValue = ref.read(
    postOfficeLookupProvider((
      filter,
      _currentPage,
      _searchController.text.trim(),
    )),
  );

  if (!asyncValue.hasValue) return;
  final data = asyncValue.requireValue;

  if (!isLoadingMore &&
      _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
      data.currentPage < data.totalPages) {

    isLoadingMore = true;

    setState(() {
      _currentPage++;
    });

    Future.microtask(() {
      isLoadingMore = false;
    });
  }
});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final form = ref.watch(editPlaceFormProvider);
    final notifier = ref.read(editPlaceFormProvider.notifier);

    final filter = ref.watch(postOfficeFilterForEditProvider(widget.placeId));

    final postOfficesAsync = filter.isReady
        ? ref.watch(
            postOfficeLookupProvider((
              filter,
              _currentPage,
              _searchController.text.trim(),
            )),
          )
        : AsyncValue<PaginatedLookupResponse<PostOfficeLookup>>.data(
            PaginatedLookupResponse(
              items: const [],
              totalCount: 0,
              totalPages: 1,
              currentPage: 1,
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add More Zip Codes'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FormLabel('Available Post Offices'),
            const SizedBox(height: 12),

            /// 🔎 API SEARCH
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search post offices...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _currentPage = 1;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (_) {
                setState(() {
                  _currentPage = 1;
                });
              },
            ),

            const SizedBox(height: 16),

            /// 📦 POST OFFICE LIST
            postOfficesAsync.when(
              data: (response) {
                final offices = response.items;

                if (!filter.isReady) {
                  return const SizedBox();
                }

                if (offices.isEmpty) {
                  return const Text(
                    'No post offices found for selected hierarchy',
                  );
                }

                return Container(
                  height: 450,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    // itemCount: offices.length,
                    itemCount:
                        offices.length +
                        (response.currentPage < response.totalPages ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= offices.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final office = offices[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ExpansionTile(
                          title: Text(office.postOfficeName),
                          children: [
                            Consumer(
                              builder: (context, ref, _) {
                                final zipAsync = ref.watch(
                                  unlinkedZipCodesProvider((
                                    postOfficeId: office.postOfficeId,
                                    placeId: widget.placeId,
                                  )),
                                );

                                return zipAsync.when(
                                  loading: () => const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: LinearProgressIndicator(),
                                  ),
                                  error: (_, __) => const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text("Failed to load zip codes"),
                                  ),
                                  data: (zips) {
                                    return Column(
                                      children: zips.map((zip) {
                                        final existing = form.zipCodeItems
                                            .firstWhere(
                                              (z) =>
                                                  z.zipCodeLinkId ==
                                                  zip.zipCodeLinkId,
                                              orElse: () => EditZipCodeItem(
                                                postOfficeId:
                                                    office.postOfficeId,
                                                zipCodeLinkId:
                                                    zip.zipCodeLinkId,
                                                zipCode: zip.zipCode,
                                                postOfficeName:
                                                    office.postOfficeName,
                                                isNew: false,
                                                isActive: false,
                                              ),
                                            );

                                        return CheckboxListTile(
                                          value: existing.isActive,
                                          title: Text(zip.zipCode),
                                          onChanged: (_) => notifier.toggleZip(
                                            zip.zipCodeLinkId,
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Failed to load post offices'),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
    );
  }
}
