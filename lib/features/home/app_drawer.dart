import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppTheme.brandGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.seed.withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.qr_code_2_rounded,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Qrly',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800)),
                      Text(
                        'Scan & create QR codes',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _Item(
              icon: Icons.history_rounded,
              label: 'History',
              onTap: () => _push(context, const HistoryScreen()),
            ),
            _Item(
              icon: Icons.settings_rounded,
              label: 'Settings',
              onTap: () => _push(context, const SettingsScreen()),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                'Qrly · v2.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.pop(context); // close drawer
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _Item extends StatelessWidget {
  const _Item(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      onTap: onTap,
    );
  }
}
