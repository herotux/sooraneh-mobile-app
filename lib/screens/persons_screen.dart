import 'package:flutter/material.dart';
import 'package:daric/models/person.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/main_scaffold.dart';

class PersonsScreen extends StatefulWidget {
  @override
  _PersonsScreenState createState() => _PersonsScreenState();
}

class _PersonsScreenState extends State<PersonsScreen> {
  final ApiService _apiService = ApiService();
  List<Person> _persons = [];
  bool _isLoading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _fetchPersons();
  }

  Future<void> _fetchPersons() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final persons = await _apiService.getPersons();
      setState(() {
        _persons = persons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = 'خطا در بارگذاری اشخاص';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'اشخاص',
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _persons.isEmpty
              ? Center(child: Text(_message ?? 'شخصی ثبت نشده است'))
              : ListView.builder(
                  itemCount: _persons.length,
                  itemBuilder: (context, index) {
                    final p = _persons[index];
                    return ListTile(
                      title: Text('${p.firstName} ${p.lastName ?? ''}'),
                      subtitle: Text('نسبت: ${p.relation}'),
                    );
                  },
                ),
    );
  }
}
