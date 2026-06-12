// import 'package:device_info_plus/device_info_plus.dart';

// class DeviceInfoService {
//   static final DeviceInfoService _instance = DeviceInfoService._internal();
//   factory DeviceInfoService() => _instance;
//   DeviceInfoService._internal();

//   final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

//   Future<Map<String, dynamic>> getDeviceInfo(String platform) async {
//     if (platform == 'android') {
//       return _readAndroidBuildData(await _deviceInfoPlugin.androidInfo);
//     } else {
//       return _readIosDeviceInfo(await _deviceInfoPlugin.iosInfo);
//     }
//   }

//   Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
//     return <String, dynamic>{
//       'version.securityPatch': build.version.securityPatch,
//       'version.sdkInt': build.version.sdkInt,
//       'version.release': build.version.release,
//       // ... rest of the Android info mapping
//     };
//   }

//   Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
//     return <String, dynamic>{
//       'name': data.name,
//       'systemName': data.systemName,
//       // ... rest of the iOS info mapping
//     };
//   }
// }
