import 'package:flutter/material.dart';
import 'package:daric/widgets/my_date_picker_modal.dart';
import 'package:daric/widgets/person_dropdown.dart';

class FinanceFormWidget extends StatefulWidget {
  final String title;
  final String saveButtonText;
  final Future<bool> Function({
    required String description,
    required double amount,
    required DateTime date,
    required int? personId,
  }) onSubmit;
  final DateTime? initialDate;

  const FinanceFormWidget({
    super.key,
    required this.title,
    required this.saveButtonText,
    required this.onSubmit,
    this.initialDate,
  });

  @override
  State<FinanceFormWidget> createState() => _FinanceFormWidgetState();
}

class _FinanceFormWidgetState extends State<FinanceFormWidget> {
  final _formKey = GlobalKey<FormState>();
  String _description = '';
  double? _amount;
  DateTime _selectedDate = DateTime.now();
  int? _selectedPersonId;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  Future<void> _selectDate() async {
    final picked = await showMyDatePickerModal(
      context: context,
      label: 'انتخاب تاریخ',
      initialDate: _selectedDate,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.onSubmit(
        description: _description,
        amount: _amount!,
        date: _selectedDate,
        personId: _selectedPersonId,
      );

      if (success && mounted) Navigator.pop(context, true);
      if (!success) {
        setState(() {
          _errorMessage = 'خطا در ذخیره اطلاعات';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطا: $e';
      });
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: _isSaving
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'توضیحات',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'توضیح را وارد کنید';
                          }
                          if (val.trim().length > 30) {
                            return 'حداکثر ۳۰ کاراکتر';
                          }
                          return null;
                        },
                        onSaved: (val) => _description = val!.trim(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'مبلغ',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'مبلغ را وارد کنید';
                          }
                          final parsed = double.tryParse(val.replaceAll(',', ''));
                          if (parsed == null || parsed <= 0) {
                            return 'مبلغ نامعتبر است';
                          }
                          return null;
                        },
                        onSaved: (val) =>
                            _amount = double.tryParse(val!.replaceAll(',', '')),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'تاریخ',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            '${_selectedDate.year}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PersonDropdown(
                        selectedPersonId: _selectedPersonId,
                        onChanged: (id) => _selectedPersonId = id,
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text(widget.saveButtonText),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
