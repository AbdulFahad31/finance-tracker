import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/transaction_model.dart';
import 'package:finance_tracker/services/finance_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> _initializeHiveForTest() async {
  try {
    await Hive.initFlutter();
  } on MissingPluginException {
    final tempDir = Directory.systemTemp.createTempSync('finance_tracker_hive_test');
    Hive.init(tempDir.path);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FinanceService service;

  setUp(() async {
    await _initializeHiveForTest();
    await Hive.deleteBoxFromDisk('finance_box');
    await Hive.openBox('finance_box');
    service = FinanceService();
    await service.initialize();
  });

  test('loads default categories and stores new transactions', () async {
    expect(service.categories, contains('Food'));
    expect(service.categories, contains('Salary'));

    final transaction = TransactionModel(
      id: 'test-id',
      title: 'Freelance payment',
      amount: 2500,
      category: 'Salary',
      type: 'Income',
      date: DateTime.now(),
      notes: 'Project payment',
    );

    await service.addTransaction(transaction);
    expect(service.transactions, hasLength(1));
    expect(service.transactions.first.title, 'Freelance payment');
  });
}
