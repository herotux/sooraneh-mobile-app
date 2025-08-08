import 'package:flutter/material.dart';
import 'package:daric/widgets/my_date_picker_modal.dart';
import 'package:daric/widgets/person_dropdown.dart';
import 'package:daric/utils/entry_type.dart';
import 'package:daric/models/income.dart';
import 'package:daric/models/expense.dart';
import 'package:daric/models/credit.dart';
import 'package:daric/models/debt.dart';

class FinanceFormWidget extends StatefulWidget {
  final EntryType type;
  final dynamic initialEntry;
  final Future<bool> Function(dynamic entry) onSubmit;

  const FinanceFormWidget({
    super.key,
    required this.type,
    required this.onSubmit,
    this.initialEntry,
  });

  @override
  State<FinanceFormWidget> createState() => _FinanceFormWidgetState();
}

class _FinanceFormWidgetState extends State<FinanceFormWidget> {
  final _formKey = GlobalKey<FormState>();
  String _description = '';
  double? _amount;
  DateTime _date = DateTime.now();
  DateTime? _payDate;
  int? _personId;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialValues();
  }

  void _loadInitialValues() {
    final e = widget.initialEntry;
    if (e != null) {
      if (e is Income) {
        _description = e.text;
        _amount = e.amount.toDouble();
        _date = DateTime.parse(e.date);
        _personId = e.personId;
      } else if (e is Expense) {
        _description = e.text;
        _amount = e.amount.toDouble();
        _date = DateTime.parse(e.date);
        _personId = e.personId;
      } else if (e is Credit) {
        _description = e.description ?? '';
        _amount = e.amount.toDouble();
        _date = e.date;
        _payDate = e.payDate;
        _personId = e.personId;
      } else if (e is Debt) {
        _description = e.description;
        _amount = e.amount.toDouble();
        _date = e.date;
        _payDate = e.payDate;
        _personId = e.personId;
      }
    }
  }

  Future<void> _selectDate({required bool isPayDate}) async {
    final picked = await showMyDatePickerModal(
      context: context,
      label: isPayDate ? 'تاریخ تسویه' : 'تاریخ ثبت',
      initialDate: isPayDate ? (_payDate ?? DateTime.now()) : _date,
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
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    dynamic entry;
    try {
      final id = widget.initialEntry?.id; // گرفتن id برای حالت ویرایش

      switch (widget.type) {
        case EntryType.income:
          entry = Income(
            id: id,
            amount: _amount!.toInt(),
            text: _description,
            date: _date.toIso8601String(),
            personId: _personId,
          );
          break;

        case EntryType.expense:
          entry = Expense(
            id: id,
            amount: _amount!.toInt(),
            text: _description,
            date: _date.toIso8601String(),
            personId: _personId,
          );
          break;

        case EntryType.credit:
          if (_payDate == null) throw Exception("تاریخ تسویه لازم است");
          entry = Credit(
            id: id ?? 0,
            amount: _amount!.toInt(),
            description: _description,
            date: _date,
            payDate: _payDate!,
            personId: _personId,
          );
          break;

        case EntryType.debt:
          if (_payDate == null) throw Exception("تاریخ تسویه لازم است");
          entry = Debt(
            id: id ?? 0,
            amount: _amount!.toInt(),
            description: _description,
            date: _date,
            payDate: _payDate!,
            personId: _personId,
          );
          break;
      }

      final success = await widget.onSubmit(entry);
      if (success && mounted) {
        Navigator.pop(context, true);
      } else {
        setState(() => _errorMessage = 'خطا در ذخیره اطلاعات');
      }
    } catch (e) {
      setState(() => _errorMessage = 'خطا: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    initialValue: _description,
                    decoration: const InputDecoration(
                      labelText: 'توضیحات',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'توضیح را وارد کنید' : null,
                    onSaved: (val) => _description = val!.trim(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _amount?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'مبلغ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      final parsed = double.tryParse(val ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'مبلغ معتبر نیست';
                      }
                      return null;
                    },
                    onSaved: (val) => _amount = double.tryParse(val!),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(isPayDate: false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'تاریخ ثبت',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_formatDate(_date)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.type == EntryType.credit || widget.type == EntryType.debt)
                    InkWell(
                      onTap: () => _selectDate(isPayDate: true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'تاریخ تسویه',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _payDate != null ? _formatDate(_payDate!) : 'انتخاب نشده',
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  PersonDropdown(
                    selectedPersonId: _personId,
                    onChanged: (id) => _personId = id,
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
                    child: const Text('ذخیره'),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}