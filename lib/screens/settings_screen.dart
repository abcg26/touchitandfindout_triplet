import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/alarm_controller.dart';
import '../theme/tokens.dart';
import '../widgets/action_tile.dart';
import '../widgets/screen_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _minHold = 50;
  static const _maxHold = 1000;

  final _field = TextEditingController();
  late final AlarmController _c;
  int? _synced;
  String? _error;

  @override
  void initState() {
    super.initState();
    _c = context.read<AlarmController>();
    _c.addListener(_syncFromDevice);
    _syncFromDevice();
  }

  /// Copies the device's trigger hold into the text box, but only when the
  /// device's value actually changes, so typing is never overwritten.
  void _syncFromDevice() {
    final hold = _c.status?.triggerHoldMs;
    if (hold != null && hold != _synced) {
      _synced = hold;
      _field.text = hold.toString();
    }
  }

  @override
  void dispose() {
    _c.removeListener(_syncFromDevice);
    _field.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = int.tryParse(_field.text.trim());
    if (value == null || value < _minHold || value > _maxHold) {
      setState(() => _error = 'ENTER A VALUE FROM $_minHold TO $_maxHold MS');
      return;
    }
    setState(() => _error = null);
    FocusScope.of(context).unfocus();

    final ok = await _c.saveTriggerHold(value);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? Tifo.yellow : Tifo.red,
        content: Text(
          ok ? 'TRIGGER HOLD SAVED' : 'SAVE FAILED / CHECK CONNECTION',
          style: Tifo.mono(
            size: 11,
            weight: FontWeight.w700,
            color: Tifo.black,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AlarmController>();
    final status = c.status;
    final canSave = c.isConnected && !c.savingHold;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: [
          ScreenHeader(
            crumb: 'TIFO / DEVICE CONFIGURATION',
            title: 'SETTINGS',
            subtitle:
                'DEVICE ${status?.deviceId ?? '----'} / CHANGES APPLY ON SAVE',
          ),
          const SizedBox(height: 24),
          Text(
            'TRIGGER HOLD / CONFIRMATION TIME',
            style: Tifo.mono(
              size: 10,
              weight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Tifo.white, width: 2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _field,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    cursorColor: Tifo.yellow,
                    style: Tifo.mono(size: 32, weight: FontWeight.w700),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Text(
                  'MS',
                  style: Tifo.mono(
                    size: 18,
                    weight: FontWeight.w500,
                    color: Tifo.yellow,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'RANGE $_minHold-$_maxHold MS / FILTERS SHORT IMPACTS',
            style: Tifo.label(color: _error == null ? Tifo.grey : Tifo.red),
          ),
          const SizedBox(height: 16),
          ActionTile(
            title: c.savingHold ? 'SAVING...' : 'SAVE TRIGGER HOLD',
            titleSize: 18,
            color: Tifo.yellow,
            onPressed: canSave ? _save : null,
          ),
          const SizedBox(height: 20),
          _KeyValue(label: 'FIRMWARE', value: status?.firmware ?? '---'),
          const SizedBox(height: 10),
          _KeyValue(label: 'SENSOR', value: status?.sensor ?? '---'),
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Tifo.label()),
        Text(value, style: Tifo.mono(size: 11, letterSpacing: 0.4)),
      ],
    );
  }
}
