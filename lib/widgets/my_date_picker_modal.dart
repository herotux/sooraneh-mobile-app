import 'package:flutter/material.dart';
import 'package:daric/widgets/my_date_picker.dart';

Future<DateTime?> showMyDatePickerModal({
  required BuildContext context,
  required String label,
  DateTime? initialDate,
}) async {
  DateTime? selectedDate = initialDate;

  return await showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            MyDatePicker(
              label: label,
              initialDate: selectedDate,
              onDateChanged: (date) => selectedDate = date,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('انصراف'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(selectedDate),
                  child: Text('تأیید'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
