import 'package:flutter/material.dart';
import 'package:daric/models/expense.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/utils/entry_type.dart';
import 'package:daric/widgets/finance_form_widget.dart';
import 'package:daric/widgets/main_scaffold.dart';

class EditExpenseScreen extends StatelessWidget {
  final Expense expense;

  const EditExpenseScreen({required this.expense, super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "ویرایش هزینه",
      body: FinanceFormWidget(
        type: EntryType.expense,
        initialEntry: expense,
        onSubmit: (updatedEntry) async {
          final success = await ApiService().updateExpense(updatedEntry as Expense);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'ویرایش هزینه با موفقیت انجام شد' : 'خطا در ویرایش هزینه'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
          if (success) {
            Navigator.pop(context, true);
          }
          return success;
        },
      ),
    );
  }
}