import 'dart:convert';

import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api/auth';
    }

    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:3000/api/auth'
        : 'http://localhost:3000/api/auth';
  }

  String get _ordersBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api/orders';
    }

    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:3000/api/orders'
        : 'http://localhost:3000/api/orders';
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Map<String, String> _jsonHeaders({String? token}) {
    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: _jsonHeaders(),
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['token'] as String;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return true;
      }

      return false;
    } catch (_error) {
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: _jsonHeaders(),
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['token'] as String;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return true;
      }

      return false;
    } catch (_error) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: _jsonHeaders(token: token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (_error) {
      return null;
    }
  }

  Future<List<dynamic>> getPastOrders() async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_ordersBaseUrl/history'),
        headers: _jsonHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return (decoded['data'] as List<dynamic>?) ?? [];
      }
      return [];
    } catch (_error) {
      return [];
    }
  }

  Future<bool> submitOrder({
    required List<Map<String, dynamic>> items,
    int? tableNumber,
    String? note,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse(_ordersBaseUrl),
        headers: _jsonHeaders(token: token),
        body: jsonEncode(<String, dynamic>{
          'items': items,
          if (tableNumber != null) 'tableNumber': tableNumber,
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        }),
      );

      return response.statusCode == 201;
    } catch (_error) {
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }
}
