import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:sooraneh_mobile/models/income.dart';
import 'package:sooraneh_mobile/services/api_service.dart';

class IncomeScreen extends StatefulWidget {
  @override
  _IncomeScreenState createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  late Future<List<Income>> _incomesFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _incomesFuture = _fetchIncomes();
  }

  Future<List<Income>> _fetchIncomes() async {
    final data = await _apiService.getIncomes();
    if (data != null) {
      return data.map((item) => Income.fromJson(item)).toList();
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
      appBar: AppBar(title: Text('درآمدها')),
      body: FutureBuilder<List<Income>>(
        future: _incomesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('درآمدی وجود ندارد'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final inc = snapshot.data![index];
              final jDate = _convertToJalali(inc.date);
              return ListTile(
                title: Text(inc.text),
                subtitle: Text('$jDate - ${inc.amount} تومان'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              );
            },
          );
        },
      ),
    );
  }
}
