import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:daric/models/installment.dart';
import 'package:daric/models/person.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/main_scaffold.dart';
import 'package:daric/widgets/my_date_picker.dart';
import 'package:daric/widgets/searchable_add_dropdown.dart';

class EditInstallmentScreen extends StatefulWidget {
  final Installment installment;

  EditInstallmentScreen({required this.installment});

  @override
  _EditInstallmentScreenState createState() => _EditInstallmentScreenState();
}

class _EditInstallmentScreenState extends State<EditInstallmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _textController;
  late TextEditingController _amountController;
  late TextEditingController _periodController;
  late TextEditingController _numController;
  late TextEditingController _rateController;
  DateTime? _selectedDate;
  int? _selectedPersonId;
  Person? _initialPerson;
  bool _isInitializing = true;

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final inst = widget.installment;
    _textController = TextEditingController(text: inst.text);
    _amountController = TextEditingController(text: inst.amount.toString());
    _periodController = TextEditingController(text: inst.pay_period.toString());
    _numController = TextEditingController(text: inst.inst_num.toString());
    _rateController = TextEditingController(text: inst.inst_rate?.toString() ?? '');
    _selectedDate = DateTime.tryParse(inst.first_date);
    _selectedPersonId = inst.person;
    _loadInitialPerson();
  }

  Future<void> _loadInitialPerson() async {
    if (_selectedPersonId == null) {
      setState(() => _isInitializing = false);
      return;
    }
    final persons = await _apiService.getPersons();
    if (persons != null) {
      setState(() {
        _initialPerson = persons.firstWhere((p) => p.id == _selectedPersonId, orElse: () => persons.first);
      });
    }
    setState(() => _isInitializing = false);
  }

  Future<void> _updateInstallment() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('لطفا تاریخ را انتخاب کنید')));
      return;
    }

    setState(() { _isLoading = true; });

    final updatedInstallment = Installment(
      id: widget.installment.id,
      text: _textController.text.trim(),
      amount: int.parse(_amountController.text.trim()),
      first_date: _selectedDate!.toIso8601String(),
      pay_period: int.parse(_periodController.text.trim()),
      inst_num: int.parse(_numController.text.trim()),
      inst_rate: _rateController.text.trim().isEmpty ? null : int.parse(_rateController.text.trim()),
      person: _selectedPersonId,
    );

    final success = await _apiService.updateInstallment(updatedInstallment);

    setState(() { _isLoading = false; });

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('قسط با موفقیت به‌روزرسانی شد')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در به‌روزرسانی قسط')));
    }
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

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: "ویرایش قسط",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _textController, decoration: InputDecoration(labelText: 'عنوان'), validator: (v) => v!.isEmpty ? 'عنوان را وارد کنید' : null),
              SizedBox(height: 8),
              TextFormField(controller: _amountController, decoration: InputDecoration(labelText: 'مبلغ هر قسط'), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], validator: (v) => v!.isEmpty ? 'مبلغ را وارد کنید' : null),
              SizedBox(height: 8),
              TextFormField(controller: _periodController, decoration: InputDecoration(labelText: 'دوره پرداخت (به روز)'), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], validator: (v) => v!.isEmpty ? 'دوره را وارد کنید' : null),
              SizedBox(height: 8),
              TextFormField(controller: _numController, decoration: InputDecoration(labelText: 'تعداد اقساط'), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], validator: (v) => v!.isEmpty ? 'تعداد را وارد کنید' : null),
              SizedBox(height: 8),
              TextFormField(controller: _rateController, decoration: InputDecoration(labelText: 'نرخ سود (اختیاری)'), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              SizedBox(height: 16),
              MyDatePicker(
                labelText: 'تاریخ اولین قسط',
                selectedDate: _selectedDate,
                onDateSelected: (date) => setState(() => _selectedDate = date),
              ),
              SizedBox(height: 16),
              _isInitializing
                ? Center(child: CircularProgressIndicator())
                : SearchableAddDropdown<Person>(
                    label: "طرف حساب (اختیاری)",
                    selectedItem: _initialPerson,
                    onChanged: (person) => setState(() => _selectedPersonId = person?.id),
                    onSearch: (query) => ApiService().getPersons(),
                    onAddNew: (context) => _showAddPersonModal(context),
                  ),
              SizedBox(height: 24),
              _isLoading ? Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _updateInstallment, child: Text('ذخیره تغییرات')),
            ],
          ),
        ),
      ),
    );
  }
}
