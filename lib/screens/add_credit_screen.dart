import 'package:flutter/material.dart';
import 'package:daric/models/credit.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/utils/entry_type.dart';
import 'package:daric/widgets/finance_form_widget.dart';

class AddCreditScreen extends StatelessWidget {
  const AddCreditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FinanceFormWidget(
      type: EntryType.credit,
      onSubmit: (credit) async {
        final success = await ApiService().addCredit(credit as Credit);
        if (success) {
          if (context.mounted) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('اعتبار با موفقیت ثبت شد'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('خطا در ثبت اعتبار'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return success;
      },
    );
  }
}