import 'package:flutter/material.dart';
import 'package:daric/models/tag.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/main_scaffold.dart';

class AddTagScreen extends StatefulWidget {
  @override
  _AddTagScreenState createState() => _AddTagScreenState();
}

class _AddTagScreenState extends State<AddTagScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _submitTag() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final tag = Tag(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
    );

    final newTag = await _apiService.addTag(tag);

    setState(() {
      _isLoading = false;
    });

    if (newTag != null) {
      Navigator.pop(context, true); // Go back with success result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تگ با موفقیت اضافه شد')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ثبت تگ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "افزودن تگ جدید",
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
                      onPressed: _submitTag,
                      child: Text('ثبت تگ'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
