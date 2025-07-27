import 'package:flutter/material.dart';
import 'package:flutter_linear_datepicker/flutter_datepicker.dart';

class MyDatePicker extends StatefulWidget {
  final String label;
  final DateTime? initialDate;
  final Function(DateTime) onDateChanged;

  const MyDatePicker({
    Key? key,
    required this.label,
    this.initialDate,
    required this.onDateChanged,
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
        Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        LinearDatePicker(
          isJalali: true,
          initialDate: _selectedDate,
          startDate: DateTime(1370, 1, 1),
          endDate: DateTime(1450, 12, 29),
          showLabels: true,
          showDay: true,
          columnWidth: 80,
          labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          selectedRowStyle: const TextStyle(fontSize: 16, color: Colors.blue),
          unselectedRowStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          dateChangeListener: (selectedDate) {
            setState(() => _selectedDate = selectedDate);
            widget.onDateChanged(selectedDate);
          },
        ),
      ],
    );
  }
}
