class Income {
  final int? id;  // id اختیاری چون هنگام ایجاد نداریم
  final int amount;
  final String text;
  final String date;  // رشته ISO 8601
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

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      amount: json['amount'],
      text: json['text'],
      date: json['date'],
      person: json['person'],
      category: json['category'],
      tag: json['tag'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'amount': amount,
      'text': text,
      'date': date,
    };

    if (person != null) data['person'] = person;
    if (category != null) data['category'] = category;
    if (tag != null) data['tag'] = tag;

    return data;
  }
}
