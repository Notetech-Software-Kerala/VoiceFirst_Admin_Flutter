import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/program/data/models/program_management_model.dart';
import 'package:voice_first_admin/features/program/presentation/providers/program_provider.dart';
import 'package:voice_first_admin/features/application/providers/application_provider.dart';
import 'package:voice_first_admin/features/program_actions/presentation/providers/program_action_lookup_provider.dart';

class AddProgramPage extends ConsumerStatefulWidget {
  const AddProgramPage({super.key});
  @override
  ConsumerState<AddProgramPage> createState() => _AddProgramPageState();
}

class _AddProgramPageState extends ConsumerState<AddProgramPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _labelCtrl = TextEditingController();
  final TextEditingController _routeCtrl = TextEditingController();

  int _applicationId = 1;

  final Set<int> _selectedActionIds = <int>{};

  String? _routeError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _labelCtrl.dispose();
    _routeCtrl.dispose();
    super.dispose();
  }

  Future<void> _openActionsBottomSheet(List actions) async {
    if (!mounted) return;

    final theme = Theme.of(context);
    final Set<int> tempSelected = {..._selectedActionIds};
    String searchQuery = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            final filtered = actions.where((a) {
              final q = searchQuery.toLowerCase();
              if (q.isEmpty) return true;
              final name = (a.actionName ?? '').toString().toLowerCase();
              return name.contains(q);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Select Program Actions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search actions...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          modalSetState(() {
                            searchQuery = value.trim();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text('No actions match your search'),
                            )
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) => Divider(
                                height: 1,
                                color: theme.dividerColor.withAlpha(128),
                              ),
                              itemBuilder: (context, index) {
                                final a = filtered[index];
                                final isChecked = tempSelected.contains(
                                  a.actionId as int,
                                );
                                return CheckboxListTile(
                                  title: Text(a.actionName ?? ''),
                                  value: isChecked,
                                  dense: true,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  onChanged: (checked) {
                                    modalSetState(() {
                                      if (checked ?? false) {
                                        tempSelected.add(a.actionId as int);
                                      } else {
                                        tempSelected.remove(a.actionId as int);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              modalSetState(() {
                                tempSelected.clear();
                              });
                            },
                            child: const Text('Clear All'),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedActionIds
                                  ..clear()
                                  ..addAll(tempSelected);
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final label = _labelCtrl.text.trim();
    var route = _routeCtrl.text.trim();

    if (name.isEmpty || label.isEmpty || route.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name, label and route are required')),
      );
      return;
    }
    // Validate route: first and last characters must be letters only
    // Allowed characters in between: letters, numbers, '/', '_' and '-'
    final routePattern = RegExp(r'^[A-Za-z](?:[A-Za-z0-9/_-]*[A-Za-z])?$');
    if (!routePattern.hasMatch(route)) {
      setState(() {
        _routeError =
            'Must start and end with a letter and only contain letters, numbers, /, _ or - in between.';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid route. It must start and end with a letter and not have special characters at the beginning or end.',
            ),
          ),
        );
      }
      return;
    }

    final program = ProgramModel(
      sysProgramId: null,
      programName: name,
      labelName: label,
      programRoute: route,
      applicationId: _applicationId,
      companyId: null,

      /// 🔥 CREATE fake actions from selected IDs
      actions: _selectedActionIds.map((id) {
        return ProgramActionSummary(actionId: id, actionName: '', active: true);
      }).toList(),
    );

    await ref.read(programProvider.notifier).add(program);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Color(0xFF0D7FF2);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withAlpha(230),
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.arrow_back,
                            size: 24,
                            color: theme.iconTheme.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Add Program',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              const SizedBox(height: 12),

              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Program Info'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Program Name',
                        filled: true,
                        fillColor: theme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _labelCtrl,
                      decoration: InputDecoration(
                        labelText: 'Label Name',
                        filled: true,
                        fillColor: theme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _routeCtrl,
                      onChanged: (value) {
                        final trimmed = value.trim();
                        if (trimmed.isEmpty) {
                          setState(() => _routeError = null);
                          return;
                        }
                        final routePattern = RegExp(
                          r'^[A-Za-z](?:[A-Za-z0-9/_-]*[A-Za-z])?$',
                        );
                        setState(() {
                          _routeError = routePattern.hasMatch(trimmed)
                              ? null
                              : 'Must start and end with a letter and only contain letters, numbers, /, _ or - in between.';
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Program Route (e.g. programs)',
                        filled: true,
                        fillColor: theme.cardColor,
                        errorText: _routeError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'APPLICATION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ref
                        .watch(applicationProvider)
                        .when(
                          data: (apps) {
                            final items = apps
                                .map(
                                  (a) => DropdownMenuItem<int>(
                                    value: a.platformId,
                                    child: Text(a.platformName),
                                  ),
                                )
                                .toList();
                            final current =
                                apps.any((a) => a.platformId == _applicationId)
                                ? _applicationId
                                : (apps.isNotEmpty
                                      ? apps.first.platformId
                                      : null);
                            if (current != null && current != _applicationId) {
                              _applicationId = current;
                            }
                            return DropdownButtonFormField<int>(
                              initialValue: current,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: theme.cardColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.dividerColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.dividerColor,
                                  ),
                                ),
                              ),
                              items: items,
                              onChanged: (val) {
                                if (val == null) return;
                                setState(() => _applicationId = val);
                              },
                            );
                          },
                          loading: () =>
                              const LinearProgressIndicator(minHeight: 2),
                          error: (_, _) =>
                              const Text('Failed to load applications'),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'PROGRAM ACTIONS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: theme.hintColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ref
                    .watch(programActionLookupProvider)
                    .when(
                      data: (actions) {
                        if (actions.isEmpty) {
                          return const Text('No actions available');
                        }
                        final selected = actions
                            .where(
                              (a) => _selectedActionIds.contains(a.actionId),
                            )
                            .toList();
                        final selectedLabel = selected.isEmpty
                            ? 'No actions selected'
                            : selected.length <= 2
                            ? selected
                                  .map((a) => (a.actionName).toString())
                                  .join(', ')
                            : '${selected.length} actions selected';

                        return Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: InkWell(
                            onTap: () => _openActionsBottomSheet(actions),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Select Program Actions',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          selectedLabel,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.hintColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_up),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      loading: () =>
                          const LinearProgressIndicator(minHeight: 2),
                      error: (_, _) =>
                          const Text('Failed to load program actions'),
                    ),
              ),
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    theme.scaffoldBackgroundColor,
                    theme.scaffoldBackgroundColor.withAlpha(243),
                    theme.scaffoldBackgroundColor.withAlpha(0),
                  ],
                  stops: const [0.6, 0.8, 1.0],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: isDark
                            ? Colors.white.withAlpha(13)
                            : Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shadowColor: primaryColor.withAlpha(102),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Program',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
