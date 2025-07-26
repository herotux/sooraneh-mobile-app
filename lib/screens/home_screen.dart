import 'package:flutter/material.dart';
import 'package:daric/screens/income_screen.dart';
import 'package:daric/screens/expense_screen.dart';
import 'package:daric/screens/settings_screen.dart';
import 'package:daric/utils/jwt_storage.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    DashboardWidget(),
    IncomeScreen(),
    ExpenseScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('دریک'),
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'خانه'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'درآمدها'),
          BottomNavigationBarItem(icon: Icon(Icons.money_off), label: 'هزینه‌ها'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'تنظیمات'),
        ],
      ),
    );
  }
}

class DashboardWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'خوش آمدید به داشبورد دریک',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
