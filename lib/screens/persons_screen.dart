import 'package:flutter/material.dart';
import 'package:daric/models/person.dart';
import 'package:daric/services/api_service.dart';
import 'package:daric/widgets/daric_list_card.dart';
import 'package:daric/widgets/finance_list_view.dart';
import 'edit_person_screen.dart'; // فرض می‌کنیم وجود دارد

class PersonListScreen extends StatelessWidget {
  final ApiService _api = ApiService();

  @override
  Widget build(BuildContext context) {
    return FinanceListView<Person>(
      title: 'طرف‌های حساب',
      fetchItems: () async {
        final persons = await _api.getPersons();
        if (persons == null) {
          // در صورت خطا، لیست خالی برمی‌گردانیم و کاربر با RefreshIndicator می‌تونه دوباره امتحان کنه
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("خطا در بارگذاری اطلاعات")),
          );
          return [];
        }
        return persons;
      },
      onDelete: (id) async {
        final success = await _api.deletePerson(id);
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("حذف ناموفق بود")),
          );
        }
        return success;
      },
      onEdit: (person) async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditPersonScreen(person: person),
          ),
        );
        // FinanceListView بعد از ویرایش، لیست ریفرش می‌شه (با Dismissible یا RefreshIndicator)
      },
      itemBuilder: (person) {
        return DaricListCard(
          title: person.fullName,
          subtitle: person.relation,
          trailingText: '', // نمایش اضافی نداریم
          leadingIcon: Icons.person,
          leadingIconColor: Colors.blue,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditPersonScreen(person: person),
              ),
            );
          },
        );
      },
      addRoute: '/add-person', // بعداً با Navigator یا GoRouter پیاده‌سازی می‌شه
      emptyMessage: 'طرف حسابی وجود ندارد',
    );
  }
}