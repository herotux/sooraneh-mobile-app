import 'package:flutter/material.dart';
import 'package:daric/models/person.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/main_scaffold.dart';
import 'edit_person_screen.dart'; // برای reuse فرم (اختیاری)، یا مستقیم فرم رو می‌نویسیم

class AddPersonScreen extends StatelessWidget {
  const AddPersonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "افزودن طرف حساب",
      body: _AddPersonForm(
        onSubmit: (newPerson) async {
          final success = await ApiService().addPerson(newPerson);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("طرف حساب با موفقیت اضافه شد"),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // برگشت و نشان‌دادن موفقیت
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("خطا در افزودن طرف حساب"),
                backgroundColor: Colors.red,
              ),
            );
          }
          return success;
        },
      ),
    );
  }
}

class _AddPersonForm extends StatefulWidget {
  final Future<bool> Function(Person person) onSubmit;

  const _AddPersonForm({required this.onSubmit});

  @override
  State<_AddPersonForm> createState() => _AddPersonFormState();
}

class _AddPersonFormState extends State<_AddPersonForm> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _relationController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _relationController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final newPerson = Person(
        id: 0, // id بعداً توسط سرور تعیین می‌شود
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty
            ? null
            : _lastNameController.text.trim(),
        relation: _relationController.text.trim(),
      );

      final success = await widget.onSubmit(newPerson);
      if (!success) {
        setState(() => _errorMessage = 'ذخیره ناموفق بود');
      }
    } catch (e) {
      setState(() => _errorMessage = 'خطا: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // نام
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'نام *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'نام الزامی است';
                      if (value.length > 60) return 'نام نباید بیشتر از 60 کاراکتر باشد';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // نام خانوادگی
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'نام خانوادگی',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value != null && value.length > 60) {
                        return 'نام خانوادگی نباید بیشتر از 60 کاراکتر باشد';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // رابطه
                  TextFormField(
                    controller: _relationController,
                    decoration: const InputDecoration(
                      labelText: 'رابطه *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'رابطه الزامی است';
                      if (value.length > 60) return 'رابطه نباید بیشتر از 60 کاراکتر باشد';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // پیام خطا
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),

                  const SizedBox(height: 24),

                  // دکمه ذخیره
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('افزودن'),
                  ),
                ],
              ),
            ),
    );
  }
}