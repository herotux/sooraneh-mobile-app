import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:sooraneh_mobile/models/income.dart'; // یا expense.dart
import 'package:sooraneh_mobile/services/api_service.dart';

class IncomeScreen extends StatefulWidget {
  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  late Future<List<Income>> _futureIncomes;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _futureIncomes = _fetchIncomes();
  }

  Future<List<Income>> _fetchIncomes() async {
    final data = await _apiService.getIncomes();
    if (data != null) {
      return data.map((item) => Income.fromJson(item)).toList();
    }
    return [];
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Income>>(
      future: _futureIncomes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());

        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return Center(child: Text('درآمدی وجود ندارد'));

        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final inc = snapshot.data![index];
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text(
                  inc.text,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textDirection: TextDirection.rtl,
                ),
                subtitle: Text(
                  '${_formatJalaliDate(inc.date)} - ${inc.amount} تومان',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 18),
              ),
            );
          },
        );
      },
    );
  }
}
