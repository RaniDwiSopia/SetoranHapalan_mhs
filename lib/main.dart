import 'package:flutter/material.dart';
import 'pages/login_page.dart'; // Ganti dengan path halaman login Anda

void main() {
  runApp(const MyApp()); // TAMBAHKAN const DI SINI
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // TAMBAHKAN const DI SINI

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Setoran Hafalan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // Set halaman login sebagai halaman awal
    );
  }
}
