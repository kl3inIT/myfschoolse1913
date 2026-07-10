import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';

/// Material adaptive guidance: windows narrower than 600lp are
/// phone-sized and content should fill them edge-to-edge; wider windows
/// (web, tablet, desktop) keep a centered column on a gray backdrop.
const double kWideWindowMinWidth = 600;

/// Max content width for wide windows, keeps line lengths readable.
const double kWideContentMaxWidth = 480;

double pageContentMaxWidth(BuildContext context) {
  final windowWidth = MediaQuery.sizeOf(context).width;
  return windowWidth < kWideWindowMinWidth
      ? windowWidth
      : kWideContentMaxWidth;
}

Color pageBackdropColor(BuildContext context) {
  final windowWidth = MediaQuery.sizeOf(context).width;
  return windowWidth < kWideWindowMinWidth ? Colors.white : FptColors.field;
}
