import 'person.dart';

class Credit {
  final int id;
  final Person? person; // فقط برای نمایش
  final int amount;
  final DateTime date;
  final DateTime payDate;
  final String? description;

  /// این فیلد فقط برای ارسال استفاده میشه
  final int? personId;

  Credit({
    required this.id,
    this.person,
    required this.amount,
    required this.date,
    required this.payDate,
    this.description,
    this.personId,
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
        'person_id': personId, // فقط آی‌دی
        'amount': amount,
        'date': date.toIso8601String(),
        'pay_date': payDate.toIso8601String(),
        'text': description,
      };
}
