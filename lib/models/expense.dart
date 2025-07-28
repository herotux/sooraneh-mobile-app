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

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      text: json['text'],
      amount: json['amount'],
      date: json['date'],
      category: json['category'],
      person: json['person'],
      tag: json['tag'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'text': text,
      'amount': amount,
      'date': date,
    };

    if (category != null) data['category'] = category;
    if (person != null) data['person'] = person;
    if (tag != null) data['tag'] = tag;

    return data;
  }
}
