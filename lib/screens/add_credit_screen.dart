import 'package:flutter/material.dart';
import 'package:daric/models/credit.dart';
import 'package:daric/services/api_service.dart';

class AddCreditScreen extends StatefulWidget {
  @override
  _AddCreditScreenState createState() => _AddCreditScreenState();
}

class _AddCreditScreenState extends State<AddCreditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _personController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _date;
  DateTime? _payDate;
  bool _isLoading = false;
  String? _message;

  Future<void> _pickDate(BuildContext context, bool isPayDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: Locale('fa'),
    );
    if (picked != null) {
      setState(() {
        if (isPayDate) {
          _payDate = picked;
        } else {
          _date = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _date == null || _payDate == null) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final credit = Credit(
      id: 0,
      personName: _personController.text.trim(),
      amount: int.parse(_amountController.text.trim()),
      date: _date!,
      payDate: _payDate!,
      description: null,
    );

    final success = await ApiService().addCredit(credit);

    setState(() {
      _isLoading = false;
      _message = success ? 'اعتبار با موفقیت ثبت شد' : 'خطا در ثبت اعتبار';
    });

    if (success) {
      _personController.clear();
      _amountController.clear();
      _date = null;
      _payDate = null;
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('افزودن اعتبار')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _personController,
                decoration: InputDecoration(labelText: 'نام شخص'),
                validator: (val) => val == null || val.isEmpty ? 'نام شخص را وارد کنید' : null,
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
                title: Text(_date == null ? 'تاریخ ثبت' : 'تاریخ ثبت: ${_date!.toLocal().toString().split(' ')[0]}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickDate(context, false),
              ),
              ListTile(
                title: Text(_payDate == null ? 'تاریخ بازپرداخت' : 'تاریخ بازپرداخت: ${_payDate!.toLocal().toString().split(' ')[0]}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickDate(context, true),
              ),
              SizedBox(height: 24),
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submit,
                  child: Text('ثبت اعتبار'),
                ),
              if (_message != null) ...[
                SizedBox(height: 16),
                Text(
                  _message!,
                  style: TextStyle(color: _message!.contains('موفق') ? Colors.green : Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
