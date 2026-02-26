import 'package:dream_app/core/theme.dart';
import 'package:dream_app/screens/auth_screen.dart';
import 'package:dream_app/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart'; // Ekle
import 'package:flutter/material.dart';
import 'package:dream_app/core/theme.dart';
import 'package:dream_app/screens/auth_screen.dart';
import 'package:dream_app/screens/home_screen.dart';
import 'package:dream_app/services/auth_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


// Firebase ayar dosyası (Bunu birazdan oluşturacağız, şimdilik hata verebilir)
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // flutter_dotenv'ini başlat
  await dotenv.load();
  
  // Firebase ve Reklamları başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dream Oracle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // KULLANICI DURUMUNU DİNLEYEN YAPI
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomeScreen(); // Giriş yapmışsa Ana Sayfa
          }
          return const AuthScreen(); // Yapmamışsa Giriş Ekranı
        },
      ),
    );
  }
}