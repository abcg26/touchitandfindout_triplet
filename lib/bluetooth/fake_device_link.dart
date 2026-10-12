import 'dart:async';
import 'dart:math';

import 'device_link.dart';
import 'models.dart';

/// A pretend Arduino, so the whole UI can be built and tested without hardware.
///
/// In the app, long-press the "TOUCH IT & FIND OUT" title to open the
/// simulate sheet (breach, RFID disarm, dropped connection).
class FakeDeviceLink implements DeviceLink {
  final _connection = StreamController<LinkState>.broadcast();
  final _status = StreamController<DeviceStatus>.broadcast();
  final _telemetry = StreamController<Telemetry>.broadcast();
  final _rng = Random();
  Timer? _telemetryTimer;

  DeviceStatus _current = const DeviceStatus(
    deviceId: '0482',
    firmware: 'TIFO 1.0.4',
    sensor: 'MPU-6050',
    arm: ArmState.disarmed,
    sensorOnline: true,
    batteryPercent: 92,
    triggerHoldMs: 200,
  );

  /// Newest first, seeded with the events from the mockup.
  final List<AlarmEvent> _history = [
    AlarmEvent(
      time: DateTime(2026, 10, 8, 14, 22, 5),
      type: EventType.breach,
      source: 'RFID 0482',
      alarmDuration: const Duration(seconds: 18),
      peakG: 3.4,
    ),
    AlarmEvent(
      time: DateTime(2026, 10, 8, 14, 10, 32),
      type: EventType.armed,
      source: 'MAIN CONSOLE',
    ),
    AlarmEvent(
      time: DateTime(2026, 10, 8, 9, 45, 11),
      type: EventType.disarmed,
      source: 'KEYPAD PIN',
    ),
    AlarmEvent(
      time: DateTime(2026, 10, 8, 9, 12, 48),
      type: EventType.armed,
      source: 'MAIN CONSOLE',
    ),
  ];

  @override
  Stream<LinkState> get connection => _connection.stream;

  @override
  Stream<DeviceStatus> get status => _status.stream;

  @override
  Stream<Telemetry> get telemetry => _telemetry.stream;

  /// The mockup says 100 Hz, but an HM-10 at its default 9600 baud moves
  /// roughly 1 KB/s, so a real link will need a lower rate.
  @override
  int get telemetryHz => 10;

  @override
  Future<void> connect() async {
    _connection.add(LinkState.connecting);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _connection.add(LinkState.connected);
    _status.add(_current);
    _startTelemetry();
  }

  @override
  Future<void> disconnect() async {
    _stopTelemetry();
    _connection.add(LinkState.disconnected);
  }

  @override
  Future<void> arm() async {
    if (_current.arm != ArmState.disarmed) return;
    _history.insert(
      0,
      AlarmEvent(
        time: DateTime.now(),
        type: EventType.armed,
        source: 'MAIN CONSOLE',
      ),
    );
    _setStatus(_current.copyWith(arm: ArmState.armed));
  }

  @override
  Future<void> disarm() async {
    if (_current.arm == ArmState.disarmed) return;
    _disarmBy('MAIN CONSOLE');
  }

  @override
  Future<void> silence() async {
    if (_current.arm != ArmState.breach) return;
    _setStatus(_current.copyWith(silenced: true));
  }

  @override
  Future<void> setTriggerHold(int ms) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _setStatus(_current.copyWith(triggerHoldMs: ms));
  }

  @override
  Future<List<AlarmEvent>> fetchHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List<AlarmEvent>.unmodifiable(_history);
  }

  // --- Simulation hooks (used by the debug sheet) ---

  void simulateBreach() {
    if (_current.arm == ArmState.breach) return;
    final peak = double.parse((2.5 + _rng.nextDouble() * 2).toStringAsFixed(1));
    _setStatus(
      _current.copyWith(
        arm: ArmState.breach,
        silenced: false,
        breach: BreachInfo(time: DateTime.now(), peakG: peak),
      ),
    );
  }

  void simulateRfidDisarm() {
    if (_current.arm == ArmState.disarmed) return;
    _disarmBy('RFID 0482');
  }

  void simulateDrop() {
    _stopTelemetry();
    _connection.add(LinkState.lost);
  }

  // --- Internals ---

  void _disarmBy(String source) {
    final breach = _current.breach;
    if (_current.arm == ArmState.breach && breach != null) {
      _history.insert(
        0,
        AlarmEvent(
          time: breach.time,
          type: EventType.breach,
          source: source,
          alarmDuration: DateTime.now().difference(breach.time),
          peakG: breach.peakG,
        ),
      );
    } else {
      _history.insert(
        0,
        AlarmEvent(
          time: DateTime.now(),
          type: EventType.disarmed,
          source: source,
        ),
      );
    }
    _setStatus(
      _current.copyWith(
        arm: ArmState.disarmed,
        silenced: false,
        clearBreach: true,
      ),
    );
  }

  void _setStatus(DeviceStatus s) {
    _current = s;
    _status.add(s);
  }

  void _startTelemetry() {
    _telemetryTimer?.cancel();
    _telemetryTimer = Timer.periodic(
      Duration(milliseconds: 1000 ~/ telemetryHz),
      (_) => _telemetry.add(_sample()),
    );
  }

  void _stopTelemetry() {
    _telemetryTimer?.cancel();
    _telemetryTimer = null;
  }

  Telemetry _sample() {
    double jitter(double scale) => (_rng.nextDouble() - 0.5) * scale;
    if (_current.arm == ArmState.breach) {
      return Telemetry(jitter(6), jitter(6), 1 + jitter(6));
    }
    return Telemetry(
      0.012 + jitter(0.02),
      -0.008 + jitter(0.02),
      1.003 + jitter(0.02),
    );
  }
}
