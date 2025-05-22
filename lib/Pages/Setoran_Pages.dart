import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Services/Auth_Service.dart';
import 'Login_Page.dart';

class SetoranSayaPage extends StatefulWidget {
  @override
  _SetoranSayaPageState createState() => _SetoranSayaPageState();
}

class _SetoranSayaPageState extends State<SetoranSayaPage> {
  late Future<Map<String, dynamic>> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = fetchData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF547792), // background halaman sesuai permintaan
      appBar: AppBar(
        title: Text("Setoran Saya"),
        backgroundColor: Color(0xFF547792), // warna bar header
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
          Widget content;

          if (snapshot.connectionState == ConnectionState.waiting) {
            content = Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            content = Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!['data'] == null) {
            content = Center(child: Text("Data tidak ditemukan."));
          } else {
            final data = snapshot.data!['data'];
            final profil = data['info'];
            final infoDasar = data['setoran']['info_dasar'];
            final detailSetoran = List.from(data['setoran']['detail'] ?? []);
            final ringkasanList = List.from(data['setoran']['ringkasan'] ?? []);

            final totalWajib = infoDasar['total_wajib_setor'] ?? 0;
            final totalSudah = infoDasar['total_sudah_setor'] ?? 0;
            final persentase = totalWajib > 0 ? totalSudah / totalWajib : 0.0;

            content = SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profil Mahasiswa',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  _buildCard([
                    _buildProfileRow('Nama', profil['nama']),
                    _buildProfileRow('NIM', profil['nim']),
                    _buildProfileRow('Email', profil['email']),
                    _buildProfileRow('Angkatan', profil['angkatan']),
                    _buildProfileRow('Semester', profil['semester']?.toString()),
                  ]),
                  SizedBox(height: 16),
                  Text('Dosen PA',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  _buildCard([
                    _buildProfileRow('NIP', profil['dosen_pa']?['nip']),
                    _buildProfileRow('Nama', profil['dosen_pa']?['nama']),
                    _buildProfileRow('Email', profil['dosen_pa']?['email']),
                  ]),
                  SizedBox(height: 24),
                  Text('Progress Setoran Juz 30',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  _buildCard([
                    Text("Sudah disetor: $totalSudah dari $totalWajib surah",
                        style: TextStyle(fontSize: 16)),
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
                      child: Text("${(persentase * 100).toStringAsFixed(1)}%",
                          style: TextStyle(fontSize: 14)),
                    )
                  ]),

                  // --- Scroll horizontal ringkasan progress ---
                  SizedBox(height: 24),
                  Text('Progress Setoran per Tahapan',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                            color: Color(0xFFECEFCA), // warna card
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(label,
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold)),
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                        color: Color(0xFFECEFCA), // warna card
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(namaSurah,
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            'Status: ${sudahSetor ? "Sudah disetor" : "Belum disetor"}',
                            style: TextStyle(
                              color: sudahSetor ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Icon(
                            sudahSetor
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
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

          return AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: content,
          );
        },
      ),
    );
  }

  Widget _buildProfileRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text('$label:',
                  style: TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
              flex: 5,
              child: Text(value?.toString() ?? '-',
                  style: TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      color: Color(0xFFECEFCA), // warna card sesuai permintaan
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(children: children),
      ),
    );
  }
}
