import 'package:flutter/material.dart';
import 'package:daric/models/budget.dart';
import 'package:daric/services/api_service.dart';
import 'edit_budget_screen.dart'; // To be created
import 'add_budget_screen.dart'; // To be created
import 'package:daric/widgets/main_scaffold.dart';
import 'package:intl/intl.dart';

class BudgetsScreen extends StatefulWidget {
  @override
  _BudgetsScreenState createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Budget>> _budgetsFuture;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  void _loadBudgets() {
    setState(() {
      _budgetsFuture = _apiService.getBudgets().then((value) => value ?? []);
    });
  }

  Future<void> _deleteBudget(int id) async {
    final success = await _apiService.deleteBudget(id);
    if (success) {
      _loadBudgets();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('بودجه با موفقیت حذف شد')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در حذف بودجه')),
      );
    }
  }

  void _editBudget(Budget budget) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditBudgetScreen(budget: budget),
      ),
    );
    if (result == true) {
      _loadBudgets();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'fa_IR', symbol: 'تومان');

    return MainScaffold(
      title: 'بودجه‌ها',
      body: FutureBuilder<List<Budget>>(
        future: _budgetsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطا در بارگذاری بودجه‌ها'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('هیچ بودجه‌ای وجود ندارد'));
          }

          final budgets = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return Card(
                child: Dismissible(
                  key: ValueKey(budget.id),
                  background: Container(color: Colors.green, alignment: Alignment.centerLeft, padding: EdgeInsets.only(left: 20), child: Icon(Icons.edit, color: Colors.white)),
                  secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, padding: EdgeInsets.only(right: 20), child: Icon(Icons.delete, color: Colors.white)),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      _editBudget(budget);
                      return false;
                    } else {
                      return await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('حذف بودجه'),
                          content: Text('آیا از حذف این بودجه مطمئن هستید؟'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('خیر')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: Text('بله')),
                          ],
                        ),
                      ) ?? false;
                    }
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      _deleteBudget(budget.id!);
                    }
                  },
                  child: ListTile(
                    title: Text('مبلغ: ${currencyFormat.format(budget.monthly_budget)}'),
                    subtitle: Text('شناسه دسته‌بندی: ${budget.category ?? "عمومی"}'),
                    leading: Icon(Icons.account_balance_wallet_outlined),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddBudgetScreen()),
          );
          if (result == true) {
            _loadBudgets();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
