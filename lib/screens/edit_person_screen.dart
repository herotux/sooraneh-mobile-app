import 'package:flutter/material.dart';
import 'package:daric/models/person.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/main_scaffold.dart';

class EditPersonScreen extends StatelessWidget {
  final Person person;
  const EditPersonScreen({required this.person, super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "ویرایش طرف حساب",
      body: _PersonForm(
        initialPerson: person,
        onSubmit: (updatedPerson) async {
          final success = await ApiService().updatePerson(updatedPerson);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success ? 'ویرایش با موفقیت انجام شد' : 'خطا در ویرایش طرف حساب',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
          return success;
        },
      ),
    );
  }
}

class _PersonForm extends StatefulWidget {
  final Person initialPerson;
  final Future<bool> Function(Person person) onSubmit;

  const _PersonForm({
    required this.initialPerson,
    required this.onSubmit,
  });

  @override
  State<_PersonForm> createState() => _PersonFormState();
}

class _PersonFormState extends State<_PersonForm> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _relationController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.initialPerson.firstName);
    _lastNameController = TextEditingController(text: widget.initialPerson.lastName ?? '');
    _relationController = TextEditingController(text: widget.initialPerson.relation);
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
      final updatedPerson = Person(
        id: widget.initialPerson.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty
            ? null
            : _lastNameController.text.trim(),
        relation: _relationController.text.trim(),
      );

      final success = await widget.onSubmit(updatedPerson);
      if (success && mounted) {
        Navigator.pop(context, updatedPerson); // برگرداندن شخص آپدیت شده
      } else {
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
                    child: const Text('ذخیره'),
                  ),
                ],
              ),
            ),
    );
  }
}