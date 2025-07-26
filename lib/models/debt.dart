class Debt {
  final int? id;
  final String personName;
  final int amount;
  final String text;
  final DateTime date;
  final DateTime payDate;
  final int? personId;

  Debt({
    this.id,
    required this.personName,
    required this.amount,
    required this.text,
    required this.date,
    required this.payDate,
    this.personId,
  });

  factory Debt.fromJson(Map<String, dynamic> json) => Debt(
        id: json['id'],
        personName: json['person_name'] ?? '',  // فرض می‌کنیم کلید person_name در JSON هست
        amount: json['amount'],
        text: json['text'],
        date: DateTime.parse(json['date']),
        payDate: DateTime.parse(json['pay_date']),
        personId: json['person'],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'person_name': personName,
        'amount': amount,
        'text': text,
        'date': date.toIso8601String(),
        'pay_date': payDate.toIso8601String(),
        'person': personId,
      };
}
