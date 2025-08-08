import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// --- خود اپ و تم ---
import 'package:daric/theme/app_theme.dart';
import 'package:daric/utils/jwt_storage.dart';
import 'package:daric/utils/full_screen_helper.dart';

// --- صفحات (Screens) ---
import 'package:daric/screens/login_screen.dart';
import 'package:daric/screens/home_screen.dart';

// مدیریت دسته‌بندی
import 'package:daric/screens/category_screen.dart';
import 'package:daric/screens/add_category_screen.dart';

// مدیریت بدهی
import 'package:daric/screens/debt_list_screen.dart';
import 'package:daric/screens/add_debt_screen.dart';
import 'package:daric/screens/edit_debt_screen.dart';

// مدیریت طلب
import 'package:daric/screens/credit_list_screen.dart';
import 'package:daric/screens/add_credit_screen.dart';
import 'package:daric/screens/edit_credit_screen.dart';

// مدیریت درآمد و هزینه
import 'package:daric/screens/income_screen.dart';
import 'package:daric/screens/expense_screen.dart';
import 'package:daric/screens/add_income_screen.dart';
import 'package:daric/screens/add_expense_screen.dart';
import 'package:daric/screens/edit_expense_screen.dart';
import 'package:daric/screens/edit_income_screen.dart';

// مدیریت طرف حساب (افزوده شده)
import 'package:daric/screens/persons_screen.dart';
import 'package:daric/screens/add_person_screen.dart';
import 'package:daric/screens/edit_person_screen.dart';

// صفحات دیگر
import 'package:daric/screens/log_screen.dart';
import 'package:daric/screens/settings_screen.dart';

// --- مدل‌ها (Models) ---
import 'package:daric/models/credit.dart';
import 'package:daric/models/debt.dart';
import 'package:daric/models/expense.dart';
import 'package:daric/models/income.dart';
import 'package:daric/models/person.dart'; // برای آرگومان ویرایش

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تنظیم استایل سیستم (نوار وضعیت و ناوبری)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  // تعیین مسیر اولیه بر اساس وجود توکن
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
      initialRoute: initialRoute,
      routes: {
        // صفحات اصلی
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),

        // مدیریت هزینه
        '/expense-list': (context) => ExpenseScreen(),
        '/add-expense': (context) => AddExpenseScreen(),
        '/edit-expense': (context) {
          final expense = ModalRoute.of(context)!.settings.arguments as Expense;
          return EditExpenseScreen(expense: expense);
        },

        // مدیریت درآمد
        '/income-list': (context) => IncomeScreen(),
        '/add-income': (context) => AddIncomeScreen(),
        '/edit-income': (context) {
          final income = ModalRoute.of(context)!.settings.arguments as Income;
          return EditIncomeScreen(income: income);
        },

        // مدیریت دسته‌بندی
        '/categories': (context) => CategoriesScreen(),
        '/add-category': (context) => AddCategoryScreen(),

        // مدیریت طلب
        '/credit-list': (context) => CreditListScreen(),
        '/add-credit': (context) => AddCreditScreen(),
        '/edit-credit': (context) {
          final credit = ModalRoute.of(context)!.settings.arguments as Credit;
          return EditCreditScreen(credit: credit);
        },

        // مدیریت بدهی
        '/debt-list': (context) => DebtListScreen(),
        '/add-debt': (context) => AddDebtScreen(),
        '/debts/edit': (context) {
          final debt = ModalRoute.of(context)!.settings.arguments as Debt;
          return EditDebtScreen(debt: debt);
        },

        // ✅ مدیریت طرف حساب (اضافه شده)
        '/persons': (context) => PersonsScreen(),
        '/add-person': (context) => AddPersonScreen(),
        '/edit-person': (context) {
          final person = ModalRoute.of(context)!.settings.arguments as Person;
          return EditPersonScreen(person: person);
        },

        // صفحات دیگر
        '/settings': (context) => SettingsScreen(),
        '/logs': (context) => LogScreen(),
      },
    );
  }
}