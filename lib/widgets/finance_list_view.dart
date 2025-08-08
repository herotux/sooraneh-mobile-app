import 'package:flutter/material.dart';
import 'package:daric/widgets/daric_list_card.dart';
import 'package:daric/widgets/common_filter_sheet.dart';

typedef ItemToCard<T> = DaricListCard Function(T item);
typedef EditCallback<T> = void Function(T item);
typedef DeleteCallback = Future<bool> Function(int id);
typedef FetchItems<T> = Future<List<T>> Function();

class FinanceListView<T> extends StatefulWidget {
  final String title;
  final FetchItems<T> fetchItems;
  final DeleteCallback onDelete;
  final EditCallback<T> onEdit;
  final ItemToCard<T> itemBuilder;
  final Widget? header;
  final String emptyMessage;
  final String addRoute;

  const FinanceListView({
    required this.title,
    required this.fetchItems,
    required this.onDelete,
    required this.onEdit,
    required this.itemBuilder,
    required this.addRoute,
    this.header,
    this.emptyMessage = 'موردی یافت نشد',
    Key? key,
  }) : super(key: key);

  @override
  State<FinanceListView<T>> createState() => _FinanceListViewState<T>();
}

class _FinanceListViewState<T> extends State<FinanceListView<T>> {
  late Future<List<T>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.fetchItems();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = widget.fetchItems();
    });
  }

  void _openFilterSheet() {
    // اینجا بعدا می‌تونی قابلیت فیلتر اضافه کنی
    showModalBottomSheet(
      context: context,
      builder: (_) => CommonFilterSheet(
        type: 'custom',
        onApply: (_) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterSheet,
            tooltip: 'فیلتر',
          )
        ],
      ),
      body: FutureBuilder<List<T>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(widget.emptyMessage));
          }

          final items = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Dismissible(
                  key: ValueKey(item.hashCode),
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      widget.onEdit(item);
                      return false;
                    } else {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('حذف مورد'),
                          content: const Text('آیا مطمئن هستید؟'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لغو')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
                          ],
                        ),
                      );
                      if (confirm == true) return await widget.onDelete(item.hashCode);
                      return false;
                    }
                  },
                  child: widget.itemBuilder(item),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, widget.addRoute);
          if (result == true) _refresh();
        },
        child: const Icon(Icons.add),
        tooltip: 'افزودن',
      ),
    );
  }
}
