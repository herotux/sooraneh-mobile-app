import 'package:flutter/material.dart';
import 'package:daric/models/expense.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/main_scaffold.dart';
import 'package:daric/widgets/my_date_picker.dart';

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

  bool _isSaving = false;
  String? _errorMessage;

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
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
        id: 0, // یا هر عدد موقتی که لازمه
        text: _description,
        amount: _amount!,
        date: _selectedDate.toIso8601String(),
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
      child: MainScaffold(
        title: 'افزودن هزینه',
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
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'توضیح را وارد کنید' : null,
                        onSaved: (val) => _description = val!.trim(),
                        textInputAction: TextInputAction.next,
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
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 24),

                      // استفاده از ویجت دیت‌پیکر سفارشی
                      MyDatePicker(
                        label: 'تاریخ هزینه',
                        initialDate: _selectedDate,
                        onDateChanged: _onDateChanged,
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
