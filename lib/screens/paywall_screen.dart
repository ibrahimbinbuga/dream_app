import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../services/purchase_service.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  List<Package> _packages = [];
  bool _isLoading = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    final packages = await PurchaseService.fetchOffers();
    setState(() {
      _packages = packages;
      _isLoading = false;
    });
  }

  Future<void> _buyPackage(Package package) async {
    setState(() => _isPurchasing = true);
    
    bool success = await PurchaseService.purchasePackage(package);
    
    setState(() => _isPurchasing = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Premium aktif edildi! Büyülü dünyaya hoş geldin.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // true dönerek ana ekrana haber veriyoruz
    }
  }

  // APPLE ZORUNLULUĞU: Satın Alımları Geri Yükleme Fonksiyonu
  Future<void> _restorePurchases() async {
    setState(() => _isPurchasing = true);
    
    bool success = await PurchaseService.restorePurchases();
    
    setState(() => _isPurchasing = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Geçmiş satın alımlarınız başarıyla geri yüklendi!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Geri yüklenecek aktif bir abonelik bulunamadı."), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
        : SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const Icon(Icons.workspace_premium, size: 90, color: AppTheme.accentGold)
                            .animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 20),
                        
                        Text("Kahin'in Gözü", style: AppTheme.darkTheme.textTheme.displayLarge).animate().fade().slideY(),
                        
                        const SizedBox(height: 15),
                        
                        const Text(
                          "Rüyalarınızın gizemli perdesini tamamen aralayın.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ).animate().fade(delay: 200.ms),
                        
                        const SizedBox(height: 40),

                        // PREMIUM ÖZELLİKLER LİSTESİ
                        _buildFeatureRow(Icons.all_inclusive, "Sınırsız Rüya Yorumu"),
                        _buildFeatureRow(Icons.auto_awesome, "İslami, Şamanik ve Psikolojik Stiller"),
                        _buildFeatureRow(Icons.block, "Tamamen Reklamsız Deneyim"),
                        _buildFeatureRow(Icons.bolt, "Öncelikli ve Anında Yanıtlar"),
                        
                        const SizedBox(height: 40),

                        // EĞER PAKET YOKSA
                        if (_packages.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "Şu an paketlere ulaşılamıyor. Lütfen internet bağlantınızı kontrol edin.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          )
                        else
                          // PAKETLERİ LİSTELE (29.99 TL otomatik olarak burada görünecek)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _packages.length,
                            itemBuilder: (context, index) {
                              final package = _packages[index];
                              return GestureDetector(
                                onTap: () => _isPurchasing ? null : _buyPackage(package),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFD4AF37), Color(0xFF997A15)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(color: AppTheme.accentGold.withOpacity(0.3), blurRadius: 15, spreadRadius: 2)
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Aylık Abonelik",
                                            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "İstediğiniz zaman iptal edin",
                                            style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      _isPurchasing 
                                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                        : Text(
                                            package.storeProduct.priceString, // 29.99 TL buraya otomatik gelecek!
                                            style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w900),
                                          ),
                                    ],
                                  ),
                                ).animate().fade(delay: (400 + (index * 100)).ms).slideY(begin: 0.2),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                
                // ALT KISIM (APPLE ZORUNLULUKLARI)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: _isPurchasing ? null : _restorePurchases,
                        child: const Text("Satın Alımları Geri Yükle", style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline)),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {}, // İleride linklenebilir
                            child: const Text("Kullanım Koşulları", style: TextStyle(color: Colors.white30, fontSize: 10)),
                          ),
                          const Text("|", style: TextStyle(color: Colors.white30, fontSize: 10)),
                          TextButton(
                            onPressed: () {}, // İleride linklenebilir
                            child: const Text("Gizlilik Politikası", style: TextStyle(color: Colors.white30, fontSize: 10)),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
    );
  }

  // Özellikleri listelemek için yardımcı widget
  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentGold, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ).animate().fade(delay: 300.ms).slideX(begin: 0.2),
    );
  }
}