import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class UserService {
  static const String _baseUrl = host;

  // Login user
  static Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Backend returns user data directly, not nested in 'user' field
      final user = User(
        id: data['id'] ?? '',
        name: '${data['firstName']} ${data['lastName']}',
        email: email, // Use the email from login
        role: data['type'] ?? 'viewer',
        token: data['token'],
      );
      
      // Save to SharedPreferences
      await _saveUser(user);

      return user;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // Save user to SharedPreferences
  static Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    if (user.token != null) {
      await prefs.setString('token', user.token!);
    }
  }

  // Get saved user
  static Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');

    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Get saved token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('token');
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final user = await getSavedUser();
    return user != null;
  }
}

