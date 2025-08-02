import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:daric/models/expense.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/person_dropdown.dart';
import 'package:daric/widgets/my_date_picker_modal.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;
  const EditExpenseScreen({Key? key, required this.expense}) : super(key: key);

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _textController;
  late TextEditingController _amountController;
  DateTime? _selectedDate;
  int? _selectedPersonId;

  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.expense.text);
    _amountController = TextEditingController(text: widget.expense.amount.toString());
    _selectedDate = DateTime.tryParse(widget.expense.date);
    _selectedPersonId = widget.expense.personId;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showError('لطفاً تاریخ را انتخاب کنید');
      return;
    }

    setState(() => _loading = true);

    final updatedExpense = Expense(
      id: widget.expense.id,
      text: _textController.text.trim(),
      amount: int.tryParse(_amountController.text.trim()) ?? 0,
      date: _selectedDate!.toIso8601String(),
      personId: _selectedPersonId,
      category: widget.expense.category,
      tag: widget.expense.tag,
    );

    final success = await _apiService.updateExpense(updatedExpense);
    setState(() => _loading = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      _showError('خطا در ذخیره تغییرات');
    }
  }

  Future<void> _pickDate() async {
    final picked = await showMyDatePickerModal(
      context: context,
      label: 'تاریخ هزینه',
      initialDate: _selectedDate,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final j = Jalali.fromDateTime(date);
    return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('ویرایش هزینه')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _textController,
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
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
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
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'تاریخ',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _selectedDate != null
                                ? _formatDate(_selectedDate!)
                                : 'انتخاب تاریخ',
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
                        onPressed: _submit,
                        child: const Text('ذخیره تغییرات'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
