import 'package:flutter/material.dart';
import 'package:daric/models/debt.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/utils/entry_type.dart';
import 'package:daric/widgets/finance_form_widget.dart';
import 'package:daric/widgets/main_scaffold.dart';

class EditDebtScreen extends StatelessWidget {
  final Debt debt;

  const EditDebtScreen({required this.debt, super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "ویرایش بدهی",
      body: FinanceFormWidget(
        type: EntryType.debt,
        initialEntry: debt,
        onSubmit: (updatedEntry) async {
          // updatedEntry از نوع Debt است
          final success = await ApiService().updateDebt(updatedEntry as Debt);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'ویرایش بدهی با موفقیت انجام شد' : 'خطا در ویرایش بدهی'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
          if (success) Navigator.pop(context, true);
          return success;
        },
      ),
    );
  }
}