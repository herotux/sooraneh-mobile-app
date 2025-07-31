class Expense {
  final int? id;
  final String text;
  final int amount;
  final String date;  // رشته تاریخ به فرمت ISO8601
  final int? category;
  final int? personId;
  final Person? person;
  final int? tag;

  Expense({
    this.id,
    required this.text,
    required this.amount,
    required this.date,
    this.category,
    this.personId,
    this.person,
    this.tag,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'],
        text: json['text'],
        amount: json['amount'],
        date: json['date'],
        category: json['category'],
        personId: json['person_id'],
        person: json['person'] != null ? Person.fromJson(json['person']) : null,
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
        'date': date,
        'text': text,
        if (tag != null) 'tag': tag,
        if (category != null) 'category': category,
      };
}
