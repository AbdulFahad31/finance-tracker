import 'package:flutter/material.dart';
import 'package:finance_tracker/services/finance_service.dart';
import 'package:finance_tracker/utils/constants.dart';
import 'package:finance_tracker/widgets/custom_button.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.service});

  final FinanceService service;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.service.currency;
  }

  Future<void> _deleteAllTransactions() async {
    await widget.service.deleteAllTransactions();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile.adaptive(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use the darker theme across the app'),
            value: widget.service.isDarkMode,
            onChanged: (value) async {
              await widget.service.setDarkMode(value);
              setState(() {});
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedCurrency,
            decoration: const InputDecoration(labelText: 'Currency', border: OutlineInputBorder()),
            items: Constants.supportedCurrencies.map((currency) => DropdownMenuItem(value: currency, child: Text(currency))).toList(),
            onChanged: (value) async {
              if (value == null) return;
              await widget.service.setCurrency(value);
              setState(() => _selectedCurrency = value);
            },
          ),
          const SizedBox(height: 16),
          CustomButton(label: 'Delete All Transactions', onPressed: _deleteAllTransactions, icon: Icons.delete_outline, isPrimary: false),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              title: const Text('About Finance Tracker'),
              subtitle: const Text('A beginner-friendly app for tracking income, expenses, and plans.'),
              leading: const Icon(Icons.info_outline),
            ),
          ),
        ],
      ),
    );
  }
}
