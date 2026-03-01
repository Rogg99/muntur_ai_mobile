import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:munturai/services/api/auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../core/fonctions.dart';
import '../model/user.dart';
import '../model/token.dart';

Future<Map<String, dynamic>> getDeviceMetadata() async {
  final deviceInfo = DeviceInfoPlugin();
  final packageInfo = await PackageInfo.fromPlatform();

  Map<String, dynamic> deviceData;

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    deviceData = {
      'device': androidInfo.model,
      'manufacturer': androidInfo.manufacturer,
      'os': 'Android ${androidInfo.version.release}',
    };
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    deviceData = {
      'device': iosInfo.utsname.machine,
      'manufacturer': 'APPLE Inc.',
      'os': 'iOS ${iosInfo.systemVersion}',
    };
  } else {
    deviceData = {'device': 'Unknown', 'os': 'Unknown'};
  }

  return {
    'device': deviceData['device'],
    'os': deviceData['os'],
    'app_version': packageInfo.version,
    'manufacturer': deviceData['manufacturer'],
    'build_number': packageInfo.buildNumber,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

Future<Map<String, String>> getDeviceAndAppMetaInfo() async {
  final deviceInfoPlugin = DeviceInfoPlugin();
  final packageInfo = await PackageInfo.fromPlatform();

  User user = await AuthApi().getUser();

  String deviceId = '';
  String deviceModel = '';
  String manufacturer = '';
  String brand = '';
  String deviceName = '';
  String sdkInt = '';
  String os = '';
  String platform = Platform.operatingSystem;

  if (Platform.isAndroid) {
    final android = await deviceInfoPlugin.androidInfo;
    deviceId = android.id ?? '';
    deviceModel = android.model ?? '';
    manufacturer = android.manufacturer ?? '';
    brand = android.brand ?? '';
    deviceName = android.device ?? '';
    sdkInt = '${android.version.sdkInt}';
    os = 'Android ${android.version.release}';
  }
  else if (Platform.isIOS) {
    final ios = await deviceInfoPlugin.iosInfo;
    deviceId = ios.identifierForVendor ?? '';
    deviceModel = ios.utsname.machine ?? '';
    manufacturer = 'Apple';
    brand = 'Apple';
    deviceName = ios.name ?? '';
    sdkInt = ios.systemVersion ?? '';
    os = 'iOS $sdkInt';
  }

  return {
    'appId': packageInfo.packageName,
    'appName': packageInfo.appName,
    'appVersion': packageInfo.version,
    'buildNumber': packageInfo.buildNumber,
    'deviceId': deviceId,
    'userId': user!=null?user.id.toString():"Not Signed In",
    'deviceModel': deviceModel,
    'deviceManufacturer': manufacturer,
    'deviceBrand': brand,
    'deviceName': deviceName,
    'deviceSdkInt': sdkInt,
    'platform': platform,
    'os': os,
  };
}

Future<void> logToELK({required LogLevel level,required String tag,required String message,}) async {
  // Log locally (saves to file, console, etc.)
  FlutterLogs.logThis(
    level: level,
    tag: tag,
    logMessage: message,
  );

  // Get your meta info
  final meta = await getDeviceAndAppMetaInfo();

  // Prepare payload
  final payload = {
    'log_level': level.toString(),
    'tag': tag,
    'message': message,
    'source': 'flutter-egopass',
    "app": "egopass",
    'timestamp': DateTime.now().toIso8601String(),
    'metadata': meta,
  };

  // Send to Logstash (or your backend endpoint)
  try {
    await http.post(
      Uri.parse('http://195.26.244.215:5002'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
  } catch (e) {
    print("⚠️ Failed to send log to ELK: $e");
  }

}


FutureOr<Set<Set<void>>> ThrowError(Object error, StackTrace stackTrace) async {
  if (kDebugMode) {
    print('🔴 ERROR: $error');
    print('🧵 STACK TRACE:\n$stackTrace');
  }
  logToELK(level:LogLevel.ERROR,tag: error.toString(),message: stackTrace.toString());
  Set<Set<void>> result = Set();
  return result;
}

