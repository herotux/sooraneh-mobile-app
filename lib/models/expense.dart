class Expense {
  final int? id;
  final String text;
  final int amount;
  final String date;
  final int? category;
  final int? person;
  final int? tag;

  Expense({
    this.id,
    required this.text,
    required this.amount,
    required this.date,
    this.category,
    this.person,
    this.tag,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'],
        text: json['text'],
        amount: json['amount'],
        date: json['date'],
        category: json['category'],
        person: json['person'],
        tag: json['tag'],
      );

  Map<String, Object?> toJson() => {
        'text': text,
        'amount': amount,
        'date': date,
        if (category != null) 'category': category,
        if (person != null) 'person': person,
        if (tag != null) 'tag': tag,
      };
}
