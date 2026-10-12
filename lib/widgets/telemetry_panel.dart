import 'package:flutter/material.dart';

import '../bluetooth/models.dart';
import '../theme/tokens.dart';
import '../util/format.dart';
import 'rule.dart';

/// "RAW TELEMETRY / 10 HZ" header plus live X / Y / Z rows.
class TelemetryPanel extends StatelessWidget {
  const TelemetryPanel({
    super.key,
    required this.telemetry,
    required this.hz,
    required this.statusLabel,
  });

  final ValueListenable<Telemetry> telemetry;
  final int hz;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('RAW TELEMETRY / $hz HZ', style: Tifo.label()),
            Text(
              statusLabel,
              style: Tifo.mono(
                size: 10,
                color: Tifo.yellow,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Rule(),
        const SizedBox(height: 10),
        ValueListenableBuilder<Telemetry>(
          valueListenable: telemetry,
          builder: (context, t, _) {
            return Column(
              children: [
                _AxisRow(axis: 'X', value: t.x),
                _AxisRow(axis: 'Y', value: t.y),
                _AxisRow(axis: 'Z', value: t.z),
              ],
            );
          },
        ),
        const SizedBox(height: 6),
        const Rule(),
      ],
    );
  }
}

class _AxisRow extends StatelessWidget {
  const _AxisRow({required this.axis, required this.value});

  final String axis;
  final double value;

  @override
  Widget build(BuildContext context) {
    final style = Tifo.mono(size: 13, weight: FontWeight.w500);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text(axis, style: style)),
          Text(fmtG(value), style: style),
        ],
      ),
    );
  }
}
