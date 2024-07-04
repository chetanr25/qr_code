// ignore_for_file: unused_local_variable

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vibration/vibration.dart';

class QR extends StatefulWidget {
  const QR({Key? key}) : super(key: key);

  @override
  State<QR> createState() => _QRState();
}

class _QRState extends State<QR> {
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
// bool permissionGrantedBool = false;

//Requesting permission for camera access and handling the response accordingly
/*
  void permissionGranted() async {
    // await Permission.camera.request();
    var status = await Permission.camera.status;
    print(status);
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          closeIconColor: Colors.white,
          content: Text(
            'Please grant camera permission',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      await Permission.camera.request();
    } else if (status.isGranted) {
      setState(() {
        permissionGrantedBool = true;
      });
    } else if (status.isRestricted ||
        status.isLimited ||
        status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          closeIconColor: Colors.white,
          content: Text(
            'Please grant camera permission from settings',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      await Permission.camera.request();
    }
    if (status.isGranted) {
      setState(() {
        permissionGrantedBool = true;
      });
    }
  }
*/

// Future<bool> permissionCam() async {
//   PermissionStatus p = await Permission.camera.request();
//   if (p.isGranted) {
//     permissionGrantedBool = true;
//     return true;
//   } else {
//     return false;
//   }
//   if (permissionGrantedBool) {
//     return true;
//   } else {
//     return false;
//   }
// }
  bool isProcessingScan = false;
  bool isFlashOn = false;
  bool isBackCamera = true;
  void onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (isProcessingScan) {
        return;
      }
      isProcessingScan = true;
      controller.pauseCamera();
      Vibration.vibrate(duration: 1, amplitude: 1);
      bool isUrl = await canLaunchUrl(
        Uri.parse(scanData.code!),
      );
      if (isUrl || scanData.code!.startsWith('upi')) {
        launchUrl(Uri.parse(scanData.code!),
            mode: LaunchMode.externalApplication);

        // controller.resumeCamera();
        isProcessingScan = false;
        return;
      }
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            content: SingleChildScrollView(
              child: Text(
                scanData.code ?? '',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Clipboard.setData(ClipboardData(text: scanData.code!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Text copied to clipboard'),
                    ),
                  );
                  await controller.resumeCamera();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Copy text'),
              ),
              TextButton(
                onPressed: () async {
                  await controller.resumeCamera();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      isProcessingScan = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    void firstRun() async {
      await controller?.resumeCamera();
      isBackCamera = await controller?.getCameraInfo() == CameraFacing.back;
    }

    @override
    void initState() {
      super.initState();
      firstRun();
      // WidgetsBinding.instance.addObserver(observer);
    }
    // initState() async {
    //   super.initState();

    //   controller?.resumeCamera();
    // }

    // @override
    // initState() {
    //   super.initState();
    // setState(() {
    // controller?.resumeCamera();
    // });
    // permissionGranted();
    // }
    // @override
    // void permissionGranted() async {
    //   var status = await Permission.camera.status;
    //   if (status.isDenied) {
    //     await Permission.camera.request();
    //   }
    // }

    Color blur = Colors.transparent; //const Color.fromARGB(150, 0, 0, 0);
    var width = MediaQuery.of(context).size.width * 0.7;
    var appBarHeight = AppBar().preferredSize.height;
    var bottomNavigationBarHeight = kBottomNavigationBarHeight;
    var safearea = MediaQuery.of(context).padding.top;
    var safeareaBottom = MediaQuery.of(context).padding.bottom;
    // if (!permissionGrantedBool || permissionCam() == false) {
    //   return Scaffold(
    //     body: Center(
    //       child: ElevatedButton(
    //         onPressed: () {
    //           permissionGranted();
    //           permissionGrantedBool = true;
    //         },
    //         child: const Text('Grant Permission'),
    //       ),
    //     ),
    //   );
    // }

    return Scaffold(
        appBar: AppBar(
          title: Container(
            alignment: Alignment.center,
            child: const Row(
              children: [
                Icon(Icons.qr_code_scanner),
                SizedBox(width: 8),
                Text('Scan QR'),
                // ]),
              ],
            ),
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  if (isFlashOn && isBackCamera) {
                    controller?.toggleFlash();
                    setState(() {
                      isFlashOn = !isFlashOn;
                      isBackCamera = !isBackCamera;
                    });
                    controller?.flipCamera();
                    return;
                  }
                  isBackCamera = !isBackCamera;
                  controller?.flipCamera();
                },
                icon: const Icon(Icons.flip_camera_ios_outlined)),
            IconButton(
                onPressed: () async {
                  if (isBackCamera) {
                    controller?.toggleFlash();
                    // isBackCamera = false;
                    setState(() {
                      isFlashOn = !isFlashOn;
                    });
                  } else {
                    // print(e);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Flash not available'),
                      ),
                    );
                    return;
                  }
                },
                icon: Icon(isFlashOn || !isBackCamera
                    ? Icons.flash_off_outlined
                    : Icons.flash_on_rounded)),
            IconButton(
                onPressed: () async {
                  // print(await Connectivity());
                  await controller?.resumeCamera();
                  controller?.resumeCamera();
                  // });
                },
                icon: const Icon(Icons.refresh))
          ],
        ),
        body: GestureDetector(
            onTap: () async {
              controller?.resumeCamera();
              await controller?.resumeCamera();
            },
            onDoubleTap: () async {
              if (isFlashOn && isBackCamera) {
                await controller?.toggleFlash();
                setState(() {
                  isFlashOn = !isFlashOn;
                });
                isBackCamera = !isBackCamera;
                controller?.flipCamera();
                return;
              }
              isBackCamera = !isBackCamera;
              controller?.flipCamera();
              // controller?.toggleFlash();
            },
            child: Stack(
              children: <Widget>[
                QRView(
                  key: qrKey,
                  onQRViewCreated: onQRViewCreated,
                ),
                // ),
                // Container(
                //   alignment: Alignment.topCenter,
                //   height: (MediaQuery.of(context).size.height - width) / 2 -
                //       bottomNavigationBarHeight -
                //       safeareaBottom,
                //   width: width,
                //   child: BackdropFilter(
                //
                //   filter: ImageFilter.blur(
                //       tileMode: TileMode.clamp,
                //       sigmaX: 1,
                //       sigmaY: 1,
                //     ),
                // child: Container(
                //   color: Color.fromARGB(77, 0, 0, 0),
                // ),
                // blendMode: ,
                // ),
                // ),
                // Align(
                //   alignment: Alignment.topCenter,
                //   child: Container(
                //     height: (MediaQuery.of(context).size.height - width) / 2 -
                //         appBarHeight -
                //         safearea,
                //     width: width,
                //     decoration: BoxDecoration(
                //       color: blur,
                //     ),
                //     // color: Colors.black,
                //   ),
                // ),
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: Container(
                //     height: (MediaQuery.of(context).size.height - width) / 2 -
                //         bottomNavigationBarHeight -
                //         safeareaBottom,
                //     width: width,
                //     decoration: BoxDecoration(color: blur),
                //   ),
                // ),
                // Align(
                //   alignment: Alignment.centerLeft,
                //   child: Container(
                //     height: MediaQuery.of(context).size.height,
                //     width: MediaQuery.of(context).size.width * 0.15,
                //     decoration: BoxDecoration(color: blur),
                //   ),
                // ),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: Container(
                //     height: MediaQuery.of(context).size.height,
                //     width: MediaQuery.of(context).size.width * 0.15,
                //     decoration: BoxDecoration(color: blur),
                //   ),
                // ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      // width: double.maxFinite,
                      // color: Colors.black.withAlpha(200),
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        widthFactor: double.minPositive,
                        heightFactor: double.minPositive,
                        child: (result != null)
                            ? Column(
                                // mainAxisSize: MainAxisSize.min,
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    reverse: true,
                                    // controller: controller,

                                    child: Text(
                                      '${result!.code}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'american typewriter',
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 80),
                                ],
                              )
                            : const Text('Scan a code'),
                      )),
                ),
              ],
            )));
  }
}
