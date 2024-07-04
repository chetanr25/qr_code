// ignore_for_file: prefer_typing_uninitialized_variables, await_only_futures, avoid_print, sort_child_properties_last, dead_code

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qrcode_scanner/device_info.dart';
import 'package:qrcode_scanner/generate_qr_screen.dart';
import 'package:qrcode_scanner/qr_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final List<Widget> screens = [const QR(), const GenerateScreen()];
  final List<String> screenNames = ['Scan QR', 'Generate QR'];

  int screenIndex = 1;
  void fetchDeviceInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
// await prefs.get('first_time') == null
    if (true) {
      var deviceInfo;
      if (Platform.isAndroid) {
        deviceInfo = await DeviceInfo().androidInfo;
      }
      if (Platform.isIOS) {
        deviceInfo = await DeviceInfo().iosInfo;
      }
      prefs.setBool('first_time', false);
      prefs.setString('deviceInfo', deviceInfo.data['model']);
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('deviceInfo', deviceInfo.data['model']);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[screenIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Generate QR',
          ),
        ],
        currentIndex: screenIndex,
        onTap: (index) {
          setState(() {
            screenIndex = index;
          });
        },
      ),
    );
  }
}
