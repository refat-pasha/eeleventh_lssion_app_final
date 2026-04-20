// placeholder
// lib/modules/dashboard/widgets/stats_tile.dart

import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';

class StatsTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatsTile({super.key, required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.primary, size: 26),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(color: textColor?.withValues(alpha: 0.7), fontSize: 14)),
        ],
      ),
    );
  }
}
