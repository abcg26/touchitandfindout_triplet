import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Bottom tab bar: the active tab is a solid yellow block.
class TifoNavBar extends StatelessWidget {
  const TifoNavBar({super.key, required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  static const _labels = ['CONSOLE', 'HISTORY', 'SETTINGS'];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Tifo.black,
        border: Border(top: BorderSide(color: Tifo.rule)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              for (var i = 0; i < _labels.length; i++)
                Expanded(
                  child: _NavItem(
                    label: _labels[i],
                    active: i == index,
                    onTap: () => onChanged(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? Tifo.yellow : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              label,
              style: Tifo.mono(
                size: 11,
                weight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? Tifo.black : Tifo.white,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
