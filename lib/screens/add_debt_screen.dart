import 'package:flutter/material.dart';
import 'package:daric/models/debt.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/my_date_picker.dart';
import 'package:daric/widgets/main_scaffold.dart';
import 'package:daric/widgets/person_dropdown.dart';
import 'package:daric/models/person.dart';



class AddDebtScreen extends StatefulWidget {
  @override
  _AddDebtScreenState createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _date;
  DateTime? _payDate;
  bool _isLoading = false;
  String? _message;
  int? _selectedPersonId;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _date == null || _payDate == null || _selectedPersonId == null) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final debt = Debt(
      id: 0,
      person: _selectedPersonId != null ? Person(id: _selectedPersonId!, firstName: '', relation: '') : null,
      amount: int.parse(_amountController.text.trim()),
      date: _date!,
      payDate: _payDate!,
      description: _descriptionController.text.trim(),
    );


    final success = await ApiService().addDebt(debt);

    setState(() {
      _isLoading = false;
      _message = success ? 'بدهی با موفقیت ثبت شد' : 'خطا در ثبت بدهی';
    });

    if (success) {
      _selectedPersonId = null;
      _amountController.clear();
      _descriptionController.clear();
      _date = null;
      _payDate = null;
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "افزودن بدهی",
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              PersonDropdown(
                selectedPersonId: _selectedPersonId,
                onChanged: (val) => setState(() => _selectedPersonId = val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'مبلغ'),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'مبلغ را وارد کنید';
                  if (int.tryParse(val) == null || int.parse(val) <= 0) return 'مبلغ باید عدد صحیح مثبت باشد';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'توضیحات'),
                validator: (val) => val == null || val.isEmpty ? 'توضیحات را وارد کنید' : null,
              ),
              const SizedBox(height: 16),
              MyDatePicker(
                label: 'تاریخ ثبت',
                initialDate: _date,
                onDateChanged: (selected) => setState(() => _date = selected),
              ),
              const SizedBox(height: 16),
              MyDatePicker(
                label: 'تاریخ بازپرداخت',
                initialDate: _payDate,
                onDateChanged: (selected) => setState(() => _payDate = selected),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text('ثبت بدهی'),
                    ),
              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.contains('موفق') ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
