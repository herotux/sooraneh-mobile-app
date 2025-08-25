import 'package:flutter/material.dart';
import 'package:daric/models/tag.dart';
import 'package:daric/services/api_service.dart';
import 'edit_tag_screen.dart'; // This file doesn't exist yet, but we'll create it.
import 'add_tag_screen.dart'; // This file doesn't exist yet, but we'll create it.
import 'package:daric/widgets/main_scaffold.dart';

class TagsScreen extends StatefulWidget {
  @override
  _TagsScreenState createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Tag>> _tagsFuture;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  void _loadTags() {
    setState(() {
      _tagsFuture = _apiService.getTags().then((value) => value ?? []);
    });
  }

  Future<void> _deleteTag(int id) async {
    final success = await _apiService.deleteTag(id);
    if (success) {
      _loadTags();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تگ با موفقیت حذف شد')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در حذف تگ')),
      );
    }
  }

  void _editTag(Tag tag) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTagScreen(tag: tag),
      ),
    );

    if (result == true) {
      _loadTags();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'تگ‌ها',
      body: FutureBuilder<List<Tag>>(
        future: _tagsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطا در بارگذاری تگ‌ها'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('هیچ تگی وجود ندارد'));
          }

          final tags = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              return Card(
                child: Dismissible(
                  key: ValueKey(tag.id),
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
                      _editTag(tag);
                      return false;
                    } else {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('حذف تگ'),
                          content: Text('آیا از حذف این تگ مطمئن هستید؟'),
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
                      return confirm ?? false;
                    }
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      _deleteTag(tag.id!);
                    }
                  },
                  child: ListTile(
                    title: Text(tag.name),
                    subtitle: tag.description != null ? Text(tag.description!) : null,
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
            MaterialPageRoute(builder: (_) => AddTagScreen()),
          );
          if (result == true) {
            _loadTags();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
