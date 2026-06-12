import 'package:flutter/material.dart';
import '../controllers/scanner_controller.dart';

class ScannerControls extends StatelessWidget {
  final ScannerController controller;
  final VoidCallback onRefresh;

  const ScannerControls({
    Key? key,
    required this.controller,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            controller.isFlashOn ? Icons.flash_off : Icons.flash_on,
            color: Colors.white,
          ),
          onPressed: controller.toggleFlash,
        ),
        IconButton(
          icon: const Icon(
            Icons.flip_camera_ios,
            color: Colors.white,
          ),
          onPressed: controller.toggleCamera,
        ),
        IconButton(
          icon: const Icon(
            Icons.refresh,
            color: Colors.white,
          ),
          onPressed: onRefresh,
        ),
      ],
    );
  }
}
