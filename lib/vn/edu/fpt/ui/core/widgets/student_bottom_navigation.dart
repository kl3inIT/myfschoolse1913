import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';

class StudentBottomNavigation extends StatelessWidget {
  const StudentBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _items = [
    _StudentNavItem(Icons.home_outlined, Icons.home, 'Trang chủ'),
    _StudentNavItem(
      Icons.calendar_month_outlined,
      Icons.calendar_month,
      'Lịch',
    ),
    _StudentNavItem(
      Icons.notifications_outlined,
      Icons.notifications,
      'Thông báo',
    ),
    _StudentNavItem(Icons.person_outline, Icons.person, 'Tài khoản'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: FptColors.border)),
      ),
      child: Row(
        children: [
          for (var index = 0; index < _items.length; index++)
            Expanded(
              child: _StudentNavButton(
                item: _items[index],
                selected: index == currentIndex,
                onTap: () => onDestinationSelected(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _StudentNavItem {
  const _StudentNavItem(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _StudentNavButton extends StatelessWidget {
  const _StudentNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _StudentNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? FptColors.orange : FptColors.textSecondary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            Icon(
              selected ? item.selectedIcon : item.icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
