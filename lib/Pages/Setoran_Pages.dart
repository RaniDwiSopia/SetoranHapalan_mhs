import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Services/Auth_Service.dart';
import 'Login_Page.dart';
import 'ProfilPage.dart';
import 'Log_Page.dart'; // Pastikan halaman ini ada

class SetoranSayaPage extends StatefulWidget {
  @override
  _SetoranSayaPageState createState() => _SetoranSayaPageState();
}

class _SetoranSayaPageState extends State<SetoranSayaPage> {
  late Future<Map<String, dynamic>> _futureData;
  int _selectedIndex = 0;

  Map<String, dynamic>? profilData;
  List<dynamic>? logList;

  @override
  void initState() {
    super.initState();
    _futureData = fetchData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<Map<String, dynamic>> fetchData() async {
    try {
      final token = await AuthService().getValidToken();
      final response = await http.get(
        Uri.parse('https://api.tif.uin-suska.ac.id/setoran-dev/v1/mahasiswa/setoran-saya'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal mengambil data setoran: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("Gagal memuat data: $e");
    }
  }

  Future<void> _handleLogout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  Widget _buildSetoranPage(Map<String, dynamic> data) {
    final profil = data['data']['info'];
    final infoDasar = data['data']['setoran']['info_dasar'];
    final detailSetoran = List.from(data['data']['setoran']['detail'] ?? []);
    final ringkasanList = List.from(data['data']['setoran']['ringkasan'] ?? []);
    final log = List.from(data['data']['setoran']['log'] ?? []);

    final totalWajib = infoDasar['total_wajib_setor'] ?? 0;
    final totalSudah = infoDasar['total_sudah_setor'] ?? 0;
    final persentase = totalWajib > 0 ? totalSudah / totalWajib : 0.0;

    // Simpan data log dan profil
    profilData = profil;
    logList = log;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress Setoran Juz 30',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 8),
          Card(
            color: Color(0xFFECEFCA),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Text("Sudah disetor: $totalSudah dari $totalWajib surah", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: persentase,
                    backgroundColor: Colors.grey[300],
                    color: Colors.teal,
                    minHeight: 10,
                  ),
                  SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text("${(persentase * 100).toStringAsFixed(1)}%", style: TextStyle(fontSize: 14)),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          Text('Progress Setoran per Tahapan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ringkasanList.map<Widget>((item) {
                final label = item['label'] ?? '-';
                final sudah = item['total_sudah_setor'] ?? 0;
                final wajib = item['total_wajib_setor'] ?? 0;
                final persen = (item['persentase_progres_setor'] ?? 0).toDouble();

                return Container(
                  width: 200,
                  margin: EdgeInsets.only(right: 12),
                  child: Card(
                    color: Color(0xFFECEFCA),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text("Sudah: $sudah dari $wajib"),
                          SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: wajib > 0 ? persen / 100 : 0,
                            backgroundColor: Colors.grey[300],
                            color: Colors.teal,
                            minHeight: 10,
                          ),
                          SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text("${persen.toStringAsFixed(1)}%"),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16),
          Text('Daftar Setoran Surah Juz 30',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: detailSetoran.length,
            itemBuilder: (context, index) {
              final surah = detailSetoran[index];
              final namaSurah = surah['nama'] ?? 'Surah Tidak Diketahui';
              final sudahSetor = surah['sudah_setor'] == true;

              return Card(
                color: Color(0xFFECEFCA),
                margin: EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(namaSurah, style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    'Status: ${sudahSetor ? "Sudah disetor" : "Belum disetor"}',
                    style: TextStyle(
                      color: sudahSetor ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Icon(
                    sudahSetor ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: sudahSetor ? Colors.green : Colors.grey,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _getBody(Map<String, dynamic> data) {
    if (_selectedIndex == 0) {
      return _buildSetoranPage(data);
    } else if (_selectedIndex == 1) {
      return logList != null
          ? LogPage(logList: logList!)
          : Center(child: Text("Log belum tersedia"));
    } else {
      return profilData != null
          ? ProfilePage(profil: profilData!)
          : Center(child: Text("Profil belum tersedia"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF547792),
      appBar: AppBar(
        backgroundColor: Color(0xFF547792),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!['data'] == null) {
            return Center(child: Text("Data tidak ditemukan."));
          } else {
            return _getBody(snapshot.data!);
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF547792),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black54,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Log'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
