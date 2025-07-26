import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // اضافه شد
import 'package:daric/theme/app_theme.dart';
import 'package:daric/screens/login_screen.dart';
import 'package:daric/screens/home_screen.dart';
import 'package:daric/screens/category_screen.dart';
import 'package:daric/screens/add_category_screen.dart';
import 'package:daric/utils/jwt_storage.dart';
import 'package:daric/screens/debt_list_screen.dart';
import 'package:daric/screens/edit_debt_screen.dart';
import 'package:daric/screens/credit_list_screen.dart';
import 'package:daric/screens/edit_credit_screen.dart';
import 'package:daric/screens/income_screen.dart';
import 'package:daric/screens/expense_screen.dart';
import 'package:daric/models/credit.dart';
import 'package:daric/models/debt.dart';


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
        '/expense-list': (context) => ExpenseScreen(),
        '/income-list': (context) => IncomeScreen(),
        '/categories': (context) => CategoryScreen(),
        '/add-category': (context) => AddCategoryScreen(),
        '/credit-list': (context) => CreditListScreen(),
        '/add-credit': (context) => AddCreditScreen(),
        '/edit-credit': (context) {
          final credit = ModalRoute.of(context)!.settings.arguments as Credit;
          return EditCreditScreen(credit: credit);
        },
        '/debt-list': (context) => DebtListScreen(),
        '/add-debt': (context) => AddDebtScreen(),
        '/debts/edit': (context) {
          final debt = ModalRoute.of(context)!.settings.arguments as Debt;
          return EditDebtScreen(debt: debt);
        },
        
      },
    );
  }
}
