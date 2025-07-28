import 'person.dart';

class Credit {
  final int id;
  final Person? person;           // خود آبجکت Person به جای فقط id
  final int amount;
  final DateTime date;
  final DateTime payDate;
  final String? description;

  Credit({
    required this.id,
    this.person,
    required this.amount,
    required this.date,
    required this.payDate,
    this.description,
  });

  factory Credit.fromJson(Map<String, dynamic> json) => Credit(
        id: json['id'],
        person: json['person'] != null ? Person.fromJson(json['person']) : null,
        amount: json['amount'],
        date: DateTime.parse(json['date']),
        payDate: DateTime.parse(json['pay_date']),
        description: json['text'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'person': person != null ? person!.toJson() : null,
        'amount': amount,
        'date': date.toIso8601String(),
        'pay_date': payDate.toIso8601String(),
        'text': description,
      };
}
