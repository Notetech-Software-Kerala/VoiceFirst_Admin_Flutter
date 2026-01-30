import 'package:flutter/material.dart';

class StandardPageLayout extends StatelessWidget {
  final String title;
  final Widget? body; // Standard non-sliver body (optional)
  final List<Widget>? slivers; // Silver content
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final String searchHint;
  final VoidCallback? onRefresh;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? bottom; // Bottom widget for SliverAppBar (e.g. Filters)
  final List<Widget>? actions;
  final Widget? leading; // Custom leading widget (optional)

  const StandardPageLayout({
    super.key,
    required this.title,
    this.body,
    this.slivers,
    this.searchController,
    this.onSearchChanged,
    this.searchHint = "Search...",
    this.onRefresh,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.bottom,
    this.actions,
    this.leading,
  }) : assert(
         body != null || slivers != null,
         'Provide either body or slivers',
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate Search Bar height
    // Search (48) + Vertical Padding (16) = 64
    // + Bottom Widget height (optional)
    // + Safety buffer
    double bottomHeight = 80;
    if (bottom != null) bottomHeight += 50;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.95),
            elevation: 0,
            toolbarHeight: 70,
            leading:
                leading ??
                (Navigator.canPop(context)
                    ? InkWell(
                        onTap: () => Navigator.maybePop(context),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey[100],
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 20),
                        ),
                      )
                    : (Scaffold.maybeOf(context)?.hasDrawer ?? false)
                    ? InkWell(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey[100],
                          ),
                          child: const Icon(Icons.menu, size: 20),
                        ),
                      )
                    : null),
            title: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            actions: actions,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(bottomHeight),
              child: Column(
                children: [
                  // Search Bar
                  if (searchController != null)
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
                                controller: searchController,
                                onChanged: onSearchChanged,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Color(0xFF9DA6B9),
                                  ),
                                  hintText: searchHint,
                                  fillColor: isDark
                                      ? const Color(0xFF282E39)
                                      : Colors.white,
                                  suffixIcon: searchController!.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.clear,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            searchController!.clear();
                                            if (onSearchChanged != null) {
                                              onSearchChanged!("");
                                            }
                                          },
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          if (onRefresh != null) ...[
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
                                onPressed: onRefresh,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                  // Optional Bottom Widget (Filters, etc)
                  if (bottom != null) bottom!,

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          if (slivers != null) ...slivers!,

          if (body != null) SliverFillRemaining(child: body),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
