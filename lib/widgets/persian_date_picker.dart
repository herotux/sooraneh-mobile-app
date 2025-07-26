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

  Future<void> _showDatePicker() async {
    final picked = await showDatePickerDialog(
      context: context,
      initialDate: _selectedDate,
      datePickerType: DatePickerType.persian, // تاریخ شمسی در نسخه ۴ به پایین نوشته شده
      // تنظیمات اختیاری دیگر:
      firstDate: DateTime(1300, 1, 1),
      lastDate: DateTime(1500, 12, 29),
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
        Text(widget.label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _showDatePicker,
          icon: Icon(Icons.date_range),
          label: Text('${_selectedDate.toLocal().toString().split(' ')[0]}'),
        ),
      ],
    );
  }
}
