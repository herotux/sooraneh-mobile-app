import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:daric/models/expense.dart';
import 'package:daric/models/income.dart';
import 'package:daric/services/api_service.dart';
import 'package:shamsi_date/shamsi_date.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final ApiService _apiService = ApiService();
  List<double> monthlyIncome = List.filled(12, 0);
  List<double> monthlyExpense = List.filled(12, 0);
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
    final expenses = await _apiService.getExpenses();
    final incomes = await _apiService.getIncomes();

    List<double> incomeData = List.filled(12, 0);
    List<double> expenseData = List.filled(12, 0);

    if (expenses != null) {
      for (var e in expenses) {
        DateTime dt = DateTime.parse(e['date']);
        int monthIndex = Jalali.fromDateTime(dt).month - 1;
        expenseData[monthIndex] += (e['amount'] ?? 0).toDouble();
      }
    }

    if (incomes != null) {
      for (var i in incomes) {
        DateTime dt = DateTime.parse(i['date']);
        int monthIndex = Jalali.fromDateTime(dt).month - 1;
        incomeData[monthIndex] += (i['amount'] ?? 0).toDouble();
      }
    }

    setState(() {
      monthlyExpense = expenseData;
      monthlyIncome = incomeData;
      latestExpenses = (expenses ?? [])
          .map((e) => Expense.fromJson(e))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      latestIncomes = (incomes ?? [])
          .map((i) => Income.fromJson(i))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      latestExpenses = latestExpenses.take(5).toList();
      latestIncomes = latestIncomes.take(5).toList();
      isLoading = false;
    });
  }

  String _convertToPersianNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], persian[i]);
    }
    return input;
  }

  Widget _buildBarChart() {
    List<BarChartGroupData> barGroups = List.generate(12, (i) =>
      BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: monthlyIncome[i],
            color: Colors.green,
            width: 6,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: monthlyExpense[i],
            color: Colors.red,
            width: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      )
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: ([...monthlyIncome, ...monthlyExpense].reduce((a, b) => a > b ? a : b)) * 1.2,
            barGroups: barGroups,
            groupsSpace: 8,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, _) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _convertToPersianNumber((value.toInt() + 1).toString()),
                      style: const TextStyle(fontFamily: 'Vazirmatn'),
                    ),
                  ),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, _) => Text(
                    _convertToPersianNumber(value.toInt().toString()),
                    style: const TextStyle(fontFamily: 'Vazirmatn', fontSize: 10),
                  ),
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: false),
            barTouchData: BarTouchData(enabled: true),
          ),
        ),
      ),
    );
  }

  Widget _buildList<T>({required String title, required List<T> items, required Widget Function(T) itemBuilder}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...items.map(itemBuilder).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildExpenseItem(Expense e) => ListTile(
    leading: Icon(Icons.money_off, color: Colors.red[700]),
    title: Text(e.text, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text(_convertToPersianNumber(Jalali.fromDateTime(DateTime.parse(e.date)).formatFullDate())),
    trailing: Text('${_convertToPersianNumber(e.amount.toString())} تومان', style: TextStyle(color: Colors.red[700])),
  );

  Widget _buildIncomeItem(Income i) => ListTile(
    leading: Icon(Icons.attach_money, color: Colors.green[700]),
    title: Text(i.text, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text(_convertToPersianNumber(Jalali.fromDateTime(DateTime.parse(i.date)).formatFullDate())),
    trailing: Text('${_convertToPersianNumber(i.amount.toString())} تومان', style: TextStyle(color: Colors.green[700])),
  );

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
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildBarChart(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('آخرین هزینه‌ها', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/expense-list'),
                child: const Text('مشاهده همه'),
              ),
            ],
          ),
          _buildList<Expense>(title: '', items: latestExpenses, itemBuilder: _buildExpenseItem),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('آخرین درآمدها', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/income-list'),
                child: const Text('مشاهده همه'),
              ),
            ],
          ),
          _buildList<Income>(title: '', items: latestIncomes, itemBuilder: _buildIncomeItem),
          const SizedBox(height: 12),
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
