import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';

/// Shared orange header for every student screen. Paints behind the
/// status bar (edge-to-edge, light status icons); pages using it must
/// disable the top edge of their [SafeArea].
class StudentTopAppBar extends StatelessWidget {
  const StudentTopAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;

  /// Shows an adaptive back button when set; omit on the home screen.
  final VoidCallback? onBack;

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final back = onBack;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        height: 64 + topInset,
        color: FptColors.orangeDeep,
        padding: EdgeInsets.only(
          top: topInset,
          left: back != null ? 8 : 24,
          right: trailing != null ? 12 : 24,
        ),
        child: Row(
          children: [
            if (back != null) ...[
              IconButton(
                tooltip: 'Quay lại',
                onPressed: back,
                icon: Icon(Icons.adaptive.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
