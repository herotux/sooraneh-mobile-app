import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:daric/models/expense.dart';
import 'package:daric/services/api_service.dart';

class ExpenseScreen extends StatefulWidget {
  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  late Future<List<Expense>> _expensesFuture;
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
        _expenses = data.map((item) => Expense.fromJson(item)).toList();
      });
    } else {
      setState(() {
        _expenses = [];
      });
    }
  }

  String _convertToJalali(String enDateString) {
    try {
      final dateTime = DateTime.parse(enDateString);
      final jDate = Jalali.fromDateTime(dateTime);
      return '${jDate.year}/${jDate.month.toString().padLeft(2, '0')}/${jDate.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'تاریخ نامعتبر';
    }
  }

  Future<void> _deleteExpense(int id) async {
    final success = await _apiService.deleteExpense(id);
    if (success) {
      setState(() {
        _expenses.removeWhere((e) => e.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('هزینه حذف شد')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در حذف هزینه')),
      );
    }
  }

  void _editExpense(Expense expense) async {
    // فرض می‌کنیم صفحه ویرایش دارید و route اش '/edit-expense'
    final updated = await Navigator.pushNamed(
      context,
      '/edit-expense',
      arguments: expense,
    );
    if (updated == true) {
      _loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // راست‌چین برای فارسی
      child: Scaffold(
        appBar: AppBar(
          title: Text('هزینه‌ها'),
        ),
        body: _expenses.isEmpty
            ? Center(
                child: Text(
                  'هزینه‌ای ثبت نشده',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _expenses.length,
                itemBuilder: (context, index) {
                  final exp = _expenses[index];
                  final jDate = _convertToJalali(exp.date);

                  return Dismissible(
                    key: Key(exp.id.toString()),
                    background: Container(
                      color: Colors.green,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 20),
                      child: Icon(Icons.edit, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        // کشیدن به راست => ویرایش
                        _editExpense(exp);
                        return false; // حذف نشود، فقط ویرایش
                      } else if (direction == DismissDirection.endToStart) {
                        // کشیدن به چپ => حذف
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('حذف هزینه'),
                            content: Text('آیا مطمئنید می‌خواهید این هزینه را حذف کنید؟'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: Text('خیر'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: Text('بله'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await _deleteExpense(exp.id);
                          return true; // حذف شود
                        } else {
                          return false; // لغو حذف
                        }
                      }
                      return false;
                    },
                    child: Card(
                      elevation: 4,
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red[100],
                          child: Icon(Icons.money_off, color: Colors.red[800]),
                        ),
                        title: Text(
                          exp.text,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(jDate),
                        trailing: Text(
                          '${exp.amount.toString()} تومان',
                          style: TextStyle(
                            color: Colors.red[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/add-expense').then((_) => _loadExpenses());
          },
          child: Icon(Icons.add),
          tooltip: 'افزودن هزینه',
        ),
      ),
    );
  }
}
