import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'controllers/scanner_controller.dart';
import 'widgets/scanner_controls.dart';
import 'widgets/scanner_overlay.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final ScannerController _scannerController = ScannerController();

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: Stack(
        children: [
          QRView(
            key: _scannerController.qrKey,
            onQRViewCreated: (controller) =>
                _scannerController.onQRViewCreated(controller, context),
          ),
          const ScannerOverlay(),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: ScannerControls(
              controller: _scannerController,
              onRefresh: () => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }
}
