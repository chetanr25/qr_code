import 'package:flutter/material.dart';

import '../scan/scan_screen.dart';
import '../create/create_home.dart';
import 'app_drawer.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _index = 0;

  static const _tabs = [
    _TabDef('Scan', Icons.qr_code_scanner_rounded),
    _TabDef('Create', Icons.add_box_rounded),
  ];

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  @override
  Widget build(BuildContext context) {
    final screens = [
      ScanScreen(onMenu: _openDrawer),
      CreateHome(onMenu: _openDrawer),
    ];
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      drawer: const AppDrawer(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey(_index),
          child: screens[_index],
        ),
      ),
      bottomNavigationBar: _GlassNavBar(
        index: _index,
        tabs: _tabs,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _TabDef {
  const _TabDef(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _GlassNavBar extends StatelessWidget {
  const _GlassNavBar({
    required this.index,
    required this.tabs,
    required this.onTap,
  });

  final int index;
  final List<_TabDef> tabs;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: _NavItem(
                  tab: tabs[i],
                  selected: i == index,
                  onTap: () => onTap(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final _TabDef tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tab.icon,
              size: 22,
              color: selected
                  ? scheme.primary
                  : scheme.onSurface.withValues(alpha: 0.55),
            ),
            const SizedBox(width: 8),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
