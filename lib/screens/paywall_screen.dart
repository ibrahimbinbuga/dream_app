import 'package:flutter/material.dart';
import '../core/theme.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Arka plana mistik bir gradyan atalım
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050A30), Color(0xFF2A1B3D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // --- KAPAT BUTONU ---
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                
                const Spacer(),

                // --- İKON & BAŞLIK ---
                const Icon(Icons.diamond, size: 80, color: AppTheme.accentGold),
                const SizedBox(height: 20),
                Text(
                  "Kahin Ol",
                  style: AppTheme.darkTheme.textTheme.displayLarge,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Bilinçaltının tüm kapılarını arala.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),

                const SizedBox(height: 40),

                // --- AVANTAJLAR LİSTESİ ---
                _buildFeatureItem("Reklamları Tamamen Kaldır"),
                _buildFeatureItem("Sınırsız Rüya Yorumu"),
                _buildFeatureItem("Detaylı Psikolojik Analiz"),
                _buildFeatureItem("Rüya Günlüğü Tutma"),

                const Spacer(),

                // --- FİYAT KARTLARI ---
                // 1. Seçenek: Pahalı olan (Kıyaslama için)
                _buildPriceCard(
                  title: "Aylık Abonelik",
                  price: "₺29.99 / Ay",
                  isBestValue: false,
                ),
                const SizedBox(height: 15),
                
                // 2. Seçenek: Bizim satmak istediğimiz (Ucuz & Ömür Boyu)
                _buildPriceCard(
                  title: "Ömür Boyu Erişim",
                  price: "₺59.99 Tek Sefer",
                  isBestValue: true, // "En İyi Fiyat" etiketi
                  onTap: () {
                    // BURADA SATIN ALMA TETİKLENECEK
                    print("Satın alma tıklandı");
                  },
                ),

                const SizedBox(height: 20),
                const Text(
                  "Satın alma işlemi iTunes/Google hesabından tahsil edilir.",
                  style: TextStyle(color: Colors.white24, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppTheme.accentGold, size: 20),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildPriceCard({
    required String title,
    required String price,
    required bool isBestValue,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isBestValue ? AppTheme.accentGold : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: isBestValue ? null : Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isBestValue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text("EN ÇOK SATAN", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                Text(
                  title,
                  style: TextStyle(
                    color: isBestValue ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Text(
              price,
              style: TextStyle(
                color: isBestValue ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}