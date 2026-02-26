import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Renklerimiz (Tasarımından alındı)
  static const Color background = Color(0xFF0B0C24); // Derin Gece Mavisi
  static const Color cardColor = Color(0xFF1C1C3D);  // Kart Rengi
  static const Color accentGold = Color(0xFFFFD369); // Parlak Altın
  static const Color textWhite = Color(0xFFEAEAEA);  // Beyaz Metin
  static const Color inputColor = Color(0xFF25264F); // Yazı yazma kutusu

  // Uygulamanın Genel Teması
  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: background, // Tüm sayfaların arka planı
      primaryColor: accentGold,
      brightness: Brightness.dark,
      
      // Yazı Tipleri
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cinzel( // Başlıklar için mistik font
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: accentGold,
        ),
        bodyMedium: GoogleFonts.poppins( // Normal yazılar için okunaklı font
          fontSize: 16,
          color: textWhite,
        ),
      ),
    );
  }
}