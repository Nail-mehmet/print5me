import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthRepository {
  final String _baseUrl = 'https://myprinter.tr/auth/email';

  Future<User> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        body: jsonEncode({
          'email': email,
          'password': password,
          'action': 'register'
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print('Raw register response: ${response.body}');

      if (response.statusCode == 200) {
        final body = response.body.trim();

        if (body.toLowerCase().contains('user created')) {
          final user = User(email: email); // minimum info ile User oluştur
          await _saveUser(user);
          return user;
        }

        // Eğer bir hata mesajı ise
        throw Exception(body);
      } else {
        throw Exception('Registration failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('Register error: $e');
      throw Exception('Registration error: ${e.toString()}');
    }
  }


  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'action': 'login',
        }),
      );

      final body = response.body.trim().toLowerCase();

      if (response.statusCode == 200 && body.contains('login successful')) {
        final user = User(email: email); // Temel bilgilerle user oluşturuluyor
        await _saveUser(user);
        return user;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Login error: ${e.toString()}');
    }
  }


  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }
}
