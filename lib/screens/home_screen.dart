import 'package:flutter/material.dart';
import 'package:daric/utils/jwt_storage.dart';

// فرض: این توابع را با دیتا واقعی جایگزین کن
Future<double> getMonthlyIncome() async => 12500000;
Future<double> getMonthlyExpense() async => 7800000;

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    DashboardWidget(),
    // سایر صفحات را همینجا اضافه کن اگر نیاز بود
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
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'داشبورد'),
          // اگر صفحات دیگر داری اینجا اضافه کن
        ],
      ),
    );
  }
}

class DashboardWidget extends StatelessWidget {
  final List<_DashboardItem> items = [
    _DashboardItem(title: 'دسته‌بندی‌ها', icon: Icons.category, route: '/categories'),
    _DashboardItem(title: 'بدهی‌ها', icon: Icons.money_off, route: '/debt-list'),
    _DashboardItem(title: 'طلب‌ها', icon: Icons.attach_money, route: '/credit-list'),
    _DashboardItem(title: 'هزینه‌ها', icon: Icons.explicit, route: '/expense-list'),
    _DashboardItem(title: 'درآمدها', icon: Icons.account_balance_wallet, route: '/income-list'),
    _DashboardItem(title: 'تنظیمات', icon: Icons.settings, route: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'خوش آمدید به داشبورد دریک',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FutureBuilder<double>(
                  future: getMonthlyIncome(),
                  builder: (context, snapshot) {
                    final value = snapshot.hasData ? snapshot.data!.toStringAsFixed(0) : '...';
                    return _InfoCard(
                      label: 'درآمد ماه جاری',
                      value: '$value تومان',
                      icon: Icons.trending_up,
                      color: Colors.green,
                    );
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: FutureBuilder<double>(
                  future: getMonthlyExpense(),
                  builder: (context, snapshot) {
                    final value = snapshot.hasData ? snapshot.data!.toStringAsFixed(0) : '...';
                    return _InfoCard(
                      label: 'هزینه ماه جاری',
                      value: '$value تومان',
                      icon: Icons.trending_down,
                      color: Colors.red,
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, item.route),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, size: 36, color: Theme.of(context).primaryColor),
                      SizedBox(height: 12),
                      Text(
                        item.title,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final String route;

  const _DashboardItem({required this.title, required this.icon, required this.route});
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(fontSize: 16, color: color)),
      ),
    );
  }
}