import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bluetooth/models.dart';
import '../state/alarm_controller.dart';
import '../theme/tokens.dart';
import '../util/format.dart';
import '../widgets/rule.dart';
import '../widgets/screen_header.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AlarmController>();
    final events = c.history;

    final emptyText = c.historyLoading
        ? 'READING DEVICE LOG...'
        : (c.isConnected ? 'NO EVENTS RECORDED' : 'CONNECT TO READ DEVICE LOG');

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: [
          const ScreenHeader(
            crumb: 'TIFO / EVENT LOG',
            title: 'HISTORY',
            subtitle: 'LOCAL DEVICE RECORD / NEWEST FIRST',
          ),
          const SizedBox(height: 20),
          if (events.isEmpty)
            Text(emptyText, style: Tifo.label())
          else ...[
            ..._buildLog(events),
            _EndOfLog(count: events.length),
          ],
        ],
      ),
    );
  }
}

/// Events arrive newest first. A yellow date bar is inserted whenever the day
/// changes, showing how many events happened that day.
List<Widget> _buildLog(List<AlarmEvent> events) {
  final counts = <String, int>{};
  for (final e in events) {
    counts.update(fmtDate(e.time), (n) => n + 1, ifAbsent: () => 1);
  }

  final widgets = <Widget>[];
  String? currentDate;
  for (final e in events) {
    final date = fmtDate(e.time);
    if (date != currentDate) {
      currentDate = date;
      widgets.add(_DateBar(date: date, count: counts[date] ?? 0));
      widgets.add(const SizedBox(height: 14));
      widgets.add(const Rule());
    }
    widgets.add(_EventRow(event: e));
  }
  return widgets;
}

class _DateBar extends StatelessWidget {
  const _DateBar({required this.date, required this.count});

  final String date;
  final int count;

  @override
  Widget build(BuildContext context) {
    final style = Tifo.mono(
      size: 11,
      weight: FontWeight.w500,
      color: Tifo.black,
      letterSpacing: 0.4,
    );
    return Container(
      color: Tifo.yellow,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: style),
          Text('${two(count)} EVENTS', style: style),
        ],
      ),
    );
  }
}

Widget _line(String text, Color color) {
  return Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Text(text, style: Tifo.mono(size: 10, color: color, letterSpacing: 0.4)),
  );
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final AlarmEvent event;

  @override
  Widget build(BuildContext context) {
    final e = event;
    final String title;
    final Color titleColor;
    final List<Widget> details;

    switch (e.type) {
      case EventType.breach:
        title = 'MOTION BREACH';
        titleColor = Tifo.red;
        details = [
          _line('DISARMED BY ${e.source}', Tifo.white),
          _line(
            'ALARM DURATION ${e.alarmDuration?.inSeconds ?? 0} SECONDS',
            Tifo.grey,
          ),
          _line(
            'PEAK ${(e.peakG ?? 0).toStringAsFixed(1)} G / TILT DETECTED',
            Tifo.yellow,
          ),
        ];
      case EventType.armed:
        title = 'SYSTEM ARMED';
        titleColor = Tifo.white;
        details = [_line('ARMED VIA ${e.source}', Tifo.white)];
      case EventType.disarmed:
        title = 'SYSTEM DISARMED';
        titleColor = Tifo.white;
        details = [
          _line('DISARMED BY ${e.source}', Tifo.white),
          _line('NO ALARM TRIGGERED', Tifo.grey),
        ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fmtStamp(e.time), style: Tifo.label()),
              const SizedBox(height: 8),
              Text(
                title,
                style: Tifo.mono(
                  size: 16,
                  weight: FontWeight.w800,
                  color: titleColor,
                  letterSpacing: 0.3,
                ),
              ),
              ...details,
            ],
          ),
        ),
        const Rule(),
      ],
    );
  }
}

class _EndOfLog extends StatelessWidget {
  const _EndOfLog({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('END OF LOG', style: Tifo.label()),
              Text(
                '${two(count)} / ${two(count)}',
                style: Tifo.mono(size: 10, letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('RECORDS STORED ON DEVICE', style: Tifo.label()),
        ],
      ),
    );
  }
}
