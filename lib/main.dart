import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/Auth_Service.dart'; // Ganti nama file ke lowercase
import 'pages/login_page.dart'; // Ganti sesuai path file LoginPage kamu
import 'pages/Setoran_Pages.dart'; // Ganti sesuai path file SetoranPage kamu

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();

  bool loggedIn = await authService.isLoggedIn();

  runApp(MyApp(initialRoute: loggedIn ? '/setoran' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, this.initialRoute = '/login'}); // Default route

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Setoran Hafalan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => LoginPage(),
        '/setoran': (context) => SetoranSayaPage(),
      },
    );
  }
}
