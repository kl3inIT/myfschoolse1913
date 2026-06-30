import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      children: [
        Text('Phiên bản 1.0.0', style: style),
        const SizedBox(height: 2),
        Text('© 2026 FPT Schools', style: style),
      ],
    );
  }
}
