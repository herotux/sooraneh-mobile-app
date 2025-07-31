class Income {
  final int? id;
  final int amount;
  final String text;
  final String date;
  final int? personId;
  final Person? person;
  final int? category;
  final int? tag;

  Income({
    this.id,
    required this.amount,
    required this.text,
    required this.date,
    this.personId,
    this.person,
    this.category,
    this.tag,
  });

  factory Income.fromJson(Map<String, dynamic> json) => Income(
        id: json['id'],
        amount: json['amount'],
        text: json['text'],
        date: json['date'],
        personId: json['person_id'],
        person: json['person'] != null ? Person.fromJson(json['person']) : null,
        category: json['category'],
        tag: json['tag'],
      );

  Map<String, Object?> toJson() => {
        if (person != null) 'person': {
          'first_name': person!.firstName,
          'last_name': person!.lastName,
          'relation': person!.relation,
        },
        if (personId != null) 'person_id': personId,
        'amount': amount,
        'text': text,
        'date': date,
        if (category != null) 'category': category,
        if (tag != null) 'tag': tag,
      };
}
