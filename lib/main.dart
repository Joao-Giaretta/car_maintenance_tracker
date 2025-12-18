import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Tenta carregar o .env de diferentes formas para garantir compatibilidade
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // Fallback: tenta carregar sem o ponto
      try {
        await dotenv.load(fileName: "env");
      } catch (e2) {
        print('❌ Error loading .env file: $e');
        print('❌ Error loading env file: $e2');
        rethrow;
      }
    }
    // Debug: verificar se as variáveis foram carregadas
    print('✅ .env file loaded successfully');
    final connStr = dotenv.env['MONGODB_CONNECTION_STRING'];
    final dbName = dotenv.env['DATABASE_NAME'];
    print('MONGODB_CONNECTION_STRING: ${connStr != null && connStr.length > 20 ? connStr.substring(0, 20) : "null"}...');
    print('DATABASE_NAME: $dbName');
    
    // Validação crítica: se as variáveis não foram carregadas, o app não pode funcionar
    if (connStr == null || connStr.isEmpty) {
      throw Exception('MONGODB_CONNECTION_STRING is missing from .env file');
    }
  } catch (e) {
    print('❌ Critical error loading .env file: $e');
    // Em produção, você pode querer usar valores padrão ou mostrar um erro ao usuário
    rethrow;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Maintenance Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue[700],
        scaffoldBackgroundColor: Colors.grey[900],
        cardColor: Colors.grey[800],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white54),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue[700]!),
          ),
          labelStyle: TextStyle(color: Colors.grey[300]),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.grey[800],
          titleTextStyle: const TextStyle(color: Colors.white),
          contentTextStyle: TextStyle(color: Colors.grey[300]),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}