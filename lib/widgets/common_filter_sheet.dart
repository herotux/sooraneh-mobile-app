import 'package:flutter/material.dart';
import 'package:daric/widgets/my_date_picker_modal.dart';

class CommonFilterSheet extends StatefulWidget {
  final String type; // debt, credit, expense, income
  final Map<String, dynamic>? initialValues;
  final void Function(Map<String, dynamic> filters) onApply;

  const CommonFilterSheet({
    super.key,
    required this.type,
    this.initialValues,
    required this.onApply,
  });

  @override
  State<CommonFilterSheet> createState() => _CommonFilterSheetState();
}

class _CommonFilterSheetState extends State<CommonFilterSheet> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _fromAmount;
  String? _toAmount;
  String? _description;
  String _sort = 'asc';

  @override
  void initState() {
    super.initState();
    final init = widget.initialValues ?? {};
    _fromDate = init['fromDate'];
    _toDate = init['toDate'];
    _fromAmount = init['fromAmount']?.toString();
    _toAmount = init['toAmount']?.toString();
    _description = init['description'];
    _sort = init['sort'] ?? 'asc';
  }

  Future<void> _selectDate({
    required String label,
    DateTime? initialDate,
    required void Function(DateTime date) onDateSelected,
  }) async {
    final picked = await showMyDatePickerModal(
      context: context,
      label: label,
      initialDate: initialDate,
    );
    if (picked != null) {
      setState(() => onDateSelected(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('فیلتر', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 16),

            // از تاریخ
            ListTile(
              title: Text('از تاریخ'),
              subtitle: Text(_fromDate != null
                  ? _fromDate!.toLocal().toString().split(' ')[0]
                  : 'انتخاب نشده'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(
                label: 'از تاریخ',
                initialDate: _fromDate,
                onDateSelected: (d) => _fromDate = d,
              ),
            ),
            const SizedBox(height: 12),

            // تا تاریخ
            ListTile(
              title: Text('تا تاریخ'),
              subtitle: Text(_toDate != null
                  ? _toDate!.toLocal().toString().split(' ')[0]
                  : 'انتخاب نشده'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(
                label: 'تا تاریخ',
                initialDate: _toDate,
                onDateSelected: (d) => _toDate = d,
              ),
            ),

            const SizedBox(height: 16),

            // مبلغ
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'از مبلغ'),
                    onChanged: (v) => _fromAmount = v,
                    controller: TextEditingController(text: _fromAmount),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'تا مبلغ'),
                    onChanged: (v) => _toAmount = v,
                    controller: TextEditingController(text: _toAmount),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // شرح
            TextField(
              decoration: InputDecoration(labelText: 'شرح'),
              onChanged: (v) => _description = v,
              controller: TextEditingController(text: _description),
            ),

            const SizedBox(height: 16),

            // مرتب‌سازی
            Row(
              children: [
                Text('مرتب‌سازی بر اساس تاریخ:'),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _sort,
                  items: const [
                    DropdownMenuItem(value: 'asc', child: Text('صعودی')),
                    DropdownMenuItem(value: 'desc', child: Text('نزولی')),
                  ],
                  onChanged: (v) => setState(() => _sort = v!),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // دکمه‌ها
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  child: Text('انصراف'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: Text('اعمال فیلتر'),
                  onPressed: () {
                    widget.onApply({
                      'fromDate': _fromDate,
                      'toDate': _toDate,
                      'fromAmount': _fromAmount,
                      'toAmount': _toAmount,
                      'description': _description ?? '',
                      'sort': _sort,
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
