import 'package:flutter/material.dart';
import 'package:daric/models/debt.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/main_scaffold.dart';
import 'package:daric/widgets/my_date_picker.dart';
import 'edit_debt_screen.dart';

class DebtListScreen extends StatefulWidget {
  @override
  State<DebtListScreen> createState() => _DebtListScreenState();
}

class _DebtListScreenState extends State<DebtListScreen> {
  final ApiService _apiService = ApiService();
  List<Debt> _allDebts = [];
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    final debts = await _apiService.getDebts();
    setState(() {
      _allDebts = debts ?? [];
      _isLoading = false;
    });
  }

  Future<void> _deleteDebt(int id) async {
    final success = await _apiService.deleteDebt(id);
    if (success) {
      setState(() => _allDebts.removeWhere((d) => d.id == id));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('بدهی حذف شد')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در حذف بدهی')));
    }
  }

  void _editDebt(Debt debt) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditDebtScreen(debt: debt)),
    );
    if (updated == true) {
      _loadDebts();
    }
  }

  List<Debt> get _filteredDebts {
    return _allDebts
        .where((d) {
          if (_fromDate != null && d.date.isBefore(_fromDate!)) return false;
          if (_toDate != null && d.date.isAfter(_toDate!)) return false;
          return true;
        })
        .toList()
      ..sort((a, b) => a.payDate.compareTo(b.payDate));
  }

  int get _totalAmount => _filteredDebts.fold(0, (sum, d) => sum + d.amount);

  Color _getCardColor(Debt debt) {
    final now = DateTime.now();
    final diff = debt.payDate.difference(now).inDays;
    if (diff < 0) return Colors.red[100]!;
    if (diff <= 3) return Colors.orange[100]!;
    return Colors.white;
  }

  String _personDisplayName(Debt debt) {
    if (debt.person != null) {
      final p = debt.person!;
      return p.lastName != null && p.lastName!.isNotEmpty
          ? '${p.firstName} ${p.lastName}'
          : p.firstName;
    }
    return 'نامشخص';
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "لیست بدهی‌ها",
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  /// فیلتر تاریخ
                  Row(
                    children: [
                      Expanded(
                        child: MyDatePicker(
                          label: 'از تاریخ',
                          initialDate: _fromDate,
                          onDateChanged: (d) => setState(() => _fromDate = d),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: MyDatePicker(
                          label: 'تا تاریخ',
                          initialDate: _toDate,
                          onDateChanged: (d) => setState(() => _toDate = d),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  /// نمایش مجموع بدهی‌ها
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('جمع بدهی‌ها در بازه:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('$_totalAmount تومان', style: TextStyle(color: Colors.red[800], fontSize: 16)),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  /// لیست بدهی‌ها
                  Expanded(
                    child: _filteredDebts.isEmpty
                        ? Center(child: Text('بدهی‌ای یافت نشد'))
                        : ListView.builder(
                            itemCount: _filteredDebts.length,
                            itemBuilder: (context, index) {
                              final debt = _filteredDebts[index];
                              return Dismissible(
                                key: Key(debt.id.toString()),
                                background: Container(
                                  color: Colors.green,
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(left: 20),
                                  child: Icon(Icons.edit, color: Colors.white),
                                ),
                                secondaryBackground: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(right: 20),
                                  child: Icon(Icons.delete, color: Colors.white),
                                ),
                                confirmDismiss: (direction) async {
                                  if (direction == DismissDirection.startToEnd) {
                                    _editDebt(debt);
                                    return false;
                                  } else if (direction == DismissDirection.endToStart) {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text('حذف بدهی'),
                                        content: Text('آیا مطمئن هستید؟'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(ctx).pop(false),
                                            child: Text('لغو'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(ctx).pop(true),
                                            child: Text('حذف'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true && debt.id != null) {
                                      await _deleteDebt(debt.id!);
                                      return true;
                                    }
                                    return false;
                                  }
                                  return false;
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _getCardColor(debt),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'به ${_personDisplayName(debt)}',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      SizedBox(height: 4),
                                      Text('مبلغ: ${debt.amount} تومان'),
                                      SizedBox(height: 4),
                                      Text('گرفته شده در: ${debt.date.toLocal().toString().split(" ")[0]}'),
                                      Text('سررسید: ${debt.payDate.toLocal().toString().split(" ")[0]}'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.pushNamed(context, '/add-debt');
          if (added == true) _loadDebts();
        },
        child: Icon(Icons.add),
        tooltip: 'افزودن بدهی',
      ),
    );
  }
}
