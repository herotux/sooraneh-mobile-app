import 'package:flutter/material.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/finance_list_view.dart';
import 'package:daric/widgets/daric_list_card.dart';
import 'package:daric/models/credit.dart';
import 'edit_credit_screen.dart';

class CreditsListScreen extends StatelessWidget {
  final ApiService _api = ApiService();

  @override
  Widget build(BuildContext context) {
    return FinanceListView<Credit>(
      title: 'لیست طلب‌ها',
      fetchItems: () async => (await _api.getCredits()) ?? [],
      onDelete: (id) async => await _api.deleteCredit(id),
      onEdit: (credit) async {
        final updated = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditCreditScreen(credit: credit)),
        );
        if (updated == true) {
          // صفحه خودش ریفرش میشه
        }
      },
      itemBuilder: (credit) {
        return DaricListCard(
          title: 'از ${credit.person?.firstName ?? 'نامشخص'}',
          subtitle: credit.description,
          trailingText: '${credit.amount} تومان',
          date: 'تاریخ: ${credit.date.toLocal().toString().split(" ")[0]}',
          secondDate: 'سررسید: ${credit.payDate.toLocal().toString().split(" ")[0]}',
        );
      },
      addRoute: '/add-credit',
    );
  }
}
