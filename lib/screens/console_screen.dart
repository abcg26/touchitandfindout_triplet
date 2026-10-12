import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bluetooth/models.dart';
import '../state/alarm_controller.dart';
import '../theme/tokens.dart';
import '../widgets/action_tile.dart';
import '../widgets/connection_banner.dart';
import '../widgets/screen_header.dart';
import '../widgets/simulate_sheet.dart';
import '../widgets/status_chip.dart';
import '../widgets/telemetry_panel.dart';

class ConsoleScreen extends StatelessWidget {
  const ConsoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AlarmController>();
    final status = c.status;
    final connected = c.isConnected;

    final sensorText = status == null
        ? 'SENSOR UNKNOWN'
        : '${status.sensor} ${status.sensorOnline ? 'ONLINE' : 'OFFLINE'}';
    final batteryText =
        status == null ? 'BATTERY --%' : 'BATTERY ${status.batteryPercent}%';

    final telemetryLabel = !connected
        ? 'OFFLINE'
        : switch (c.armState) {
            ArmState.disarmed => 'IDLE',
            ArmState.armed => 'LIVE',
            ArmState.breach => 'ALERT',
          };

    final stateLine = !connected
        ? 'STATE: NO LINK / CONTROLS DISABLED'
        : switch (c.armState) {
            ArmState.disarmed => 'STATE: DISARMED / READY TO ARM',
            ArmState.armed => 'STATE: ARMED / MONITORING MOTION',
            ArmState.breach => 'STATE: BREACH / ALARM ACTIVE',
          };

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: [
          ScreenHeader(
            crumb: 'TIFO / BACKPACK MOTION ALARM',
            title: 'TOUCH IT\n& FIND OUT',
            subtitle: 'DEVICE ${status?.deviceId ?? '----'} / LOCAL CONNECTION',
            // Debug aid: opens the simulate sheet when using the fake device.
            onTitleLongPress: () => showSimulateSheet(context),
          ),
          if (!connected) ...[
            const SizedBox(height: 16),
            ConnectionBanner(state: c.connection, onRetry: c.connect),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: StatusChip(text: sensorText, color: Tifo.yellow),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 3,
                child: StatusChip(text: batteryText, color: Tifo.blue),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ActionTile(
            title: 'ARM',
            subtitle: 'START MOTION MONITORING',
            color: Tifo.yellow,
            onPressed: connected ? c.arm : null,
          ),
          const SizedBox(height: 4),
          ActionTile(
            title: 'DISARM',
            subtitle: 'STOP MOTION MONITORING',
            color: Tifo.blue,
            onPressed: connected ? c.disarm : null,
          ),
          const SizedBox(height: 20),
          TelemetryPanel(
            telemetry: c.telemetry,
            hz: c.link.telemetryHz,
            statusLabel: telemetryLabel,
          ),
          const SizedBox(height: 14),
          Text(stateLine, style: Tifo.label()),
        ],
      ),
    );
  }
}
