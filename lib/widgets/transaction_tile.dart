import 'package:flutter/material.dart';
import 'package:finance_tracker/models/transaction_model.dart';
import 'package:finance_tracker/utils/app_colors.dart';
import 'package:finance_tracker/utils/formatter.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.currency,
    this.onEdit,
    this.onDelete,
  });

  final TransactionModel transaction;
  final String currency;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'Income';
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isIncome ? AppColors.income : AppColors.expense).withValues(alpha: 0.16),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? AppColors.income : AppColors.expense,
          ),
        ),
        title: Text(transaction.title),
        subtitle: Text('${transaction.category} • ${Formatter.formatDate(transaction.date)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${Formatter.formatCurrency(transaction.amount, currency: currency)}',
              style: TextStyle(
                color: isIncome ? AppColors.income : AppColors.expense,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onEdit != null || onDelete != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
                  if (onDelete != null)
                    IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
