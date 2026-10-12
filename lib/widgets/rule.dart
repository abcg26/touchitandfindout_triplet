import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A full-width horizontal line.
class Rule extends StatelessWidget {
  const Rule({super.key, this.color = Tifo.rule, this.thickness = 1});

  final Color color;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: thickness,
      width: double.infinity,
      child: ColoredBox(color: color),
    );
  }
}
