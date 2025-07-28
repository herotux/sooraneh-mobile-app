import 'package:flutter/material.dart';
import 'package:daric/models/debt.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/my_date_picker.dart';
import 'package:daric/widgets/main_scaffold.dart';
import 'package:daric/widgets/person_dropdown.dart';
import 'package:daric/models/person.dart';



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
  late DateTime _date;
  late DateTime _payDate;
  int? _selectedPersonId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.debt.description);
    _amountController = TextEditingController(text: widget.debt.amount.toString());
    _date = widget.debt.date;
    _payDate = widget.debt.payDate;
    _selectedPersonId = widget.debt.person?.id; // ✅ استخراج id از person
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

    final updatedDebt = Debt(
      id: widget.debt.id,
      person: _selectedPersonId != null ? Person(id: _selectedPersonId!, firstName: '') : null, // ✅ تبدیل id به شیء Person
      description: _descriptionController.text.trim(),
      amount: int.parse(_amountController.text.trim()),
      date: _date,
      payDate: _payDate,
    );

    final success = await ApiService().updateDebt(updatedDebt);

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'بدهی با موفقیت ویرایش شد' : 'خطا در ویرایش بدهی')),
    );

    if (success) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "ویرایش بدهی",
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              PersonDropdown(
                initialPersonId: _selectedPersonId,
                onChanged: (val) => setState(() => _selectedPersonId = val),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'توضیحات'),
                validator: (val) => val == null || val.isEmpty ? 'وارد کردن توضیحات الزامی است' : null,
              ),
              const SizedBox(height: 24),
              MyDatePicker(
                label: 'تاریخ بدهی',
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
