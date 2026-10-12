import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bluetooth/fake_device_link.dart';
import '../state/alarm_controller.dart';
import '../theme/tokens.dart';
import 'action_tile.dart';

/// Opens a sheet of buttons that make the fake device misbehave, so you can
/// see the breach screen and connection states. Does nothing when the app is
/// running against a real device.
void showSimulateSheet(BuildContext context) {
  final link = context.read<AlarmController>().link;
  if (link is! FakeDeviceLink) return;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Tifo.black,
    shape: const RoundedRectangleBorder(),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SIMULATE / FAKE DEVICE ONLY', style: Tifo.crumb()),
              const SizedBox(height: 16),
              ActionTile(
                title: 'TRIGGER BREACH',
                titleSize: 18,
                color: Tifo.red,
                onPressed: () {
                  link.simulateBreach();
                  Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: 4),
              ActionTile(
                title: 'DISARM VIA RFID',
                titleSize: 18,
                color: Tifo.blue,
                onPressed: () {
                  link.simulateRfidDisarm();
                  Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: 4),
              ActionTile(
                title: 'DROP CONNECTION',
                titleSize: 18,
                color: Tifo.yellow,
                onPressed: () {
                  link.simulateDrop();
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
