class Income {
  final int? id;
  final int amount;
  final String text;
  final String date;
  final int? person;
  final int? category;
  final int? tag;

  Income({
    this.id,
    required this.amount,
    required this.text,
    required this.date,
    this.person,
    this.category,
    this.tag,
  });

  factory Income.fromJson(Map<String, dynamic> json) => Income(
        id: json['id'],
        amount: json['amount'],
        text: json['text'],
        date: json['date'],
        person: json['person'],
        category: json['category'],
        tag: json['tag'],
      );

  Map<String, Object?> toJson() => {
        'amount': amount,
        'text': text,
        'date': date,
        if (person != null) 'person': person,
        if (category != null) 'category': category,
        if (tag != null) 'tag': tag,
      };
}
