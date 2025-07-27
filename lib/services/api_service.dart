import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:daric/utils/jwt_storage.dart';
import 'package:daric/utils/network_utils.dart';
import 'package:daric/models/category.dart';
import 'package:daric/models/credit.dart';
import 'package:daric/models/debt.dart';

class ApiService {
  static const String baseUrl = 'https://freetux.pythonanywhere.com/api';

  // ==== AUTH ====

  Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login/');
    final body = jsonEncode({'username': username, 'password': password});
    try {
      final response = await http.post(url, headers: _jsonHeaders(), body: body);
      if (response.statusCode == 200) {
        final data = parseJsonResponse(response);
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
        final data = parseJsonResponse(response);
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

  // ==== INCOMES / EXPENSES ====

  Future<List<dynamic>?> getIncomes() async {
    final token = await JwtStorage.getToken();
    if (token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/incomes/'),
        headers: _authHeaders(token),
      );
      if (response.statusCode == 200) {
        return parseJsonResponse(response);
      }
      return null;
    } catch (e) {
      print('getIncomes error: $e');
      return null;
    }
  }

  Future<List<dynamic>?> getExpenses() async {
    final token = await JwtStorage.getToken();
    if (token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/expenses/'),
        headers: _authHeaders(token),
      );
      if (response.statusCode == 200) {
        return parseJsonResponse(response);
      }
      return null;
    } catch (e) {
      print('getExpenses error: $e');
      return null;
    }
  }

  // ==== CATEGORY ====

  Future<List<Category>?> getCategories() async {
    final token = await JwtStorage.getToken();
    if (token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/categories/'),
        headers: _authHeaders(token),
      );
      if (response.statusCode == 200) {
        final List jsonList = parseJsonResponse(response);
        return jsonList.map((e) => Category.fromJson(e)).toList();
      }
      return null;
    } catch (e) {
      print('getCategories error: $e');
      return null;
    }
  }

  Future<bool> addCategory(Category category) async {
    final token = await JwtStorage.getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/v1/categories/'),
      headers: _authHeaders(token),
      body: jsonEncode(category.toJson()),
    );
    return response.statusCode == 201;
  }

  Future<bool> deleteCategory(int id) async {
    final token = await JwtStorage.getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/v1/categories/$id/'),
      headers: _authHeaders(token),
    );
    return response.statusCode == 204;
  }

  Future<bool> updateCategory(int id, Map<String, dynamic> data) async {
    final token = await JwtStorage.getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/v1/categories/$id/'),
      headers: _authHeaders(token),
      body: jsonEncode(data),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  // ==== CREDITS ====

  Future<List<Credit>?> getCredits() async {
    final token = await JwtStorage.getToken();
    if (token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/credits/'),
        headers: _authHeaders(token),
      );
      if (response.statusCode == 200) {
        final List jsonList = parseJsonResponse(response);
        return jsonList.map((e) => Credit.fromJson(e)).toList();
      }
      return null;
    } catch (e) {
      print('getCredits error: $e');
      return null;
    }
  }

  Future<bool> addCredit(Credit credit) async {
    final token = await JwtStorage.getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/v1/credits/'),
      headers: _authHeaders(token),
      body: jsonEncode(credit.toJson()),
    );
    return response.statusCode == 201;
  }

  Future<bool> deleteCredit(int id) async {
    final token = await JwtStorage.getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/v1/credits/$id/'),
      headers: _authHeaders(token),
    );
    return response.statusCode == 204;
  }

  Future<bool> updateCredit(Credit credit) async {
    final token = await JwtStorage.getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/v1/credits/${credit.id}/'),
      headers: _authHeaders(token),
      body: jsonEncode(credit.toJson()),
    );
    return response.statusCode == 200;
  }

  // ==== DEBTS ====

  Future<List<Debt>?> getDebts() async {
    final token = await JwtStorage.getToken();
    if (token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/debts/'),
        headers: _authHeaders(token),
      );
      if (response.statusCode == 200) {
        final List jsonList = parseJsonResponse(response);
        return jsonList.map((e) => Debt.fromJson(e)).toList();
      }
      return null;
    } catch (e) {
      print('getDebts error: $e');
      return null;
    }
  }

  Future<bool> addDebt(Debt debt) async {
    final token = await JwtStorage.getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/v1/debts/'),
      headers: _authHeaders(token),
      body: jsonEncode(debt.toJson()),
    );
    return response.statusCode == 201;
  }

  Future<bool> deleteDebt(int id) async {
    final token = await JwtStorage.getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/v1/debts/$id/'),
      headers: _authHeaders(token),
    );
    return response.statusCode == 204;
  }

  Future<bool> updateDebt(Debt debt) async {
    final token = await JwtStorage.getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$baseUrl/v1/debts/${debt.id}/'),
      headers: _authHeaders(token),
      body: jsonEncode(debt.toJson()),
    );
    return response.statusCode == 200;
  }

  // ==== HEADERS ====

  Map<String, String> _jsonHeaders() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Map<String, String> _authHeaders(String token) => {
        ..._jsonHeaders(),
        'Authorization': 'Bearer $token',
      };
}
