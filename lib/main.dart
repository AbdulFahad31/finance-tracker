import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finance_tracker/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeHive();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const App());
}

Future<void> _initializeHive() async {
  try {
    await Hive.initFlutter();
  } on MissingPluginException {
    final tempDir = Directory.systemTemp.createTempSync('finance_tracker_hive');
    Hive.init(tempDir.path);
  }
}
