import 'package:flutter/material.dart';

import '../bluetooth/models.dart';
import '../theme/tokens.dart';

/// Shown on the console when there is no live link to the device.
/// The Figma mockup has no design for this yet, so it is deliberately plain.
class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({
    super.key,
    required this.state,
    required this.onRetry,
  });

  final LinkState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final connecting = state == LinkState.connecting;
    final text = switch (state) {
      LinkState.connecting => 'CONNECTING TO DEVICE...',
      LinkState.lost => 'CONNECTION LOST',
      _ => 'NOT CONNECTED',
    };
    final style = Tifo.mono(
      size: 11,
      weight: FontWeight.w700,
      color: Tifo.yellow,
      letterSpacing: 0.6,
    );

    return Container(
      decoration: BoxDecoration(border: Border.all(color: Tifo.yellow)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(text, style: style)),
          if (!connecting)
            InkWell(
              onTap: onRetry,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('RECONNECT', style: style),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.north_east,
                    size: 14,
                    color: Tifo.yellow,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
