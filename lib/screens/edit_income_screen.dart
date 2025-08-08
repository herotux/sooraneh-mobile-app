import 'package:flutter/material.dart';
import 'package:daric/models/income.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/utils/entry_type.dart';
import 'package:daric/widgets/finance_form_widget.dart';
import 'package:daric/widgets/main_scaffold.dart';

class EditIncomeScreen extends StatelessWidget {
  final Income income;

  const EditIncomeScreen({required this.income, super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "ویرایش درآمد",
      body: FinanceFormWidget(
        type: EntryType.income,
        initialEntry: income,
        onSubmit: (updatedEntry) async {
          final success = await ApiService().updateIncome(updatedEntry as Income);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'ویرایش درآمد با موفقیت انجام شد' : 'خطا در ویرایش درآمد'),
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