import 'package:flutter/material.dart';
import 'package:sooraneh_mobile/screens/login_screen.dart';
import 'package:sooraneh_mobile/utils/jwt_storage.dart';

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
      title: 'Sooraneh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
