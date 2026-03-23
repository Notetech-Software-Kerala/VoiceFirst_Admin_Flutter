import 'package:flutter/material.dart';
import 'package:voice_first_admin/features/Business_activity/data/models/business_activity_model.dart';

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.activity?.activityName ?? '',
    );
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
      activityId: widget.activity!.activityId,
      activityName: _nameController.text,
      active: widget.activity?.active ?? true,
      isDeleted: widget.activity?.isDeleted ?? false,
      createdUser: widget.activity?.createdUser ?? '',
      createdDate: widget.activity?.createdDate ?? DateTime.now(),
      modifiedUser: widget.activity?.modifiedUser ?? '',
      modifiedDate: widget.activity?.modifiedDate,
      deletedUser: widget.activity?.deletedUser ?? '',
      deletedDate: widget.activity?.deletedDate,
    );

    widget.onSave(activity);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.activity != null;

    return AlertDialog(
      title: Center(child: Text(isEdit ? 'Edit Activity' : 'Add New Activity')),
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
