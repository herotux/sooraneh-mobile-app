import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:daric/models/expense.dart';
import 'package:daric/models/income.dart';
import 'package:daric/services/api_service.dart';
import 'package:shamsi_date/shamsi_date.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({Key? key}) : super(key: key);

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final ApiService _apiService = ApiService();

  // داده های نمودار
  List<double> monthlyIncome = List.filled(12, 0);
  List<double> monthlyExpense = List.filled(12, 0);

  // آخرین هزینه‌ها و درآمدها
  List<Expense> latestExpenses = [];
  List<Income> latestIncomes = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => isLoading = true);

    // بارگذاری داده ها
    final expenses = await _apiService.getExpenses(); // فرضاً لیست expense‌ها با فیلد date و amount
    final incomes = await _apiService.getIncomes();

    // داده‌های ماهانه را صفر میکنیم
    List<double> incomeData = List.filled(12, 0);
    List<double> expenseData = List.filled(12, 0);

    DateTime now = DateTime.now();

    // دسته بندی داده‌ها بر اساس ماه شمسی (فرض می‌کنیم تاریخ‌ها میلادی هستند)
    if (expenses != null) {
      for (var e in expenses) {
        DateTime dt = DateTime.parse(e['date']);
        Jalali jDate = Jalali.fromDateTime(dt);
        int monthIndex = jDate.month - 1; // 0-based index
        if (monthIndex >= 0 && monthIndex < 12) {
          expenseData[monthIndex] += (e['amount'] ?? 0).toDouble();
        }
      }
    }

    if (incomes != null) {
      for (var i in incomes) {
        DateTime dt = DateTime.parse(i['date']);
        Jalali jDate = Jalali.fromDateTime(dt);
        int monthIndex = jDate.month - 1;
        if (monthIndex >= 0 && monthIndex < 12) {
          incomeData[monthIndex] += (i['amount'] ?? 0).toDouble();
        }
      }
    }

    // آخرین 5 مورد را می‌گیریم و تبدیل می‌کنیم
    List<Expense> lastExp = (expenses ?? [])
        .map((e) => Expense.fromJson(e))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    List<Income> lastInc = (incomes ?? [])
        .map((i) => Income.fromJson(i))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      monthlyExpense = expenseData;
      monthlyIncome = incomeData;
      latestExpenses = lastExp.take(5).toList();
      latestIncomes = lastInc.take(5).toList();
      isLoading = false;
    });
  }

  String _jalaliMonthName(int month) {
    const months = [
      'فروردین', 'اردیبهشت', 'خرداد', 'تیر',
      'مرداد', 'شهریور', 'مهر', 'آبان',
      'آذر', 'دی', 'بهمن', 'اسفند'
    ];
    return months[month - 1];
  }

  Widget _buildBarChart() {
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < 12; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: monthlyIncome[i],
              color: Colors.green,
              width: 8,
            ),
            BarChartRodData(
              toY: monthlyExpense[i],
              color: Colors.red,
              width: 8,
            ),
          ],
          showingTooltipIndicators: [0, 1],
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: ([
            ...monthlyIncome,
            ...monthlyExpense,
          ].reduce((a, b) => a > b ? a : b)) * 1.2, // 20% بیشتر برای فضای نمودار
          barGroups: barGroups,
          groupsSpace: 12,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  int monthIdx = value.toInt() + 1;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(_jalaliMonthName(monthIdx)),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: true),
          gridData: FlGridData(show: true),
        ),
      ),
    );
  }

  Widget _buildLatestList<T>(
      {required String title, required List<T> items, required Widget Function(T) itemBuilder}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 8),
        ...items.map(itemBuilder).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    final jDate = Jalali.fromDateTime(expense.date);
    final formattedDate = '${jDate.year}/${jDate.month.toString().padLeft(2, '0')}/${jDate.day.toString().padLeft(2, '0')}';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.money_off, color: Colors.red),
        title: Text(expense.text, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(formattedDate),
        trailing: Text('${expense.amount} تومان', style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildIncomeItem(Income income) {
    final jDate = Jalali.fromDateTime(income.date);
    final formattedDate = '${jDate.year}/${jDate.month.toString().padLeft(2, '0')}/${jDate.day.toString().padLeft(2, '0')}';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.account_balance_wallet, color: Colors.green),
        title: Text(income.text, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(formattedDate),
        trailing: Text('${income.amount} تومان', style: const TextStyle(color: Colors.green)),
      ),
    );
  }

  void _onAddPressed() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.money_off),
            title: const Text('افزودن هزینه'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/add-expense');
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('افزودن درآمد'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/add-income');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildBarChart(),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('آخرین هزینه‌ها', style: Theme.of(context).textTheme.headline6),
              TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/expense-list'),
                icon: const Icon(Icons.list),
                label: const Text('مشاهده همه'),
              ),
            ],
          ),
          _buildLatestList<Expense>(
            title: '',
            items: latestExpenses,
            itemBuilder: _buildExpenseItem,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('آخرین درآمدها', style: Theme.of(context).textTheme.headline6),
              TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/income-list'),
                icon: const Icon(Icons.list),
                label: const Text('مشاهده همه'),
              ),
            ],
          ),
          _buildLatestList<Income>(
            title: '',
            items: latestIncomes,
            itemBuilder: _buildIncomeItem,
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('افزودن هزینه یا درآمد'),
            ),
          ),
        ],
      ),
    );
  }
}
