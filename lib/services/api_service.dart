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

  // ======== Headers ========

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

  // ======== AUTH ========

  Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login/');
    final body = jsonEncode({'username': username, 'password': password});

    try {
      final response = await http.post(url, headers: _jsonHeaders(), body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access'];
        if (token != null) {
          await JwtStorage.saveToken(token);
          return data;
        }
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
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
      final response = await http.post(url, headers: _jsonHeaders(), body: body);

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
      print('Register error: $e');
      return null;
    }
  }

  // ======== EXPENSES ========

  Future<List<Expense>?> getExpenses() async {
    final headers = await _getAuthHeaders();
    if (headers == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/expenses/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List jsonList = jsonDecode(response.body);
        return jsonList.map((e) => Expense.fromJson(e)).toList();
      }

      return null;
    } catch (e) {
      print('getExpenses error: $e');
      return null;
    }
  }

  Future<bool> addExpense(Expense expense) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/v1/expenses/'),
      headers: headers,
      body: jsonEncode(expense.toJson()),
    );

    return response.statusCode == 201;
  }

  Future<bool> updateExpense(Expense expense) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/v1/expenses/${expense.id}/'),
      headers: headers,
      body: jsonEncode(expense.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> deleteExpense(int id) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/v1/expenses/$id/'),
      headers: headers,
    );

    return response.statusCode == 204;
  }

  // ======== INCOMES ========

  Future<List<Income>?> getIncomes() async {
    final headers = await _getAuthHeaders();
    if (headers == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/incomes/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List jsonList = jsonDecode(response.body);
        return jsonList.map((e) => Income.fromJson(e)).toList();
      }

      return null;
    } catch (e) {
      print('getIncomes error: $e');
      return null;
    }
  }

  Future<bool> addIncome(Income income) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/v1/incomes/'),
      headers: headers,
      body: jsonEncode(income.toJson()),
    );

    return response.statusCode == 201;
  }

  Future<bool> updateIncome(Income income) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/v1/incomes/${income.id}/'),
      headers: headers,
      body: jsonEncode(income.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> deleteIncome(int id) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/v1/incomes/$id/'),
      headers: headers,
    );

    return response.statusCode == 204;
  }

  // ======== CATEGORIES ========

  Future<List<Category>?> getCategories() async {
    final headers = await _getAuthHeaders();
    if (headers == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/categories/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List jsonList = jsonDecode(response.body);
        return jsonList.map((e) => Category.fromJson(e)).toList();
      }

      return null;
    } catch (e) {
      print('getCategories error: $e');
      return null;
    }
  }

  Future<bool> addCategory(Category category) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/v1/categories/'),
      headers: headers,
      body: jsonEncode(category.toJson()),
    );

    return response.statusCode == 201;
  }

  Future<bool> updateCategory(int id, Map<String, dynamic> data) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/v1/categories/$id/'),
      headers: headers,
      body: jsonEncode(data),
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> deleteCategory(int id) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/v1/categories/$id/'),
      headers: headers,
    );

    return response.statusCode == 204;
  }

  // ======== CREDITS ========

  Future<List<Credit>?> getCredits() async {
    final headers = await _getAuthHeaders();
    if (headers == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/credits/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List jsonList = jsonDecode(response.body);
        return jsonList.map((e) => Credit.fromJson(e)).toList();
      }

      return null;
    } catch (e) {
      print('getCredits error: $e');
      return null;
    }
  }

  Future<bool> addCredit(Credit credit) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/v1/credits/'),
      headers: headers,
      body: jsonEncode(credit.toJson()),
    );

    return response.statusCode == 201;
  }

  Future<bool> updateCredit(Credit credit) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/v1/credits/${credit.id}/'),
      headers: headers,
      body: jsonEncode(credit.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> deleteCredit(int id) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/v1/credits/$id/'),
      headers: headers,
    );

    return response.statusCode == 204;
  }

  // ======== DEBTS ========

  Future<List<Debt>?> getDebts() async {
    final headers = await _getAuthHeaders();
    if (headers == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/debts/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List jsonList = jsonDecode(response.body);
        return jsonList.map((e) => Debt.fromJson(e)).toList();
      }

      return null;
    } catch (e) {
      print('getDebts error: $e');
      return null;
    }
  }

  Future<bool> addDebt(Debt debt) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/v1/debts/'),
      headers: headers,
      body: jsonEncode(debt.toJson()),
    );

    return response.statusCode == 201;
  }

  Future<bool> updateDebt(Debt debt) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/v1/debts/${debt.id}/'),
      headers: headers,
      body: jsonEncode(debt.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> deleteDebt(int id) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/v1/debts/$id/'),
      headers: headers,
    );

    return response.statusCode == 204;
  }
}
