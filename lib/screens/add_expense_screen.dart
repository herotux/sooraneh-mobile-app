import 'package:flutter/material.dart';
import 'package:daric/models/expense.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/finance_form_widget.dart';

class AddExpenseScreen extends StatelessWidget {
  final ApiService _api = ApiService();

  AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FinanceFormWidget(
      title: 'افزودن هزینه',
      saveButtonText: 'ذخیره هزینه',
      onSubmit: ({
        required String description,
        required double amount,
        required DateTime date,
        required int? personId,
      }) async {
        final expense = Expense(
          id: 0,
          text: description,
          amount: amount.toInt(),
          date: date.toIso8601String(),
          personId: personId,
        );
        return await _api.addExpense(expense);
      },
    );
  }
}
