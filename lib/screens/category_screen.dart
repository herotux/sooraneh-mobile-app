import 'package:flutter/material.dart';
import 'package:daric/models/category.dart';
import 'package:daric/services/api_service.dart';

class CategoryScreen extends StatefulWidget {
  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Category>?> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _apiService.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('دسته‌بندی‌ها'),
        actions: [
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                Navigator.pushNamed(context, '/add-category').then((_) {
                    setState(() {
                    _categoriesFuture = _apiService.getCategories(); // رفرش لیست
                    });
                });
                },
            )
        ],

      ),
      body: FutureBuilder<List<Category>?>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text('دسته‌ای یافت نشد'));

          final categories = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final c = categories[index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Icon(
                    c.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: c.isIncome ? Colors.green : Colors.red,
                  ),
                  title: Text(c.name),
                  subtitle: Text(c.isIncome ? 'درآمد' : 'هزینه'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
