import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Big tappable block with an arrow: ARM, DISARM, SILENCE ALARM, SAVE.
/// Passing a null [onPressed] dims it and disables it.
class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.title,
    required this.color,
    required this.onPressed,
    this.subtitle,
    this.textColor = Tifo.black,
    this.titleSize = 28,
  });

  final String title;
  final String? subtitle;
  final Color color;
  final Color textColor;
  final double titleSize;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Material(
        color: color,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Tifo.mono(
                          size: titleSize,
                          weight: FontWeight.w800,
                          color: textColor,
                          height: 1.0,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitle!,
                          style: Tifo.mono(
                            size: 10,
                            color: textColor,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.north_east, size: 18, color: textColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A block that is not tappable, such as "LAST SEEN LOCATION".
class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    this.textColor = Tifo.black,
  });

  final String title;
  final String subtitle;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Tifo.mono(
              size: 14,
              weight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Tifo.mono(size: 10, color: textColor, letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}
