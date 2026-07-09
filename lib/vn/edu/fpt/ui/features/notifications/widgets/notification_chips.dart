import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_notifications.dart';

class NotificationCategoryChip extends StatelessWidget {
  const NotificationCategoryChip({super.key, required this.category});

  final StudentNotificationCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFF047857),
          fontWeight: FontWeight.w800,
          height: 1.0,
        ),
      ),
    );
  }
}

class PinnedNotificationChip extends StatelessWidget {
  const PinnedNotificationChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDD5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Ghim',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: FptColors.orangeDeep,
          fontWeight: FontWeight.w800,
          height: 1.0,
        ),
      ),
    );
  }
}

String formatNotificationDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
