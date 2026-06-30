import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/qr_kind.dart';

/// Bottom sheet shown after a scan, with smart contextual actions.
class ResultSheet extends StatelessWidget {
  const ResultSheet({super.key, required this.value, required this.kind});

  final String value;
  final QrKind kind;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: scheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: kind.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(kind.icon, color: kind.color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                kind.label,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ContentCard(value: value, kind: kind),
          const SizedBox(height: 20),
          ..._primaryActions(context),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MiniButton(
                  icon: Icons.copy_rounded,
                  label: 'Copy',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    _toast(context, 'Copied to clipboard');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniButton(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  onTap: () => Share.share(value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _primaryActions(BuildContext context) {
    switch (kind) {
      case QrKind.url:
        return [
          _Primary('Open link', Icons.open_in_new_rounded,
              () => _launch(context, value)),
        ];
      case QrKind.upi:
        return [
          _Primary('Pay with UPI app', Icons.account_balance_wallet_rounded,
              () => _launch(context, value)),
        ];
      case QrKind.phone:
        return [
          _Primary('Call', Icons.call_rounded,
              () => _launch(context, value)),
        ];
      case QrKind.sms:
        return [
          _Primary('Send message', Icons.sms_rounded,
              () => _launch(context, value.replaceFirst('smsto:', 'sms:'))),
        ];
      case QrKind.email:
        return [
          _Primary('Send email', Icons.email_rounded,
              () => _launch(context, value)),
        ];
      case QrKind.geo:
        return [
          _Primary('Open in Maps', Icons.map_rounded,
              () => _launch(context, value)),
        ];
      case QrKind.contact:
        return [
          _Primary('Save contact', Icons.person_add_rounded,
              () => _saveContact(context)),
        ];
      case QrKind.wifi:
        final pass = _wifiField('P');
        return [
          if (pass != null)
            _Primary('Copy Wi-Fi password', Icons.key_rounded, () {
              Clipboard.setData(ClipboardData(text: pass));
              _toast(context, 'Password copied');
            }),
        ];
      case QrKind.event:
      case QrKind.text:
        return [
          _Primary('Search the web', Icons.search_rounded, () {
            _launch(context,
                'https://www.google.com/search?q=${Uri.encodeComponent(value)}');
          }),
        ];
    }
  }

  String? _wifiField(String key) {
    final m = RegExp('$key:((?:[^;\\\\]|\\\\.)*);').firstMatch(value);
    return m?.group(1)?.replaceAll(RegExp(r'\\(.)'), r'$1');
  }

  Future<void> _launch(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) _toast(context, 'No app available to open this');
    }
  }

  Future<void> _saveContact(BuildContext context) async {
    try {
      final fullName = _vcardField('FN') ?? 'Contact';
      final contact = Contact()
        ..displayName = fullName
        ..name = Name(first: fullName);
      final tel = _vcardField('TEL');
      final email = _vcardField('EMAIL');
      if (tel != null) contact.phones = [Phone(tel)];
      if (email != null) contact.emails = [Email(email)];
      if (await FlutterContacts.requestPermission()) {
        await contact.insert();
        if (context.mounted) _toast(context, 'Contact saved');
      } else if (context.mounted) {
        _toast(context, 'Contacts permission denied');
      }
    } catch (_) {
      if (context.mounted) _toast(context, 'Could not save contact');
    }
  }

  String? _vcardField(String key) {
    final m =
        RegExp('^$key(?:;[^:]*)?:(.*)\$', multiLine: true).firstMatch(value);
    return m?.group(1)?.trim();
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.value, required this.kind});
  final String value;
  final QrKind kind;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 160),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Text(
          _pretty(),
          style: const TextStyle(fontSize: 15, height: 1.4),
        ),
      ),
    );
  }

  String _pretty() {
    if (kind == QrKind.wifi) {
      final s = RegExp(r'S:((?:[^;\\]|\\.)*);').firstMatch(value)?.group(1);
      return 'Network: ${s ?? value}';
    }
    if (kind == QrKind.upi) {
      final uri = Uri.tryParse(value);
      final pa = uri?.queryParameters['pa'];
      final am = uri?.queryParameters['am'];
      final pn = uri?.queryParameters['pn'];
      return [
        if (pn != null) 'Payee: $pn',
        if (pa != null) 'UPI ID: $pa',
        if (am != null) 'Amount: ₹$am',
      ].join('\n');
    }
    return value;
  }
}

class _Primary extends StatelessWidget {
  const _Primary(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
