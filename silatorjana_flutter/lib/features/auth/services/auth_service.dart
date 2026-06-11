import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../../../core/constants/api_config.dart';

class AuthService {

  // Use in-memory token storage — works reliably on all platforms
  // (flutter_secure_storage has issues on Linux desktop and Web)
  static String? _token;
  static User? _cachedUser;

  Future<bool> login(String email, String password) async {
    try {
      debugPrint('AUTH: Login to ${ApiConfig.baseUrl}/login');
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      debugPrint('AUTH: Login status=${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        if (token != null && token.toString().isNotEmpty) {
          _token = token.toString();
          debugPrint('AUTH: Token saved: ${_token!.substring(0, 10)}...');
        } else {
          _token = 'no-token';
          debugPrint('AUTH: No token from server');
        }

        // Cache user from login response
        if (data['user'] != null) {
          _cachedUser = User.fromJson(data['user']);
          debugPrint('AUTH: User cached: ${_cachedUser!.nama}');
        }

        return true;
      }
      debugPrint('AUTH: Login failed ${response.statusCode}: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('AUTH ERROR login: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null && _token != 'no-token') {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/logout'),
          headers: <String, String>{
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
          },
        );
      }
    } catch (e) {
      debugPrint('AUTH ERROR logout: $e');
    }
    _token = null;
    _cachedUser = null;
  }

  Future<String?> getToken() async {
    return _token;
  }

  Future<User?> getMe() async {
    // Return cached user from login if available
    if (_cachedUser != null) {
      debugPrint('AUTH: Returning cached user: ${_cachedUser!.nama}');
      return _cachedUser;
    }

    try {
      if (_token == null || _token == 'no-token') return null;

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/me'),
        headers: <String, String>{
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      debugPrint('AUTH: /me status=${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'] ?? data;
        _cachedUser = User.fromJson(userData);
        return _cachedUser;
      }
    } catch (e) {
      debugPrint('AUTH ERROR getMe: $e');
    }
    return null;
  }
}
