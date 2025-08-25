import 'package:daric/widgets/searchable_add_dropdown.dart';

class Person implements SearchableItem {
  @override
  final int id;
  final String firstName;
  final String? lastName;
  final String relation;

  Person({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.relation,
  });

  @override
  String get name => fullName;

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json['id'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        relation: json['relation'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'relation': relation,
      };

  String get fullName => lastName != null && lastName!.isNotEmpty
      ? '$firstName $lastName'
      : firstName;
}
