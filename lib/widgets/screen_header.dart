import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Yellow breadcrumb, big title, grey caption: the top of every screen.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.crumb,
    required this.title,
    required this.subtitle,
    this.onTitleLongPress,
  });

  final String crumb;
  final String title;
  final String subtitle;
  final VoidCallback? onTitleLongPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(crumb, style: Tifo.crumb()),
        const SizedBox(height: 14),
        GestureDetector(
          onLongPress: onTitleLongPress,
          child: Text(title, style: Tifo.display()),
        ),
        const SizedBox(height: 10),
        Text(subtitle, style: Tifo.label()),
      ],
    );
  }
}
