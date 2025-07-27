import 'package:flutter/material.dart';
import 'package:daric/models/category.dart';
import 'package:daric/services/api_service.dart';

class AddCategoryScreen extends StatefulWidget {
  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isIncome = false;

  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _message;

  Future<void> _submitCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final category = Category(
      id: 0, // سرور خودش مقدار میده
      name: _nameController.text.trim(),
      isIncome: _isIncome,
      parent: null,
    );

    final success = await _apiService.addCategory(category);

    setState(() {
      _isLoading = false;
      _message = success ? 'دسته‌بندی با موفقیت اضافه شد' : 'خطا در ثبت دسته‌بندی';
    });

    if (success) {
      _nameController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "افزودن دسته‌بندی جدید",
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'نام دسته‌بندی'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'نام را وارد کنید' : null,
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('این دسته‌بندی برای درآمد است؟'),
                value: _isIncome,
                onChanged: (val) => setState(() => _isIncome = val),
              ),
              SizedBox(height: 24),
              if (_isLoading)
                CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submitCategory,
                  child: Text('ثبت دسته‌بندی'),
                ),
              if (_message != null) ...[
                SizedBox(height: 16),
                Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.contains('موفق')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
