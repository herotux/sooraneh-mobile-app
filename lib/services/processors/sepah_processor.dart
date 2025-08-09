import 'base_bank_processor.dart';

class SepehProcessor extends BaseBankProcessor {
  @override
  List<String> get senders => [
        "Bank Sepah",
        "بانک سپه",
        "بانك سپه",
      ];

  // الگوهای برداشت
  final RegExp _withdrawPattern1 = RegExp(
      r"برداشت\s+از:\s*[\d]+.*?مبلغ[:：]\s*([\d,]+)\s*ريال",
      caseSensitive: false);
  final RegExp _withdrawPattern2 = RegExp(
      r"مبلغ[:：]\s*([\d,]+)\s*ريال.*?(?:خريد|انتقال|برداشت)",
      caseSensitive: false);

  // الگوهای واریز
  final RegExp _depositPattern1 = RegExp(
      r"(?:واريز|پرداخت)\s+(?:به|حقوق|لحظه‌اي|گروهي).*?مبلغ[:：]\s*([\d,]+)\s*ريال",
      caseSensitive: false);
  final RegExp _depositPattern2 = RegExp(
      r"مبلغ[:：]\s*([\d,]+)\s*ريال.*?واريز",
      caseSensitive: false);

  // الگو استخراج تاریخ شمسی - مثال: 1404/5/17-18:55 یا 04/03/06_22:33
  final RegExp _datePattern1 = RegExp(
    r"زمان[:：]?\s*([\d]{4}/[\d]{1,2}/[\d]{1,2})[-_]([\d]{1,2}:[\d]{2})",
    caseSensitive: false,
  );

  final RegExp _datePattern2 = RegExp(
    r"(\d{2}/\d{2}/\d{2})[_ ](\d{1,2}:\d{2})",
    caseSensitive: false,
  );

  // تبدیل تاریخ شمسی به DateTime (می‌تونید با پکیج شمسی یا خودتان بنویسید)
  DateTime? _parseShamsiDate(String yearMonthDay, String hourMin) {
    try {
      // اگر سال چهار رقمی بود
      if (yearMonthDay.length >= 8) {
        final parts = yearMonthDay.split('/');
        int y = int.parse(parts[0]);
        int m = int.parse(parts[1]);
        int d = int.parse(parts[2]);
        final timeParts = hourMin.split(':');
        int hh = int.parse(timeParts[0]);
        int mm = int.parse(timeParts[1]);

        // تبدیل شمسی به میلادی، به صورت نمونه (نیاز به پکیج یا تبدیل دقیق)
        // اگر پکیج شمسی دارید، اینجا تبدیل دقیق انجام دهید.
        // اینجا فقط فرض شده تاریخ شمسی هست و بدون تبدیل به DateTime معمولی.
        // برای نمونه تبدیل مستقیم:
        return DateTime(y, m, d, hh, mm);
      } else if (yearMonthDay.length == 8) {
        // حالت 2 رقمی سال: 04/03/06
        final parts = yearMonthDay.split('/');
        int y = 1300 + int.parse(parts[0]); // فرض می‌گیریم ۱۳۰۰+ سال
        int m = int.parse(parts[1]);
        int d = int.parse(parts[2]);
        final timeParts = hourMin.split(':');
        int hh = int.parse(timeParts[0]);
        int mm = int.parse(timeParts[1]);
        return DateTime(y, m, d, hh, mm);
      }
    } catch (_) {}
    return null;
  }

  @override
  Map<String, dynamic>? process(String sms) {
    // حذف کاراکترهای مخفی و سفید اضافه
    sms = sms.replaceAll("\u202C", "").replaceAll("\u202A", "").trim();

    // مقدار پیش‌فرض برای تاریخ (زمان فعلی)
    DateTime date = DateTime.now();

    // تلاش برای استخراج تاریخ شمسی از پیامک
    var dateMatch = _datePattern1.firstMatch(sms) ?? _datePattern2.firstMatch(sms);
    if (dateMatch != null) {
      final datePart = dateMatch.group(1)!;
      final timePart = dateMatch.group(2)!;
      final parsedDate = _parseShamsiDate(datePart, timePart);
      if (parsedDate != null) {
        date = parsedDate;
      }
    }

    // بررسی واریز
    if (_depositPattern1.hasMatch(sms) || _depositPattern2.hasMatch(sms)) {
      final match =
          _depositPattern1.firstMatch(sms) ?? _depositPattern2.firstMatch(sms);
      if (match != null) {
        final amountStr = match.group(1)!.replaceAll(",", "").trim();
        final amount = int.tryParse(amountStr) ?? 0;
        return {
          'type': 'income',
          'amount': amount,
          'description': sms,
          'date': date.toIso8601String(),
        };
      }
    }

    // بررسی برداشت
    if (_withdrawPattern1.hasMatch(sms) || _withdrawPattern2.hasMatch(sms)) {
      final match =
          _withdrawPattern1.firstMatch(sms) ?? _withdrawPattern2.firstMatch(sms);
      if (match != null) {
        final amountStr = match.group(1)!.replaceAll(",", "").trim();
        final amount = int.tryParse(amountStr) ?? 0;
        return {
          'type': 'expense',
          'amount': amount,
          'description': sms,
          'date': date.toIso8601String(),
        };
      }
    }

    // اگر الگوها منطبق نشدند
    return null;
  }
}