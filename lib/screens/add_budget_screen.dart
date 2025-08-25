import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:daric/models/budget.dart';
import 'package:daric/models/category.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/main_scaffold.dart';
import 'package:daric/widgets/searchable_add_dropdown.dart';

class AddBudgetScreen extends StatefulWidget {
  @override
  _AddBudgetScreenState createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  int? _selectedCategoryId;

  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _apiService.getCategories().then((value) => value ?? []);
  }

  Future<void> _submitBudget() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    final budget = Budget(
      monthly_budget: int.parse(_amountController.text.trim()),
      category: _selectedCategoryId,
    );

    final newBudget = await _apiService.addBudget(budget);

    setState(() { _isLoading = false; });

    if (newBudget != null) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('بودجه با موفقیت اضافه شد')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در ثبت بودجه')));
    }
  }

  Future<Category?> _showAddCategoryModal(BuildContext context) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isIncome = false; // Default to expense

    return showDialog<Category>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('افزودن دسته‌بندی جدید'),
          content: StatefulBuilder(
            builder: (context, setModalState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'نام دسته‌بندی'),
                      validator: (val) => val!.isEmpty ? 'نام را وارد کنید' : null,
                    ),
                    SwitchListTile(
                      title: Text('برای درآمد'),
                      value: isIncome,
                      onChanged: (val) => setModalState(() => isIncome = val),
                    )
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('لغو'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newCategory = await ApiService().addCategory(
                    Category(id: 0, name: nameController.text, isIncome: isIncome),
                  );
                  if (newCategory != null && dialogContext.mounted) {
                    Navigator.pop(dialogContext, newCategory);
                  } else {
                     ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text('خطا در افزودن دسته‌بندی')),
                    );
                  }
                }
              },
              child: Text('ذخیره'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "افزودن بودجه جدید",
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'مبلغ بودجه'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value == null || value.isEmpty ? 'مبلغ را وارد کنید' : null,
              ),
              SizedBox(height: 16),
              SearchableAddDropdown<Category>(
                label: "دسته‌بندی (اختیاری)",
                onChanged: (category) => setState(() => _selectedCategoryId = category?.id),
                onSearch: (query) => ApiService().getCategories().then((value) => value ?? []),
                onAddNew: (context) => _showAddCategoryModal(context),
              ),
              SizedBox(height: 24),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitBudget,
                      child: Text('ثبت بودجه'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
