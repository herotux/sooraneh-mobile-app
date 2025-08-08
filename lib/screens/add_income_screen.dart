import 'package:flutter/material.dart';
import 'package:daric/models/income.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/utils/entry_type.dart';
import 'package:daric/widgets/finance_form_widget.dart';

class AddIncomeScreen extends StatelessWidget {
  const AddIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('افزودن درآمد'),
      ),
      body: FinanceFormWidget(
        type: EntryType.income,
        onSubmit: (income) async {
          final success = await ApiService().addIncome(income as Income);
          if (success) {
            if (context.mounted) {
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('درآمد با موفقیت ثبت شد'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('خطا در ثبت درآمد'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
          return success;
        },
      ),
    );
  }
}