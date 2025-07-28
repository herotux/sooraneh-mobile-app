import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:daric/models/income.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/main_scaffold.dart';
import 'package:daric/screens/add_income_screen.dart';
import 'package:daric/screens/edit_income_screen.dart';



class IncomeScreen extends StatefulWidget {
  @override
  _IncomeScreenState createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final ApiService _apiService = ApiService();
  List<Income> _incomes = [];
  bool _isLoading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _fetchIncomes();
  }

  Future<void> _fetchIncomes() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      final data = await _apiService.getIncomes();
      setState(() {
        _incomes = data ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = 'خطا در بارگذاری درآمدها';
        _isLoading = false;
      });
    }
  }

  String _formatJalaliDate(String enDate) {
    try {
      final dt = DateTime.parse(enDate);
      final j = Jalali.fromDateTime(dt);
      return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'تاریخ نامعتبر';
    }
  }

  Future<void> _deleteIncome(int id) async {
    final success = await _apiService.deleteIncome(id);
    if (success) {
      setState(() {
        _incomes.removeWhere((inc) => inc.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('درآمد حذف شد')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در حذف درآمد')),
      );
    }
  }

  Future<void> _editIncome(Income income) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditIncomeScreen(income: income)),
    );
    if (updated == true) {
      _fetchIncomes();
    }
  }

  Future<void> _addIncome() async {
    final added = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddIncomeScreen()),
    );
    if (added == true) {
      _fetchIncomes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MainScaffold(
        title: 'درآمدها',
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _incomes.isEmpty
                ? Center(
                    child: Text(
                      _message ?? 'درآمدی وجود ندارد',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _incomes.length,
                    itemBuilder: (context, index) {
                      final inc = _incomes[index];
                      final jDate = _formatJalaliDate(inc.date);
                      return Dismissible(
                        key: Key(inc.id.toString()),
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
                            _editIncome(inc);
                            return false;
                          } else if (direction == DismissDirection.endToStart) {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('حذف درآمد'),
                                content: Text('آیا مطمئنید می‌خواهید این درآمد را حذف کنید؟'),
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
                              if (inc.id != null) await _deleteIncome(inc.id!);
                              return true;
                            }
                            return false;
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
                            title: Text(
                              inc.text,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textDirection: TextDirection.rtl,
                            ),
                            subtitle: Text(
                              '$jDate - ${inc.amount} تومان',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 18),
                          ),
                        ),
                      );
                    },
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addIncome,
          child: Icon(Icons.add),
          tooltip: 'افزودن درآمد',
        ),
      ),
    );
  }
}
