class Expense {
  final int id;
  final int amount;
  final String text;
  final String date;

  Expense({
    required this.id,
    required this.amount,
    required this.text,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      amount: json['amount'],
      text: json['text'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'text': text,
      'date': date,
    };
  }
}
