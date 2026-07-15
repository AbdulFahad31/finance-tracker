// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finance_tracker/app.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  try {
    await Hive.initFlutter();
  } on MissingPluginException {
    final tempDir = Directory.systemTemp.createTempSync('finance_tracker_widget_test');
    Hive.init(tempDir.path);
  }

  testWidgets('Finance Tracker splash screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('Finance Tracker'), findsWidgets);
  });
}
