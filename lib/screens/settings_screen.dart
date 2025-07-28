import 'package:flutter/material.dart';
import 'package:daric/widgets/main_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'تنظیمات',
      body: ListView(
        children: [
          ListTile(
            title: Text('لاگ‌های برنامه'),
            leading: Icon(Icons.list_alt),
            onTap: () => Navigator.pushNamed(context, '/logs'),
          ),
          // اینجا می‌تونی آیتم‌های دیگه تنظیمات رو هم اضافه کنی
          ListTile(
            title: Text('سایر تنظیمات'),
            leading: Icon(Icons.settings),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
