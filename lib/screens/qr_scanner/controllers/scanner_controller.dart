import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

class ScannerController {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isProcessingScan = false;
  bool isFlashOn = false;
  bool isBackCamera = true;

  void onQRViewCreated(QRViewController controller, BuildContext context) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      await _handleScannedData(scanData, context);
    });
  }

  Future<void> _handleScannedData(
      Barcode scanData, BuildContext context) async {
    if (isProcessingScan) return;

    isProcessingScan = true;
    controller?.pauseCamera();
    await Vibration.vibrate(duration: 1, amplitude: 1);

    if (scanData.code == null) {
      isProcessingScan = false;
      return;
    }

    bool isUrl = await canLaunchUrl(Uri.parse(scanData.code!));
    if (isUrl || scanData.code!.startsWith('upi')) {
      await launchUrl(
        Uri.parse(scanData.code!),
        mode: LaunchMode.externalApplication,
      );
      isProcessingScan = false;
      return;
    }

    await _showResultDialog(context, scanData.code!);
    isProcessingScan = false;
  }

  Future<void> _showResultDialog(BuildContext context, String code) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        content: SingleChildScrollView(
          child: Text(
            code,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await controller?.resumeCamera();
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> toggleFlash() async {
    if (isBackCamera) {
      await controller?.toggleFlash();
      isFlashOn = !isFlashOn;
    }
  }

  Future<void> toggleCamera() async {
    await controller?.flipCamera();
    isBackCamera = !isBackCamera;
    if (isFlashOn) {
      isFlashOn = false;
      await controller?.toggleFlash();
    }
  }

  void dispose() {
    controller?.dispose();
  }
}
