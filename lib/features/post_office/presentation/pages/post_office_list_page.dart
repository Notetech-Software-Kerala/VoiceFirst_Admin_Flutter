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
  int _pageNumber = 1;
  final int _limit = 10;
  int _totalItems = 0;
  String _searchQuery = "";

  // Controllers
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchPostOffices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- API FETCH LOGIC ---
  Future<void> _fetchPostOffices() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

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

        // Try to get total count for pagination
        // Adjust key 'totalItems' if backend uses something else like 'count' or 'total'
        final totalCount =
            dataWrapper['totalCount'] ?? dataWrapper['totalItems'] ?? 0;

        final newItems = items
            .map((json) => PostOffice.fromJson(json))
            .toList();

        setState(() {
          _postOffices = newItems; // Replace items for current page
          _totalItems = totalCount;
        });
      } else {
        _showSnack('Failed to load: ${response.statusCode}', isError: true);
      }
    } catch (e) {
      _showSnack('Connection Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onPageChanged(int newPage) {
    if (newPage < 1) return;
    setState(() {
      _pageNumber = newPage;
    });
    _fetchPostOffices();
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  // --- DELETE LOGIC ---
  Future<void> _deletePostOffice(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post Office?"),
        content: const Text("Are you sure? this cannot be undone."),
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
        _showSnack("Post office deleted successfully");
        _fetchPostOffices(); // Refresh current page
      } else {
        _showSnack("Failed to delete: ${response.statusCode}", isError: true);
      }
    } catch (e) {
      _showSnack("Error: $e", isError: true);
    }
  }

  // --- SEARCH HANDLER ---
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query != _searchQuery) {
        setState(() {
          _searchQuery = query;
          _pageNumber = 1; // Reset to page 1 on search
        });
        _fetchPostOffices();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate pagination info
    final totalPages = (_totalItems / _limit).ceil();
    // Safety check just in case totalItems is 0 but we have items (fallback)
    final safeTotalPages = totalPages > 0 ? totalPages : 1;

    return Scaffold(
      body: CustomScrollView(
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
                  onTap: () => Navigator.maybePop(context),
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
              preferredSize: const Size.fromHeight(
                120,
              ), // Approx height for Search + Filters
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
                            onPressed: _fetchPostOffices,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Filters
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
          if (_isLoading)
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
                delegate: SliverChildBuilderDelegate((context, index) {
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
                      ).then((_) => _fetchPostOffices());
                    },
                  );
                }, childCount: _postOffices.length),
              ),
            ),
        ],
      ),

      // Pagination Bottom Bar
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
              onPressed: _pageNumber > 1
                  ? () => _onPageChanged(_pageNumber - 1)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              "Page $_pageNumber of $safeTotalPages",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _pageNumber < safeTotalPages
                  ? () => _onPageChanged(_pageNumber + 1)
                  : null,
            ),
          ],
        ),
      ),

      // FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPostOfficePage()),
          ).then((_) => _fetchPostOffices());
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
          if (office.zipCodes.any((z) => z.active))
            Row(
              children: [
                Icon(Icons.pin_drop, size: 14, color: theme.disabledColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    // Show first 3 ACTIVE zips, then "..."
                    (() {
                      final activeZips = office.zipCodes
                          .where((z) => z.active)
                          .toList();
                      if (activeZips.isEmpty) return "No active zip codes";
                      return activeZips.take(3).map((z) => z.code).join(", ") +
                          (activeZips.length > 3
                              ? " +${activeZips.length - 3} more"
                              : "");
                    })(),
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
