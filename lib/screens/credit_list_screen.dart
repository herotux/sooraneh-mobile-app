import 'package:flutter/material.dart';
import 'package:daric/models/credit.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/main_scaffold.dart';
import 'package:daric/widgets/my_date_picker.dart';

class CreditsListScreen extends StatefulWidget {
  @override
  State<CreditsListScreen> createState() => _CreditsListScreenState();
}

class _CreditsListScreenState extends State<CreditsListScreen> {
  List<Credit> _allCredits = [];
  bool _isLoading = true;

  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _fetchCredits();
  }

  Future<void> _fetchCredits() async {
    setState(() => _isLoading = true);
    final credits = await ApiService().getCredits();
    setState(() {
      _allCredits = credits ?? [];
      _isLoading = false;
    });
  }

  List<Credit> get _filteredCredits {
    return _allCredits
        .where((c) {
          if (_fromDate != null && c.date.isBefore(_fromDate!)) return false;
          if (_toDate != null && c.date.isAfter(_toDate!)) return false;
          return true;
        })
        .toList()
      ..sort((a, b) => a.payDate.compareTo(b.payDate));
  }

  int get _totalAmount => _filteredCredits.fold(0, (sum, c) => sum + c.amount);

  Color _getCardColor(Credit credit) {
    final now = DateTime.now();
    final diff = credit.payDate.difference(now).inDays;
    if (diff < 0) return Colors.red[100]!;
    if (diff <= 3) return Colors.orange[100]!;
    return Colors.white;
  }

  Future<void> _deleteCredit(int id, int index) async {
    final success = await ApiService().deleteCredit(id);
    if (success) {
      setState(() => _allCredits.removeAt(index));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('طلب حذف شد')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در حذف طلب')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'لیست طلب‌ها',
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

                  /// نمایش مجموع طلب‌ها
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
                        Text('جمع طلب‌ها در بازه:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('$_totalAmount تومان', style: TextStyle(color: Colors.green[800], fontSize: 16)),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  /// لیست طلب‌ها
                  Expanded(
                    child: _filteredCredits.isEmpty
                        ? Center(child: Text('طلبی در این بازه یافت نشد'))
                        : ListView.builder(
                            itemCount: _filteredCredits.length,
                            itemBuilder: (context, index) {
                              final credit = _filteredCredits[index];
                              return Dismissible(
                                key: Key(credit.id.toString()),
                                background: Container(
                                  color: Colors.green,
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Icon(Icons.edit, color: Colors.white),
                                ),
                                secondaryBackground: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Icon(Icons.delete, color: Colors.white),
                                ),
                                confirmDismiss: (direction) async {
                                  if (direction == DismissDirection.startToEnd) {
                                    Navigator.pushNamed(context, '/edit-credit', arguments: credit).then((result) {
                                      if (result == true) _fetchCredits();
                                    });
                                    return false;
                                  } else if (direction == DismissDirection.endToStart) {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text('حذف طلب'),
                                        content: Text('آیا مطمئن هستید؟'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(ctx).pop(false),
                                            child: Text('خیر'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(ctx).pop(true),
                                            child: Text('بله'),
                                          ),
                                        ],
                                      ),
                                    );
                                    return confirm == true;
                                  }
                                  return false;
                                },
                                onDismissed: (direction) {
                                  if (direction == DismissDirection.endToStart) {
                                    _deleteCredit(credit.id, index);
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _getCardColor(credit),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'از ${credit.personName}',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      SizedBox(height: 4),
                                      Text('مبلغ: ${credit.amount} تومان'),
                                      SizedBox(height: 4),
                                      Text('ثبت شده در: ${credit.date.toLocal().toString().split(' ')[0]}'),
                                      Text('سررسید: ${credit.payDate.toLocal().toString().split(' ')[0]}'),
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
          final result = await Navigator.pushNamed(context, '/add-credit');
          if (result == true) _fetchCredits();
        },
        child: Icon(Icons.add),
        tooltip: 'افزودن اعتبار جدید',
      ),
    );
  }
}
