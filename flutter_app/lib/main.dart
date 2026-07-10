import 'package:flutter/material.dart';

import 'models/user.dart';
import 'screens/login_screen.dart';
import 'screens/products_screen.dart';
import 'services/session_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ventes Privées',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const _StartupScreen(),
    );
  }
}

/// Vérifie au démarrage si une session existe déjà en local (auto-login).
/// Si oui, on saute directement l'écran de connexion.
class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: SessionService.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.data != null ? const ProductsScreen() : const LoginScreen();
      },
    );
  }
}
