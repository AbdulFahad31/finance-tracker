import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finance_tracker/pages/add_transaction_page.dart';
import 'package:finance_tracker/pages/category_page.dart';
import 'package:finance_tracker/pages/settings_page.dart';
import 'package:finance_tracker/pages/statistics_page.dart';
import 'package:finance_tracker/pages/transaction_history_page.dart';
import 'package:finance_tracker/services/finance_service.dart';
import 'package:finance_tracker/utils/app_colors.dart';
import 'package:finance_tracker/widgets/balance_card.dart';
import 'package:finance_tracker/widgets/empty_state.dart';
import 'package:finance_tracker/widgets/income_expense_card.dart';
import 'package:finance_tracker/widgets/transaction_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final FinanceService _service;

  @override
  void initState() {
    super.initState();
    _service = FinanceService();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await Hive.initFlutter();
    } catch (_) {}
    await _service.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openAddTransaction() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddTransactionPage(service: _service)),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = _service.isDarkMode;
    final appTheme = isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true);
    return Theme(
      data: appTheme.copyWith(
        colorScheme: appTheme.colorScheme.copyWith(primary: AppColors.primary),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Finance Tracker'),
          actions: [
            IconButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsPage(service: _service))), icon: const Icon(Icons.settings_outlined)),
          ],
        ),
        body: !_service.isInitialized
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello there 👋', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Here is your financial overview', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        BalanceCard(balance: _service.balance, currency: _service.currency),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            IncomeExpenseCard(title: 'Income', amount: _service.totalIncome, currency: _service.currency, icon: Icons.arrow_downward, color: AppColors.income),
                            const SizedBox(width: 12),
                            IncomeExpenseCard(title: 'Expense', amount: _service.totalExpense, currency: _service.currency, icon: Icons.arrow_upward, color: AppColors.expense),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Recent Transactions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TransactionHistoryPage(service: _service))), child: const Text('View all')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_service.transactions.isEmpty)
                          const EmptyState(title: 'No transactions yet', subtitle: 'Tap + to add your first income or expense.', icon: Icons.receipt_long_outlined)
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _service.recentTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = _service.recentTransactions[index];
                              return TransactionTile(transaction: transaction, currency: _service.currency);
                            },
                          ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _ActionChip(label: 'History', icon: Icons.history, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TransactionHistoryPage(service: _service)))),
                            _ActionChip(label: 'Statistics', icon: Icons.bar_chart, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => StatisticsPage(service: _service)))),
                            _ActionChip(label: 'Categories', icon: Icons.category, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CategoryPage(service: _service)))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddTransaction,
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
