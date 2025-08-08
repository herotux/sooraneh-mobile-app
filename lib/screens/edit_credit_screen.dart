import 'package:flutter/material.dart';
import 'package:daric/models/credit.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/utils/entry_type.dart';
import 'package:daric/widgets/finance_form_widget.dart';
import 'package:daric/widgets/main_scaffold.dart';

class EditCreditScreen extends StatelessWidget {
  final Credit credit;
  const EditCreditScreen({required this.credit, super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "ویرایش طلب",
      body: FinanceFormWidget(
        type: EntryType.credit,
        initialEntry: credit,
        onSubmit: (updatedEntry) async {
          // updatedEntry در اینجا از نوع Credit است
          final success = await ApiService().updateCredit(updatedEntry as Credit);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'ویرایش با موفقیت انجام شد' : 'خطا در ویرایش طلب'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
          return success;
        },
      ),
    );
  }
}