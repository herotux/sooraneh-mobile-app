import 'package:flutter/material.dart';
import 'package:daric/models/credit.dart';
import 'package:daric/services/api_service.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:daric/widgets/my_date_picker.dart'; // فرض بر اینکه این ویجت رو ساختید

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
  Jalali? _date;
  Jalali? _payDate;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.credit.description ?? '');
    _amountController = TextEditingController(text: widget.credit.amount.toString());
    _date = Jalali.fromDateTime(widget.credit.date);
    _payDate = Jalali.fromDateTime(widget.credit.payDate);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null || _payDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لطفاً تاریخ‌ها را انتخاب کنید')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final updatedCredit = Credit(
      id: widget.credit.id,
      personName: widget.credit.personName,
      description: _descriptionController.text.trim(),
      amount: int.parse(_amountController.text.trim()),
      date: _date!.toDateTime(),
      payDate: _payDate!.toDateTime(),
    );

    final success = await _apiService.updateCredit(updatedCredit);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('اعتبار با موفقیت ویرایش شد')),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ویرایش اعتبار')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ویرایش اعتبار')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'توضیحات'),
                validator: (val) => val == null || val.isEmpty ? 'توضیحات را وارد کنید' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'مبلغ'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'مبلغ را وارد کنید';
                  if (int.tryParse(val) == null) return 'مبلغ باید عدد باشد';
                  return null;
                },
              ),
              SizedBox(height: 16),

              MyDatePicker(
                initialDate: _date?.toDateTime(),
                label: 'تاریخ اعتبار',
                onDateChanged: (selectedDate) {
                  setState(() {
                    _date = Jalali.fromDateTime(selectedDate);
                  });
                },
              ),

              SizedBox(height: 16),

              MyDatePicker(
                initialDate: _payDate?.toDateTime(),
                label: 'تاریخ پرداخت',
                onDateChanged: (selectedDate) {
                  setState(() {
                    _payDate = Jalali.fromDateTime(selectedDate);
                  });
                },
              ),

              SizedBox(height: 24),

              _isLoading
                  ? Center(child: CircularProgressIndicator())
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
