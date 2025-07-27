import 'package:flutter/material.dart';
import 'package:daric/models/income.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/main_scaffold.dart';

class AddIncomeScreen extends StatefulWidget {
  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('fa'),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) return;

    setState(() => _isLoading = true);

    final income = Income(
      id: 0,
      text: _textController.text.trim(),
      amount: int.parse(_amountController.text.trim()),
      date: _selectedDate!.toIso8601String(),
    );

    final success = await ApiService().addIncome(income);

    setState(() => _isLoading = false);
    if (success) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      appBar: AppBar(title: Text('افزودن درآمد')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _textController,
                decoration: InputDecoration(labelText: 'عنوان درآمد'),
                validator: (val) => val == null || val.isEmpty ? 'عنوان را وارد کنید' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'مبلغ'),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'مبلغ را وارد کنید';
                  if (int.tryParse(val) == null) return 'مبلغ باید عدد باشد';
                  return null;
                },
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(_selectedDate == null
                    ? 'تاریخ را انتخاب کنید'
                    : 'تاریخ: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              SizedBox(height: 24),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text('ثبت درآمد'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
