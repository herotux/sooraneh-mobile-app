import 'person.dart';

class Debt {
  final int? id;
  final Person? person;
  final int amount;
  final String description;
  final DateTime date;
  final DateTime payDate;

  Debt({
    this.id,
    this.person,
    required this.amount,
    required this.description,
    required this.date,
    required this.payDate,
  });

  factory Debt.fromJson(Map<String, dynamic> json) => Debt(
        id: json['id'],
        person: json['person'] != null ? Person.fromJson(json['person']) : null,
        amount: json['amount'],
        description: json['text'] ?? '',
        date: DateTime.parse(json['date']),
        payDate: DateTime.parse(json['pay_date']),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'person': person != null ? person!.toJson() : null,
        'amount': amount,
        'text': description,
        'date': date.toIso8601String(),
        'pay_date': payDate.toIso8601String(),
      };
}
