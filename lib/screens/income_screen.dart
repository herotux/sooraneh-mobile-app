import 'package:flutter/material.dart';
import 'package:persian_datetime/persian_datetime.dart';
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
              final jDate = PersianDateTime.parse(inc.date).format('YYYY/MM/DD');
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
