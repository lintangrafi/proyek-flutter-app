import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user.dart'; // Pastikan model User sudah dibuat

class AuthProvider with ChangeNotifier {
  ApiService? _apiService;
  String? _token;
  String? _baseUrl;
  User? _currentUser;

  String? get token => _token;
  String? get baseUrl => _baseUrl;
  ApiService? get apiService => _apiService;
  User? get currentUser => _currentUser;
  int? get userId => _currentUser?.id;

  bool get isLoggedIn =>
      _token != null && _baseUrl != null && _apiService != null;

  // Metode inisialisasi untuk memeriksa login tersimpan
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // Coba ambil data login yang tersimpan
    final savedToken = prefs.getString('token');
    final savedBaseUrl = prefs.getString('baseUrl');
    final savedUserId = prefs.getInt('userId');
    final savedUserName = prefs.getString('userName');
    final savedUserEmail = prefs.getString('userEmail');

    // Jika data login tersedia, coba memulihkan sesi
    if (savedToken != null && savedBaseUrl != null) {
      _token = savedToken;
      _baseUrl = savedBaseUrl;
      _apiService = ApiService(baseUrl: _baseUrl!, token: _token);

      // Jika ada info user tersimpan, buat objek User
      if (savedUserId != null && savedUserEmail != null) {
        _currentUser = User(
          id: savedUserId,
          name: savedUserName ?? 'User',
          email: savedUserEmail,
        );
      }

      // Opsional: Verifikasi token dengan server
      try {
        await _apiService!.getUserInfo();
        notifyListeners();
      } catch (e) {
        // Token tidak valid, hapus semua data login
        print('Stored token invalid: $e');
        await logout();
      }
    }
  }

  Future<bool> login(String apiUrl, String email, String password) async {
    try {
      final svc = ApiService(baseUrl: apiUrl);
      final result = await svc.login(email, password);

      if (result.containsKey('token')) {
        _token = result['token'];
        _baseUrl = apiUrl;
        _apiService = ApiService(baseUrl: _baseUrl!, token: _token);

        // Simpan info user jika tersedia
        if (result.containsKey('user')) {
          _currentUser = result['user'];
        } else {
          // Jika tidak ada dalam respons login, coba dapatkan dari endpoint khusus
          try {
            _currentUser = await _apiService!.getUserInfo();
          } catch (e) {
            print('Failed to get user info: $e');
            // Buat user default jika tidak bisa mendapatkan info
            _currentUser = User(
              id: 1, // ID default
              name: 'User',
              email: email,
            );
          }
        }

        // Simpan info login untuk persistent session
        await _saveLoginInfo();

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Metode untuk menyimpan info login
  Future<void> _saveLoginInfo() async {
    if (!isLoggedIn) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
    await prefs.setString('baseUrl', _baseUrl!);

    // Simpan info user jika tersedia
    if (_currentUser != null) {
      await prefs.setInt('userId', _currentUser!.id);
      await prefs.setString('userName', _currentUser!.name);
      await prefs.setString('userEmail', _currentUser!.email);
    }
  }

  Future<void> logout() async {
    if (_apiService != null) {
      try {
        await _apiService!.logout();
      } catch (e) {
        print('Logout error: $e');
      }
    }

    // Hapus data dari memory
    _token = null;
    _baseUrl = null;
    _apiService = null;
    _currentUser = null;

    // Hapus data login tersimpan
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('baseUrl');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');

    notifyListeners();
  }

  // Untuk pengembangan/debugging
  void setUserId(int id, {String? name, String? email}) {
    _currentUser = User(
      id: id,
      name: name ?? 'User',
      email: email ?? 'user@example.com',
    );
    notifyListeners();
  }
}
