import 'package:flutter/material.dart';
import 'package:daric/models/credit.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/my_date_picker.dart';
import 'package:daric/widgets/main_scaffold.dart';
import 'package:daric/widgets/person_dropdown.dart';
import 'package:daric/models/person.dart';



class EditCreditScreen extends StatefulWidget {
  final Credit credit;

  const EditCreditScreen({required this.credit, Key? key}) : super(key: key);

  @override
  State<EditCreditScreen> createState() => _EditCreditScreenState();
}

class _EditCreditScreenState extends State<EditCreditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;

  late DateTime _date;
  late DateTime _payDate;

  int? _selectedPersonId;

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.credit.description ?? '');
    _amountController = TextEditingController(text: widget.credit.amount.toString());
    _date = widget.credit.date;
    _payDate = widget.credit.payDate;
    _selectedPersonId = widget.credit.person?.id; // ✅ استخراج id از شیء person
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedPersonId == null) return;

    setState(() => _isLoading = true);

    final updatedCredit = Credit(
      id: widget.credit.id,
      person: _selectedPersonId != null ? Person(id: _selectedPersonId!, firstName: '', relation: '') : null, // ✅ تبدیل id به آبجکت Person
      description: _descriptionController.text.trim(),
      amount: int.parse(_amountController.text.trim()),
      date: _date,
      payDate: _payDate,
    );

    final success = await _apiService.updateCredit(updatedCredit);

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'اعتبار با موفقیت ویرایش شد' : 'خطا در ویرایش اعتبار')),
    );

    if (success) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "ویرایش اعتبار",
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              PersonDropdown(
                selectedPersonId: _selectedPersonId,
                onChanged: (personId) {
                  setState(() {
                    _selectedPersonId = personId;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'توضیحات'),
                validator: (val) => val == null || val.isEmpty ? 'توضیحات را وارد کنید' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'مبلغ'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'مبلغ را وارد کنید';
                  if (int.tryParse(val) == null || int.parse(val) <= 0) return 'مبلغ باید عدد صحیح مثبت باشد';
                  return null;
                },
              ),

              const SizedBox(height: 24),

              MyDatePicker(
                label: 'تاریخ اعتبار',
                initialDate: _date,
                onDateChanged: (newDate) => setState(() => _date = newDate),
              ),

              const SizedBox(height: 24),

              MyDatePicker(
                label: 'تاریخ پرداخت',
                initialDate: _payDate,
                onDateChanged: (newDate) => setState(() => _payDate = newDate),
              ),

              const SizedBox(height: 32),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
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
