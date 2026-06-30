import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

import '../../core/history_store.dart';
import '../../core/qr_kind.dart';
import 'scan_overlay.dart';
import 'result_sheet.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, this.onMenu});

  /// Opens the app drawer (provided by [HomeShell]).
  final VoidCallback? onMenu;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  bool _sheetOpen = false;
  bool _picking = false;

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
    // Don't fight the camera while the gallery picker or a result sheet is up.
    if (_picking || _sheetOpen) return;
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
    try {
      _picking = true;
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      final result = await _controller.analyzeImage(picked.path);
      final raw = result?.barcodes.firstOrNull?.rawValue;
      if (raw == null || raw.isEmpty) {
        _snack('No QR code found in that image');
        return;
      }
      await _handleResult(raw);
    } catch (_) {
      _snack('Could not scan that image');
    } finally {
      _picking = false;
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ValueListenableBuilder<MobileScannerState>(
        valueListenable: _controller,
        builder: (context, state, _) {
          // No camera / permission denied: show a full-screen message only,
          // with no scanner preview or controls. The bottom nav (owned by
          // HomeShell) is unaffected.
          if (state.error != null) {
            return _PermissionView(
              error: state.error!,
              onMenu: widget.onMenu,
              onRetry: () => _controller.start(),
              onOpenSettings: openAppSettings,
            );
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(controller: _controller, onDetect: _onDetect),
              const ScanOverlay(),
              _topBar(context),
              _bottomControls(context),
            ],
          );
        },
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.55),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _GlassIconButton(
                      icon: Icons.menu_rounded,
                      onTap: widget.onMenu,
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Scan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                _flashButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _flashButton() {
    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: _controller,
      builder: (context, state, _) {
        final unavailable = state.torchState == TorchState.unavailable;
        final on = state.torchState == TorchState.on;
        return _GlassIconButton(
          icon: on ? Icons.flash_on_rounded : Icons.flash_off_rounded,
          active: on,
          disabled: unavailable,
          onTap: unavailable ? null : () => _controller.toggleTorch(),
        );
      },
    );
  }

  Widget _bottomControls(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          // sit just above the floating bottom nav bar (HomeShell)
          padding: const EdgeInsets.only(bottom: 78),
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
    this.disabled = false,
  });
  final IconData icon;
  final VoidCallback? onTap;
  final bool active;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final Color bg = disabled
        ? Colors.white.withValues(alpha: 0.08)
        : active
            ? Colors.amber.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.18);
    final Color fg = disabled
        ? Colors.white.withValues(alpha: 0.35)
        : active
            ? Colors.black
            : Colors.white;
    return Stack(
      alignment: Alignment.center,
      children: [
        Material(
          color: bg,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: disabled ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: fg, size: 24),
            ),
          ),
        ),
        // diagonal "not available" slash when there is no torch
        if (disabled)
          IgnorePointer(
            child: Transform.rotate(
              angle: 0.785398, // 45°
              child: Container(
                width: 30,
                height: 2,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ),
      ],
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

/// Full-screen state shown when the camera can't run (permission denied or
/// no camera). Replaces the scanner entirely; the bottom nav stays untouched.
class _PermissionView extends StatelessWidget {
  const _PermissionView({
    required this.error,
    required this.onRetry,
    required this.onOpenSettings,
    this.onMenu,
  });

  final MobileScannerException error;
  final VoidCallback onRetry;
  final Future<bool> Function() onOpenSettings;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isPermission =
        error.errorCode == MobileScannerErrorCode.permissionDenied;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 0, 0),
              child: IconButton.filledTonal(
                onPressed: onMenu,
                icon: const Icon(Icons.menu_rounded),
                style: IconButton.styleFrom(
                  backgroundColor:
                      scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPermission
                          ? Icons.no_photography_rounded
                          : Icons.videocam_off_rounded,
                      color: scheme.primary,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isPermission
                        ? 'Camera access needed'
                        : 'Camera unavailable',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isPermission
                        ? 'Qrly needs camera permission to scan QR codes. Grant it to continue, or import an image from your gallery instead.'
                        : 'No camera is available on this device. You can still create QR codes, or scan from a saved image.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.4,
                      color: scheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (isPermission) ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.lock_open_rounded),
                        label: const Text('Grant permission'),
                        style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => onOpenSettings(),
                        icon: const Icon(Icons.settings_rounded),
                        label: const Text('Open settings'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
