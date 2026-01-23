import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/models/post_office_model.dart';
import 'add_post_office_page.dart';

// --- MAIN SCREEN ---

class PostOfficeListScreen extends StatefulWidget {
  const PostOfficeListScreen({super.key});

  @override
  State<PostOfficeListScreen> createState() => _PostOfficeListScreenState();
}

class _PostOfficeListScreenState extends State<PostOfficeListScreen> {
  // State Variables
  List<PostOffice> _postOffices = [];
  bool _isLoading = false;
  bool _hasMore = true; // For pagination
  int _pageNumber = 1;
  final int _limit = 10;
  String _searchQuery = "";

  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchPostOffices();

    // Pagination Listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchPostOffices(isNextPage: true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- API FETCH LOGIC ---
  Future<void> _fetchPostOffices({bool isNextPage = false}) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    if (!isNextPage) {
      _pageNumber = 1; // Reset if new search/refresh
    }

    try {
      final queryParams = {
        'PageNumber': _pageNumber.toString(),
        'Limit': _limit.toString(),
        'SortOrder': 'Desc',
        'Deleted': 'false',
        if (_searchQuery.isNotEmpty) 'SearchText': _searchQuery,
      };

      final uri = Uri.http(
        '192.168.0.202:8010',
        '/api/post-office',
        queryParams,
      );

      debugPrint("Fetching: $uri");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        final dataWrapper = jsonMap['data'];
        final List<dynamic> items = dataWrapper['items'] ?? [];

        final newItems = items
            .map((json) => PostOffice.fromJson(json))
            .toList();

        setState(() {
          if (isNextPage) {
            _postOffices.addAll(newItems);
          } else {
            _postOffices = newItems;
          }

          _hasMore = newItems.length >= _limit;
          if (_hasMore) _pageNumber++;
        });
      } else {
        debugPrint("Error: ${response.statusCode}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint("Connection Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Connection Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- DELETE LOGIC ---
  Future<void> _deletePostOffice(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post Office?"),
        content: const Text(
          "Are you sure you want to delete this post office? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final uri = Uri.http('192.168.0.202:8010', '/api/post-office/$id');
      final response = await http.delete(uri);

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _postOffices.removeWhere((p) => p.id == id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Post office deleted successfully"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to delete: ${response.statusCode}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- SEARCH HANDLER ---
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Wait 500ms after user stops typing to call API
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query != _searchQuery) {
        setState(() {
          _searchQuery = query;
          _postOffices.clear(); // Clear old results
        });
        _fetchPostOffices();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use MediaQuery for responsive height, but ensure min 120 to prevent overflow
    final double screenHeight = MediaQuery.of(context).size.height;
    final double bottomHeight = screenHeight * 0.15;
    final double safeBottomHeight = bottomHeight < 120 ? 120 : bottomHeight;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // --- STICKY HEADER ---
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.95),
            elevation: 0,
            toolbarHeight: 70,
            title: Row(
              children: [
                InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[100],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 40),
                    child: Text(
                      "Post Office Management",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(safeBottomHeight),
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Color(0xFF9DA6B9),
                                ),
                                hintText: "Search by name...",
                                fillColor: isDark
                                    ? const Color(0xFF282E39)
                                    : Colors.white,
                                // Clear button
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          _onSearchChanged("");
                                        },
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF282E39)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              _postOffices.clear();
                              _fetchPostOffices();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filter Chips
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      children: const [
                        _FilterChip(label: "Active", isSelected: true),
                        SizedBox(width: 8),
                        _FilterChip(label: "Zip Code", isSelected: false),
                        SizedBox(width: 8),
                        _FilterChip(label: "Sort: Desc", isSelected: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- LIST CONTENT ---
          if (_isLoading && _postOffices.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_postOffices.isEmpty)
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
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Loader at bottom for pagination
                    if (index == _postOffices.length) {
                      return _hasMore
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : const SizedBox(height: 50); // Spacer at end
                    }

                    final office = _postOffices[index];
                    return _PostOfficeCard(
                      office: office,
                      onDelete: () => _deletePostOffice(office.id),
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddPostOfficePage(postOffice: office),
                          ),
                        ).then((_) {
                          _postOffices.clear();
                          _fetchPostOffices();
                        });
                      },
                    );
                  },
                  childCount: _postOffices.length + 1, // +1 for loader
                ),
              ),
            ),
        ],
      ),

      // FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPostOfficePage()),
          ).then((_) {
            // Refresh list when returning from Add Page
            _postOffices.clear();
            _fetchPostOffices();
          });
        },
        backgroundColor: theme.primaryColor,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

// --- HELPER WIDGETS ---

class _PostOfficeCard extends StatelessWidget {
  final PostOffice office;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _PostOfficeCard({
    required this.office,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Logic to choose an icon based on something (random for now, or based on office type if you had it)
    final IconData icon = Icons.local_post_office;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Icon + Title + Actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Box
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: theme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      office.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(office.flag, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          office.countryName,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Row(
                children: [
                  _ActionButton(
                    icon: Icons.edit,
                    color: theme.disabledColor,
                    onTap: onEdit,
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.delete,
                    color: theme.disabledColor,
                    hoverColor: Colors.red,
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Bottom Row: Zip Codes
          if (office.zipCodes.isNotEmpty)
            Row(
              children: [
                Icon(Icons.pin_drop, size: 14, color: theme.disabledColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    // Show first 3 zips, then "..."
                    office.zipCodes.take(3).map((z) => z.code).join(", ") +
                        (office.zipCodes.length > 3
                            ? " +${office.zipCodes.length - 3} more"
                            : ""),
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: theme.hintColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? hoverColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(icon, size: 20, color: color),
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
