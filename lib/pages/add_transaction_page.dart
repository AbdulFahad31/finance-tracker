import 'package:flutter/material.dart';
import 'package:finance_tracker/models/transaction_model.dart';
import 'package:finance_tracker/services/finance_service.dart';
import 'package:finance_tracker/utils/app_colors.dart';
import 'package:finance_tracker/utils/constants.dart';
import 'package:finance_tracker/widgets/custom_button.dart';
import 'package:finance_tracker/widgets/custom_textfield.dart';
import 'package:intl/intl.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key, this.transaction, required this.service});

  final TransactionModel? transaction;
  final FinanceService service;

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final List<String> _types = ['Income', 'Expense'];
  String _selectedType = 'Expense';
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final transaction = widget.transaction!;
      _titleController.text = transaction.title;
      _amountController.text = transaction.amount.toString();
      _notesController.text = transaction.notes;
      _selectedType = transaction.type;
      _selectedCategory = transaction.category;
      _selectedDate = transaction.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final transaction = TransactionModel(
      id: widget.transaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      category: _selectedCategory,
      type: _selectedType,
      date: _selectedDate,
      notes: _notesController.text.trim(),
    );

    if (widget.transaction == null) {
      await widget.service.addTransaction(transaction);
    } else {
      await widget.service.updateTransaction(transaction);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = <String>{...widget.service.categories, ...Constants.defaultCategories}.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: 'Title',
                  controller: _titleController,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Amount',
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter an amount';
                    if (double.tryParse(value) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value ?? 'Food'),
                ),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: _types.map((type) => ButtonSegment(value: type, label: Text(type))).toList(),
                  selected: {_selectedType},
                  onSelectionChanged: (value) => setState(() => _selectedType = value.first),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(DateFormat('MMM d, yyyy').format(_selectedDate)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(label: 'Notes', controller: _notesController, maxLines: 3),
                const SizedBox(height: 24),
                CustomButton(label: 'Save Transaction', onPressed: _save, icon: Icons.save_outlined),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
