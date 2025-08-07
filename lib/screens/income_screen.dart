import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:daric/models/income.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/finance_list_view.dart';
import 'package:daric/widgets/daric_list_card.dart';

class IncomeScreen extends StatelessWidget {
  final ApiService _api = ApiService();

  String _formatJalaliDate(String enDate) {
    try {
      final dt = DateTime.parse(enDate);
      final j = Jalali.fromDateTime(dt);
      return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'تاریخ نامعتبر';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FinanceListView<Income>(
      title: 'درآمدها',
      fetchItems: () => _api.getIncomes(),
      onDelete: (id) => _api.deleteIncome(id),
      onEdit: (income) async {
        final updated = await Navigator.pushNamed(
          context,
          '/edit-income',
          arguments: income,
        );
        return;
      },
      addRoute: '/add-income',
      itemBuilder: (income) {
        return DaricListCard(
          title: income.text,
          subtitle: '${_formatJalaliDate(income.date)}',
          trailingText: '${income.amount} تومان',
          backgroundColor: Colors.green[50]!,
          icon: Icons.attach_money,
          iconColor: Colors.green[800],
          onTap: () async {
            await Navigator.pushNamed(context, '/edit-income', arguments: income);
          },
        );
      },
    );
  }
}
