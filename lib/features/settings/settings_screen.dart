import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_prefs.dart';
import '../../core/app_theme.dart';
import '../../widgets/ui_kit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              SectionLabel('Appearance', icon: Icons.dark_mode_rounded),
              GlassCard(
                padding: const EdgeInsets.all(8),
                child: ValueListenableBuilder<ThemeMode>(
                  valueListenable: AppPrefs.instance.themeMode,
                  builder: (context, mode, _) {
                    return Column(
                      children: [
                        _modeTile(context, 'System default',
                            Icons.brightness_auto_rounded, ThemeMode.system, mode),
                        _modeTile(context, 'Light', Icons.light_mode_rounded,
                            ThemeMode.light, mode),
                        _modeTile(context, 'Dark', Icons.dark_mode_rounded,
                            ThemeMode.dark, mode),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SectionLabel('About', icon: Icons.info_outline_rounded),
              GlassCard(
                child: Column(
                  children: [
                    _aboutHeader(context),
                    const Divider(height: 28),
                    _linkTile(context, Icons.code_rounded, 'Source on GitHub',
                        'github.com/chetanr25/qr_code',
                        'https://github.com/chetanr25/qr_code'),
                    _linkTile(context, Icons.star_outline_rounded,
                        'Rate the app', 'Leave a review', null),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Qrly · v2.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeTile(BuildContext context, String label, IconData icon,
      ThemeMode value, ThemeMode current) {
    final selected = value == current;
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Icon(icon, color: selected ? scheme.primary : null),
      title: Text(label,
          style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: scheme.primary)
          : null,
      onTap: () => AppPrefs.instance.setThemeMode(value),
    );
  }

  Widget _aboutHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.qr_code_2_rounded,
              color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Qrly',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              Text(
                'Fast, beautiful QR scanner & generator',
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _linkTile(BuildContext context, IconData icon, String title,
      String subtitle, String? url) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: url == null
          ? null
          : () => launchUrl(Uri.parse(url),
              mode: LaunchMode.externalApplication),
    );
  }
}
