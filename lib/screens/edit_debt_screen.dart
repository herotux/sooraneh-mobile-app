import 'package:flutter/material.dart';
import 'package:daric/models/debt.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/persian_date_picker.dart';

class EditDebtScreen extends StatefulWidget {
  final Debt debt;

  const EditDebtScreen({required this.debt, Key? key}) : super(key: key);

  @override
  State<EditDebtScreen> createState() => _EditDebtScreenState();
}

class _EditDebtScreenState extends State<EditDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  DateTime? _date;
  DateTime? _payDate;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.debt.description);
    _amountController = TextEditingController(text: widget.debt.amount.toString());
    _date = widget.debt.date;
    _payDate = widget.debt.payDate;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedDebt = Debt(
      id: widget.debt.id,
      personName: widget.debt.personName,
      description: _descriptionController.text.trim(),
      amount: int.parse(_amountController.text.trim()),
      date: _date ?? DateTime.now(),
      payDate: _payDate ?? DateTime.now(),
      personId: widget.debt.personId,
    );

    final success = await _apiService.updateDebt(updatedDebt);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('بدهی با موفقیت ویرایش شد')),
      );
      Navigator.of(context).pop(true);
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
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'توضیحات'),
                validator: (val) => val == null || val.isEmpty ? 'وارد کردن توضیحات الزامی است' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'مبلغ'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'مبلغ را وارد کنید';
                  final n = int.tryParse(val);
                  if (n == null || n <= 0) return 'مبلغ باید عدد صحیح مثبت باشد';
                  return null;
                },
              ),
              SizedBox(height: 16),
              MyDatePicker(
                initialDate: _date,
                label: 'تاریخ بدهی',
                onDateChanged: (date) => _date = date,
              ),
              SizedBox(height: 16),
              MyDatePicker(
                initialDate: _payDate,
                label: 'تاریخ پرداخت',
                onDateChanged: (date) => _payDate = date,
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
