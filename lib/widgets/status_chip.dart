import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Flat coloured label such as "MPU-6050 ONLINE" or "BATTERY 92%".
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Text(
        text,
        style: Tifo.mono(
          size: 11,
          weight: FontWeight.w500,
          color: Tifo.black,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
