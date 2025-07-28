import 'package:flutter/material.dart';
import 'package:daric/models/credit.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/my_date_picker.dart';
import 'package:daric/widgets/main_scaffold.dart';
import 'package:daric/widgets/person_dropdown.dart';
import 'package:daric/models/person.dart';



class AddCreditScreen extends StatefulWidget {
  @override
  _AddCreditScreenState createState() => _AddCreditScreenState();
}

class _AddCreditScreenState extends State<AddCreditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  int? _selectedPersonId;
  DateTime? _date;
  DateTime? _payDate;
  bool _isLoading = false;
  String? _message;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _date == null || _payDate == null || _selectedPersonId == null) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final credit = Credit(
      id: 0,
      person: _selectedPersonId != null ? Person(id: _selectedPersonId!, firstName: '') : null,
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
      _selectedPersonId = null;
      _amountController.clear();
      _date = null;
      _payDate = null;
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "افزودن اعتبار",
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              /// شخص انتخابی
              PersonDropdown(
                onChanged: (personId) {
                  setState(() => _selectedPersonId = personId);
                },
                initialPersonId: _selectedPersonId,
              ),

              SizedBox(height: 16),

              /// مبلغ
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

              SizedBox(height: 16),

              /// تاریخ ثبت
              MyDatePicker(
                label: 'تاریخ ثبت',
                initialDate: _date,
                onDateChanged: (selected) {
                  setState(() => _date = selected);
                },
              ),

              SizedBox(height: 16),

              /// تاریخ بازپرداخت
              MyDatePicker(
                label: 'تاریخ بازپرداخت',
                initialDate: _payDate,
                onDateChanged: (selected) {
                  setState(() => _payDate = selected);
                },
              ),

              SizedBox(height: 24),

              /// دکمه ثبت
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
