import 'package:flutter/material.dart';
import 'package:date_picker_plus/date_picker_plus.dart';

class MyDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateChanged;
  final String label;

  const MyDatePicker({
    Key? key,
    this.initialDate,
    required this.onDateChanged,
    required this.label,
  }) : super(key: key);

  @override
  State<MyDatePicker> createState() => _MyDatePickerState();
}

class _MyDatePickerState extends State<MyDatePicker> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  Future<void> _showPicker() async {
    final picked = await showDatePickerDialog(
        context: context,
        initialDate: _selectedDate,
        datePickerType: DatePickerType.Persian,
    );


    if (picked != null) {
      setState(() => _selectedDate = picked);
      widget.onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _showPicker,
          child: Text(
            'انتخاب تاریخ: ${_selectedDate.toLocal().toString().split(' ')[0]}',
          ),
        ),
      ],
    );
  }
}
