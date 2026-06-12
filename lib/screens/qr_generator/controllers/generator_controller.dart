import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneratorController {
  final TextEditingController textController = TextEditingController();
  final screenshotController = ScreenshotController();
  final qrScreenshotController = ScreenshotController();

  bool isCustomised = false;
  bool isImageUploaded = false;
  String uploadingStatus = 'Embed an Image in QR Code';
  String imagePath = '';
  late SharedPreferences prefs;

  List<bool> selectedShape = [true, false];
  List<bool> selectedColor1 = [true, false, false, false];
  List<bool> selectedColor2 = [false, false, false, false];

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> pickAndUploadImage(String deviceModel) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final tempDir = await getTemporaryDirectory();
    final tempPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
    final tempFile = File(tempPath);

    await tempFile.writeAsBytes(await pickedFile.readAsBytes());
    imagePath = tempPath;
    isImageUploaded = true;

    // await _uploadToFirebase(tempPath, deviceModel);
  }

  // Future<void> _uploadToFirebase(String path, String model) async {
  //   final storageRef = FirebaseStorage.instance
  //       .ref()
  //       .child(model)
  //       .child('${textController.text}.jpg');
  //   await storageRef.putFile(File(path));
  //   await storageRef.getDownloadURL();
  // }

  void resetImage() {
    isImageUploaded = false;
    uploadingStatus = 'Embed an Image in QR Code';
    imagePath = '';
  }

  void dispose() {
    textController.dispose();
  }
}
