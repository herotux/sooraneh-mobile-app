import 'package:flutter/material.dart';
import 'package:daric/models/expense.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/my_date_picker.dart';
import 'package:daric/widgets/person_dropdown.dart';
import 'package:daric/widgets/my_date_picker_modal.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  String _description = '';
  double? _amount;
  DateTime _selectedDate = DateTime.now();

  int? _selectedCategoryId;
  int? _selectedPersonId;
  int? _selectedTagId;

  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _selectDate() async {
    final pickedDate = await showMyDatePickerModal(
      context: context,
      label: 'انتخاب تاریخ',
      initialDate: _selectedDate,
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final expense = Expense(
        id: 0,
        text: _description,
        amount: _amount!.toInt(),
        date: _selectedDate.toIso8601String(),
        category: _selectedCategoryId,
        personId: _selectedPersonId,
        tag: _selectedTagId,
      );

      final success = await _apiService.addExpense(expense);
      if (success) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          _errorMessage = 'خطا در ذخیره هزینه';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطا در ذخیره هزینه: $e';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('افزودن هزینه')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isSaving
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'توضیحات',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'توضیح را وارد کنید';
                          }
                          if (val.trim().length > 30) {
                            return 'حداکثر ۳۰ کاراکتر';
                          }
                          return null;
                        },
                        onSaved: (val) => _description = val!.trim(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'مبلغ',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'مبلغ را وارد کنید';
                          }
                          final parsed = double.tryParse(val.replaceAll(',', ''));
                          if (parsed == null || parsed <= 0) {
                            return 'مبلغ نامعتبر است';
                          }
                          return null;
                        },
                        onSaved: (val) =>
                            _amount = double.tryParse(val!.replaceAll(',', '')),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'تاریخ هزینه',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            '${_selectedDate.year}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PersonDropdown(
                        selectedPersonId: _selectedPersonId,
                        onChanged: (id) => _selectedPersonId = id,
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saveExpense,
                        child: const Text('ذخیره هزینه'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
