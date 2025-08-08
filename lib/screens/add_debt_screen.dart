import 'package:flutter/material.dart';
import 'package:daric/models/debt.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/utils/entry_type.dart';
import 'package:daric/widgets/finance_form_widget.dart';

class AddDebtScreen extends StatelessWidget {
  const AddDebtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FinanceFormWidget(
      type: EntryType.debt,
      onSubmit: (debt) async {
        final success = await ApiService().addDebt(debt as Debt);
        if (success) {
          if (context.mounted) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('بدهی با موفقیت ثبت شد'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('خطا در ثبت بدهی'),
              backgroundColor: Colors.red,
            ),
          );
        }

        return success;
      },
    );
  }
}