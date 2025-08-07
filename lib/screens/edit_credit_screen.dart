import 'package:flutter/material.dart';
import 'package:daric/models/credit.dart';
import 'package:daric/models/person.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/generic_form_widget.dart';
import 'package:daric/widgets/main_scaffold.dart';

class EditCreditScreen extends StatelessWidget {
  final Credit credit;

  const EditCreditScreen({required this.credit, super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "ویرایش اعتبار",
      body: GenericFormWidget(
        title: "ویرایش اعتبار",
        initialPersonId: credit.person?.id,
        initialAmount: credit.amount.toString(),
        initialDescription: credit.description,
        initialDate: credit.date,
        initialPayDate: credit.payDate,
        showPersonDropdown: true,
        showPayDate: true,
        submitButtonText: 'ذخیره تغییرات',
        onSubmit: (data) async {
          final updatedCredit = Credit(
            id: credit.id,
            person: data['personId'] != null
                ? Person(id: data['personId'], firstName: '', relation: '')
                : null,
            amount: data['amount'],
            date: data['date'],
            payDate: data['payDate'],
            description: data['description'],
          );

          final success = await ApiService().updateCredit(updatedCredit);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'ویرایش با موفقیت انجام شد' : 'خطا در ویرایش اعتبار'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );

          if (success) Navigator.pop(context, true);
        },
      ),
    );
  }
}
