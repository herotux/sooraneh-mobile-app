import 'package:flutter/material.dart';
import 'package:daric/models/debt.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/daric_list_card.dart';
import 'package:daric/widgets/finance_list_view.dart';
import 'edit_debt_screen.dart';

class DebtListScreen extends StatelessWidget {
  final ApiService _api = ApiService();

  Color _getCardColor(Debt debt) {
    final now = DateTime.now();
    final diff = debt.payDate.difference(now).inDays;
    if (diff < 0) return Colors.red[100]!;
    if (diff <= 3) return Colors.orange[100]!;
    return Colors.white;
  }

  String _personDisplayName(Debt debt) {
    if (debt.person != null) {
      final p = debt.person!;
      return p.lastName != null && p.lastName!.isNotEmpty
          ? '${p.firstName} ${p.lastName}'
          : p.firstName;
    }
    return 'نامشخص';
  }

  @override
  Widget build(BuildContext context) {
    return FinanceListView<Debt>(
      title: 'لیست بدهی‌ها',
      fetchItems: () => _api.getDebts(),
      onDelete: (id) async => await _api.deleteDebt(id),
      onEdit: (debt) async {
        final updated = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditDebtScreen(debt: debt)),
        );
        return;
      },
      itemBuilder: (debt) {
        return DaricListCard(
          title: 'به ${_personDisplayName(debt)}',
          subtitle: debt.description,
          trailingText: '${debt.amount} تومان',
          date: 'گرفته شده: ${debt.date.toLocal().toString().split(" ")[0]}',
          secondDate: 'سررسید: ${debt.payDate.toLocal().toString().split(" ")[0]}',
          backgroundColor: _getCardColor(debt),
          onTap: () async {
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditDebtScreen(debt: debt)),
            );
            // لیست خودش بعد از برگشت ریفرش میشه
          },
        );
      },
      addRoute: '/add-debt',
    );
  }
}
