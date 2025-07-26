import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:daric/utils/jwt_storage.dart';
import 'package:daric/models/category.dart';


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
