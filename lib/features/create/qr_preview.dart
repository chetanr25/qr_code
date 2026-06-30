import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_prefs.dart';
import '../../core/gradients.dart';
import '../../core/history_store.dart';
import '../../core/qr_kind.dart';
import '../../widgets/ui_kit.dart';

class QrPreview extends StatefulWidget {
  const QrPreview({super.key, required this.data, required this.kind});
  final String data;
  final QrKind kind;

  @override
  State<QrPreview> createState() => _QrPreviewState();
}

class _QrPreviewState extends State<QrPreview> {
  final _cardShot = ScreenshotController();
  final _qrShot = ScreenshotController();

  late String _gradient = AppPrefs.instance.gradientName.value;
  Color _fg = Colors.black;
  int _shape = 0; // 0 square, 1 circle, 2 rounded -> see mapping
  String _logoPath = '';
  bool _saved = false;
  bool _showLabel = true;
  late final TextEditingController _labelCtrl =
      TextEditingController(text: qrCaption(widget.kind, widget.data));

  static const _fgColors = [
    Colors.black,
    Color(0xFF1E3A8A),
    Color(0xFF7C3AED),
    Color(0xFFBE123C),
    Color(0xFF065F46),
    Color(0xFF7C2D12),
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    HistoryStore.instance.add(widget.data, widget.kind, 'create');
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  QrEyeShape get _eyeShape =>
      _shape == 1 ? QrEyeShape.circle : QrEyeShape.square;
  QrDataModuleShape get _moduleShape =>
      _shape == 0 ? QrDataModuleShape.square : QrDataModuleShape.circle;

  Future<void> _pickLogo() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (f == null) return;
    setState(() => _logoPath = f.path);
  }

  Future<void> _save({required bool withBackground}) async {
    final controller = withBackground ? _cardShot : _qrShot;
    final bytes = await controller.capture();
    if (bytes == null) return;
    await ImageGallerySaverPlus.saveImage(bytes,
        name: 'qrly_${DateTime.now().millisecondsSinceEpoch}');
    setState(() => _saved = true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to gallery')),
    );
  }

  Future<void> _share({required bool withBackground}) async {
    final controller = withBackground ? _cardShot : _qrShot;
    final bytes = await controller.capture();
    if (bytes == null) return;
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/qrly_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(path).writeAsBytes(bytes);
    await Share.shareXFiles([XFile(path)], subject: 'QR Code');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Your QR'),
        actions: [
          IconButton(
            onPressed: () => _chooseFormatSheet(share: true),
            icon: const Icon(Icons.share_rounded),
          ),
          IconButton(
            onPressed: () => _chooseFormatSheet(share: false),
            icon: Icon(
                _saved ? Icons.check_circle_rounded : Icons.download_rounded),
          ),
        ],
      ),
      body: AuroraBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              Center(child: _qrCard()),
              const SizedBox(height: 28),
              SectionLabel('Background', icon: Icons.gradient_rounded),
              _gradientStrip(),
              const SizedBox(height: 20),
              SectionLabel('Module colour', icon: Icons.palette_rounded),
              _colorStrip(),
              const SizedBox(height: 20),
              SectionLabel('Style', icon: Icons.category_rounded),
              _shapeChips(),
              const SizedBox(height: 20),
              SectionLabel('Label', icon: Icons.label_rounded),
              _labelToggle(),
              const SizedBox(height: 20),
              SectionLabel('Logo', icon: Icons.image_rounded),
              _logoRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qrCard() {
    return Screenshot(
      controller: _cardShot,
      child: Container(
        width: 300,
        height: 360,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppGradients.of(_gradient),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppGradients.colorsFor(_gradient)
                  .first
                  .withValues(alpha: 0.5),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Screenshot(
              controller: _qrShot,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: QrImageView(
                  data: widget.data,
                  version: QrVersions.auto,
                  size: 210,
                  backgroundColor: Colors.white,
                  eyeStyle: QrEyeStyle(
                    eyeShape: _eyeShape,
                    color: _fg,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: _moduleShape,
                    color: _fg,
                  ),
                  embeddedImage:
                      _logoPath.isNotEmpty ? FileImage(File(_logoPath)) : null,
                  embeddedImageStyle:
                      const QrEmbeddedImageStyle(size: Size(54, 54)),
                  embeddedImageEmitsError: true,
                ),
              ),
            ),
            if (_showLabel && _labelCtrl.text.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.kind.icon, color: Colors.white, size: 17),
                    const SizedBox(width: 7),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _labelCtrl.text.trim(),
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _gradientStrip() {
    final names = AppGradients.presets.keys.toList();
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: names.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final name = names[i];
          final selected = name == _gradient;
          return GestureDetector(
            onTap: () {
              setState(() => _gradient = name);
              AppPrefs.instance.setGradient(name);
            },
            child: Container(
              width: 56,
              decoration: BoxDecoration(
                gradient: AppGradients.of(name),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? Colors.white : Colors.transparent,
                  width: 3,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppGradients.colorsFor(name)
                              .first
                              .withValues(alpha: 0.6),
                          blurRadius: 12,
                        )
                      ]
                    : null,
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _colorStrip() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final c in _fgColors)
          GestureDetector(
            onTap: () => setState(() => _fg = c),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _fg == c
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.withValues(alpha: 0.3),
                  width: _fg == c ? 3 : 1,
                ),
              ),
              child: _fg == c
                  ? Icon(Icons.check,
                      size: 18,
                      color: c == Colors.white ? Colors.black : Colors.white)
                  : null,
            ),
          ),
      ],
    );
  }

  Widget _shapeChips() {
    const labels = ['Square', 'Rounded', 'Dots'];
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          ChoiceChip(
            label: Text(labels[i]),
            selected: _shape == i,
            onSelected: (_) => setState(() => _shape = i),
          ),
          if (i < labels.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _labelToggle() {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 12),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            title: const Text('Show label on QR',
                style: TextStyle(fontWeight: FontWeight.w600)),
            value: _showLabel,
            onChanged: (v) => setState(() => _showLabel = v),
          ),
          if (_showLabel)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _labelCtrl,
                onChanged: (_) => setState(() {}),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Label text',
                  suffixIcon: IconButton(
                    tooltip: 'Reset to default',
                    icon: const Icon(Icons.restart_alt_rounded, size: 20),
                    onPressed: () => setState(() {
                      _labelCtrl.text = qrCaption(widget.kind, widget.data);
                    }),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _logoRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickLogo,
            icon: Icon(_logoPath.isEmpty
                ? Icons.add_photo_alternate_rounded
                : Icons.check_circle_rounded),
            label: Text(_logoPath.isEmpty ? 'Embed a logo' : 'Logo added'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        if (_logoPath.isNotEmpty) ...[
          const SizedBox(width: 10),
          IconButton.filledTonal(
            onPressed: () => setState(() => _logoPath = ''),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ],
    );
  }

  void _chooseFormatSheet({required bool share}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                share ? 'Share as' : 'Save as',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: const Icon(Icons.gradient_rounded),
                title: const Text('With background'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                tileColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.4),
                onTap: () {
                  Navigator.pop(context);
                  share
                      ? _share(withBackground: true)
                      : _save(withBackground: true);
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.qr_code_2_rounded),
                title: const Text('QR code only'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                tileColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.4),
                onTap: () {
                  Navigator.pop(context);
                  share
                      ? _share(withBackground: false)
                      : _save(withBackground: false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
