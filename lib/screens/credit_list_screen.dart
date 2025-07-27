import 'package:flutter/material.dart';
import 'package:daric/models/credit.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/main_scaffold.dart';

class CreditsListScreen extends StatefulWidget {
  @override
  State<CreditsListScreen> createState() => _CreditsListScreenState();
}

class _CreditsListScreenState extends State<CreditsListScreen> {
  List<Credit> _credits = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCredits();
  }

  Future<void> _fetchCredits() async {
    setState(() => _isLoading = true);
    final credits = await ApiService().getCredits();
    setState(() {
      _credits = credits ?? [];
      _isLoading = false;
    });
  }

  Future<void> _deleteCredit(int id, int index) async {
    final success = await ApiService().deleteCredit(id);
    if (success) {
      setState(() {
        _credits.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('اعتبار حذف شد')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در حذف اعتبار')),
      );
      _fetchCredits(); // بارگذاری مجدد برای اطمینان
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'لیست اعتبارات',
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _credits.length,
              itemBuilder: (context, index) {
                final credit = _credits[index];

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
                    if (direction == DismissDirection.endToStart) {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('حذف اعتبار'),
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
                    } else if (direction == DismissDirection.startToEnd) {
                      Navigator.pushNamed(context, '/edit-credit', arguments: credit)
                          .then((value) {
                        if (value == true) _fetchCredits();
                      });
                      return false;
                    }
                    return false;
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      _deleteCredit(credit.id, index);
                    }
                  },
                  child: ListTile(
                    title: Text('${credit.personName}'),
                    subtitle: Text(
                      'مبلغ: ${credit.amount} تومان\nتاریخ: ${credit.date.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: Text(
                      'تاریخ بازپرداخت:\n${credit.payDate.toLocal().toString().split(' ')[0]}',
                      textAlign: TextAlign.end,
                    ),
                  ),
                );
              },
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
