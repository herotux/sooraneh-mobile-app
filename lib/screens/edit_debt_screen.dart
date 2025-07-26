import 'package:flutter/material.dart';
import 'package:daric/models/debt.dart';
import 'package:daric/services/api_service.dart';

class EditDebtScreen extends StatefulWidget {
  final Debt debt;

  const EditDebtScreen({required this.debt, Key? key}) : super(key: key);

  @override
  State<EditDebtScreen> createState() => _EditDebtScreenState();
}

class _EditDebtScreenState extends State<EditDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _textController;
  late TextEditingController _amountController;
  late TextEditingController _payDateController;
  late TextEditingController _dateController;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.debt.text);
    _amountController = TextEditingController(text: widget.debt.amount.toString());
    _dateController = TextEditingController(text: widget.debt.date.toLocal().toString().split(' ')[0]);
    _payDateController = TextEditingController(text: widget.debt.payDate.toLocal().toString().split(' ')[0]);
  }

  @override
  void dispose() {
    _textController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _payDateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedDebt = Debt(
      id: widget.debt.id,
      personName: widget.debt.personName,
      text: _textController.text,
      amount: int.parse(_amountController.text),
      date: DateTime.parse(_dateController.text),
      payDate: DateTime.parse(_payDateController.text),
    );

    final success = await _apiService.updateDebt(updatedDebt);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('بدهی با موفقیت ویرایش شد')),
      );
      Navigator.of(context).pop(true); // برگرد و اعلام موفقیت کن
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ویرایش بدهی')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ویرایش بدهی')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _textController,
                decoration: InputDecoration(labelText: 'توضیحات'),
                validator: (val) => val == null || val.isEmpty ? 'وارد کردن توضیحات الزامی است' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'مبلغ'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'مبلغ را وارد کنید' : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'تاریخ بدهی (YYYY-MM-DD)'),
                validator: (val) => val == null || val.isEmpty ? 'تاریخ را وارد کنید' : null,
              ),
              TextFormField(
                controller: _payDateController,
                decoration: InputDecoration(labelText: 'تاریخ پرداخت (YYYY-MM-DD)'),
                validator: (val) => val == null || val.isEmpty ? 'تاریخ پرداخت را وارد کنید' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text('ذخیره تغییرات'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
