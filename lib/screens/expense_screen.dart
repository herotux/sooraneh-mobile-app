import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:sooraneh_mobile/models/expense.dart';
import 'package:sooraneh_mobile/services/api_service.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text('هزینه‌ها')),
      body: FutureBuilder<List<Expense>>(
        future: _expensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('هزینه‌ای وجود ندارد'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final exp = snapshot.data![index];
              final jDate = _convertToJalali(exp.date);
              return ListTile(
                title: Text(exp.text),
                subtitle: Text('$jDate - ${exp.amount} تومان'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              );
            },
          );
        },
      ),
    );
  }
}
