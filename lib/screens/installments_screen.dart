import 'package:flutter/material.dart';
import 'package:daric/models/installment.dart';
import 'package:daric/services/api_service.dart';
import 'edit_installment_screen.dart'; // To be created
import 'add_installment_screen.dart'; // To be created
import 'package:daric/widgets/main_scaffold.dart';
import 'package:intl/intl.dart';

class InstallmentsScreen extends StatefulWidget {
  @override
  _InstallmentsScreenState createState() => _InstallmentsScreenState();
}

class _InstallmentsScreenState extends State<InstallmentsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Installment>> _installmentsFuture;

  @override
  void initState() {
    super.initState();
    _loadInstallments();
  }

  void _loadInstallments() {
    setState(() {
      _installmentsFuture = _apiService.getInstallments().then((value) => value ?? []);
    });
  }

  Future<void> _deleteInstallment(int id) async {
    final success = await _apiService.deleteInstallment(id);
    if (success) {
      _loadInstallments();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('قسط با موفقیت حذف شد')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در حذف قسط')));
    }
  }

  void _editInstallment(Installment installment) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditInstallmentScreen(installment: installment)),
    );
    if (result == true) {
      _loadInstallments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'fa_IR', symbol: 'تومان');

    return MainScaffold(
      title: 'اقساط',
      body: FutureBuilder<List<Installment>>(
        future: _installmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطا در بارگذاری اقساط'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('هیچ قسطی وجود ندارد'));
          }

          final installments = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: installments.length,
            itemBuilder: (context, index) {
              final installment = installments[index];
              return Card(
                child: Dismissible(
                  key: ValueKey(installment.id),
                  background: Container(color: Colors.green, alignment: Alignment.centerLeft, padding: EdgeInsets.only(left: 20), child: Icon(Icons.edit, color: Colors.white)),
                  secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, padding: EdgeInsets.only(right: 20), child: Icon(Icons.delete, color: Colors.white)),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      _editInstallment(installment);
                      return false;
                    } else {
                      return await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('حذف قسط'),
                          content: Text('آیا از حذف این قسط مطمئن هستید؟'),
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
                      _deleteInstallment(installment.id!);
                    }
                  },
                  child: ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text(installment.text),
                    subtitle: Text('${installment.inst_num} قسط ${currencyFormat.format(installment.amount)}'),
                    trailing: Text('هر ${installment.pay_period} روز'),
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
            MaterialPageRoute(builder: (_) => AddInstallmentScreen()),
          );
          if (result == true) {
            _loadInstallments();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
