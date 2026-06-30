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
      appBar: AppBar(title: const Text('Settings')),
      body: AuroraBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
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
                    _contactTile(context),
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

  Widget _contactTile(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.alternate_email_rounded),
      title: const Text('Contact developer',
          style: TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => launchUrl(
        Uri.parse('https://chetanr25.in'),
        mode: LaunchMode.externalApplication,
      ),
    );
  }
}
