import 'package:daric/models/searchable_item.dart';

class Tag implements SearchableItem {
  @override
  final int? id;
  @override
  final String name;
  final String? description;

  Tag({
    this.id,
    required this.name,
    this.description,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
    };
  }
}
