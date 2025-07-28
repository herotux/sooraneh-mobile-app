import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:daric/models/person.dart';
import 'package:daric/services/api_service.dart';

class PersonDropdown extends StatelessWidget {
  final int? selectedPersonId;
  final void Function(int?) onChanged;

  const PersonDropdown({
    Key? key,
    required this.selectedPersonId,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<Person>(
      asyncItems: (String filter) async {
        final persons = await ApiService().getPersons();
        return persons?.where((p) {
          final fullName = '${p.firstName} ${p.lastName ?? ''}';
          return fullName.contains(filter);
        }).toList() ?? [];
      },
      itemAsString: (Person p) => '${p.firstName} ${p.lastName ?? ''} (${p.relation})',
      selectedItem: null,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "نام شخص",
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          border: OutlineInputBorder(),
        ),
      ),
      onChanged: (person) => onChanged(person?.id),
      dropdownBuilder: (context, selectedItem) {
        if (selectedItem == null) return Text('انتخاب شخص');
        return Text('${selectedItem.firstName} ${selectedItem.lastName ?? ''}');
      },
    );
  }
}
