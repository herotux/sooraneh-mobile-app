import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:daric/models/person.dart';
import 'package:daric/services/api_service.dart';

class PersonDropdown extends StatefulWidget {
  final int? selectedPersonId;
  final void Function(int?) onChanged;

  const PersonDropdown({
    Key? key,
    required this.selectedPersonId,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<PersonDropdown> createState() => _PersonDropdownState();
}

class _PersonDropdownState extends State<PersonDropdown> {
  Person? _selectedPerson;
  bool _isLoadingInitial = true;

  @override
  void initState() {
    super.initState();
    _loadInitialPerson();
  }

  Future<void> _loadInitialPerson() async {
    if (widget.selectedPersonId != null) {
      try {
        final persons = await ApiService().getPersons();
        if (persons != null) {
          final matched = persons.firstWhere(
            (p) => p.id == widget.selectedPersonId,
            orElse: () => null,
          );
          if (matched != null) {
            setState(() {
              _selectedPerson = matched;
            });
          }
        }
      } catch (e) {
        print('Error loading initial person: $e');
      }
    }
    setState(() {
      _isLoadingInitial = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitial) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: 'نام شخص',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return DropdownSearch<Person>(
      asyncItems: (String filter) async {
        final persons = await ApiService().getPersons();
        if (persons == null) return [];
        if (filter.isEmpty) return persons;
        return persons
            .where((p) {
              final fullName = '${p.firstName} ${p.lastName ?? ''}'.toLowerCase();
              return fullName.contains(filter.toLowerCase());
            })
            .toList();
      },
      itemAsString: (Person p) => '${p.firstName} ${p.lastName ?? ''} (${p.relation ?? ''})',
      selectedItem: _selectedPerson,
      onChanged: (person) {
        setState(() {
          _selectedPerson = person;
        });
        widget.onChanged(person?.id);
      },
      dropdownBuilder: (context, selectedItem) {
        if (selectedItem == null) {
          return Text('انتخاب شخص');
        }
        return Text('${selectedItem.firstName} ${selectedItem.lastName ?? ''}');
      },
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            labelText: 'جستجوی نام',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "نام شخص",
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
