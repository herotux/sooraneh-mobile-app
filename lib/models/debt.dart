import 'person.dart';

class Debt {
  final int? id;
  final Person? person;       // فقط برای نمایش
  final int amount;
  final String description;
  final DateTime date;
  final DateTime payDate;
  final int? personId;        // فقط برای ارسال

  Debt({
    this.id,
    this.person,
    this.personId,
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
        if (personId != null) 'person_id': personId,
        'amount': amount,
        'text': description,
        'date': date.toIso8601String(),
        'pay_date': payDate.toIso8601String(),
      };
}
