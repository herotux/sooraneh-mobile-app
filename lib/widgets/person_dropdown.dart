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
  @override
  Widget build(BuildContext context) {
    return DropdownSearch<Person>(
      asyncItems: (String filter) async {
        final persons = await ApiService().getPersons();
        if (persons == null) return [];
        if (filter.isEmpty) return persons;
        return persons
            .where((p) {
              final fullName =
                  '${p.firstName} ${p.lastName ?? ''}'.toLowerCase();
              return fullName.contains(filter.toLowerCase());
            })
            .toList();
      },
      itemAsString: (Person p) =>
          '${p.firstName} ${p.lastName ?? ''} (${p.relation ?? ''})',

      // این بخش باعث میشه آیتم انتخاب‌شده با id مقایسه بشه
      compareFn: (a, b) => a.id == b.id,

      // مقدار اولیه بر اساس selectedPersonId
      selectedItem: widget.selectedPersonId != null
          ? Person(id: widget.selectedPersonId!, firstName: '', relation: '')
          : null,

      onChanged: (person) => widget.onChanged(person?.id),

      dropdownBuilder: (context, selectedItem) {
        if (selectedItem == null || selectedItem.id == null) {
          return const Text('انتخاب شخص');
        }
        return Text(
          '${selectedItem.firstName} ${selectedItem.lastName ?? ''}',
        );
      },
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: const InputDecoration(
            labelText: 'جستجوی نام',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: const InputDecoration(
          labelText: "نام شخص",
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}