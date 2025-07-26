import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:daric/utils/jwt_storage.dart';
import 'package:daric/models/category.dart';
import 'package:daric/models/credit.dart';
import 'package:daric/models/debt.dart';

class ApiService {
  static const String baseUrl = 'https://freetux.pythonanywhere.com/api';

  /// ورود کاربر
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('Login Status: ${response.statusCode}');
      print('Login Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access']; // توکن دسترسی
        if (token != null) {
          await JwtStorage.saveToken(token);
          return data;
        }
      }
      return null;
    } catch (e) {
      print('Login Error: $e');
      return null;
    }
  }

  /// ثبت‌نام کاربر جدید
  Future<Map<String, dynamic>?> register(
    String username,
    String email,
    String firstName,
    String lastName,
    String password,
    bool isAdmin,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'password': password,
          'is_admin': isAdmin,
        }),
      );

      print('Register Status: ${response.statusCode}');
      print('Register Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['access'];
        if (token != null) {
          await JwtStorage.saveToken(token);
          return data;
        }
      }
      return null;
    } catch (e) {
      print('Register Error: $e');
      return null;
    }
  }

  Future<List<dynamic>?> getIncomes() async {
    final token = await JwtStorage.getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/v1/incomes/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return jsonDecode(decodedBody);
    }
    return null;
  }

  Future<List<dynamic>?> getExpenses() async {
    final token = await JwtStorage.getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/v1/expenses/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return jsonDecode(decodedBody);
    }
    return null;
  }

  Future<List<Category>?> getCategories() async {
  final token = await JwtStorage.getToken();
  if (token == null) return null;

  final response = await http.get(
    Uri.parse('$baseUrl/v1/categories/'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Category>.from(data.map((item) => Category.fromJson(item)));
  }

  return null;
}

Future<bool> addCategory(Category category) async {
  final token = await JwtStorage.getToken();
  if (token == null) return false;

  final response = await http.post(
    Uri.parse('$baseUrl/v1/categories/'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(category.toJson()),
  );

  return response.statusCode == 201;
}


Future<bool> deleteCategory(int id) async {
    final token = await JwtStorage.getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/v1/categories/$id/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 204;
  }


  Future<bool> updateCategory(int id, Map<String, dynamic> data) async {
    final token = await JwtStorage.getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/v1/categories/$id/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }


  // دریافت لیست طلب ها
  Future<List<Credit>> getCredits() async {
    final response = await http.get(Uri.parse('$baseUrl/credits/'));
    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);
      return jsonData.map((item) => Credit.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load credits');
    }
  }

  // افزودن طلب جدید
  Future<bool> addCredit(Credit credit) async {
    final response = await http.post(
      Uri.parse('$baseUrl/credits/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(credit.toJson()),
    );
    return response.statusCode == 201;
  }

  // حذف طلب
  Future<bool> deleteCredit(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/credits/$id/'));
    return response.statusCode == 204; // 204 یعنی حذف موفق
  }

  // ویرایش طلب (PUT)
  Future<bool> updateCredit(Credit credit) async {
    final response = await http.put(
      Uri.parse('$baseUrl/credits/${credit.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(credit.toJson()),
    );
    return response.statusCode == 200;
  }
  // دریافت لیست بدهی‌ها
  Future<List<Debt>> getDebts() async {
    final response = await http.get(Uri.parse('$baseUrl/debts/'));
    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);
      return jsonData.map((item) => Debt.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load debts');
    }
  }

  // افزودن بدهی جدید
  Future<bool> addDebt(Debt debt) async {
    final response = await http.post(
      Uri.parse('$baseUrl/debts/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(debt.toJson()),
    );
    return response.statusCode == 201;
  }

  // حذف بدهی
  Future<bool> deleteDebt(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/debts/$id/'));
    return response.statusCode == 204;
  }

  // ویرایش بدهی (PUT)
  Future<bool> updateDebt(Debt debt) async {
    final response = await http.put(
      Uri.parse('$baseUrl/debts/${debt.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(debt.toJson()),
    );
    return response.statusCode == 200;
  }

}



