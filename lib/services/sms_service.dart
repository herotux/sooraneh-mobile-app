import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daric/services/bank_processors/base_bank_processor.dart';
import 'package:daric/services/bank_processors/sepeh_processor.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/models/income.dart';
import 'package:daric/models/expense.dart';

class SmsService {
  final List<BaseBankProcessor> _processors = [
    SepehProcessor(),
    // سایر بانک‌ها اینجا اضافه شوند
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
      count: 50,
    );

    int newestId = lastId;
    final ApiService api = ApiService();

    for (final sms in messages) {
      final id = sms.id ?? 0;
      if (id <= lastId) continue;

      final sender = sms.address ?? '';
      final text = sms.body ?? '';

      bool processed = false;

      for (final processor in _processors) {
        if (processor.matchesSender(sender)) {
          final result = processor.process(text);
          if (result != null) {
            final type = result['type'] as String;
            final amount = result['amount'] as int;
            final description = result['description'] as String;
            final dateIso = result['date'] as String? ?? DateTime.now().toIso8601String();

            bool success = false;

            if (type == 'income') {
              final income = Income(
                amount: amount,
                text: description,
                date: dateIso,
              );
              success = await api.addIncome(income);
            } else if (type == 'expense') {
              final expense = Expense(
                amount: amount,
                text: description,
                date: dateIso,
              );
              success = await api.addExpense(expense);
            }

            if (success && id > newestId) {
              newestId = id;
            }

            processed = true;
            break;
          }
        }
      }

      if (!processed) {
        print('Ignored SMS from $sender: $text');
      }
    }

    if (newestId > lastId) {
      await _setLastSmsId(newestId);
    }
  }
}