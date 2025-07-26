import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // اضافه شد
import 'package:daric/theme/app_theme.dart';
import 'package:daric/screens/login_screen.dart';
import 'package:daric/screens/home_screen.dart';
import 'package:daric/screens/category_screen.dart';
import 'package:daric/screens/add_category_screen.dart';
import 'package:daric/utils/jwt_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final token = await JwtStorage.getToken();
  runApp(MyApp(initialRoute: token != null ? '/home' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({required this.initialRoute, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('fa'),
      supportedLocales: const [
        Locale('fa'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'دریک',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/categories': (context) => CategoryScreen(),
        '/add-category': (context) => AddCategoryScreen(),
      },
    );
  }
}
