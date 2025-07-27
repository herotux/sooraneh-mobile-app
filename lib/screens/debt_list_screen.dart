import 'package:flutter/material.dart';
import 'package:daric/models/debt.dart';
import 'package:daric/services/api_service.dart';
import 'edit_debt_screen.dart';

class DebtListScreen extends StatefulWidget {
  @override
  State<DebtListScreen> createState() => _DebtListScreenState();
}

class _DebtListScreenState extends State<DebtListScreen> {
  final ApiService _apiService = ApiService();
  List<Debt> _debts = [];
  bool _isLoading = true;

  Future<void> _fetchDebts() async {
    try {
      final debts = await _apiService.getDebts();
      setState(() {
        _debts = debts ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // میتونی پیام خطا اینجا نشون بدی
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDebts();
  }

  Future<void> _deleteDebt(int id) async {
    final success = await _apiService.deleteDebt(id);
    if (success) {
      setState(() {
        _debts.removeWhere((d) => d.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('بدهی حذف شد')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در حذف بدهی')),
      );
    }
  }

  void _editDebt(Debt debt) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditDebtScreen(debt: debt)),
    );
    if (updated == true) {
      _fetchDebts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('بدهی‌ها')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _debts.length,
              itemBuilder: (context, index) {
                final debt = _debts[index];
                return Dismissible(
                  key: Key(debt.id.toString()),
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
                      // ویرایش (کشیدن به راست)
                      _editDebt(debt);
                      return false; // dismiss نشود چون ویرایش صفحه جدید است
                    } else if (direction == DismissDirection.endToStart) {
                      // حذف (کشیدن به چپ)
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('حذف بدهی'),
                          content: Text('آیا مطمئنید می‌خواهید این بدهی را حذف کنید؟'),
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
                        if (debt.id != null) {
                            await _deleteDebt(debt.id!);
                        }

                        return true; // dismiss item
                      } else {
                        return false; // لغو حذف
                      }
                    }
                    return false;
                  },
                  child: ListTile(
                    title: Text(debt.description ?? ''),
                    subtitle: Text('مبلغ: ${debt.amount} - تاریخ: ${debt.date.toLocal().toString().split(' ')[0]}'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.pushNamed(context, '/add-debt');
          if (added == true) {
            _fetchDebts(); // لیست رو بعد از افزودن رفرش کن
          }
        },

        child: Icon(Icons.add),
        tooltip: 'افزودن بدهی',
      ),
    );
  }
}
