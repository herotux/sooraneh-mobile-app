class Person {
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

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json['id'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        relation: json['relation'],
      );
}
