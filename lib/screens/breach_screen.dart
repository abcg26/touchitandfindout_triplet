import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../bluetooth/fake_device_link.dart';
import '../state/alarm_controller.dart';
import '../theme/tokens.dart';
import '../util/format.dart';
import '../widgets/action_tile.dart';
import '../widgets/rule.dart';

/// Full-screen red takeover, shown on top of everything while the device is in
/// breach. It goes away on its own when the device reports it is disarmed.
class BreachScreen extends StatelessWidget {
  const BreachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AlarmController>();
    final status = c.status;
    final breach = status?.breach;
    final silenced = status?.silenced ?? false;
    final stamp = breach == null ? '--' : fmtStamp(breach.time);
    final peak = breach == null ? '--' : breach.peakG.toStringAsFixed(1);

    final small = Tifo.mono(
      size: 11,
      weight: FontWeight.w700,
      color: Tifo.ink,
      letterSpacing: 0.8,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Tifo.red,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Tifo.red,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Material(
        color: Tifo.red,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Debug aid: long-press to disarm the fake device.
                          GestureDetector(
                            onLongPress: () {
                              final link = c.link;
                              if (link is FakeDeviceLink) {
                                link.simulateRfidDisarm();
                              }
                            },
                            child: Text('ALARM ACTIVE', style: small),
                          ),
                          Text('ERR_001', style: small),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Rule(color: Tifo.ink, thickness: 3),
                      const SizedBox(height: 28),
                      Text(
                        'SECURITY\nBREACH\nDETECTED',
                        style: Tifo.display(color: Tifo.ink, size: 46),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        stamp,
                        style: Tifo.mono(
                          size: 11,
                          color: Tifo.ink,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'BACKPACK MOTION EXCEEDED LIMIT',
                        style: Tifo.mono(
                          size: 11,
                          color: Tifo.ink,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Rule(color: Tifo.ink, thickness: 2),
                      const SizedBox(height: 14),
                      Text('PEAK MOTION READING', style: small),
                      const SizedBox(height: 8),
                      Text(
                        '${peak}G TILT',
                        style: Tifo.display(color: Tifo.ink, size: 44),
                      ),
                      const SizedBox(height: 14),
                      const Rule(color: Tifo.ink, thickness: 2),
                      const Spacer(),
                      const SizedBox(height: 24),
                      ActionTile(
                        title: silenced ? 'ALARM SILENCED' : 'SILENCE ALARM',
                        titleSize: 18,
                        color: Tifo.ink,
                        textColor: Tifo.white,
                        onPressed: silenced ? null : c.silence,
                      ),
                      const SizedBox(height: 4),
                      const InfoTile(
                        title: 'LAST SEEN LOCATION',
                        subtitle: 'LOCATION UNAVAILABLE',
                        color: Tifo.yellow,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'SILENCING STOPS SOUND ONLY.',
                        style: Tifo.mono(
                          size: 10,
                          color: Tifo.ink,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'TIFO / SECURITY OVERRIDE',
                        style: Tifo.mono(
                          size: 10,
                          color: Tifo.ink,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
