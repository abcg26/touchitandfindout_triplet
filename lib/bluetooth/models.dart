enum LinkState { disconnected, connecting, connected, lost }

enum ArmState { disarmed, armed, breach }

enum EventType { armed, disarmed, breach }

/// One accelerometer sample, in g.
class Telemetry {
  const Telemetry(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  /// A device lying still: no tilt, 1 g of gravity on Z.
  static const rest = Telemetry(0.012, -0.008, 1.003);
}

class BreachInfo {
  const BreachInfo({required this.time, required this.peakG});

  final DateTime time;
  final double peakG;
}

/// Everything the device reports about itself.
class DeviceStatus {
  const DeviceStatus({
    required this.deviceId,
    required this.firmware,
    required this.sensor,
    required this.arm,
    required this.sensorOnline,
    required this.batteryPercent,
    required this.triggerHoldMs,
    this.breach,
    this.silenced = false,
  });

  final String deviceId;
  final String firmware;
  final String sensor;
  final ArmState arm;
  final bool sensorOnline;
  final int batteryPercent;
  final int triggerHoldMs;
  final BreachInfo? breach;
  final bool silenced;

  DeviceStatus copyWith({
    ArmState? arm,
    bool? sensorOnline,
    int? batteryPercent,
    int? triggerHoldMs,
    BreachInfo? breach,
    bool clearBreach = false,
    bool? silenced,
  }) {
    return DeviceStatus(
      deviceId: deviceId,
      firmware: firmware,
      sensor: sensor,
      arm: arm ?? this.arm,
      sensorOnline: sensorOnline ?? this.sensorOnline,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      triggerHoldMs: triggerHoldMs ?? this.triggerHoldMs,
      breach: clearBreach ? null : (breach ?? this.breach),
      silenced: silenced ?? this.silenced,
    );
  }
}

/// One line of the on-device event log.
///
/// [source] is who did it: 'MAIN CONSOLE', 'RFID 0482', 'KEYPAD PIN'.
/// For a breach it is who disarmed the alarm afterwards.
class AlarmEvent {
  const AlarmEvent({
    required this.time,
    required this.type,
    required this.source,
    this.alarmDuration,
    this.peakG,
  });

  final DateTime time;
  final EventType type;
  final String source;
  final Duration? alarmDuration;
  final double? peakG;
}
