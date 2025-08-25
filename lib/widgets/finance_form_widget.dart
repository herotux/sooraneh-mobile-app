import 'package:flutter/material.dart';
import 'package:daric/models/category.dart';
import 'package:daric/models/tag.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/my_date_picker_modal.dart';
import 'package:daric/utils/entry_type.dart';
import 'package:daric/widgets/searchable_add_dropdown.dart';
import 'package:daric/models/person.dart';
import 'package:daric/models/income.dart';
import 'package:daric/models/expense.dart';
import 'package:daric/models/credit.dart';
import 'package:daric/models/debt.dart';

class FinanceFormWidget extends StatefulWidget {
  final EntryType type;
  final dynamic initialEntry;
  final Future<bool> Function(dynamic entry) onSubmit;

  const FinanceFormWidget({
    super.key,
    required this.type,
    required this.onSubmit,
    this.initialEntry,
  });

  @override
  State<FinanceFormWidget> createState() => _FinanceFormWidgetState();
}

class _FinanceFormWidgetState extends State<FinanceFormWidget> {
  final _formKey = GlobalKey<FormState>();
  String _description = '';
  double? _amount;
  DateTime _date = DateTime.now();
  DateTime? _payDate;
  int? _personId;
  int? _categoryId;
  int? _tagId;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialValues();
  }

  void _loadInitialValues() {
    final e = widget.initialEntry;
    if (e != null) {
      if (e is Income) {
        _description = e.text;
        _amount = e.amount.toDouble();
        _date = DateTime.parse(e.date);
        _personId = e.personId;
        _categoryId = e.category;
        _tagId = e.tag;
      } else if (e is Expense) {
        _description = e.text;
        _amount = e.amount.toDouble();
        _date = DateTime.parse(e.date);
        _personId = e.personId;
        _categoryId = e.category;
        _tagId = e.tag;
      } else if (e is Credit) {
        _description = e.description ?? '';
        _amount = e.amount.toDouble();
        _date = e.date;
        _payDate = e.payDate;
        _personId = e.personId;
      } else if (e is Debt) {
        _description = e.description;
        _amount = e.amount.toDouble();
        _date = e.date;
        _payDate = e.payDate;
        _personId = e.personId;
      }
    }
  }

  Future<void> _selectDate({required bool isPayDate}) async {
    final picked = await showMyDatePickerModal(
      context: context,
      label: isPayDate ? 'تاریخ تسویه' : 'تاریخ ثبت',
      initialDate: isPayDate ? (_payDate ?? DateTime.now()) : _date,
    );
    if (picked != null) {
      setState(() {
        if (isPayDate) {
          _payDate = picked;
        } else {
          _date = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    dynamic entry;
    try {
      final id = widget.initialEntry?.id; // گرفتن id برای حالت ویرایش

      switch (widget.type) {
        case EntryType.income:
          entry = Income(
            id: id,
            amount: _amount!.toInt(),
            text: _description,
            date: _date.toIso8601String(),
            personId: _personId,
            category: _categoryId,
            tag: _tagId,
          );
          break;

        case EntryType.expense:
          entry = Expense(
            id: id,
            amount: _amount!.toInt(),
            text: _description,
            date: _date.toIso8601String(),
            personId: _personId,
            category: _categoryId,
            tag: _tagId,
          );
          break;

        case EntryType.credit:
          if (_payDate == null) throw Exception("تاریخ تسویه لازم است");
          entry = Credit(
            id: id ?? 0,
            amount: _amount!.toInt(),
            description: _description,
            date: _date,
            payDate: _payDate!,
            personId: _personId,
          );
          break;

        case EntryType.debt:
          if (_payDate == null) throw Exception("تاریخ تسویه لازم است");
          entry = Debt(
            id: id ?? 0,
            amount: _amount!.toInt(),
            description: _description,
            date: _date,
            payDate: _payDate!,
            personId: _personId,
          );
          break;
      }

      final success = await widget.onSubmit(entry);
      if (success && mounted) {
        Navigator.pop(context, true);
      } else {
        setState(() => _errorMessage = 'خطا در ذخیره اطلاعات');
      }
    } catch (e) {
      setState(() => _errorMessage = 'خطا: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    initialValue: _description,
                    decoration: const InputDecoration(
                      labelText: 'توضیحات',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'توضیح را وارد کنید' : null,
                    onSaved: (val) => _description = val!.trim(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _amount?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'مبلغ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      final parsed = double.tryParse(val ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'مبلغ معتبر نیست';
                      }
                      return null;
                    },
                    onSaved: (val) => _amount = double.tryParse(val!),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(isPayDate: false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'تاریخ ثبت',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_formatDate(_date)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.type == EntryType.credit || widget.type == EntryType.debt)
                    InkWell(
                      onTap: () => _selectDate(isPayDate: true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'تاریخ تسویه',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _payDate != null ? _formatDate(_payDate!) : 'انتخاب نشده',
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SearchableAddDropdown<Person>(
                    label: "طرف حساب",
                    onChanged: (person) => setState(() => _personId = person?.id),
                    onSearch: (query) => ApiService().getPersons(), // Simplified search
                    onAddNew: (context) => _showAddPersonModal(context),
                  ),
                  const SizedBox(height: 16),
                  if (widget.type == EntryType.expense || widget.type == EntryType.income) ...[
                    SearchableAddDropdown<Category>(
                      label: "دسته‌بندی",
                      onChanged: (category) => setState(() => _categoryId = category?.id),
                      onSearch: (query) => ApiService().getCategories(),
                    onAddNew: (context) => _showAddCategoryModal(context),
                    ),
                    const SizedBox(height: 16),
                    SearchableAddDropdown<Tag>(
                    label: "تگ",
                    onChanged: (tag) => setState(() => _tagId = tag?.id),
                    onSearch: (query) => ApiService().getTags(),
                    onAddNew: (context) => _showAddTagModal(context),
                  ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('ذخیره'),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  Future<Person?> _showAddPersonModal(BuildContext context) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final relationController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<Person>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('افزودن شخص جدید'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: firstNameController,
                  decoration: InputDecoration(labelText: 'نام'),
                  validator: (val) => val!.isEmpty ? 'نام را وارد کنید' : null,
                ),
                TextFormField(
                  controller: lastNameController,
                  decoration: InputDecoration(labelText: 'نام خانوادگی (اختیاری)'),
                ),
                TextFormField(
                  controller: relationController,
                  decoration: InputDecoration(labelText: 'نسبت'),
                   validator: (val) => val!.isEmpty ? 'نسبت را وارد کنید' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('لغو'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newPerson = await ApiService().addPerson(
                    Person(
                      id: 0,
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      relation: relationController.text,
                    ),
                  );
                  if (newPerson != null && dialogContext.mounted) {
                    Navigator.pop(dialogContext, newPerson);
                  } else {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text('خطا در افزودن شخص')),
                    );
                  }
                }
              },
              child: Text('ذخیره'),
            ),
          ],
        );
      },
    );
  }

  Future<Category?> _showAddCategoryModal(BuildContext context) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isIncome = false; // Default to expense

    return showDialog<Category>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('افزودن دسته‌بندی جدید'),
          content: StatefulBuilder(
            builder: (context, setModalState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'نام دسته‌بندی'),
                      validator: (val) => val!.isEmpty ? 'نام را وارد کنید' : null,
                    ),
                    SwitchListTile(
                      title: Text('برای درآمد'),
                      value: isIncome,
                      onChanged: (val) => setModalState(() => isIncome = val),
                    )
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('لغو'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newCategory = await ApiService().addCategory(
                    Category(id: 0, name: nameController.text, isIncome: isIncome),
                  );
                  if (newCategory != null && dialogContext.mounted) {
                    Navigator.pop(dialogContext, newCategory);
                  } else {
                     ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text('خطا در افزودن دسته‌بندی')),
                    );
                  }
                }
              },
              child: Text('ذخیره'),
            ),
          ],
        );
      },
    );
  }

  Future<Tag?> _showAddTagModal(BuildContext context) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<Tag>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('افزودن تگ جدید'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'نام تگ'),
              validator: (val) => val!.isEmpty ? 'نام را وارد کنید' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('لغو'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newTag = await ApiService().addTag(Tag(name: nameController.text));
                  if (newTag != null && dialogContext.mounted) {
                    Navigator.pop(dialogContext, newTag);
                  } else {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text('خطا در افزودن تگ')),
                    );
                  }
                }
              },
              child: Text('ذخیره'),
            ),
          ],
        );
      },
    );
  }
}