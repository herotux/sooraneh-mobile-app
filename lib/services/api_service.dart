import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:daric/utils/jwt_storage.dart';
import 'package:daric/models/category.dart';
import 'package:daric/models/credit.dart';
import 'package:daric/models/debt.dart';
import 'package:daric/models/income.dart';
import 'package:daric/models/expense.dart';

class ApiService {
  static const String baseUrl = 'https://freetux.pythonanywhere.com/api';

  // ========= Headers =========
  Map<String, String> _jsonHeaders() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Map<String, String> _authHeaders(String token) => {
        ..._jsonHeaders(),
        'Authorization': 'Bearer $token',
      };

  Future<Map<String, String>?> _getAuthHeaders() async {
    final token = await JwtStorage.getToken();
    if (token == null) return null;
    return _authHeaders(token);
  }

  dynamic _parseResponse(http.Response response) {
    return json.decode(utf8.decode(response.bodyBytes));
  }

  // ========= AUTH =========
  Future<Map<String, dynamic>?> login({required String username, required String password}) async {
    final url = Uri.parse('$baseUrl/auth/login/');
    final body = jsonEncode({'username': username, 'password': password});
    try {
      final res = await http.post(url, headers: _jsonHeaders(), body: body);
      if (res.statusCode == 200) {
        final data = _parseResponse(res);
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
    final url = Uri.parse('$baseUrl/auth/register/');
    final body = jsonEncode({
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'password': password,
      'is_admin': isAdmin,
    });
    try {
      final res = await http.post(url, headers: _jsonHeaders(), body: body);
      if (res.statusCode == 201) {
        final data = _parseResponse(res);
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

  // ========= Generic CRUD methods =========
  Future<List<T>?> _getList<T>(String endpoint, T Function(Map<String, dynamic>) fromJson) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return null;
    try {
      final res = await http.get(Uri.parse('$baseUrl/$endpoint'), headers: headers);
      if (res.statusCode == 200) {
        final data = _parseResponse(res);
        final list = data is List ? data : data['results'] ?? [];
        return list.map<T>((e) => fromJson(e)).toList();
      }
    } catch (e) {
      print('getList<$T> error: $e');
    }
    return null;
  }

  Future<bool> _postData(String endpoint, Map<String, dynamic> data) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return false;
    try {
      final res = await http.post(Uri.parse('$baseUrl/$endpoint'), headers: headers, body: jsonEncode(data));
      return res.statusCode == 201;
    } catch (e) {
      print('postData error: $e');
      return false;
    }
  }

  Future<bool> _putData(String endpoint, int id, Map<String, dynamic> data) async {
    final headers = await _getAuthHeaders();
    if (headers == null || id <= 0) return false;
    try {
      final res = await http.put(Uri.parse('$baseUrl/$endpoint/$id/'), headers: headers, body: jsonEncode(data));
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      print('putData error: $e');
      return false;
    }
  }

  Future<bool> _deleteData(String endpoint, int id) async {
    final headers = await _getAuthHeaders();
    if (headers == null || id <= 0) return false;
    try {
      final res = await http.delete(Uri.parse('$baseUrl/$endpoint/$id/'), headers: headers);
      return res.statusCode == 204;
    } catch (e) {
      print('deleteData error: $e');
      return false;
    }
  }

  // ========= Expenses =========
  Future<List<Expense>?> getExpenses() => _getList('v1/expenses/', Expense.fromJson);
  Future<bool> addExpense(Expense e) => _postData('v1/expenses/', e.toJson());
  Future<bool> updateExpense(Expense e) => _putData('v1/expenses', e.id ?? 0, e.toJson());
  Future<bool> deleteExpense(int id) => _deleteData('v1/expenses', id);

  // ========= Incomes =========
  Future<List<Income>?> getIncomes() => _getList('v1/incomes/', Income.fromJson);
  Future<bool> addIncome(Income i) => _postData('v1/incomes/', i.toJson());
  Future<bool> updateIncome(Income i) => _putData('v1/incomes', i.id ?? 0, i.toJson());
  Future<bool> deleteIncome(int id) => _deleteData('v1/incomes', id);

  // ========= Categories =========
  Future<List<Category>?> getCategories() => _getList('v1/categories/', Category.fromJson);
  Future<bool> addCategory(Category c) => _postData('v1/categories/', c.toJson());
  Future<bool> updateCategory(int id, Map<String, dynamic> data) => _putData('v1/categories', id, data);
  Future<bool> deleteCategory(int id) => _deleteData('v1/categories', id);

  // ========= Credits =========
  Future<List<Credit>?> getCredits() => _getList('v1/credits/', Credit.fromJson);
  Future<bool> addCredit(Credit c) => _postData('v1/credits/', c.toJson());
  Future<bool> updateCredit(Credit c) => _putData('v1/credits', c.id, c.toJson());
  Future<bool> deleteCredit(int id) => _deleteData('v1/credits', id);

  // ========= Debts =========
  Future<List<Debt>?> getDebts() => _getList('v1/debts/', Debt.fromJson);
  Future<bool> addDebt(Debt d) => _postData('v1/debts/', d.toJson());
  Future<bool> updateDebt(Debt d) => _putData('v1/debts', d.id ?? 0, d.toJson());
  Future<bool> deleteDebt(int id) => _deleteData('v1/debts', id);
}
