import 'package:flutter/material.dart';
import 'package:daric/theme/app_theme.dart';
import 'package:daric/screens/login_screen.dart';
import 'package:daric/screens/home_screen.dart';
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
      title: 'دریک',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
