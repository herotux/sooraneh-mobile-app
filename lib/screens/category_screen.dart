import 'package:flutter/material.dart';
import 'package:daric/models/category.dart';
import 'package:daric/services/api_service.dart';
import 'edit_category_screen.dart';
import 'package:daric/widgets/main_scaffold.dart';



class CategoriesScreen extends StatefulWidget {
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    _categoriesFuture = _apiService.getCategories().then((value) => value ?? []);
  }

  Future<void> _deleteCategory(int id) async {
    final success = await _apiService.deleteCategory(id);
    if (success) {
      setState(() {
        _loadCategories();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('دسته‌بندی حذف شد')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در حذف دسته‌بندی')),
      );
    }
  }

  void _editCategory(Category category) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditCategoryScreen(category: category),
      ),
    );

    if (result == true) {
      setState(() {
        _loadCategories();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'دسته‌بندی‌ها',
      body: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('هیچ دسته‌بندی‌ای وجود ندارد'));
          }

          final categories = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Dismissible(
                key: ValueKey(category.id),
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
                    // کشیدن به راست = ویرایش
                    _editCategory(category);
                    return false; // برای جلوگیری از حذف خودکار
                  } else if (direction == DismissDirection.endToStart) {
                    // کشیدن به چپ = حذف
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('حذف دسته‌بندی'),
                        content: Text('آیا مطمئنید می‌خواهید این دسته‌بندی حذف شود؟'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('خیر'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('بله'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _deleteCategory(category.id);
                      return true;
                    }
                    return false;
                  }
                  return false;
                },
                child: ListTile(
                  title: Text(category.name),
                  trailing: category.isIncome
                      ? Icon(Icons.arrow_upward, color: Colors.green)
                      : Icon(Icons.arrow_downward, color: Colors.red),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add-category');
          if (result == true) {
            setState(() {
              _loadCategories();
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
