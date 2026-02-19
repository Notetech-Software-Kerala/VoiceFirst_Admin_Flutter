import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/widgets/delete_bottom_sheet.dart';
import 'package:voice_first_admin/features/post_office/data/models/post_office_model.dart';
import 'package:voice_first_admin/features/post_office/presentation/pages/add_post_office_page.dart';
import 'package:voice_first_admin/features/post_office/presentation/providers/post_office_provider.dart';

class PostOfficeDetailsPage extends ConsumerStatefulWidget {
  final PostOffice postOffice;

  const PostOfficeDetailsPage({required this.postOffice, super.key});

  @override
  ConsumerState<PostOfficeDetailsPage> createState() =>
      _PostOfficeDetailsPageState();
}

class _PostOfficeDetailsPageState extends ConsumerState<PostOfficeDetailsPage> {
  late PostOffice _postOffice;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _postOffice = widget.postOffice;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final freshData = await ref
        .read(postOfficeProvider.notifier)
        .getPostOfficeById(_postOffice.id);

    if (freshData != null && mounted) {
      setState(() {
        _postOffice = freshData;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePostOffice() async {
    showDeleteBottomSheet(
      context: context,
      itemName: _postOffice.name,
      title: "DELETE POST OFFICE?",
      onDelete: () async {
        final success = await ref
            .read(postOfficeProvider.notifier)
            .deletePostOffice(_postOffice.id);
        if (success && context.mounted) {
          Navigator.pop(context); // Pop details page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Post office deleted successfully"),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }

  void _editPostOffice() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPostOfficePage(postOffice: _postOffice),
      ),
    ).then((_) => _fetchDetails()); // Refresh on return
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // 1. Sticky Header
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: _isLoading
              ? const LinearProgressIndicator(minHeight: 1)
              : Container(color: theme.dividerColor, height: 1),
        ),
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            margin: const EdgeInsets.all(8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey[100],
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
        ),
        title: const Text(
          "Post Office Details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              Icons.local_post_office,
              color: theme.primaryColor,
              size: 20,
            ),
          ),
        ],
      ),

      // 2. Main Content
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              120,
            ), // Bottom padding for footer
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabelText("Post Office Name"),
                    const SizedBox(height: 4),
                    Text(
                      _postOffice.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LabelText("Country"),

                    const SizedBox(height: 4),
                    Text(
                      "${_postOffice.flag} ${_postOffice.countryName}",
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Search Bar (Disabled style)
              Opacity(
                opacity: 0.6,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: theme.iconTheme.color),
                      const SizedBox(width: 12),
                      const Text(
                        "Search detail sections...",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _SectionHeader("Details"),
              const SizedBox(height: 8),

              // Expandable Cards
              _ExpandableCard(
                title: "Location Details",
                subtitle:
                    "${_postOffice.countryName}, ${_postOffice.zipCodes.isNotEmpty ? _postOffice.zipCodes.first.code : 'No Zip'}",
                icon: Icons.location_on,
                isExpanded: true,
                children: [
                  _DetailGridItem(
                    label: "Country",
                    value: _postOffice.countryName,
                  ),
                  _DetailGridItem(
                    label: "Zip Codes",
                    value: _postOffice.zipCodes.map((z) => z.code).join(", "),
                  ),
                  _DetailGridItem(
                    label: "State (Div One)",
                    value: _postOffice.divOneName ?? "Loading...",
                  ),
                  _DetailGridItem(
                    label: "District (Div Two)",
                    value: _postOffice.divTwoName ?? "Loading...",
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ExpandableCard(
                title: "Admin Levels",
                subtitle: "Div Three: ${_postOffice.divThreeName ?? 'N/A'}",
                icon: Icons.corporate_fare,
                isExpanded: false,
                children: [
                  _DetailGridItem(
                    label: "Division Three",
                    value: _postOffice.divThreeName ?? "N/A",
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ExpandableCard(
                title: "Creation Info",
                subtitle: "Created by: ${_postOffice.createdUser ?? 'Unknown'}",
                icon: Icons.person_add,
                isExpanded: false,
                children: [
                  _DetailGridItem(
                    label: "Created By",
                    value: _postOffice.createdUser ?? "Unknown",
                  ),
                  _DetailGridItem(
                    label: "Created Date",
                    // Simple substring to strip time if desired, or duplicate api format
                    value:
                        _postOffice.createdDate?.split('T').first ?? "Unknown",
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ExpandableCard(
                title: "Modification Info",
                subtitle: "Modified by: ${_postOffice.modifiedUser ?? 'N/A'}",
                icon: Icons.history,
                isExpanded: false,
                children: [
                  _DetailGridItem(
                    label: "Modified By",
                    value: _postOffice.modifiedUser ?? "N/A",
                  ),
                  _DetailGridItem(
                    label: "Modified Date",
                    value: _postOffice.modifiedDate?.split('T').first ?? "N/A",
                  ),
                ],
              ),
            ],
          ),

          // 3. Floating Footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    theme.scaffoldBackgroundColor,
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Delete Button
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _deletePostOffice,
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                      label: Text(
                        "Delete",
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.error.withValues(
                          alpha: 0.1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Edit Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _editPostOffice,
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      label: const Text(
                        "Edit Details",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Helper Widgets (Unchanged)
// -----------------------------------------------------------------------------

class _LabelText extends StatelessWidget {
  final String text;
  const _LabelText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: Theme.of(context).iconTheme.color,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }
}

class _ExpandableCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isExpanded;
  final List<Widget>? children;

  const _ExpandableCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isExpanded,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    // Determine styles based on state
    final borderColor = isExpanded ? primary : theme.dividerColor;
    final borderWidth = isExpanded ? 2.0 : 1.0;
    final iconBg = isExpanded
        ? primary.withValues(alpha: 0.1)
        : (theme.brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[100]);
    final iconColor = isExpanded ? primary : theme.iconTheme.color;
    final subtitleColor = isExpanded ? primary : theme.iconTheme.color;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: subtitleColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.grey,
          ),
          children: children != null
              ? [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                    children: children!,
                  ),
                ]
              : [],
        ),
      ),
    );
  }
}

class _DetailGridItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailGridItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101922) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: theme.iconTheme.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
