import 'models.dart';

/// What the UI needs from the alarm hardware.
///
/// The screens only ever talk to this interface. Today it is backed by
/// [FakeDeviceLink]; when the HM-10 arrives, write a BLE implementation (parse
/// the Arduino's text lines into these typed streams) and swap it in main.dart.
abstract class DeviceLink {
  Stream<LinkState> get connection;
  Stream<DeviceStatus> get status;
  Stream<Telemetry> get telemetry;

  /// How many telemetry samples per second the device actually sends.
  int get telemetryHz;

  Future<void> connect();
  Future<void> disconnect();
  Future<void> arm();
  Future<void> disarm();

  /// Stops the siren only. The device stays in breach until disarmed.
  Future<void> silence();

  Future<void> setTriggerHold(int ms);
  Future<List<AlarmEvent>> fetchHistory();
}
