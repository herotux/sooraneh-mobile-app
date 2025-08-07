import 'package:flutter/material.dart';
import 'package:daric/models/debt.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/main_scaffold.dart';
import 'package:daric/widgets/common_filter_sheet.dart';
import 'package:daric/widgets/daric_list_card.dart';
import 'edit_debt_screen.dart';

class DebtListScreen extends StatefulWidget {
  @override
  State<DebtListScreen> createState() => _DebtListScreenState();
}

class _DebtListScreenState extends State<DebtListScreen> {
  final ApiService _apiService = ApiService();
  List<Debt> _allDebts = [];
  bool _isLoading = true;

  DateTime? _fromDate;
  DateTime? _toDate;
  int? _fromAmount;
  int? _toAmount;
  String? _description;
  String _sort = 'asc';

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
    List<Debt> filtered = _allDebts.where((d) {
      if (_fromDate != null && d.date.isBefore(_fromDate!)) return false;
      if (_toDate != null && d.date.isAfter(_toDate!)) return false;
      if (_fromAmount != null && d.amount < _fromAmount!) return false;
      if (_toAmount != null && d.amount > _toAmount!) return false;
      if (_description != null &&
          _description!.isNotEmpty &&
          !(d.description?.contains(_description!) ?? false)) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) =>
        _sort == 'asc' ? a.payDate.compareTo(b.payDate) : b.payDate.compareTo(a.payDate));
    return filtered;
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

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CommonFilterSheet(
        type: 'debt',
        initialValues: {
          'fromDate': _fromDate,
          'toDate': _toDate,
          'fromAmount': _fromAmount?.toString(),
          'toAmount': _toAmount?.toString(),
          'description': _description,
          'sort': _sort,
        },
        onApply: (filters) {
          setState(() {
            _fromDate = filters['fromDate'];
            _toDate = filters['toDate'];
            _fromAmount = int.tryParse(filters['fromAmount'] ?? '');
            _toAmount = int.tryParse(filters['toAmount'] ?? '');
            _description = filters['description'];
            _sort = filters['sort'];
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "لیست بدهی‌ها",
      actions: [
        IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: _openFilterSheet,
          tooltip: 'فیلتر',
        ),
      ],
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  /// مجموع بدهی‌ها
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
                        Text('جمع بدهی‌ها:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                child: DaricListCard(
                                  title: 'به ${_personDisplayName(debt)}',
                                  subtitle: debt.description,
                                  trailingText: '${debt.amount} تومان',
                                  date: 'گرفته شده: ${debt.date.toLocal().toString().split(" ")[0]}',
                                  secondDate: 'سررسید: ${debt.payDate.toLocal().toString().split(" ")[0]}',
                                  backgroundColor: _getCardColor(debt),
                                  onTap: () => _editDebt(debt),
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
