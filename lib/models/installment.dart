class Installment {
  final int? id;
  final int amount;
  final String text;
  final String first_date;
  final int pay_period;
  final int inst_num;
  final int? inst_rate;
  final int? person;

  Installment({
    this.id,
    required this.amount,
    required this.text,
    required this.first_date,
    required this.pay_period,
    required this.inst_num,
    this.inst_rate,
    this.person,
  });

  factory Installment.fromJson(Map<String, dynamic> json) {
    return Installment(
      id: json['id'],
      amount: json['amount'],
      text: json['text'],
      first_date: json['first_date'],
      pay_period: json['pay_period'],
      inst_num: json['inst_num'],
      inst_rate: json['inst_rate'],
      person: json['person'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'text': text,
      'first_date': first_date,
      'pay_period': pay_period,
      'inst_num': inst_num,
      if (inst_rate != null) 'inst_rate': inst_rate,
      if (person != null) 'person': person,
    };
  }
}
