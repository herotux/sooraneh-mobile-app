import 'package:flutter/material.dart';
import 'package:daric/models/expense.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/finance_form_widget.dart';

class EditExpenseScreen extends StatelessWidget {
  final Expense expense;

  const EditExpenseScreen({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('ویرایش هزینه')),
        body: FinanceFormWidget(
          type: EntryType.expense,
          initialExpense: expense,
          onSubmit: (updatedExpense) async {
            final success = await ApiService().updateExpense(updatedExpense);
            if (success) {
              if (context.mounted) Navigator.pop(context, true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('خطا در ذخیره تغییرات')),
              );
            }
          },
        ),
      ),
    );
  }
}
