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
      } else {
        print('Login failed: ${response.statusCode} - ${response.body}');
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
      } else {
        print('Register failed: ${response.statusCode} - ${response.body}');
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
      final response = await http.get(Uri.parse('$baseUrl/v1/expenses/'), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List jsonList = data is List ? data : data['results'] ?? [];
        return jsonList.map((e) => Expense.fromJson(e)).toList();
      } else {
        print('getExpenses failed: ${response.statusCode} - ${response.body}');
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

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/expenses/'),
        headers: headers,
        body: jsonEncode(expense.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('addExpense failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('addExpense error: $e');
      return false;
    }
  }

  Future<bool> updateExpense(Expense expense) async {
    if ((expense.id ?? 0) <= 0) {
      print('updateExpense failed: invalid expense id');
      return false;
    }
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/v1/expenses/${expense.id}/'),
        headers: headers,
        body: jsonEncode(expense.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('updateExpense failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('updateExpense error: $e');
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    if (id <= 0) {
      print('deleteExpense failed: invalid id');
      return false;
    }
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/v1/expenses/$id/'),
        headers: headers,
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print('deleteExpense failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('deleteExpense error: $e');
      return false;
    }
  }

  // ======== INCOMES ========
  Future<List<Income>?> getIncomes() async {
    final headers = await _getAuthHeaders();
    if (headers == null) return null;

    try {
      final response = await http.get(Uri.parse('$baseUrl/v1/incomes/'), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List jsonList = data is List ? data : data['results'] ?? [];
        return jsonList.map((e) => Income.fromJson(e)).toList();
      } else {
        print('getIncomes failed: ${response.statusCode} - ${response.body}');
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

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/incomes/'),
        headers: headers,
        body: jsonEncode(income.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('addIncome failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('addIncome error: $e');
      return false;
    }
  }

  Future<bool> updateIncome(Income income) async {
    if (income.id != null && income.id! <= 0) {
      print('updateIncome failed: invalid income id');
      return false;
    }
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/v1/incomes/${income.id}/'),
        headers: headers,
        body: jsonEncode(income.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('updateIncome failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('updateIncome error: $e');
      return false;
    }
  }

  Future<bool> deleteIncome(int id) async {
    if (id <= 0) {
      print('deleteIncome failed: invalid id');
      return false;
    }
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/v1/incomes/$id/'),
        headers: headers,
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print('deleteIncome failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('deleteIncome error: $e');
      return false;
    }
  }

  // ======== CATEGORIES ========
  Future<List<Category>?> getCategories() async {
    final headers = await _getAuthHeaders();
    if (headers == null) return null;

    try {
      final response = await http.get(Uri.parse('$baseUrl/v1/categories/'), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List jsonList = data is List ? data : data['results'] ?? [];
        return jsonList.map((e) => Category.fromJson(e)).toList();
      } else {
        print('getCategories failed: ${response.statusCode} - ${response.body}');
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

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/categories/'),
        headers: headers,
        body: jsonEncode(category.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('addCategory failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('addCategory error: $e');
      return false;
    }
  }

  Future<bool> updateCategory(int id, Map<String, dynamic> data) async {
    if (id <= 0) {
      print('updateCategory failed: invalid id');
      return false;
    }
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/v1/categories/$id/'),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('updateCategory failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('updateCategory error: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    if (id <= 0) {
      print('deleteCategory failed: invalid id');
      return false;
    }
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/v1/categories/$id/'),
        headers: headers,
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print('deleteCategory failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('deleteCategory error: $e');
      return false;
    }
  }

  // ======== CREDITS ========
  Future<List<Credit>?> getCredits() async {
    final headers = await _getAuthHeaders();
    if (headers == null) return null;

    try {
      final response = await http.get(Uri.parse('$baseUrl/v1/credits/'), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List jsonList = data is List ? data : data['results'] ?? [];
        return jsonList.map((e) => Credit.fromJson(e)).toList();
      } else {
        print('getCredits failed: ${response.statusCode} - ${response.body}');
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

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/credits/'),
        headers: headers,
        body: jsonEncode(credit.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('addCredit failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('addCredit error: $e');
      return false;
    }
  }

  Future<bool> updateCredit(Credit credit) async {
    if (credit.id <= 0) {
      print('updateCredit failed: invalid credit id');
      return false;
    }
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/v1/credits/${credit.id}/'),
        headers: headers,
        body: jsonEncode(credit.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('updateCredit failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('updateCredit error: $e');
      return false;
    }
  }

  Future<bool> deleteCredit(int id) async {
    if (id <= 0) {
      print('deleteCredit failed: invalid id');
      return false;
    }
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/v1/credits/$id/'),
        headers: headers,
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print('deleteCredit failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('deleteCredit error: $e');
      return false;
    }
  }

  // ======== DEBTS ========
  Future<List<Debt>?> getDebts() async {
    final headers = await _getAuthHeaders();
    if (headers == null) return null;

    try {
      final response = await http.get(Uri.parse('$baseUrl/v1/debts/'), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List jsonList = data is List ? data : data['results'] ?? [];
        return jsonList.map((e) => Debt.fromJson(e)).toList();
      } else {
        print('getDebts failed: ${response.statusCode} - ${response.body}');
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

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/debts/'),
        headers: headers,
        body: jsonEncode(debt.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('addDebt failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('addDebt error: $e');
      return false;
    }
  }

  Future<bool> updateDebt(Debt debt) async {
    if (debt.id <= 0) {
      print('updateDebt failed: invalid debt id');
      return false;
    }
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/v1/debts/${debt.id}/'),
        headers: headers,
        body: jsonEncode(debt.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('updateDebt failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('updateDebt error: $e');
      return false;
    }
  }

  Future<bool> deleteDebt(int id) async {
    if (id <= 0) {
      print('deleteDebt failed: invalid id');
      return false;
    }
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/v1/debts/$id/'),
        headers: headers,
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print('deleteDebt failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('deleteDebt error: $e');
      return false;
    }
  }
}
