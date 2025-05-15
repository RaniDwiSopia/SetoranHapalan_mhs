import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final String tokenUrl = 'https://id.tif.uin-suska.ac.id/realms/dev/protocol/openid-connect/token';
  final String clientId = 'setoran-mobile-dev';
  final String clientSecret = 'aqJp3xnXKudgC7RMOshEQP7ZoVKWzoSl';

  // Fungsi login
  Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'password',
        'client_id': clientId,
        'client_secret': clientSecret,
        'username': username,
        'password': password,
        'scope': 'openid email roles profile',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access_token']);
      await prefs.setString('refresh_token', data['refresh_token']);
      await prefs.setString('id_token', data['id_token']);

      // Simpan waktu kadaluarsa access_token
      final decoded = JwtDecoder.decode(data['access_token']);
      await prefs.setInt('access_token_exp', decoded['exp']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception('Login gagal: ${error['error_description'] ?? error['error'] ?? response.body}');
    }
  }

  // Fungsi logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('id_token');
    await prefs.remove('access_token_exp');
  }

  // Fungsi refresh token
  Future<String?> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'refresh_token',
        'client_id': clientId,
        'client_secret': clientSecret,
        'refresh_token': refreshToken,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('access_token', data['access_token']);
      await prefs.setString('refresh_token', data['refresh_token'] ?? refreshToken);
      await prefs.setString('id_token', data['id_token'] ?? '');

      final decoded = JwtDecoder.decode(data['access_token']);
      await prefs.setInt('access_token_exp', decoded['exp']);

      return data['access_token'];
    } else {
      throw Exception('Gagal memperbarui token');
    }
  }

  // Fungsi untuk mendapatkan token yang valid dan merefresh jika kurang dari 2 menit lagi expired
  Future<String?> getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    int? exp = prefs.getInt('access_token_exp');

    if (token == null || exp == null) {
      throw Exception("Tidak ada token yang tersimpan");
    }

    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeLeft = exp - currentTimestamp;

    if (timeLeft < 120) {
      // Token akan expire dalam kurang dari 2 menit, refresh dulu
      final storedRefreshToken = prefs.getString('refresh_token');
      if (storedRefreshToken != null) {
        try {
          token = await refreshToken(storedRefreshToken);
        } catch (e) {
          await logout();
          throw Exception("Sesi habis, silakan login kembali.");
        }
      } else {
        throw Exception("Tidak ada refresh token. Login ulang.");
      }
    }

    return token;
  }

  // (Opsional) Fungsi tambahan untuk memeriksa token kadaluarsa (manual)
  bool isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (_) {
      return true;
    }
  }
}
