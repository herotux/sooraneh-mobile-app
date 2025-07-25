import 'package:flutter/material.dart';
import 'package:sooraneh_mobile/screens/income_screen.dart';
import 'package:sooraneh_mobile/screens/expense_screen.dart';
import 'package:sooraneh_mobile/utils/jwt_storage.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('داشبورد Sooraneh'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await JwtStorage.deleteToken();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IncomeScreen()),
                );
              },
              child: Text('درآمدها'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExpenseScreen()),
                );
              },
              child: Text('هزینه‌ها'),
            ),
          ],
        ),
      ),
    );
  }
}
