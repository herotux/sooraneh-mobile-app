import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:daric/models/expense.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/my_date_picker.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({Key? key, required this.expense}) : super(key: key);

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  DateTime? _selectedDate;

  bool _loading = false;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.title);
    _amountController = TextEditingController(text: widget.expense.amount.toString());
    _descriptionController = TextEditingController(text: widget.expense.description ?? '');
    _selectedDate = widget.expense.date ?? DateTime.now();
  }

  DateTime _jalaliToGregorian(DateTime jalaliDate) {
    final j = Jalali(jalaliDate.year, jalaliDate.month, jalaliDate.day);
    final g = j.toGregorian();
    return DateTime(g.year, g.month, g.day);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      _showError('لطفا تاریخ را انتخاب کنید');
      return;
    }

    setState(() => _loading = true);

    // تبدیل تاریخ شمسی به میلادی
    final gregorianDate = _jalaliToGregorian(_selectedDate!);

    final updatedExpense = Expense(
      id: widget.expense.id,
      title: _titleController.text.trim(),
      amount: double.tryParse(_amountController.text.trim()) ?? 0,
      description: _descriptionController.text.trim(),
      date: gregorianDate,
    );

    final success = await _apiService.updateExpense(updatedExpense);

    setState(() => _loading = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      _showError('خطا در ذخیره تغییرات');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'عنوان'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'عنوان را وارد کنید' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'مبلغ'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'مبلغ را وارد کنید' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'توضیحات'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    MyDatePicker(
                      label: 'تاریخ',
                      initialDate: _selectedDate,
                      onDateChanged: (date) {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('ذخیره تغییرات'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
