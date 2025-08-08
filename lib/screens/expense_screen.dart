import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/models/expense.dart';
import 'package:daric/widgets/daric_list_card.dart';
import 'package:daric/widgets/main_scaffold.dart';

class ExpenseScreen extends StatefulWidget {
  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final ApiService _api = ApiService();
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final data = await _api.getExpenses();
    setState(() => _expenses = data ?? []);
  }

  String _formatJalali(String enDate) {
    try {
      final date = DateTime.parse(enDate);
      final j = Jalali.fromDateTime(date);
      return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'تاریخ نامعتبر';
    }
  }

  Future<void> _deleteExpense(int id) async {
    final result = await _api.deleteExpense(id);
    if (result) {
      setState(() => _expenses.removeWhere((e) => e.id == id));
    }
  }

  Widget _buildItem(Expense exp) {
    return Slidable(
      key: ValueKey(exp.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) async {
              final updated = await Navigator.pushNamed(context, '/edit-expense', arguments: exp);
              if (updated == true) _loadExpenses();
            },
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'ویرایش',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('حذف هزینه'),
                  content: Text('از حذف این هزینه مطمئنی؟'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text('خیر')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: Text('بله')),
                  ],
                ),
              );
              if (confirm == true && exp.id != null) await _deleteExpense(exp.id!);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'حذف',
          ),
        ],
      ),
      child: DaricListCard(
        title: exp.text,
        subtitle: _formatJalali(exp.date),
        amountText: '${exp.amount} تومان',
        leadingIcon: Icons.money_off,
        leadingIconColor: Colors.red[800],
        backgroundColor: Colors.red[50],
        onTap: () async {
          final updated = await Navigator.pushNamed(context, '/edit-expense', arguments: exp);
          if (updated == true) _loadExpenses();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'هزینه‌ها',
      body: _expenses.isEmpty
          ? Center(child: Text('هزینه‌ای ثبت نشده است'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _expenses.length,
              itemBuilder: (_, i) => _buildItem(_expenses[i]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add-expense');
          if (result == true) _loadExpenses();
        },
        child: Icon(Icons.add),
        tooltip: 'افزودن هزینه',
      ),
    );
  }
}