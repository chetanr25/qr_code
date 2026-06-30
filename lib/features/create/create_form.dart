import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../core/qr_builders.dart';
import '../../core/qr_kind.dart';
import '../../core/upi.dart';
import '../../widgets/ui_kit.dart';
import 'qr_preview.dart';

class CreateForm extends StatefulWidget {
  const CreateForm({super.key, required this.kind});
  final QrKind kind;

  @override
  State<CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _c = {};

  // Common UPI handles (after the @) shown as quick-fill chips.
  static const _upiHandles = [
    '@oksbi', '@okhdfcbank', '@okicici', '@okaxis', '@ybl', '@paytm', //
    '@apl', '@ibl', '@axl', '@kotak811', '@yapl', '@upi',
  ];

  // type-specific state
  String _wifiEnc = 'WPA';
  bool _wifiHidden = false;
  DateTime _eventStart = DateTime.now().add(const Duration(hours: 1));
  DateTime _eventEnd = DateTime.now().add(const Duration(hours: 2));

  TextEditingController ctrl(String key) =>
      _c.putIfAbsent(key, () => TextEditingController());

  @override
  void initState() {
    super.initState();
    if (widget.kind == QrKind.whatsapp) ctrl('cc').text = '+91';
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickContact({String? phoneKey, bool full = false}) async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      _toast('Contacts permission denied');
      return;
    }
    final picked = await FlutterContacts.openExternalPick();
    if (picked == null) return;
    final contact = await FlutterContacts.getContact(picked.id);
    if (contact == null) return;
    final phone =
        contact.phones.isNotEmpty ? contact.phones.first.number : '';
    setState(() {
      if (phoneKey != null) {
        ctrl(phoneKey).text = phone.replaceAll(RegExp(r'\s'), '');
      }
      if (full) {
        ctrl('name').text = contact.displayName;
        ctrl('phone').text = phone;
        if (contact.emails.isNotEmpty) {
          ctrl('email').text = contact.emails.first.address;
        }
      }
      if (widget.kind == QrKind.upi) {
        ctrl('payee').text = contact.displayName;
      }
    });
  }

  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  String? _buildPayload() {
    switch (widget.kind) {
      case QrKind.url:
        var u = ctrl('url').text.trim();
        if (u.isEmpty) return null;
        if (!u.contains('://')) u = 'https://$u';
        return u;
      case QrKind.text:
        final t = ctrl('text').text.trim();
        return t.isEmpty ? null : t;
      case QrKind.upi:
        final vpa = ctrl('vpa').text.trim();
        if (!Upi.isValidVpa(vpa)) {
          _toast('Enter a valid UPI ID like name@bank');
          return null;
        }
        return QrBuilders.upi(
          vpa: vpa,
          name: ctrl('payee').text.trim(),
          amount: ctrl('amount').text.trim(),
          note: ctrl('note').text.trim(),
        );
      case QrKind.whatsapp:
        final phone = ctrl('phone').text.trim();
        if (phone.isEmpty) return null;
        return QrBuilders.whatsapp(
          countryCode: ctrl('cc').text.trim(),
          phone: phone,
          message: ctrl('msg').text.trim(),
        );
      case QrKind.wifi:
        final ssid = ctrl('ssid').text.trim();
        if (ssid.isEmpty) return null;
        return QrBuilders.wifi(
          ssid: ssid,
          password: ctrl('pass').text,
          encryption: _wifiEnc,
          hidden: _wifiHidden,
        );
      case QrKind.contact:
        final name = ctrl('name').text.trim();
        if (name.isEmpty) return null;
        return QrBuilders.vcard(
          name: name,
          phone: ctrl('phone').text.trim(),
          email: ctrl('email').text.trim(),
          org: ctrl('org').text.trim(),
          title: ctrl('title').text.trim(),
          url: ctrl('curl').text.trim(),
        );
      case QrKind.email:
        final to = ctrl('to').text.trim();
        if (to.isEmpty) return null;
        return QrBuilders.email(
          to: to,
          subject: ctrl('subject').text.trim(),
          body: ctrl('body').text.trim(),
        );
      case QrKind.phone:
        final n = ctrl('phone').text.trim();
        return n.isEmpty ? null : QrBuilders.phone(n);
      case QrKind.sms:
        final n = ctrl('phone').text.trim();
        if (n.isEmpty) return null;
        return QrBuilders.sms(number: n, message: ctrl('msg').text.trim());
      case QrKind.geo:
        final lat = double.tryParse(ctrl('lat').text.trim());
        final lng = double.tryParse(ctrl('lng').text.trim());
        if (lat == null || lng == null) return null;
        return QrBuilders.geo(
            lat: lat, lng: lng, label: ctrl('label').text.trim());
      case QrKind.event:
        final t = ctrl('etitle').text.trim();
        if (t.isEmpty) return null;
        return QrBuilders.event(
          title: t,
          location: ctrl('eloc').text.trim(),
          description: ctrl('edesc').text.trim(),
          start: _eventStart,
          end: _eventEnd,
        );
    }
  }

  void _generate() {
    final payload = _buildPayload();
    if (payload == null) {
      _toast('Please fill in the required field');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QrPreview(data: payload, kind: widget.kind),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(widget.kind.label)),
      body: AuroraBackground(
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: [
                _typeHeader(),
                const SizedBox(height: 22),
                ..._fields(),
                const SizedBox(height: 28),
                GradientButton(
                  label: 'Generate QR',
                  icon: Icons.qr_code_2_rounded,
                  onPressed: _generate,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _typeHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.kind.color, widget.kind.color.withValues(alpha: 0.6)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(widget.kind.icon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'Enter details for your ${widget.kind.label.toLowerCase()} QR code',
            style: TextStyle(
              fontSize: 14,
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _fields() {
    switch (widget.kind) {
      case QrKind.url:
        return [
          _field('url', 'Website URL', hint: 'example.com',
              keyboard: TextInputType.url)
        ];
      case QrKind.text:
        return [_field('text', 'Text', maxLines: 5)];
      case QrKind.upi:
        return _upiFields();
      case QrKind.whatsapp:
        return [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 92,
                child: _field('cc', 'Code',
                    keyboard: TextInputType.phone, paste: false),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field('phone', 'Phone number',
                    hint: 'without leading 0',
                    keyboard: TextInputType.phone),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _contactButton(
              'Pick from contacts', () => _pickContact(phoneKey: 'phone')),
          const SizedBox(height: 14),
          _field('msg', 'Message (optional)', maxLines: 3),
          const SizedBox(height: 10),
          _hintBox(
              'Opens a WhatsApp chat with a pre-filled message. Country code defaults to +91 (India) — change it for other countries.'),
        ];
      case QrKind.wifi:
        return [
          _field('ssid', 'Network name (SSID)'),
          const SizedBox(height: 14),
          if (_wifiEnc != 'nopass')
            _field('pass', 'Password', obscure: true),
          if (_wifiEnc != 'nopass') const SizedBox(height: 14),
          SectionLabel('Encryption', icon: Icons.lock_rounded),
          Wrap(
            spacing: 8,
            children: [
              for (final e in ['WPA', 'WEP', 'nopass'])
                ChoiceChip(
                  label: Text(e == 'nopass' ? 'None' : e),
                  selected: _wifiEnc == e,
                  onSelected: (_) => setState(() => _wifiEnc = e),
                ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Hidden network'),
            value: _wifiHidden,
            onChanged: (v) => setState(() => _wifiHidden = v),
          ),
        ];
      case QrKind.contact:
        return [
          _contactButton(
              'Import from contacts', () => _pickContact(full: true)),
          const SizedBox(height: 14),
          _field('name', 'Full name'),
          const SizedBox(height: 14),
          _field('phone', 'Phone', keyboard: TextInputType.phone),
          const SizedBox(height: 14),
          _field('email', 'Email', keyboard: TextInputType.emailAddress),
          const SizedBox(height: 14),
          _field('org', 'Organization (optional)'),
          const SizedBox(height: 14),
          _field('title', 'Job title (optional)'),
          const SizedBox(height: 14),
          _field('curl', 'Website (optional)'),
        ];
      case QrKind.email:
        return [
          _field('to', 'Recipient email',
              keyboard: TextInputType.emailAddress),
          const SizedBox(height: 14),
          _field('subject', 'Subject (optional)'),
          const SizedBox(height: 14),
          _field('body', 'Message (optional)', maxLines: 4),
        ];
      case QrKind.phone:
        return [
          _contactButton('Pick from contacts',
              () => _pickContact(phoneKey: 'phone')),
          const SizedBox(height: 14),
          _field('phone', 'Phone number', keyboard: TextInputType.phone),
        ];
      case QrKind.sms:
        return [
          _contactButton('Pick from contacts',
              () => _pickContact(phoneKey: 'phone')),
          const SizedBox(height: 14),
          _field('phone', 'Phone number', keyboard: TextInputType.phone),
          const SizedBox(height: 14),
          _field('msg', 'Message (optional)', maxLines: 3),
        ];
      case QrKind.geo:
        return [
          _field('lat', 'Latitude',
              keyboard:
                  const TextInputType.numberWithOptions(decimal: true, signed: true)),
          const SizedBox(height: 14),
          _field('lng', 'Longitude',
              keyboard:
                  const TextInputType.numberWithOptions(decimal: true, signed: true)),
          const SizedBox(height: 14),
          _field('label', 'Label (optional)'),
        ];
      case QrKind.event:
        return [
          _field('etitle', 'Event title'),
          const SizedBox(height: 14),
          _field('eloc', 'Location (optional)'),
          const SizedBox(height: 14),
          _field('edesc', 'Description (optional)', maxLines: 3),
          const SizedBox(height: 14),
          _dateRow('Starts', _eventStart, (d) => setState(() {
                _eventStart = d;
                if (_eventEnd.isBefore(d)) {
                  _eventEnd = d.add(const Duration(hours: 1));
                }
              })),
          _dateRow('Ends', _eventEnd, (d) => setState(() => _eventEnd = d)),
        ];
    }
  }

  List<Widget> _upiFields() {
    final vpa = ctrl('vpa').text.trim();
    final hasInput = vpa.isNotEmpty;
    final ok = Upi.isValidVpa(vpa);
    return [
      _field(
        'vpa',
        'UPI ID',
        hint: 'name@bank  ·  9876543210@ybl',
        keyboard: TextInputType.text,
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 12),
      _upiFormatPill(hasInput, ok),
      const SizedBox(height: 16),
      const SectionLabel('Quick bank handles', icon: Icons.alternate_email_rounded),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final h in _upiHandles)
            ActionChip(
              label: Text(h),
              onPressed: () => _applyUpiHandle(h),
            ),
        ],
      ),
      const SizedBox(height: 16),
      _field('payee', 'Payee name (optional)'),
      const SizedBox(height: 14),
      _field('amount', 'Amount ₹ (optional)',
          keyboard: const TextInputType.numberWithOptions(decimal: true)),
      const SizedBox(height: 14),
      _field('note', 'Note (optional)'),
      const SizedBox(height: 10),
      _hintBox(
          'Enter the payee\'s real UPI ID — the name@bank they see in their UPI app — or scan their UPI QR from the Scan tab. Tap a handle to set the part after @.'),
    ];
  }

  /// Sets the bank handle on the UPI field, replacing anything after an
  /// existing @ (does not append a second @).
  void _applyUpiHandle(String handle) {
    final c = ctrl('vpa');
    final at = c.text.indexOf('@');
    final base = at >= 0 ? c.text.substring(0, at) : c.text;
    final next = '$base$handle';
    c.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    setState(() {});
  }

  Widget _upiFormatPill(bool hasInput, bool ok) {
    final scheme = Theme.of(context).colorScheme;
    final color = !hasInput
        ? scheme.onSurface.withValues(alpha: 0.4)
        : (ok ? const Color(0xFF10B981) : const Color(0xFFEF4444));
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            !hasInput
                ? Icons.info_outline_rounded
                : (ok ? Icons.check_circle_rounded : Icons.error_rounded),
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              !hasInput
                  ? 'Enter a UPI ID like name@bank'
                  : (ok
                      ? 'Format OK — make sure it\'s the payee\'s real UPI ID'
                      : 'Bad format — should look like name@bank'),
              style: TextStyle(
                  fontSize: 12.5, color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String key,
    String label, {
    String? hint,
    int maxLines = 1,
    bool obscure = false,
    TextInputType? keyboard,
    ValueChanged<String>? onChanged,
    bool paste = true,
  }) {
    return TextFormField(
      controller: ctrl(key),
      maxLines: obscure ? 1 : maxLines,
      obscureText: obscure,
      keyboardType: keyboard,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: paste
            ? IconButton(
                tooltip: 'Paste',
                icon: const Icon(Icons.content_paste_rounded, size: 20),
                onPressed: () => _pasteInto(key, onChanged),
              )
            : null,
      ),
    );
  }

  Future<void> _pasteInto(String key, ValueChanged<String>? onChanged) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return;
    final c = ctrl(key);
    c.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    onChanged?.call(text);
    setState(() {});
  }

  Widget _contactButton(String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.contacts_rounded),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _hintBox(String text) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded,
              size: 18, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12.5,
                    color: scheme.onSurface.withValues(alpha: 0.75))),
          ),
        ],
      ),
    );
  }

  Widget _dateRow(String label, DateTime value, ValueChanged<DateTime> onPick) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(
        '${value.day}/${value.month}/${value.year}  '
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
      ),
      trailing: const Icon(Icons.edit_calendar_rounded),
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        );
        if (d == null || !mounted) return;
        final t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value),
        );
        if (t == null) return;
        onPick(DateTime(d.year, d.month, d.day, t.hour, t.minute));
      },
    );
  }
}