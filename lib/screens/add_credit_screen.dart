import 'package:flutter/material.dart';
import 'package:daric/models/credit.dart';
import 'package:daric/models/person.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/generic_form_widget.dart';
import 'package:daric/widgets/main_scaffold.dart';

class AddCreditScreen extends StatelessWidget {
  const AddCreditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "افزودن اعتبار",
      body: GenericFormWidget(
        title: "افزودن اعتبار",
        showPersonDropdown: true,
        showPayDate: true,
        submitButtonText: 'ثبت اعتبار',
        onSubmit: (data) async {
          final credit = Credit(
            id: 0,
            person: data['personId'] != null
                ? Person(id: data['personId'], firstName: '', relation: '')
                : null,
            amount: data['amount'],
            date: data['date'],
            payDate: data['payDate'],
            description: data['description'],
          );

          final success = await ApiService().addCredit(credit);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'اعتبار با موفقیت ثبت شد' : 'خطا در ثبت اعتبار'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );

          if (success) Navigator.pop(context, true);
        },
      ),
    );
  }
}
