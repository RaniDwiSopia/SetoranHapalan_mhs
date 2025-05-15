import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SetoranService {
  final String baseUrl = "https://api.tif.uin-suska.ac.id/setoran-dev/v1";

  /// Mengambil data setoran dari API
  /// Mengembalikan Map dengan dua key: 'profil' dan 'setoran'
  Future<Map<String, dynamic>> getSetoran() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception("Token tidak ditemukan, pengguna belum login");
    }

    try {
      // Ambil data setoran dan profil mahasiswa
      final response = await http.get(
        Uri.parse('$baseUrl/mahasiswa/setoran-saya'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        print("Gagal mengambil data setoran: ${response.statusCode}");
        throw Exception(
            "Gagal mengambil data setoran (${response.statusCode})");
      }

      final data = jsonDecode(response.body);
      final profil = data['data']['info'] ?? {}; // Mengakses data mahasiswa
      final setoranList = data['data']['setoran'] ??
          []; // Menangani data setoran

      // Debug logging opsional
      print("Profil Mahasiswa: $profil");
      print("Daftar Setoran: $setoranList");

      return {
        'profil': profil,
        'setoran': setoranList,
      };
    } catch (e) {
      print("Terjadi kesalahan: $e");
      throw Exception("Terjadi kesalahan saat mengambil data: $e");
    }
  }
}