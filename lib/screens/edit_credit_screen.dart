import 'package:flutter/material.dart';
import 'package:daric/models/credit.dart';
import 'package:daric/services/api_service.dart';

class EditCreditScreen extends StatefulWidget {
  final Credit credit;

  EditCreditScreen({required this.credit});

  @override
  State<EditCreditScreen> createState() => _EditCreditScreenState();
}

class _EditCreditScreenState extends State<EditCreditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _personController;
  late TextEditingController _amountController;
  late TextEditingController _textController;
  late TextEditingController _payDateController;
  DateTime? _selectedPayDate;

  bool _isLoading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _personController = TextEditingController(text: widget.credit.personName);
    _amountController = TextEditingController(text: widget.credit.amount.toString());
    _textController = TextEditingController(text: widget.credit.text);
    _selectedPayDate = widget.credit.payDate;
    _payDateController = TextEditingController(text: _selectedPayDate!.toLocal().toString().split(' ')[0]);
  }

  @override
  void dispose() {
    _personController.dispose();
    _amountController.dispose();
    _textController.dispose();
    _payDateController.dispose();
    super.dispose();
  }

  Future<void> _pickPayDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedPayDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('fa'),
    );
    if (picked != null) {
      setState(() {
        _selectedPayDate = picked;
        _payDateController.text = _selectedPayDate!.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final updatedCredit = Credit(
      id: widget.credit.id,
      personName: _personController.text.trim(),
      amount: int.parse(_amountController.text.trim()),
      text: _textController.text.trim(),
      date: widget.credit.date,
      payDate: _selectedPayDate ?? widget.credit.payDate,
    );

    final success = await ApiService().updateCredit(updatedCredit);

    setState(() {
      _isLoading = false;
      _message = success ? 'اعتبار با موفقیت ویرایش شد' : 'خطا در ویرایش اعتبار';
    });

    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ویرایش اعتبار'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _personController,
                decoration: InputDecoration(labelText: 'نام شخص'),
                validator: (value) => value == null || value.isEmpty ? 'نام شخص را وارد کنید' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'مبلغ'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'مبلغ را وارد کنید';
                  if (int.tryParse(value) == null) return 'مبلغ باید عدد باشد';
                  return null;
                },
              ),
              TextFormField(
                controller: _textController,
                decoration: InputDecoration(labelText: 'توضیحات'),
                maxLength: 100,
              ),
              TextFormField(
                controller: _payDateController,
                decoration: InputDecoration(labelText: 'تاریخ بازپرداخت'),
                readOnly: true,
                onTap: _pickPayDate,
              ),
              SizedBox(height: 24),
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submit,
                  child: Text('ذخیره تغییرات'),
                ),
              if (_message != null) ...[
                SizedBox(height: 16),
                Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.contains('موفق') ? Colors.green : Colors.red,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
