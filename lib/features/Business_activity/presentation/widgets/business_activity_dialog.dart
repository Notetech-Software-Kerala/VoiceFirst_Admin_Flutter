import 'package:flutter/material.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';

class BusinessActivityDialog extends StatefulWidget {
  final BusinessActivity? activity;
  final Function(BusinessActivity) onSave;

  const BusinessActivityDialog({
    super.key,
    this.activity,
    required this.onSave,
  });

  @override
  State<BusinessActivityDialog> createState() => _BusinessActivityDialogState();
}

class _BusinessActivityDialogState extends State<BusinessActivityDialog> {
  late TextEditingController _nameController;
  late bool _isForCompany;
  late bool _isForBranch;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.activity?.activityName ?? '',
    );
    _isForCompany = widget.activity?.isForCompany ?? true;
    _isForBranch = widget.activity?.isForBranch ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity name is required')),
      );
      return;
    }

    final activity = BusinessActivity(
      id:
          widget.activity?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      activityName: _nameController.text,
      isForCompany: _isForCompany,
      isForBranch: _isForBranch,
      status: widget.activity?.status ?? true,
    );

    widget.onSave(activity);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.activity != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Activity' : 'Add New Activity'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Activity Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('For Company'),
              value: _isForCompany,
              onChanged: (val) {
                setState(() => _isForCompany = val ?? false);
              },
            ),
            CheckboxListTile(
              title: const Text('For Branch'),
              value: _isForBranch,
              onChanged: (val) {
                setState(() => _isForBranch = val ?? false);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(isEdit ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
