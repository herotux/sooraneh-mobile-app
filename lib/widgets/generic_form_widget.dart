import 'package:flutter/material.dart';
import 'package:daric/widgets/person_dropdown.dart';
import 'package:daric/widgets/my_date_picker.dart';

class GenericFormWidget extends StatefulWidget {
  final String title;
  final int? initialPersonId;
  final String? initialAmount;
  final String? initialDescription;
  final DateTime? initialDate;
  final DateTime? initialPayDate;

  final bool showPersonDropdown;
  final bool showPayDate;

  final bool isLoading;
  final String submitButtonText;

  final Future<void> Function(Map<String, dynamic>) onSubmit;

  const GenericFormWidget({
    super.key,
    required this.title,
    required this.onSubmit,
    this.initialPersonId,
    this.initialAmount,
    this.initialDescription,
    this.initialDate,
    this.initialPayDate,
    this.showPersonDropdown = false,
    this.showPayDate = false,
    this.isLoading = false,
    this.submitButtonText = 'ثبت',
  });

  @override
  State<GenericFormWidget> createState() => _GenericFormWidgetState();
}

class _GenericFormWidgetState extends State<GenericFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  int? _selectedPersonId;
  DateTime? _date;
  DateTime? _payDate;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.initialAmount ?? '');
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
    _selectedPersonId = widget.initialPersonId;
    _date = widget.initialDate;
    _payDate = widget.initialPayDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate() || _date == null || (widget.showPayDate && _payDate == null)) return;

    setState(() => _isSubmitting = true);

    final formData = {
      'personId': _selectedPersonId,
      'amount': int.parse(_amountController.text.trim()),
      'description': _descriptionController.text.trim(),
      'date': _date,
      'payDate': _payDate,
    };

    await widget.onSubmit(formData);

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.showPersonDropdown)
            PersonDropdown(
              selectedPersonId: _selectedPersonId,
              onChanged: (val) => setState(() => _selectedPersonId = val),
            ),

          if (widget.showPersonDropdown) const SizedBox(height: 16),

          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'مبلغ'),
            keyboardType: TextInputType.number,
            validator: (val) {
              if (val == null || val.isEmpty) return 'مبلغ را وارد کنید';
              if (int.tryParse(val) == null || int.parse(val) <= 0) return 'مبلغ باید عدد صحیح مثبت باشد';
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'توضیحات'),
            maxLines: 2,
            validator: (val) => val == null || val.isEmpty ? 'توضیحات را وارد کنید' : null,
          ),

          const SizedBox(height: 24),

          MyDatePicker(
            label: 'تاریخ',
            initialDate: _date,
            onDateChanged: (selected) => setState(() => _date = selected),
          ),

          if (widget.showPayDate) ...[
            const SizedBox(height: 24),
            MyDatePicker(
              label: 'تاریخ بازپرداخت',
              initialDate: _payDate,
              onDateChanged: (selected) => setState(() => _payDate = selected),
            ),
          ],

          const SizedBox(height: 32),

          _isSubmitting || widget.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text(widget.submitButtonText),
                ),
        ],
      ),
    );
  }
}
