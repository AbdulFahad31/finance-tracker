import 'package:flutter/material.dart';
import 'package:finance_tracker/services/finance_service.dart';
import 'package:finance_tracker/widgets/category_card.dart';
import 'package:finance_tracker/widgets/custom_button.dart';
import 'package:finance_tracker/widgets/custom_textfield.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key, required this.service});

  final FinanceService service;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final _controller = TextEditingController();

  Future<void> _addCategory() async {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    await widget.service.addCategory(value);
    _controller.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(label: 'New category', controller: _controller),
            const SizedBox(height: 12),
            CustomButton(label: 'Add Category', onPressed: _addCategory, icon: Icons.add_circle_outline),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.service.categories.length,
                itemBuilder: (context, index) {
                  final category = widget.service.categories[index];
                  return CategoryCard(
                    title: category,
                    onDelete: category == 'Food' || category == 'Salary'
                        ? null
                        : () async {
                            await widget.service.deleteCategory(category);
                            setState(() {});
                          },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
