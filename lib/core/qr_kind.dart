import 'package:flutter/material.dart';

/// Categories a QR payload can fall into (used for both create + scan).
enum QrKind {
  url,
  upi,
  wifi,
  contact,
  email,
  phone,
  sms,
  geo,
  event,
  text;

  String get label => switch (this) {
        QrKind.url => 'Link / URL',
        QrKind.upi => 'UPI Payment',
        QrKind.wifi => 'Wi-Fi',
        QrKind.contact => 'Contact',
        QrKind.email => 'Email',
        QrKind.phone => 'Phone',
        QrKind.sms => 'SMS',
        QrKind.geo => 'Location',
        QrKind.event => 'Event',
        QrKind.text => 'Text',
      };

  IconData get icon => switch (this) {
        QrKind.url => Icons.link_rounded,
        QrKind.upi => Icons.currency_rupee_rounded,
        QrKind.wifi => Icons.wifi_rounded,
        QrKind.contact => Icons.person_rounded,
        QrKind.email => Icons.alternate_email_rounded,
        QrKind.phone => Icons.call_rounded,
        QrKind.sms => Icons.sms_rounded,
        QrKind.geo => Icons.location_on_rounded,
        QrKind.event => Icons.event_rounded,
        QrKind.text => Icons.text_fields_rounded,
      };

  /// Accent colour for tiles/badges per kind.
  Color get color => switch (this) {
        QrKind.url => const Color(0xFF3B82F6),
        QrKind.upi => const Color(0xFF10B981),
        QrKind.wifi => const Color(0xFF6366F1),
        QrKind.contact => const Color(0xFFF59E0B),
        QrKind.email => const Color(0xFFEF4444),
        QrKind.phone => const Color(0xFF06B6D4),
        QrKind.sms => const Color(0xFF8B5CF6),
        QrKind.geo => const Color(0xFFEC4899),
        QrKind.event => const Color(0xFF14B8A6),
        QrKind.text => const Color(0xFF64748B),
      };
}

/// Detect what a scanned/typed string represents.
QrKind detectKind(String raw) {
  final v = raw.trim();
  final lower = v.toLowerCase();
  if (lower.startsWith('upi://') || lower.startsWith('upi:')) return QrKind.upi;
  if (lower.startsWith('wifi:')) return QrKind.wifi;
  if (lower.startsWith('begin:vcard') || lower.startsWith('mecard:')) {
    return QrKind.contact;
  }
  if (lower.startsWith('begin:vevent') || lower.startsWith('begin:vcalendar')) {
    return QrKind.event;
  }
  if (lower.startsWith('mailto:') || lower.startsWith('matmsg:')) {
    return QrKind.email;
  }
  if (lower.startsWith('tel:')) return QrKind.phone;
  if (lower.startsWith('smsto:') || lower.startsWith('sms:')) return QrKind.sms;
  if (lower.startsWith('geo:')) return QrKind.geo;
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return QrKind.url;
  }
  // bare domain heuristic e.g. example.com
  final domain = RegExp(r'^[\w-]+(\.[\w-]+)+(/.*)?$');
  if (!v.contains(' ') && domain.hasMatch(v)) return QrKind.url;
  return QrKind.text;
}
