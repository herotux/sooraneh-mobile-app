import 'package:flutter/material.dart';
import 'package:daric/models/income.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/finance_form_widget.dart';

class EditIncomeScreen extends StatelessWidget {
  final Income income;

  const EditIncomeScreen({super.key, required this.income});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ویرایش درآمد')),
      body: FinanceFormWidget(
        type: EntryType.income,
        initialIncome: income,
        onSubmit: (updated) async {
          final success = await ApiService().updateIncome(updated as Income);
          if (success) {
            if (context.mounted) Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('خطا در ذخیره تغییرات')),
            );
          }
        },
      ),
    );
  }
}
