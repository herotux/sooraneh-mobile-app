import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

// A generic model that all our dropdown items should conform to.
// This ensures they have an ID and a name for display.
abstract class SearchableItem {
  int? get id;
  String get name;
}

class SearchableAddDropdown<T extends SearchableItem> extends StatefulWidget {
  final String label;
  final T? selectedItem;
  final Future<List<T>> Function(String) onSearch;
  final void Function(T?) onChanged;
  final Future<T?> Function(BuildContext) onAddNew;
  final String? Function(T?)? validator;

  const SearchableAddDropdown({
    Key? key,
    required this.label,
    this.selectedItem,
    required this.onSearch,
    required this.onChanged,
    required this.onAddNew,
    this.validator,
  }) : super(key: key);

  @override
  _SearchableAddDropdownState<T> createState() => _SearchableAddDropdownState<T>();
}

class _SearchableAddDropdownState<T extends SearchableItem> extends State<SearchableAddDropdown<T>> {
  final _popupBuilderKey = GlobalKey<DropdownSearchState<T>>();

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      key: _popupBuilderKey,
      selectedItem: widget.selectedItem,
      validator: widget.validator,
      onChanged: widget.onChanged,
      asyncItems: (String filter) => widget.onSearch(filter),
      itemAsString: (T? item) => item?.name ?? '',
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: widget.label,
          border: OutlineInputBorder(),
        ),
      ),
      popupProps: PopupProps.modalBottomSheet(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: 'جستجو...',
          ),
        ),
        emptyBuilder: (context, searchEntry) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('"${searchEntry}" پیدا نشد.'),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('افزودن آیتم جدید'),
                  onPressed: () async {
                    final newItem = await widget.onAddNew(context);
                    if (newItem != null) {
                      widget.onChanged(newItem);
                      Navigator.pop(context); // Close the bottom sheet
                    }
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
