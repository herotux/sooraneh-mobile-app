class Budget {
  final int? id;
  final int monthly_budget;
  final int? category;

  Budget({
    this.id,
    required this.monthly_budget,
    this.category,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      monthly_budget: json['monthly_budget'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthly_budget': monthly_budget,
      if (category != null) 'category': category,
    };
  }
}
