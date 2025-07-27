import 'package:flutter/material.dart';
import 'package:daric/models/category.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/main_scaffold.dart';



class EditCategoryScreen extends StatefulWidget {
  final Category category;

  const EditCategoryScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isIncome = false;

  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _isIncome = widget.category.isIncome;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final updatedCategory = Category(
        id: widget.category.id,
        name: _nameController.text.trim(),
        isIncome: _isIncome,
        parent: widget.category.parent,
    );

    final success = await _apiService.updateCategory(
        updatedCategory.id,
        updatedCategory.toJson(),
    );


    setState(() {
      _isLoading = false;
      _message = success ? 'دسته‌بندی با موفقیت ویرایش شد' : 'خطا در ویرایش دسته‌بندی';
    });

    if (success) {
      Navigator.of(context).pop(true); // بازگشت به صفحه قبل با نتیجه موفقیت
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "ویرایش دسته‌بندی",
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'نام دسته‌بندی'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'نام را وارد کنید' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('این دسته‌بندی برای درآمد است؟'),
                value: _isIncome,
                onChanged: (val) => setState(() => _isIncome = val),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submitCategory,
                  child: const Text('ویرایش دسته‌بندی'),
                ),
              if (_message != null) ...[
                const SizedBox(height: 16),
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
