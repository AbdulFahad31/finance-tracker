import 'package:flutter/material.dart';
import 'package:finance_tracker/utils/app_colors.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.title,
    this.onDelete,
  });

  final String title;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(title),
        trailing: onDelete == null
            ? null
            : IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: AppColors.expense),
              ),
      ),
    );
  }
}
