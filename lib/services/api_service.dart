import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:daric/utils/jwt_storage.dart';
import 'package:daric/models/category.dart';
import 'package:daric/models/credit.dart';
import 'package:daric/models/debt.dart';
import 'package:daric/models/income.dart';
import 'package:daric/models/expense.dart';
import 'package:daric/models/person.dart';

class ApiService {
  static const String _baseUrl = 'https://freetux.pythonanywhere.com/api';

  // -------------------------
  // Headers
  // -------------------------
  Map<String, String> _baseHeaders() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<Map<String, String>?> _authHeaders() async {
    final token = await JwtStorage.getToken();
    if (token == null) return null;
    return {
      ..._baseHeaders(),
      'Authorization': 'Bearer $token',
    };
  }

  dynamic _parse(http.Response res) =>
      json.decode(utf8.decode(res.bodyBytes));

  // -------------------------
  // Auth
  // -------------------------
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final uri = Uri.parse('$_baseUrl/auth/login/');
    final body = jsonEncode({'username': username, 'password': password});
    try {
      final res = await http.post(uri, headers: _baseHeaders(), body: body);
      if (res.statusCode == 200) {
        final data = _parse(res);
        final token = data['access'];
        if (token != null) {
          await JwtStorage.saveToken(token);
          return data;
        }
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> register({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required bool isAdmin,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/register/');
    final body = jsonEncode({
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
      'is_admin': isAdmin,
    });
    try {
      final res = await http.post(uri, headers: _baseHeaders(), body: body);
      if (res.statusCode == 201) {
        final data = _parse(res);
        final token = data['access'];
        if (token != null) {
          await JwtStorage.saveToken(token);
          return data;
        }
      }
    } catch (e) {
      print('Register error: $e');
    }
    return null;
  }

  // -------------------------
  // Generic Helpers
  // -------------------------
  Future<List<T>?> _getList<T>(
      String endpoint, T Function(Map<String, dynamic>) fromJson) async {
    final headers = await _authHeaders();
    if (headers == null) {
      print('⚠️ No auth token found.');
      return null;
    }
    try {
      final res = await http.get(Uri.parse('$_baseUrl/$endpoint'), headers: headers);
      if (res.statusCode == 200) {
        final data = _parse(res);
        final list = data is List ? data : data['results'] ?? [];
        return list.map<T>((e) => fromJson(e)).toList();
      }
    } catch (e) {
      print('GET <$T> error: $e');
    }
    return null;
  }

  Future<bool> _post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _authHeaders();
    if (headers == null) return false;
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      return res.statusCode == 201;
    } catch (e) {
      print('POST error: $e');
      return false;
    }
  }

  Future<bool> _put(String endpoint, int id, Map<String, dynamic> data) async {
    final headers = await _authHeaders();
    if (headers == null || id <= 0) return false;
    try {
      final res = await http.put(
        Uri.parse('$_baseUrl/$endpoint/$id/'),
        headers: headers,
        body: jsonEncode(data),
      );
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      print('PUT error: $e');
      return false;
    }
  }

  Future<bool> _delete(String endpoint, int id) async {
    final headers = await _authHeaders();
    if (headers == null || id <= 0) return false;
    try {
      final res = await http.delete(
        Uri.parse('$_baseUrl/$endpoint/$id/'),
        headers: headers,
      );
      return res.statusCode == 204;
    } catch (e) {
      print('DELETE error: $e');
      return false;
    }
  }

  // -------------------------
  // Expenses
  // -------------------------
  Future<List<Expense>?> getExpenses() => _getList('v1/expenses/', Expense.fromJson);
  Future<bool> addExpense(Expense e) => _post('v1/expenses/', e.toJson());
  Future<bool> updateExpense(Expense e) => _put('v1/expenses', e.id ?? 0, e.toJson());
  Future<bool> deleteExpense(int id) => _delete('v1/expenses', id);

  // -------------------------
  // Incomes
  // -------------------------
  Future<List<Income>?> getIncomes() => _getList('v1/incomes/', Income.fromJson);
  Future<bool> addIncome(Income i) => _post('v1/incomes/', i.toJson());
  Future<bool> updateIncome(Income i) => _put('v1/incomes', i.id ?? 0, i.toJson());
  Future<bool> deleteIncome(int id) => _delete('v1/incomes', id);

  // -------------------------
  // Categories
  // -------------------------
  Future<List<Category>?> getCategories() => _getList('v1/categories/', Category.fromJson);
  Future<bool> addCategory(Category c) => _post('v1/categories/', c.toJson());
  Future<bool> updateCategory(int id, Map<String, dynamic> data) => _put('v1/categories', id, data);
  Future<bool> deleteCategory(int id) => _delete('v1/categories', id);

  // -------------------------
  // Credits
  // -------------------------
  Future<List<Credit>?> getCredits() => _getList('v1/credits/', Credit.fromJson);
  Future<bool> addCredit(Credit c) => _post('v1/credits/', c.toJson());
  Future<bool> updateCredit(Credit c) => _put('v1/credits', c.id, c.toJson());
  Future<bool> deleteCredit(int id) => _delete('v1/credits', id);

  // -------------------------
  // Debts
  // -------------------------
  Future<List<Debt>?> getDebts() => _getList('v1/debts/', Debt.fromJson);
  Future<bool> addDebt(Debt d) => _post('v1/debts/', d.toJson());
  Future<bool> updateDebt(Debt d) => _put('v1/debts', d.id ?? 0, d.toJson());
  Future<bool> deleteDebt(int id) => _delete('v1/debts', id);

  // -------------------------
  // Persons
  // -------------------------
  Future<List<Person>?> getPersons() => _getList('v1/persons/', Person.fromJson);
  // Future<bool> addPerson(Map<String, dynamic> data) => _post('v1/persons/', data);
  // Future<bool> updatePerson(int id, Map<String, dynamic> data) => _put('v1/persons', id, data);
  // Future<bool> deletePerson(int id) => _delete('v1/persons', id);
}
