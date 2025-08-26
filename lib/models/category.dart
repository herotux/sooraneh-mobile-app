import 'package:daric/models/searchable_item.dart';

class Category implements SearchableItem {
  @override
  final int id;
  @override
  final String name;
  final bool isIncome;
  final int? parent;

  Category({
    required this.id,
    required this.name,
    required this.isIncome,
    this.parent,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      isIncome: json['is_income'],
      parent: json['parent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'is_income': isIncome,
      'parent': parent,
    };
  }
}
