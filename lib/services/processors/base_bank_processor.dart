abstract class BaseBankProcessor {
  /// شماره یا شناسه فرستنده بانک
  List<String> get senders;

  /// بررسی اینکه پیامک متعلق به این بانک هست یا نه
  bool matchesSender(String sender) {
    return senders.any((s) => sender.contains(s));
  }

  /// پردازش پیامک و برگرداندن نتیجه (درآمد یا هزینه)
  /// خروجی: {'type': 'income'|'expense', 'amount': 12345, 'description': '...'}
  Map<String, dynamic>? process(String sms);
}