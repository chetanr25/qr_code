import 'package:flutter/material.dart';

/// Categories a QR payload can fall into (used for both create + scan).
enum QrKind {
  url,
  upi,
  whatsapp,
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
        QrKind.whatsapp => 'WhatsApp',
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
        QrKind.whatsapp => Icons.chat_rounded,
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
        QrKind.whatsapp => const Color(0xFF25D366),
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

/// Canonical default order of types shown on the Create screen.
const List<QrKind> kCreateKinds = [
  QrKind.url,
  QrKind.upi,
  QrKind.whatsapp,
  QrKind.wifi,
  QrKind.contact,
  QrKind.text,
  QrKind.email,
  QrKind.phone,
  QrKind.sms,
  QrKind.geo,
  QrKind.event,
];

/// Detect what a scanned/typed string represents.
QrKind detectKind(String raw) {
  final v = raw.trim();
  final lower = v.toLowerCase();
  if (lower.startsWith('upi://') || lower.startsWith('upi:')) return QrKind.upi;
  if (lower.contains('wa.me/') ||
      lower.contains('api.whatsapp.com') ||
      lower.contains('whatsapp.com/send')) {
    return QrKind.whatsapp;
  }
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

/// A short, human-meaningful caption derived from a QR payload e.g. the
/// Wi-Fi network name, the contact's name, or a shortened URL. Used as the
/// label printed under the QR image.
String qrCaption(QrKind kind, String data) {
  String firstGroup(RegExp re, [String fallback = '']) =>
      re.firstMatch(data)?.group(1)?.trim() ?? fallback;

  switch (kind) {
    case QrKind.url:
      var s = data
          .trim()
          .replaceFirst(RegExp(r'^https?://', caseSensitive: false), '');
      s = s.replaceFirst(RegExp(r'^www\.', caseSensitive: false), '');
      if (s.endsWith('/')) s = s.substring(0, s.length - 1);
      return s;
    case QrKind.wifi:
      final ssid = firstGroup(RegExp(r'S:((?:[^;\\]|\\.)*);'));
      return (ssid.isEmpty
          ? 'Wi-Fi'
          : ssid.replaceAll(RegExp(r'\\(.)'), r'$1'));
    case QrKind.upi:
      final uri = Uri.tryParse(data);
      return uri?.queryParameters['pn'] ??
          uri?.queryParameters['pa'] ??
          'UPI Payment';
    case QrKind.whatsapp:
      final n = firstGroup(RegExp(r'wa\.me/(\d+)'));
      return n.isEmpty ? 'WhatsApp' : '+$n';
    case QrKind.contact:
      return firstGroup(RegExp(r'^FN:(.*)$', multiLine: true), 'Contact');
    case QrKind.email:
      return data
          .replaceFirst(RegExp(r'^mailto:', caseSensitive: false), '')
          .split('?')
          .first;
    case QrKind.phone:
      return data.replaceFirst(RegExp(r'^tel:', caseSensitive: false), '');
    case QrKind.sms:
      return data
          .replaceFirst(RegExp(r'^smsto:', caseSensitive: false), '')
          .split(':')
          .first;
    case QrKind.geo:
      final label = firstGroup(RegExp(r'\(([^)]+)\)'));
      if (label.isNotEmpty) return Uri.decodeComponent(label);
      return data
          .replaceFirst(RegExp(r'^geo:', caseSensitive: false), '')
          .split('?')
          .first;
    case QrKind.event:
      return firstGroup(RegExp(r'^SUMMARY:(.*)$', multiLine: true), 'Event');
    case QrKind.text:
      return data;
  }
}
