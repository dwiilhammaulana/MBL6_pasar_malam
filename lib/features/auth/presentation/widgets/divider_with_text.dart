import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.64),
              fontSize: 13,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
