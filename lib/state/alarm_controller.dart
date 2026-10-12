import 'dart:async';

import 'package:flutter/foundation.dart';

import '../bluetooth/device_link.dart';
import '../bluetooth/models.dart';

/// Holds everything the screens show and forwards their actions to the device.
class AlarmController extends ChangeNotifier {
  AlarmController(this.link) {
    _subs.add(link.connection.listen(_onConnection));
    _subs.add(link.status.listen(_onStatus));
    _subs.add(link.telemetry.listen((t) => telemetry.value = t));
    connect();
  }

  final DeviceLink link;
  final _subs = <StreamSubscription<dynamic>>[];

  /// Updated ~10x per second, so it is a separate notifier: only the
  /// telemetry panel rebuilds, not whole screens.
  final telemetry = ValueNotifier<Telemetry>(Telemetry.rest);

  LinkState connection = LinkState.disconnected;
  DeviceStatus? status;
  List<AlarmEvent> history = const [];
  bool historyLoading = false;
  bool savingHold = false;

  bool get isConnected => connection == LinkState.connected;
  ArmState get armState => status?.arm ?? ArmState.disarmed;
  bool get inBreach => status?.arm == ArmState.breach;

  Future<void> connect() async {
    try {
      await link.connect();
    } catch (_) {
      connection = LinkState.lost;
      notifyListeners();
    }
  }

  Future<void> arm() => link.arm();
  Future<void> disarm() => link.disarm();
  Future<void> silence() => link.silence();

  Future<void> loadHistory() async {
    historyLoading = true;
    notifyListeners();
    try {
      history = await link.fetchHistory();
    } catch (_) {
      // Keep whatever we had; the history screen shows the old list.
    } finally {
      historyLoading = false;
      notifyListeners();
    }
  }

  /// Returns true if the device accepted the new value.
  Future<bool> saveTriggerHold(int ms) async {
    savingHold = true;
    notifyListeners();
    try {
      await link.setTriggerHold(ms);
      return true;
    } catch (_) {
      return false;
    } finally {
      savingHold = false;
      notifyListeners();
    }
  }

  void _onConnection(LinkState s) {
    connection = s;
    if (s == LinkState.connected) loadHistory();
    notifyListeners();
  }

  void _onStatus(DeviceStatus s) {
    final previous = status?.arm;
    status = s;
    // The device log changes whenever the arm state does.
    if (previous != null && previous != s.arm) loadHistory();
    notifyListeners();
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    telemetry.dispose();
    super.dispose();
  }
}
