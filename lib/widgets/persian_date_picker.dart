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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        DatePicker(
          initialDate: _selectedDate,
          mode: DatePickerMode.date,
          datePickerType: DatePickerType.Persian, // تاریخ شمسی
          onChanged: (date) {
            setState(() => _selectedDate = date);
            widget.onDateChanged(date);
          },
        ),
      ],
    );
  }
}
