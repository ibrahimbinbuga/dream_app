import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart'; // Paylaşım paketi
import '../core/theme.dart';

class ResultScreen extends StatelessWidget {
  final String dreamText;

  const ResultScreen({super.key, required this.dreamText});

  // --- PAYLAŞMA FONKSİYONU ---
  void _shareDream(BuildContext context, String comment, List<String> numbers) {
    // Paylaşılacak havalı metin şablonu
    final String shareText = """
🔮 *Dream Oracle Yorumu* 🔮

"$comment"

✨ Şanslı Sayılarım: ${numbers.join(', ')}

Sen de rüyanı yorumlat ve gizemi çöz! 
👇
https://play.google.com/store/apps/details?id=com.senin.uygulaman
""";

    // Paylaşım pencresini aç
    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      shareText,
      subject: 'Rüyamın Gizemli Anlamı',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- PARSING (AYIKLAMA) ---
    String mainComment = dreamText;
    List<String> luckyNumbers = ["?", "?", "?"]; 

    final lowerText = dreamText.toLowerCase();
    int splitIndex = -1;

    if (lowerText.contains("şanslı sayılar")) {
      splitIndex = lowerText.lastIndexOf("şanslı sayılar");
    } else if (lowerText.contains("uğurlu sayılar")) {
      splitIndex = lowerText.lastIndexOf("uğurlu sayılar");
    }

    if (splitIndex != -1) {
      mainComment = dreamText.substring(0, splitIndex).trim();
      mainComment = mainComment.replaceAll(RegExp(r'[.:,;]+$'), '');
      String numberPart = dreamText.substring(splitIndex);
      final RegExp regex = RegExp(r'\d+');
      final matches = regex.allMatches(numberPart);
      final foundNumbers = matches.map((m) => m.group(0)!).toList();
      for (int i = 0; i < 3; i++) {
        if (i < foundNumbers.length) luckyNumbers[i] = foundNumbers[i];
      }
    }
    // -------------------------

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textWhite),
        actions: [
          // --- DÜZELTME: PAYLAŞ YERİNE ANA SAYFA BUTONU ---
          IconButton(
            onPressed: () {
              // Navigasyon geçmişini temizleyerek en başa (Ana Sayfa) dön
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home, color: AppTheme.accentGold),
          ).animate().fade(delay: 500.ms).scale()
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BAŞLIK
            Text(
              "Kehanet Hazır",
              style: AppTheme.darkTheme.textTheme.displayLarge?.copyWith(fontSize: 28),
            ).animate().fade(duration: 600.ms).slideX(begin: -0.2),
            
            const SizedBox(height: 10),
            
            const Text(
              "Yıldızlar ve bilinçaltın hizalandı. İşte rüyanın gizli anlamı:",
              style: TextStyle(color: Colors.white54),
            ).animate().fade(delay: 200.ms),
            
            const SizedBox(height: 30),

            // YORUM KARTI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.cardColor, AppTheme.cardColor.withOpacity(0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.accentGold.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(color: AppTheme.accentGold.withOpacity(0.05), blurRadius: 20, spreadRadius: 1),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.nights_stay, color: AppTheme.accentGold, size: 30)
                      .animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.elasticOut),
                  
                  const SizedBox(height: 15),
                  
                  Text(
                    mainComment, 
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
                ],
              ),
            )
            .animate()
            .fade(delay: 300.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0)
            .shimmer(delay: 1000.ms, duration: 2000.ms, color: AppTheme.accentGold.withOpacity(0.3)),

            const SizedBox(height: 30),

            // ŞANSLI SAYILAR
            const Text(
              "Şanslı Sayıların",
              style: TextStyle(color: AppTheme.accentGold, fontSize: 18, fontWeight: FontWeight.bold),
            ).animate().fade(delay: 800.ms),
            
            const SizedBox(height: 15),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLuckyNumber(luckyNumbers[0], 900),
                _buildLuckyNumber(luckyNumbers[1], 1100),
                _buildLuckyNumber(luckyNumbers[2], 1300),
              ],
            ),

            const SizedBox(height: 40),

            // --- PAYLAŞ BUTONU (BÜYÜK - Sadece bu kaldı) ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => _shareDream(context, mainComment, luckyNumbers),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.white.withOpacity(0.2))
                  ),
                ),
                icon: const Icon(Icons.ios_share), // Paylaşım ikonu
                label: const Text("Arkadaşınla Paylaş", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
            .animate()
            .fade(delay: 1500.ms) // En son gelsin
            .slideY(begin: 0.2),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLuckyNumber(String number, int delayMs) {
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.accentGold, width: 2),
        color: AppTheme.cardColor, 
        boxShadow: [BoxShadow(color: AppTheme.accentGold.withOpacity(0.2), blurRadius: 10)]
      ),
      child: Text(
        number,
        style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 20),
      ),
    )
    .animate()
    .scale(delay: delayMs.ms, duration: 500.ms, curve: Curves.elasticOut)
    .fade(delay: delayMs.ms);
  }
}