import 'package:flutter/material.dart';
import 'package:daric/models/income.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/utils/entry_type.dart';
import 'package:daric/widgets/finance_form_widget.dart';
import 'package:daric/widgets/main_scaffold.dart'; // ✅ Import MainScaffold

class AddIncomeScreen extends StatelessWidget {
  const AddIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold( // ✅ Use MainScaffold instead of Scaffold
      title: 'افزودن درآمد',
      body: FinanceFormWidget(
        type: EntryType.income,
        onSubmit: (income) async {
          final newIncome = await ApiService().addIncome(income as Income);
          if (newIncome != null) {
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
          return newIncome != null;
        },
      ),
    );
  }
}