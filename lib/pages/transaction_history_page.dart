import 'package:flutter/material.dart';
import 'package:finance_tracker/models/transaction_model.dart';
import 'package:finance_tracker/pages/add_transaction_page.dart';
import 'package:finance_tracker/services/finance_service.dart';
import 'package:finance_tracker/widgets/empty_state.dart';
import 'package:finance_tracker/widgets/transaction_tile.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key, required this.service});

  final FinanceService service;

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedType = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionModel> get _filteredTransactions {
    final search = _searchController.text.toLowerCase();
    return widget.service.transactions.where((transaction) {
      final matchesSearch = transaction.title.toLowerCase().contains(search);
      final matchesCategory = _selectedCategory == 'All' || transaction.category == _selectedCategory;
      final matchesType = _selectedType == 'All' || transaction.type == _selectedType;
      return matchesSearch && matchesCategory && matchesType;
    }).toList();
  }

  Future<void> _showDeleteDialog(TransactionModel transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.service.deleteTransaction(transaction.id);
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...widget.service.categories];
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Search by title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        items: categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                        onChanged: (value) => setState(() => _selectedCategory = value ?? 'All'),
                        decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        items: const [DropdownMenuItem(value: 'All', child: Text('All')), DropdownMenuItem(value: 'Income', child: Text('Income')), DropdownMenuItem(value: 'Expense', child: Text('Expense'))],
                        onChanged: (value) => setState(() => _selectedType = value ?? 'All'),
                        decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredTransactions.isEmpty
                ? const EmptyState(title: 'No transactions', subtitle: 'Try changing the filters or add a new entry.', icon: Icons.receipt_long_outlined)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      return TransactionTile(
                        transaction: transaction,
                        currency: widget.service.currency,
                        onEdit: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddTransactionPage(service: widget.service, transaction: transaction),
                            ),
                          );
                          setState(() {});
                        },
                        onDelete: () => _showDeleteDialog(transaction),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
