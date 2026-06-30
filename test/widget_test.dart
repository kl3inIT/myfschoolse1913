import 'package:flutter_test/flutter_test.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/my_fschool_app.dart';

void main() {
  testWidgets('shows login screen by default', (WidgetTester tester) async {
    await tester.pumpWidget(const MyFSchoolApp());

    await tester.pump();

    expect(find.text('Số điện thoại'), findsOneWidget);
    expect(find.text('Mật khẩu'), findsOneWidget);
    expect(find.text('Quên mật khẩu?'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
  });

  testWidgets('opens forgot password screen from login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyFSchoolApp());
    await tester.pump();

    await tester.tap(find.text('Quên mật khẩu?'));
    await tester.pumpAndSettle();

    expect(find.text('Quên mật khẩu'), findsOneWidget);
    expect(find.text('Gửi mã xác thực'), findsOneWidget);
    expect(find.text('Quay lại đăng nhập'), findsOneWidget);
  });
}
