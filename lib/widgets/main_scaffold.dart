import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:daric/utils/jwt_storage.dart';
import 'package:daric/utils/full_screen_helper.dart';

class MainScaffold extends StatefulWidget {
  final Widget body;
  final String title;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  const MainScaffold({
    Key? key,
    required this.body,
    required this.title,
    this.floatingActionButton,
    this.actions,
  }) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  @override
  void initState() {
    super.initState();
    // ✅ فعال‌سازی Immerse Mode در هر صفحه‌ای که از MainScaffold استفاده می‌کند
    FullScreenHelper.enableImmersiveMode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ فعال‌سازی خودمخفی‌شدن ناوبری هنگام تعامل
      FullScreenHelper.attachAutoHideOnUserInteraction();
    });
  }

  @override
  void dispose() {
    // ✅ تمیزکاری
    FullScreenHelper.dispose();
    super.dispose();
  }

  final List<_MenuItem> menuItems = [
    _MenuItem(title: 'داشبورد', icon: Icons.dashboard, route: '/home'),
    _MenuItem(title: 'دسته‌بندی‌ها', icon: Icons.category, route: '/categories'),
    _MenuItem(title: 'بدهی‌ها', icon: Icons.money_off, route: '/debt-list'),
    _MenuItem(title: 'طلب‌ها', icon: Icons.attach_money, route: '/credit-list'),
    _MenuItem(title: 'هزینه‌ها', icon: Icons.explicit, route: '/expense-list'),
    _MenuItem(title: 'درآمدها', icon: Icons.account_balance_wallet, route: '/income-list'),
    _MenuItem(title: 'اشخاص', icon: Icons.people, route: '/persons'),
    _MenuItem(title: 'تگ‌ها', icon: Icons.label, route: '/tags'),
    _MenuItem(title: 'بودجه‌ها', icon: Icons.monetization_on, route: '/budgets'),
    _MenuItem(title: 'اقساط', icon: Icons.calendar_view_week, route: '/installments'),
    _MenuItem(title: 'تنظیمات', icon: Icons.settings, route: '/settings'),
  ];

  void _onMenuItemTap(String route) {
    Navigator.pop(context);
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: widget.actions,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Text(
                'منوی کاربری',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ...menuItems.map((item) => ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              onTap: () => _onMenuItemTap(item.route),
            )),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('خروج از حساب'),
              onTap: () async {
                await JwtStorage.deleteToken();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final String route;

  _MenuItem({required this.title, required this.icon, required this.route});
}