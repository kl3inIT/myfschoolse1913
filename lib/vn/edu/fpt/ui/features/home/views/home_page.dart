import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/auth_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FptColors.field,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: const ColoredBox(
              color: Colors.white,
              child: Column(
                children: [
                  _DashboardHeader(),
                  Expanded(child: _DashboardContent()),
                  _DashboardBottomNav(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      color: FptColors.orangeDeep,
      padding: const EdgeInsets.only(left: 24, top: 28, right: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              'Xin chào, Học sinh',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Thông báo',
            onPressed: () {},
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.notifications, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      children: const [
        _StudentSummaryCard(),
        SizedBox(height: 34),
        _SectionTitle('Tiện ích'),
        SizedBox(height: 20),
        _FeatureGrid(),
        SizedBox(height: 28),
        _SectionTitle('Hôm nay'),
        SizedBox(height: 12),
        _TodayScheduleTile(
          title: 'Toán học',
          subtitle: 'Tiết 1 - Phòng A203',
          time: '07:30',
        ),
        SizedBox(height: 8),
        _TodayScheduleTile(
          title: 'Ăn trưa',
          subtitle: '11:15 - Nhà ăn',
          time: '11:15',
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class _StudentSummaryCard extends StatelessWidget {
  const _StudentSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: FptColors.orangeDeep,
            foregroundColor: Colors.white,
            child: Text(
              'MA',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nguyễn Minh Anh',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: FptColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lớp 5A1',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: FptColors.textSecondary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Năm học 2026',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: FptColors.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const _StatusChip(text: 'Đang học'),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFF047857),
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: const Color(0xFF071126),
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  static const _items = [
    _FeatureItem(Icons.fact_check_outlined, 'Điểm học kỳ'),
    _FeatureItem(Icons.calendar_month_outlined, 'Lịch học'),
    _FeatureItem(Icons.notifications_outlined, 'Sự kiện'),
    _FeatureItem(Icons.description_outlined, 'Đơn từ'),
    _FeatureItem(Icons.groups_outlined, 'CLB'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 88,
        mainAxisSpacing: 12,
        crossAxisSpacing: 14,
      ),
      itemBuilder: (context, index) {
        final item = _items[index];
        return _FeatureCard(item: item);
      },
    );
  }
}

class _FeatureItem {
  const _FeatureItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.item});

  final _FeatureItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: FptColors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 20,
            child: Center(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF1F2933),
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayScheduleTile extends StatelessWidget {
  const _TodayScheduleTile({
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 12, right: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: FptColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: FptColors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.white,
              size: 17,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF071126),
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: FptColors.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 52,
            child: Text(
              time,
              maxLines: 1,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: FptColors.blue,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardBottomNav extends StatelessWidget {
  const _DashboardBottomNav();

  static const _items = [
    _BottomNavItem(Icons.home_outlined, Icons.home, 'Trang chủ', true),
    _BottomNavItem(
      Icons.calendar_month_outlined,
      Icons.calendar_month,
      'Lịch',
      false,
    ),
    _BottomNavItem(
      Icons.chat_bubble_outline,
      Icons.chat_bubble,
      'Tin nhắn',
      false,
    ),
    _BottomNavItem(Icons.person_outline, Icons.person, 'Tài khoản', false),
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
          for (final item in _items) Expanded(child: _BottomNavButton(item)),
        ],
      ),
    );
  }
}

class _BottomNavItem {
  const _BottomNavItem(this.icon, this.selectedIcon, this.label, this.selected);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton(this.item);

  final _BottomNavItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.selected ? FptColors.orange : FptColors.textSecondary;

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            Icon(
              item.selected ? item.selectedIcon : item.icon,
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
                fontWeight: item.selected ? FontWeight.w600 : FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
