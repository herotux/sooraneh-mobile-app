import 'package:flutter/material.dart';
import 'package:daric/models/expense.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/utils/entry_type.dart';
import 'package:daric/widgets/finance_form_widget.dart';
import 'package:daric/widgets/main_scaffold.dart'; // ✅ Import MainScaffold

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold( // ✅ Wrap with MainScaffold
      title: 'افزودن هزینه', // Clear title
      body: FinanceFormWidget(
        type: EntryType.expense,
        onSubmit: (expense) async {
          final newExpense = await ApiService().addExpense(expense as Expense);
          if (newExpense != null) {
            if (context.mounted) {
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('هزینه با موفقیت ثبت شد'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('خطا در ثبت هزینه'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
          return newExpense != null;
        },
      ),
    );
  }
}