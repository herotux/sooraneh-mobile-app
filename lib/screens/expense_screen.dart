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

  @override
  void initState() {
    super.initState();
    _expensesFuture = _fetchExpenses();
  }

  Future<List<Expense>> _fetchExpenses() async {
    final data = await _apiService.getExpenses();
    if (data != null) {
      return data.map((item) => Expense.fromJson(item)).toList();
    }
    return [];
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // راست‌چین برای فارسی
      child: Scaffold(
        appBar: AppBar(
          title: Text('هزینه‌ها'),
        ),
        body: FutureBuilder<List<Expense>>(
          future: _expensesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'هزینه‌ای ثبت نشده',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            final expenses = snapshot.data!;

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final exp = expenses[index];
                final jDate = _convertToJalali(exp.date);

                return Card(
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
                    subtitle: Text('$jDate'),
                    trailing: Text(
                      '${exp.amount.toString()} تومان',
                      style: TextStyle(
                        color: Colors.red[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
