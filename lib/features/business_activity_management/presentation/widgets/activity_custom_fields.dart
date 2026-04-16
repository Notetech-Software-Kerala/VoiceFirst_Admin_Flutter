import 'package:flutter/material.dart';
import 'package:voice_first_admin/features/business_activity_management/data/models/activity_custom_field.dart';

class ActivityCustomFields extends StatelessWidget {
  final List<ActivityCustomField> fields;

  const ActivityCustomFields({super.key, required this.fields});

  @override
  Widget build(BuildContext context) {
    final activeFields = fields.where((f) => f.active).toList();

    if (activeFields.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CUSTOM FIELDS",
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 10),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: activeFields.map((field) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        field.fieldName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(25),
                          borderRadius: BorderRadius.circular(30),
                        ),

                        child: Row(
                          children: [
                            const Icon(Icons.badge, size: 16),

                            const SizedBox(width: 6),

                            Text(field.fieldDataType),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
