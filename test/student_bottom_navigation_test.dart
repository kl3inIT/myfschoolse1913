import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/student_bottom_navigation.dart';

void main() {
  testWidgets('renders student destinations without messages tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: StudentBottomNavigation(
            currentIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Lịch'), findsOneWidget);
    expect(find.text('Thông báo'), findsOneWidget);
    expect(find.text('Tài khoản'), findsOneWidget);
    expect(find.text('Tin nhắn'), findsNothing);
  });

  testWidgets('notifies selected destination index', (
    WidgetTester tester,
  ) async {
    var selectedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: StudentBottomNavigation(
            currentIndex: 0,
            onDestinationSelected: (index) {
              selectedIndex = index;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Lịch'));
    await tester.pump();

    expect(selectedIndex, 1);
  });
}
