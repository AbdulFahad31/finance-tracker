import 'package:finance_tracker/models/transaction_model.dart';
import 'package:finance_tracker/services/hive_service.dart';
import 'package:finance_tracker/utils/constants.dart';

class FinanceService {
  FinanceService({HiveService? hiveService}) : _hiveService = hiveService ?? HiveService();

  final HiveService _hiveService;
  final List<TransactionModel> _transactions = <TransactionModel>[];
  final List<String> _categories = <String>[];
  String _currency = 'USD';
  bool _isDarkMode = false;
  bool _isInitialized = false;

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<String> get categories => List.unmodifiable(_categories);
  String get currency => _currency;
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  double get totalIncome => _transactions
      .where((transaction) => transaction.type == 'Income')
      .fold(0.0, (sum, transaction) => sum + transaction.amount);

  double get totalExpense => _transactions
      .where((transaction) => transaction.type == 'Expense')
      .fold(0.0, (sum, transaction) => sum + transaction.amount);

  double get balance => totalIncome - totalExpense;

  List<TransactionModel> get recentTransactions {
    final sorted = List<TransactionModel>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  Future<void> initialize() async {
    final box = await _hiveService.openBox();

    final storedTransactions = box.get('transactions', defaultValue: <Map<String, dynamic>>[]);
    if (storedTransactions is List) {
      _transactions
        ..clear()
        ..addAll(
          storedTransactions.whereType<Map>().map((item) {
            return TransactionModel.fromMap(Map<String, dynamic>.from(item));
          }),
        );
    }

    final storedCategories = box.get('categories', defaultValue: Constants.defaultCategories);
    _categories
      ..clear()
      ..addAll(
        (storedCategories as List).whereType<String>().toList(),
      );

    _currency = box.get('currency', defaultValue: 'USD').toString();
    _isDarkMode = box.get('isDarkMode', defaultValue: false) as bool;
    _isInitialized = true;
  }

  Future<void> _save() async {
    final box = await _hiveService.openBox();
    await box.put('transactions', _transactions.map((transaction) => transaction.toMap()).toList());
    await box.put('categories', _categories.toList());
    await box.put('currency', _currency);
    await box.put('isDarkMode', _isDarkMode);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    _transactions.add(transaction);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    await _save();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final index = _transactions.indexWhere((item) => item.id == transaction.id);
    if (index >= 0) {
      _transactions[index] = transaction;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      await _save();
    }
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((transaction) => transaction.id == id);
    await _save();
  }

  Future<void> addCategory(String category) async {
    final normalized = category.trim();
    if (normalized.isEmpty || _categories.contains(normalized)) {
      return;
    }
    _categories.add(normalized);
    await _save();
  }

  Future<void> deleteCategory(String category) async {
    if (Constants.defaultCategories.contains(category)) {
      return;
    }
    _categories.remove(category);
    await _save();
  }

  Future<void> setCurrency(String currency) async {
    _currency = currency;
    await _save();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _save();
  }

  Future<void> deleteAllTransactions() async {
    _transactions.clear();
    await _save();
  }

  List<TransactionModel> transactionsForMonth(DateTime date) {
    return _transactions
        .where((transaction) => transaction.date.year == date.year && transaction.date.month == date.month)
        .toList();
  }
}
