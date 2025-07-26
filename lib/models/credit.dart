class Credit {
  final int id;
  final String personName;  
  final int amount;         
  final DateTime date;      
  final DateTime payDate;
  final String? description;

  Credit({
    required this.id,
    required this.personName,
    required this.amount,
    required this.date,
    required this.payDate,
    this.description,
  });

  factory Credit.fromJson(Map<String, dynamic> json) => Credit(
        id: json['id'],
        personName: json['person_name'],
        amount: json['amount'],
        date: DateTime.parse(json['date']),
        payDate: DateTime.parse(json['pay_date']),
        description: json['text'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'person_name': personName,
        'amount': amount,
        'date': date.toIso8601String(),
        'pay_date': payDate.toIso8601String(),
        'text': description,
      };
}
