// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenerateQR extends StatefulWidget {
  const GenerateQR({
    super.key,
    required this.data,
    this.imagePath = '',
    this.eyeShape = 0,
    this.dataModuleColor = Colors.black,
    this.eyeStyle,
  });
  final String data;
  final String? imagePath;
  final int? eyeShape;
  final Color? dataModuleColor;
  final QrEyeStyle? eyeStyle;

  @override
  State<GenerateQR> createState() => _GenerateQRState();
}

class _GenerateQRState extends State<GenerateQR> {
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      sharedPreferences = value;
      setState(() {
        selectedGradient = sharedPreferences.getString('gradient') ?? 'Timber';
        sharedPreferences.setString('gradient', selectedGradient);
      });
    });
  }

  // ignore: prefer_typing_uninitialized_variables
  var sharedPreferences;

  final Map<String, List<Color>> gradient = {
    "Timber": const [Color(0xfffc00ff), Color(0xff00dbde)],
    'Racker': const [Color(0xfffc466b), Color(0xff3f5efb)],
    'Omolon': const [Color(0xff091e3a), Color(0xff2f80ed), Color(0xff2d9ee0)],
    'Radioactive heat': const [
      Color(0xfff7941e),
      Color(0xff72c6ef),
      Color(0xff00a651)
    ],
    'The sky and sea': const [Color(0xfffd8112), Color(0xff0085ca)],
    'Passion': const [Color(0xfff43b47), Color(0xff453a94)],
    'Lunada': const [Color(0xff5433ff), Color(0xff20bdff), Color(0xffa5fecb)],
    'Rose water': const [Color(0xffe55d87), Color(0xff5fc3e4)],
    'Mantle': const [Color(0xff24c6dc), Color(0xff514a9d)],
    'Dracula': const [Color(0xffdc2424), Color(0xff4a569d)],
    'Sunrise': const [Color(0xffc21500), Color(0xffffc500)],
    'Man of steel': const [Color(0xff780206), Color(0xff061161)],
    'Atlas': const [Color(0xfffeac5e), Color(0xffc779d0), Color(0xff4bc0c8)],
    'Instagram': const [
      Color(0xff833ab4),
      Color(0xfffd1d1d),
      Color(0xfffcb045)
    ],
    'Ukraine': const [Color(0xff004ff9), Color(0xfffff94c)],
    'Netflix': const [Color(0xff8e0e00), Color(0xff1f1c18)],
    'Deep space': const [Color(0xff000000), Color(0xff434343)],
    'Alihossein': const [Color(0xfff7ff00), Color(0xffdb36a4)],
    'Transfile': const [Color(0xff16bffd), Color(0xffcb3066)],
    'Sherbert': const [Color.fromARGB(255, 255, 149, 0), Color(0xff64f38c)],
    'Azure Pop': const [Color(0xffef32d9), Color(0xff89fffd)],
    'Cosmic Fusion': const [Color(0xffff00cc), Color(0xff333399)],
    'Dawn': const [Color(0xfff3904f), Color(0xff3b4371)],
    'Vild Mad': const [Color(0xffffc371), Color(0xffff5f6d)],
    'Vice city': const [Color(0xff3494e6), Color(0xffec6ead)],
    'Relay': const [Color(0xff3a1c71), Color(0xffd76d77), Color(0xffffaf7b)],
    'King Yna': const [Color(0xff1a2a6c), Color(0xffb21f1f), Color(0xfffdbb2d)],
    'Argon': const [
      Color(0xff03001e),
      Color(0xff7303c0),
      Color(0xffec38bc),
      Color(0xfffdeff9)
    ],
    'Kyoo Pal': const [Color(0xffdd3e54), Color(0xff6be585)],
    'Kye Meh': const [Color(0xff8360c3), Color(0xff2ebf91)],
    'pink flavor': const [Color(0xff800080), Color(0xffffc0cb)],
    'Sublime vivid': const [Color(0xfffc466b), Color(0xff3f5efb)],
    'Wedding day': const [
      Color(0xff40e0d0),
      Color(0xffff8c00),
      Color(0xffff0080)
    ],
    'Rastafari': const [
      Color(0xff1e9600),
      Color(0xffff0000),
      Color(0xff0000ff)
    ],
    'Wiretap': const [Color(0xff8a2387), Color(0xffe94057), Color(0xfff27121)],
    'By design': const [Color(0xff009fff), Color(0xffec2f4b)],
    'JShine': const [Color(0xff12c2e9), Color(0xffc471ed), Color(0xfff64f59)],
    'Lensod': const [Color(0xff6025f5), Color(0xffff5555)],
    'Newspaper': const [Color(0xff8a2be2), Color(0xffffa500)],
  };
  String? selectedGradient;

  var screenshotController = ScreenshotController();
  var onlyQrScreehshotController = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(left: 20, right: 20),
            height: AppBar().preferredSize.height * 0.7,
            width: AppBar().preferredSize.width * 0.8,
            child: GestureDetector(
              onTap: () {
                try {
                  if (Platform.isIOS) {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) => Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: CupertinoActionSheet(
                          title: const Text('Change Gradient'),
                          actions: [
                            for (var key in gradient.keys)
                              CupertinoActionSheetAction(
                                onPressed: () async {
                                  setState(() {
                                    selectedGradient = key;
                                  });
                                  sharedPreferences.setString(
                                      'gradient', selectedGradient);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  // ,
                                  // width: 350,
                                  height: AppBar().preferredSize.height,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: gradient[
                                          key]!, // [Color(0xfffc00ff), Color(0xff00dbde)],
                                      // stops: [0, 1],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    throw 'its android bro';
                  }
                } catch (e) {
                  {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Theme.of(context)
                                .scaffoldBackgroundColor
                                .withOpacity(0.95),
                            scrollable: true,
                            title: Container(
                              // width: double.,
                              // height: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: gradient[selectedGradient ??
                                      'Timber']!, // [Color(0xfffc00ff), Color(0xff00dbde)],
                                  // stops: [0, 1],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                color: const Color.fromARGB(25, 255, 255, 255),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              alignment: Alignment.center,
                              child: GradientText(
                                'Change Gradient',

                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 30.0,
                                ),
                                gradientType: GradientType.linear,
                                // radius: 3,
                                colors: gradient['Atlas']!,
                                // [
                                //   const Color(0xfffc00ff),
                                //   const Color(0xff00dbde)
                                // ],
                              ),
                            ),
                            content: SingleChildScrollView(
                              // controller: controller,
                              child: Column(
                                children: [
                                  for (var key in gradient.keys)
                                    ListTile(
                                      // leading: Text(
                                      //   (gradientTitle.indexOf(key) + 1).toString(),
                                      //   style: const TextStyle(
                                      //     fontSize: 20.0,
                                      //   ),
                                      // ),
                                      title: Container(
                                        alignment: Alignment.center,
                                        // ,
                                        width: 700,
                                        height: AppBar().preferredSize.height,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: gradient[
                                                key]!, // [Color(0xfffc00ff), Color(0xff00dbde)],
                                            // stops: [0, 1],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          key,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          selectedGradient = key;
                                        });
                                        sharedPreferences.setString(
                                            'gradient', selectedGradient);
                                        Navigator.pop(context);
                                      },
                                    ),
                                ],
                              ),
                            ),
                            // actions: [Text('data')],
                          );
                        });
                  }
                }
              },
              child: Stack(
                // alignment: Alignment.center,
                // fit: StackFit.loose,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: AppBar().preferredSize.width * 0.3,
                    height: AppBar().preferredSize.height * 0.8,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurStyle: BlurStyle.solid,
                          color: const Color.fromARGB(195, 0, 170, 255)
                              .withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 20,
                          offset:
                              const Offset(0, 0), // changes position of shadow
                        ),
                      ],
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: AppBar().preferredSize.height * 0.4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradient[selectedGradient ??
                                  'Timber']!, // [Color(0xfffc00ff), Color(0xff00dbde)],
                              // stops: [0, 1],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Gradient',
                            style: TextStyle(
                              fontSize: 16.0,
                            )),
                        // ]),
                      ],
                    ),
                  )
                  // ElevatedButton(
                  //   style: ButtonStyle(
                  //       visualDensity: const VisualDensity(horizontal: 4.0),
                  //       padding: MaterialStateProperty.all(
                  //           const EdgeInsets.symmetric(
                  //               horizontal: 8.0, vertical: 4.0))),
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //   },
                  //   child: const Text('Back'),
                  // ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Theme.of(context)
                          .scaffoldBackgroundColor
                          .withOpacity(0.95),
                      title: const Text('How would you like to save?'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color.fromARGB(85, 0, 168, 253),
                                    width: 0.5),
                                backgroundColor:
                                    const Color.fromARGB(55, 0, 0, 0),
                              ),
                              onPressed: () {
                                screenshotController
                                    .capture()
                                    .then((capturedImage) {
                                  if (capturedImage == null) return;
                                  ImageGallerySaver.saveImage(capturedImage)!;
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor:
                                        Color.fromARGB(255, 2, 197, 8),
                                    content: Text(
                                      'QR code saved to gallery',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: const Text('With Background'),
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color.fromARGB(85, 0, 168, 253),
                                      width: 0.5),
                                  backgroundColor:
                                      const Color.fromARGB(55, 0, 0, 0),
                                ),
                                onPressed: () {
                                  onlyQrScreehshotController
                                      .capture()
                                      .then((capturedImage) {
                                    if (capturedImage == null) return;
                                    ImageGallerySaver.saveImage(capturedImage)!;
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor:
                                          Color.fromARGB(255, 2, 197, 8),
                                      content: Text('QR code saved to gallery',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16)),
                                    ),
                                  );
                                },
                                child: const Text('Only QR Code')),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.save_alt_sharp),
            ),
            IconButton(
              onPressed: () async {
                final directory = await getTemporaryDirectory();
                final imagePath = '${directory.path}/qr_code.png';
                final file = File(imagePath);
                //
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(0.95),
                        title: const Text('How would you like to share?'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color.fromARGB(85, 0, 168, 253),
                                      width: 0.5),
                                  backgroundColor:
                                      const Color.fromARGB(55, 0, 0, 0),
                                ),
                                onPressed: () async {
                                  final image =
                                      await screenshotController.capture();
                                  await file.writeAsBytes(image!);

                                  Share.shareFiles([imagePath],
                                      subject: 'QR Code');
                                  Navigator.pop(context);
                                },
                                child: const Text('With Background'),
                              ),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Color.fromARGB(85, 0, 168, 253),
                                        width: 0.5),
                                    backgroundColor:
                                        const Color.fromARGB(55, 0, 0, 0),
                                  ),
                                  onPressed: () async {
                                    final image =
                                        await onlyQrScreehshotController
                                            .capture();
                                    await file.writeAsBytes(image!);

                                    Share.shareFiles([imagePath],
                                        subject: 'QR Code');
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Only QR Code')),
                            ],
                          ),
                        ),
                      );
                    });
              },
              icon: const Icon(Icons.share),
            )
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottomOpacity: 0,
        ),
        body: Center(
          child: Screenshot(
            controller: screenshotController,
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: gradient[selectedGradient ??
                    'Timber']!, //[Color(0xfffc00ff), Color(0xff00dbde)],
                // stops: [0, 1],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )

                  // LinearGradient(
                  //   colors: [Color(0xff5433ff), Color(0xff20bdff), Color(0xffa5fecb)],
                  //   stops: [0, 0.5, 1],
                  //   begin: Alignment.topLeft,
                  //   end: Alignment.bottomRight,
                  // ),
                  ),
              child: Center(
                child: Container(
                  // alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(16)),
                  child: Screenshot(
                    controller: onlyQrScreehshotController,
                    child: QrImageView(
                      // semanticsLabel: 'QR Code',

                      // padding: EdgeInsets.all(30),
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(100, 100),
                      ),
                      // embeddedImageEmitsError: true,
                      foregroundColor: widget.dataModuleColor,
                      // constrainErrorBounds: false,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.values[widget.eyeShape ?? 0],
                        // color: widget.eyeColor?? Colors.black,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape:
                            QrDataModuleShape.values[widget.eyeShape ?? 0],
                        // color: widget.dataModuleColor,
                      ),
                      embeddedImageEmitsError: true,
                      embeddedImage: // AssetImage('assets/funny_tom.png'),
                          widget.imagePath != ''
                              ? FileImage(File(widget.imagePath!))
                              : null,
                      backgroundColor: Colors.white,
                      // gapless: widget.gapless,
                      data: widget.data,
                      version: QrVersions.auto,
                      // size: 200.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
