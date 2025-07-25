import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sooraneh_mobile/utils/jwt_storage.dart';

class ApiService {

  static const String baseUrl = 'https://Freetux.pythonanywhere.com/api';

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await JwtStorage.saveToken(data['access']);
      return data;
    }
    return null;
  }

  Future<Map<String, dynamic>?> register(String username, String email,
      String firstName, String lastName, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<List<dynamic>?> getIncomes() async {
    final token = await JwtStorage.getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/v1/incomes/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
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
      return jsonDecode(response.body);
    }
    return null;
  }
}
