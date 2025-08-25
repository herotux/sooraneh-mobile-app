import 'package:flutter/material.dart';
import 'package:daric/models/tag.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/main_scaffold.dart';

class EditTagScreen extends StatefulWidget {
  final Tag tag;

  EditTagScreen({required this.tag});

  @override
  _EditTagScreenState createState() => _EditTagScreenState();
}

class _EditTagScreenState extends State<EditTagScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tag.name);
    _descriptionController = TextEditingController(text: widget.tag.description);
  }

  Future<void> _updateTag() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final updatedTag = Tag(
      id: widget.tag.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
    );

    final success = await _apiService.updateTag(updatedTag);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pop(context, true); // Go back with success result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تگ با موفقیت به‌روزرسانی شد')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در به‌روزرسانی تگ')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "ویرایش تگ",
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'نام تگ'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'نام تگ را وارد کنید' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'توضیحات (اختیاری)'),
              ),
              SizedBox(height: 24),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _updateTag,
                      child: Text('ذخیره تغییرات'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
