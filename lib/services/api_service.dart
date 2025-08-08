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
    if (token == null) {
      print('❌ No token found');
      return null;
    }
    return {
      ..._baseHeaders(),
      'Authorization': 'Bearer $token',
    };
  }

  dynamic _parse(http.Response res) {
    try {
      return json.decode(utf8.decode(res.bodyBytes));
    } catch (e) {
      print('❌ Failed to parse response: $e');
      return null;
    }
  }

  // -------------------------
  // Auth
  // -------------------------
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final uri = Uri.parse('$_baseUrl/auth/login/');
    final body = jsonEncode({'username': username, 'password': password});
    print('➡️ Login request: $uri with body: $body');
    try {
      final res = await http.post(uri, headers: _baseHeaders(), body: body);
      print('⬅️ Login response [${res.statusCode}]: ${res.body}');
      if (res.statusCode == 200) {
        final data = _parse(res);
        final token = data['access'];
        if (token != null) {
          await JwtStorage.saveToken(token);
          return data;
        }
      }
    } catch (e) {
      print('❌ Login error: $e');
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
    print('➡️ Register request: $uri with body: $body');
    try {
      final res = await http.post(uri, headers: _baseHeaders(), body: body);
      print('⬅️ Register response [${res.statusCode}]: ${res.body}');
      if (res.statusCode == 201) {
        final data = _parse(res);
        final token = data['access'];
        if (token != null) {
          await JwtStorage.saveToken(token);
          return data;
        }
      }
    } catch (e) {
      print('❌ Register error: $e');
    }
    return null;
  }

  // -------------------------
  // Generic Helpers
  // -------------------------
  Future<List<T>?> _getList<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final headers = await _authHeaders();
    if (headers == null) return null;

    final uri = Uri.parse('$_baseUrl/$endpoint');
    print('➡️ GET request: $uri');

    try {
      final res = await http.get(uri, headers: headers);
      print('⬅️ GET response [${res.statusCode}]: ${res.body}');

      if (res.statusCode == 200) {
        final data = _parse(res);
        final list = data is List ? data : data['results'] ?? [];
        return list.map<T>((e) => fromJson(e)).toList();
      }
    } catch (e) {
      print('❌ GET <$T> error: $e');
    }
    return null;
  }

  Future<bool> _post(String endpoint, Map<String, dynamic> data) async {
    final headers = await _authHeaders();
    if (headers == null) return false;

    final uri = Uri.parse('$_baseUrl/$endpoint');
    print('➡️ POST request: $uri with body: $data');

    try {
      final res = await http.post(uri, headers: headers, body: jsonEncode(data));
      print('⬅️ POST response [${res.statusCode}]: ${res.body}');
      return res.statusCode == 201;
    } catch (e) {
      print('❌ POST error: $e');
      return false;
    }
  }

  Future<bool> _put(String endpoint, int id, Map<String, dynamic> data) async {
    final headers = await _authHeaders();
    if (headers == null || id <= 0) return false;

    final uri = Uri.parse('$_baseUrl/$endpoint/$id/');
    print('➡️ PUT request: $uri with body: $data');

    try {
      final res = await http.put(uri, headers: headers, body: jsonEncode(data));
      print('⬅️ PUT response [${res.statusCode}]: ${res.body}');
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      print('❌ PUT error: $e');
      return false;
    }
  }

  Future<bool> _delete(String endpoint, int id) async {
    final headers = await _authHeaders();
    if (headers == null || id <= 0) return false;

    final uri = Uri.parse('$_baseUrl/$endpoint/$id/');
    print('➡️ DELETE request: $uri');

    try {
      final res = await http.delete(uri, headers: headers);
      print('⬅️ DELETE response [${res.statusCode}]');
      return res.statusCode == 204;
    } catch (e) {
      print('❌ DELETE error: $e');
      return false;
    }
  }

  // ------------------------- CRUD Methods -------------------------
  Future<List<Expense>?> getExpenses() => _getList('v1/expenses/', Expense.fromJson);
  Future<bool> addExpense(Expense e) => _post('v1/expenses/', e.toJson());
  Future<bool> updateExpense(Expense e) => _put('v1/expenses', e.id ?? 0, e.toJson());
  Future<bool> deleteExpense(int id) => _delete('v1/expenses', id);

  Future<List<Income>?> getIncomes() => _getList('v1/incomes/', Income.fromJson);
  Future<bool> addIncome(Income i) => _post('v1/incomes/', i.toJson());
  Future<bool> updateIncome(Income i) => _put('v1/incomes', i.id ?? 0, i.toJson());
  Future<bool> deleteIncome(int id) => _delete('v1/incomes', id);

  Future<List<Category>?> getCategories() => _getList('v1/categories/', Category.fromJson);
  Future<bool> addCategory(Category c) => _post('v1/categories/', c.toJson());
  Future<bool> updateCategory(int id, Map<String, dynamic> data) => _put('v1/categories', id, data);
  Future<bool> deleteCategory(int id) => _delete('v1/categories', id);

  Future<List<Credit>?> getCredits() => _getList('v1/credits/', Credit.fromJson);
  Future<bool> addCredit(Credit c) => _post('v1/credits/', c.toJson());
  Future<bool> updateCredit(Credit c) => _put('v1/credits', c.id ?? 0, c.toJson());
  Future<bool> deleteCredit(int id) => _delete('v1/credits', id);

  Future<List<Debt>?> getDebts() => _getList('v1/debts/', Debt.fromJson);
  Future<bool> addDebt(Debt d) => _post('v1/debts/', d.toJson());
  Future<bool> updateDebt(Debt d) => _put('v1/debts', d.id ?? 0, d.toJson());
  Future<bool> deleteDebt(int id) => _delete('v1/debts', id);

  Future<List<Person>?> getPersons() => 
    _getList('v1/persons/', Person.fromJson);

  Future<bool> addPerson(Person person) => 
      _post('v1/persons/', person.toJson());

  Future<bool> updatePerson(Person person) => 
      _put('v1/persons', person.id ?? 0, person.toJson());

  Future<bool> deletePerson(int id) => 
      _delete('v1/persons', id);
}
