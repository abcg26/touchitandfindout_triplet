import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/alarm_controller.dart';
import '../widgets/nav_bar.dart';
import 'breach_screen.dart';
import 'console_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

/// The three tabs plus the bottom bar. While the device is in breach, the red
/// breach screen is stacked on top of everything.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _screens = <Widget>[
    ConsoleScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final inBreach = context.select<AlarmController, bool>((c) => c.inBreach);

    return Stack(
      fit: StackFit.expand,
      children: [
        Scaffold(
          body: IndexedStack(index: _index, children: _screens),
          bottomNavigationBar: TifoNavBar(
            index: _index,
            onChanged: (i) => setState(() => _index = i),
          ),
        ),
        if (inBreach) const Positioned.fill(child: BreachScreen()),
      ],
    );
  }
}
