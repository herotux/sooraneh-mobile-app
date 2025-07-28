import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:daric/models/expense.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/main_scaffold.dart';
import 'package:flutter_slidable/flutter_slidable.dart';




class ExpenseScreen extends StatefulWidget {
  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final ApiService _apiService = ApiService();
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final data = await _apiService.getExpenses();
    if (data != null) {
      setState(() {
        _expenses = data;
        _expenses.sort((a, b) => b.date.compareTo(a.date)); // مرتب‌سازی نزولی
      });
    } else {
      setState(() => _expenses = []);
    }
  }

  String _formatJalali(String enDateString) {
    try {
      final dateTime = DateTime.parse(enDateString);
      final jDate = Jalali.fromDateTime(dateTime);
      return '${jDate.year}/${jDate.month.toString().padLeft(2, '0')}/${jDate.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'تاریخ نامعتبر';
    }
  }

  Future<void> _deleteExpense(int id) async {
    final success = await _apiService.deleteExpense(id);
    if (success) {
      setState(() => _expenses.removeWhere((e) => e.id == id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('هزینه با موفقیت حذف شد')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در حذف هزینه')),
      );
    }
  }

  Future<bool?> _editExpense(Expense expense) async {
    final updated = await Navigator.pushNamed(context, '/edit-expense', arguments: expense);
    return updated == true;
  }


  Widget _buildExpenseItem(Expense exp) {
    final formattedDate = _formatJalali(exp.date);

    return Slidable(
      key: Key(exp.id.toString()),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) async {
              final updated = await Navigator.pushNamed(
                context,
                '/edit-expense',
                arguments: exp,
              );
              if (updated == true) {
                _loadExpenses();
              }
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
                builder: (ctx) => AlertDialog(
                  title: Text('حذف هزینه'),
                  content: Text('آیا از حذف این هزینه مطمئن هستید؟'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('خیر')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('بله')),
                  ],
                ),
              );
              if (confirm == true && exp.id != null) {
                await _deleteExpense(exp.id!);
              }
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'حذف',
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.red[100],
            child: Icon(Icons.money_off, color: Colors.red[800]),
          ),
          title: Text(exp.text, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(formattedDate),
          trailing: Text(
            '${exp.amount} تومان',
            style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'هزینه‌ها',
      body: _expenses.isEmpty
          ? Center(child: Text('هزینه‌ای ثبت نشده است', style: TextStyle(fontSize: 16)))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _expenses.length,
              itemBuilder: (context, index) => _buildExpenseItem(_expenses[index]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-expense').then((_) => _loadExpenses());
        },
        child: Icon(Icons.add),
        tooltip: 'افزودن هزینه',
      ),
    );
  }
}
