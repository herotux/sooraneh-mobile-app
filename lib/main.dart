import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:daric/theme/app_theme.dart';
import 'package:daric/utils/jwt_storage.dart';
import 'package:daric/utils/full_screen_helper.dart';

// Screens
import 'package:daric/screens/login_screen.dart';
import 'package:daric/screens/home_screen.dart';
import 'package:daric/screens/category_screen.dart';
import 'package:daric/screens/add_category_screen.dart';
import 'package:daric/screens/debt_list_screen.dart';
import 'package:daric/screens/edit_debt_screen.dart';
import 'package:daric/screens/credit_list_screen.dart';
import 'package:daric/screens/edit_credit_screen.dart';
import 'package:daric/screens/income_screen.dart';
import 'package:daric/screens/expense_screen.dart';
import 'package:daric/screens/add_income_screen.dart';
import 'package:daric/screens/add_expense_screen.dart';
import 'package:daric/screens/edit_expense_screen.dart';
import 'package:daric/screens/log_screen.dart';
import 'package:daric/screens/persons_screen.dart';
import 'package:daric/screens/settings_screen.dart';
import 'package:daric/screens/add_credit_screen.dart';
import 'package:daric/screens/add_debt_screen.dart';

// Models
import 'package:daric/models/credit.dart';
import 'package:daric/models/debt.dart';
import 'package:daric/models/expense.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FullScreenHelper.enableImmersiveMode();

  final token = await JwtStorage.getToken();
  runApp(MyApp(initialRoute: token != null ? '/home' : '/login'));
}

class MyApp extends StatefulWidget {
  final String initialRoute;

  const MyApp({required this.initialRoute, Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    FullScreenHelper.enableImmersiveMode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FullScreenHelper.attachAutoHideOnUserInteraction();
    });
  }

  @override
  void dispose() {
    FullScreenHelper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دریک',
      debugShowCheckedModeBanner: false,
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
      theme: AppTheme.lightTheme,
      initialRoute: widget.initialRoute,
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/expense-list': (context) => ExpenseScreen(),
        '/income-list': (context) => IncomeScreen(),
        '/add-income': (context) => AddIncomeScreen(),
        '/add-expense': (context) => AddExpenseScreen(),
        '/categories': (context) => CategoriesScreen(),
        '/add-category': (context) => AddCategoryScreen(),
        '/credit-list': (context) => CreditsListScreen(),
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
        '/edit-expense': (context) {
          final expense = ModalRoute.of(context)!.settings.arguments as Expense;
          return EditExpenseScreen(expense: expense);
        },
        '/settings': (context) => SettingsScreen(),
        '/logs': (context) => LogScreen(),
        '/persons': (context) => PersonsScreen(),
      },
    );
  }
}
