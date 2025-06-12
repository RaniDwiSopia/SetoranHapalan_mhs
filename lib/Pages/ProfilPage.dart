import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> profil;

  const ProfilePage({Key? key, required this.profil}) : super(key: key);

  String getInitials(String fullName) {
    final words = fullName.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words.first[0].toUpperCase();
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final dosenPa = profil['dosen_pa'] as Map<String, dynamic>?;
    final nama = profil['nama'] ?? '';

    //TAMPILAN
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF213448),
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.white),
        ),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF213448),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar dengan inisial
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Text(
                getInitials(nama),
                style: const TextStyle(
                  color: Color(0xFF547792),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              nama,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Profil Mahasiswa',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildCard([
              _buildProfileRow('NIM', profil['nim']),
              _buildProfileRow('Email', profil['email']),
              _buildProfileRow('Angkatan', profil['angkatan']),
              _buildProfileRow('Semester', profil['semester']?.toString()),
            ]),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Dosen PA',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildCard([
              _buildProfileRow('NIP', dosenPa?['nip']),
              _buildProfileRow('Nama', dosenPa?['nama']),
              _buildProfileRow('Email', dosenPa?['email']),
            ]),
          ],
        ),
      ),
    );
  }

  static Widget _buildProfileRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCard(List<Widget> children) {
    return Card(
      color: const Color(0xFFF5F5F5),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(children: children),
      ),
    );
  }
}
