/// Builds standards-compliant QR payload strings from structured input.
class QrBuilders {
  /// UPI deep link: `upi://pay?pa=<vpa>&pn=<name>&am=<amount>&cu=INR&tn=<note>`
  static String upi({
    required String vpa,
    String? name,
    String? amount,
    String? note,
  }) {
    final params = <String, String>{'pa': vpa};
    if (name != null && name.isNotEmpty) params['pn'] = name;
    if (amount != null && amount.isNotEmpty) params['am'] = amount;
    params['cu'] = 'INR';
    if (note != null && note.isNotEmpty) params['tn'] = note;
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return 'upi://pay?$query';
  }

  /// Wi-Fi: `WIFI:T:WPA;S:<ssid>;P:<password>;H:<true|false>;;`
  static String wifi({
    required String ssid,
    String password = '',
    String encryption = 'WPA', // WPA | WEP | nopass
    bool hidden = false,
  }) {
    String esc(String s) => s.replaceAllMapped(
        RegExp(r'([\\;,:"])'), (m) => '\\${m.group(1)}');
    final buf = StringBuffer('WIFI:T:$encryption;S:${esc(ssid)};');
    if (encryption != 'nopass') buf.write('P:${esc(password)};');
    buf.write('H:${hidden ? 'true' : 'false'};;');
    return buf.toString();
  }

  /// vCard 3.0 contact card.
  static String vcard({
    required String name,
    String? phone,
    String? email,
    String? org,
    String? title,
    String? url,
  }) {
    final buf = StringBuffer('BEGIN:VCARD\nVERSION:3.0\n');
    buf.write('N:$name\nFN:$name\n');
    if (org != null && org.isNotEmpty) buf.write('ORG:$org\n');
    if (title != null && title.isNotEmpty) buf.write('TITLE:$title\n');
    if (phone != null && phone.isNotEmpty) buf.write('TEL;TYPE=CELL:$phone\n');
    if (email != null && email.isNotEmpty) buf.write('EMAIL:$email\n');
    if (url != null && url.isNotEmpty) buf.write('URL:$url\n');
    buf.write('END:VCARD');
    return buf.toString();
  }

  static String email({required String to, String? subject, String? body}) {
    final params = <String, String>{};
    if (subject != null && subject.isNotEmpty) params['subject'] = subject;
    if (body != null && body.isNotEmpty) params['body'] = body;
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return query.isEmpty ? 'mailto:$to' : 'mailto:$to?$query';
  }

  static String phone(String number) => 'tel:$number';

  /// WhatsApp click-to-chat: `https://wa.me/<countrycode><number>?text=<msg>`.
  /// Both [countryCode] and [phone] are reduced to digits (no +, spaces, 0s).
  static String whatsapp({
    required String countryCode,
    required String phone,
    String? message,
  }) {
    final cc = countryCode.replaceAll(RegExp(r'\D'), '');
    var p = phone.replaceAll(RegExp(r'\D'), '');
    p = p.replaceFirst(RegExp(r'^0+'), ''); // drop leading national-trunk zeros
    final base = 'https://wa.me/$cc$p';
    return (message == null || message.isEmpty)
        ? base
        : '$base?text=${Uri.encodeComponent(message)}';
  }

  static String sms({required String number, String? message}) =>
      (message == null || message.isEmpty)
          ? 'smsto:$number'
          : 'smsto:$number:$message';

  static String geo({required double lat, required double lng, String? label}) {
    final base = 'geo:$lat,$lng';
    return label == null || label.isEmpty
        ? base
        : '$base?q=$lat,$lng(${Uri.encodeComponent(label)})';
  }

  /// iCalendar VEVENT.
  static String event({
    required String title,
    String? location,
    String? description,
    required DateTime start,
    required DateTime end,
  }) {
    String fmt(DateTime d) {
      final u = d.toUtc();
      String p(int n) => n.toString().padLeft(2, '0');
      return '${u.year}${p(u.month)}${p(u.day)}T${p(u.hour)}${p(u.minute)}${p(u.second)}Z';
    }

    final buf = StringBuffer('BEGIN:VEVENT\n');
    buf.write('SUMMARY:$title\n');
    if (location != null && location.isNotEmpty) {
      buf.write('LOCATION:$location\n');
    }
    if (description != null && description.isNotEmpty) {
      buf.write('DESCRIPTION:$description\n');
    }
    buf.write('DTSTART:${fmt(start)}\nDTEND:${fmt(end)}\nEND:VEVENT');
    return buf.toString();
  }
}
