import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daric/services/bank_processors/sepeh_processor.dart';
import 'package:daric/services/bank_processors/base_processor.dart';
import 'package:daric/services/api_service.dart';

class SmsService {
  final List<BankSmsProcessor> _processors = [
    SepehProcessor(),
    // بانک‌های دیگر اینجا اضافه می‌شوند
  ];

  final _prefsKey = "last_sms_id";

  Future<int> _getLastSmsId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefsKey) ?? 0;
  }

  Future<void> _setLastSmsId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, id);
  }

  Future<void> scanAndSyncTransactions() async {
    final lastId = await _getLastSmsId();
    final SmsQuery query = SmsQuery();
    final messages = await query.querySms(
      kinds: [SmsQueryKind.inbox],
      count: 50, // آخرین ۵۰ پیامک برای اطمینان
    );

    int newestId = lastId;
    final ApiService api = ApiService();

    for (final sms in messages) {
      final id = sms.id ?? 0;
      if (id <= lastId) continue; // پیامک قدیمی، نادیده بگیر

      final text = sms.body ?? '';
      for (final processor in _processors) {
        if (processor.matches(text)) {
          final result = processor.parse(text);
          if (result != null) {
            bool success = false;
            if (result['type'] == 'income') {
              success = await api.addIncomeFromSms(result);
            } else if (result['type'] == 'expense') {
              success = await api.addExpenseFromSms(result);
            }
            if (success) {
              if (id > newestId) newestId = id;
            }
          }
          break;
        }
      }
    }

    if (newestId > lastId) {
      await _setLastSmsId(newestId);
    }
  }
}