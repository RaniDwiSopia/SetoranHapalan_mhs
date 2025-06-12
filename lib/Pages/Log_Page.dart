import 'package:flutter/material.dart';

class LogPage extends StatelessWidget {
  final List<dynamic> logList;

  const LogPage({Key? key, required this.logList}) : super(key: key);

  String formatTimestamp(String? timestamp) {
    if (timestamp == null) return '-';
    return timestamp.replaceFirst('T', ' ').replaceFirst('Z', '');
  }

  //TAMPILAN
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Log Aktivitas"),
        backgroundColor: const Color(0xFF131D4F),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF131D4F),
      body: logList.isEmpty
          ? const Center(child: Text("Belum ada log aktivitas."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logList.length,
        itemBuilder: (context, index) {
          final log = logList[index];
          final keterangan = (log['keterangan']?.split(' ').first ?? '-');
          final aksi = log['aksi'] ?? '-';
          final timestamp = formatTimestamp(log['timestamp']);
          final dosen = log['dosen_yang_mengesahkan'];
          final namaDosen = dosen is Map ? dosen['nama'] ?? '-' : '-';
          final emailDosen = dosen is Map ? dosen['email'] ?? '-' : '-';

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                keterangan,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Status: $aksi"),
                    Text("Dosen: $namaDosen"),
                    Text("Email Dosen: $emailDosen"),
                    Text("Waktu: $timestamp"),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
