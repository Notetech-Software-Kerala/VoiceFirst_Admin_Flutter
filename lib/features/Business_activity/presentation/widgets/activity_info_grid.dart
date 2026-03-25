import 'package:flutter/material.dart';
import '../../data/models/business_activity_model.dart';

class ActivityInfoGrid extends StatelessWidget {

  final BusinessActivity activity;

  const ActivityInfoGrid({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [

        Expanded(
          child: _InfoCard(
            icon: Icons.history_edu,
            title: "Created Info",
            user: activity.createdUser,
            date: activity.createdDate,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _InfoCard(
            icon: Icons.edit_note,
            title: "Modified Info",
            user: activity.modifiedUser ?? "Not Modified",
            date: activity.modifiedDate,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {

  final IconData icon;
  final String title;
  final String user;
  final DateTime? date;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.user,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Icon(icon, color: Colors.grey),

            const SizedBox(height: 10),

            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              user,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              date?.toString() ?? "N/A",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}