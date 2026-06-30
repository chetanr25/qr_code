import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';

import '../../core/history_store.dart';
import '../../core/qr_kind.dart';
import 'scan_overlay.dart';
import 'result_sheet.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  bool _torchOn = false;
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.hasCameraPermission) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _controller.start();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _controller.stop();
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_sheetOpen) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    await _handleResult(raw);
  }

  Future<void> _handleResult(String raw) async {
    _sheetOpen = true;
    await _controller.stop();
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 40);
    }
    final kind = detectKind(raw);
    await HistoryStore.instance.add(raw, kind, 'scan');
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ResultSheet(value: raw, kind: kind),
    );
    _sheetOpen = false;
    await _controller.start();
  }

  Future<void> _scanFromGallery() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final result = await _controller.analyzeImage(picked.path);
    final raw = result?.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No QR code found in that image')),
      );
      return;
    }
    await _handleResult(raw);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => _ScanError(error: error),
          ),
          const ScanOverlay(),
          _topBar(context),
          _bottomControls(context),
        ],
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Scan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            _GlassIconButton(
              icon: _torchOn
                  ? Icons.flash_on_rounded
                  : Icons.flash_off_rounded,
              active: _torchOn,
              onTap: () async {
                await _controller.toggleTorch();
                setState(() => _torchOn = !_torchOn);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomControls(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 96),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionPill(
                icon: Icons.image_rounded,
                label: 'Gallery',
                onTap: _scanFromGallery,
              ),
              const SizedBox(width: 16),
              _ActionPill(
                icon: Icons.cameraswitch_rounded,
                label: 'Flip',
                onTap: () => _controller.switchCamera(),
              ),
              const SizedBox(width: 16),
              _ActionPill(
                icon: Icons.content_paste_rounded,
                label: 'Paste',
                onTap: () async {
                  final data = await Clipboard.getData('text/plain');
                  final text = data?.text?.trim();
                  if (text == null || text.isEmpty) return;
                  await _handleResult(text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active
          ? Colors.amber.withValues(alpha: 0.9)
          : Colors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon,
              color: active ? Colors.black : Colors.white, size: 24),
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanError extends StatelessWidget {
  const _ScanError({required this.error});
  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final isPermission =
        error.errorCode == MobileScannerErrorCode.permissionDenied;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPermission ? Icons.no_photography_rounded : Icons.error_outline,
              color: Colors.white70,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              isPermission
                  ? 'Camera permission denied.\nEnable it in Settings to scan.'
                  : 'Camera unavailable on this device.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
