import 'base_bank_processor.dart';

class SepehProcessor extends BaseBankProcessor {
  @override
  List<String> get senders => [
        "Bank Sepah",
        "بانک سپه",
        "بانك سپه",
      ];

  // برداشت (انتقال یا خرید)
  final _withdrawPattern1 = RegExp(
      r"برداشت\s+از:\s*[۰-۹0-9]+.*?مبلغ[:：]([\d,]+)\s*ريال",
      caseSensitive: false);
  final _withdrawPattern2 = RegExp(
      r"مبلغ[:：]([\d,]+)\s*ريال.*?(?:خريد|انتقال|برداشت)",
      caseSensitive: false);

  // واریز (گروهی، کارت، پرداخت لحظه‌ای)
  final _depositPattern1 = RegExp(
      r"(?:واريز|پرداخت)\s+(?:به|حقوق|لحظه‌اي|گروهي).*?مبلغ[:：]([\d,]+)\s*ريال",
      caseSensitive: false);
  final _depositPattern2 =
      RegExp(r"مبلغ[:：]([\d,]+)\s*ريال.*?واريز", caseSensitive: false);

  @override
  Map<String, dynamic>? process(String sms) {
    sms = sms.replaceAll("\u202C", "").replaceAll("\u202A", ""); // حذف کاراکترهای مخفی

    // بررسی واریز
    if (_depositPattern1.hasMatch(sms) || _depositPattern2.hasMatch(sms)) {
      final match =
          _depositPattern1.firstMatch(sms) ?? _depositPattern2.firstMatch(sms);
      if (match != null) {
        return {
          'type': 'income',
          'amount': int.parse(match.group(1)!.replaceAll(",", "")),
          'description': sms
        };
      }
    }

    // بررسی برداشت
    if (_withdrawPattern1.hasMatch(sms) || _withdrawPattern2.hasMatch(sms)) {
      final match =
          _withdrawPattern1.firstMatch(sms) ?? _withdrawPattern2.firstMatch(sms);
      if (match != null) {
        return {
          'type': 'expense',
          'amount': int.parse(match.group(1)!.replaceAll(",", "")),
          'description': sms
        };
      }
    }

    return null;
  }
}