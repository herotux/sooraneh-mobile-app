class Expense {
  final int id;
  final String text;
  final int amount;
  final String date;
  final int? category;
  final int? person;
  final int? tag;

  Expense({
    required this.id,
    required this.text,
    required this.amount,
    required this.date,
    this.category,
    this.person,
    this.tag,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'amount': amount,
    'date': date,
    'category': category,
    'person': person,
    'tag': tag,
  };
}
