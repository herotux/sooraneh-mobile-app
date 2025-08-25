import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:daric/models/budget.dart';
import 'package:daric/models/category.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/main_scaffold.dart';
import 'package:daric/widgets/searchable_add_dropdown.dart';

class EditBudgetScreen extends StatefulWidget {
  final Budget budget;

  EditBudgetScreen({required this.budget});

  @override
  _EditBudgetScreenState createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  int? _selectedCategoryId;

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // No longer need a future here, the dropdown handles it.
  Category? _initialCategory;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.budget.monthly_budget.toString());
    _selectedCategoryId = widget.budget.category;
    _loadInitialCategory();
  }

  Future<void> _loadInitialCategory() async {
    if (_selectedCategoryId == null) {
      setState(() => _isInitializing = false);
      return;
    }
    final categories = await _apiService.getCategories();
    if (categories != null) {
      setState(() {
        _initialCategory = categories.firstWhere((c) => c.id == _selectedCategoryId, orElse: () => categories.first);
      });
    }
    setState(() => _isInitializing = false);
  }

  Future<void> _updateBudget() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    final updatedBudget = Budget(
      id: widget.budget.id,
      monthly_budget: int.parse(_amountController.text.trim()),
      category: _selectedCategoryId,
    );

    final success = await _apiService.updateBudget(updatedBudget);

    setState(() { _isLoading = false; });

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('بودجه با موفقیت به‌روزرسانی شد')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در به‌روزرسانی بودجه')));
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<Category?> _showAddCategoryModal(BuildContext context) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isIncome = false;

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
      title: "ویرایش بودجه",
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
              _isInitializing
                ? Center(child: CircularProgressIndicator())
                : SearchableAddDropdown<Category>(
                    label: "دسته‌بندی (اختیاری)",
                    selectedItem: _initialCategory,
                    onChanged: (category) => setState(() => _selectedCategoryId = category?.id),
                    onSearch: (query) => ApiService().getCategories(),
                    onAddNew: (context) => _showAddCategoryModal(context),
                  ),
              SizedBox(height: 24),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _updateBudget,
                      child: Text('ذخیره تغییرات'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
