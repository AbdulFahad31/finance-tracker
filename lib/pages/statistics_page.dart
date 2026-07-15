import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker/services/finance_service.dart';
import 'package:finance_tracker/utils/app_colors.dart';
import 'package:finance_tracker/utils/formatter.dart';
import 'package:finance_tracker/widgets/empty_state.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key, required this.service});

  final FinanceService service;

  @override
  Widget build(BuildContext context) {
    final monthTransactions = service.transactionsForMonth(DateTime.now());
    final income = monthTransactions.where((transaction) => transaction.type == 'Income').fold(0.0, (sum, item) => sum + item.amount);
    final expense = monthTransactions.where((transaction) => transaction.type == 'Expense').fold(0.0, (sum, item) => sum + item.amount);

    final categoryTotals = <String, double>{};
    for (final transaction in monthTransactions) {
      categoryTotals[transaction.category] = (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    final monthlyTotals = <String, double>{};
    for (final transaction in service.transactions) {
      final monthKey = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + transaction.amount;
    }

    final pieSections = categoryTotals.entries.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: service.transactions.isEmpty
          ? const EmptyState(title: 'No data yet', subtitle: 'Add transactions to see monthly insights.', icon: Icons.bar_chart_rounded)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryTile(label: 'Income', amount: income, currency: service.currency, color: AppColors.income),
                  const SizedBox(height: 12),
                  _SummaryTile(label: 'Expense', amount: expense, currency: service.currency, color: AppColors.expense),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Category Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 220,
                            child: pieSections.isEmpty
                                ? const Center(child: Text('No category data'))
                                : PieChart(
                                    PieChartData(
                                      sections: pieSections.asMap().entries.map((entry) {
                                        final color = Colors.primaries[entry.key % Colors.primaries.length];
                                        return PieChartSectionData(
                                          color: color,
                                          value: entry.value.value,
                                          title: entry.value.key,
                                          radius: 80,
                                          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Monthly Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 220,
                            child: BarChart(
                              BarChartData(
                                maxY: (monthlyTotals.values.toList().fold<double>(0, (a, b) => a > b ? a : b) * 1.2).clamp(1, double.infinity),
                                barGroups: monthlyTotals.entries.toList().asMap().entries.map((entry) {
                                  return BarChartGroupData(x: entry.key, barRods: [BarChartRodData(toY: entry.value.value, color: AppColors.primary, width: 16)]);
                                }).toList(),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, _) => Text(monthlyTotals.keys.toList()[value.toInt()].split('-').last), reservedSize: 26)),
                                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.amount, required this.currency, required this.color});

  final String label;
  final double amount;
  final String currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(Formatter.formatCurrency(amount, currency: currency), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
