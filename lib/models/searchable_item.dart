// A generic model that all our dropdown items should conform to.
// This ensures they have an ID and a name for display.
abstract class SearchableItem {
  int? get id;
  String get name;
}
