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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.accentGold),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
        : SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium, size: 80, color: AppTheme.accentGold)
                      .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 20),
                  Text("Kahin'in Gözü", style: AppTheme.darkTheme.textTheme.displayLarge).animate().fade().slideY(),
                  const SizedBox(height: 10),
                  const Text(
                    "Sınırsız rüya yorumu, reklamsız deneyim ve size özel mistik şamanik/islami yorum stillerinin kilidini açın.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ).animate().fade(delay: 200.ms),
                  
                  const SizedBox(height: 40),

                  // EĞER PAKET YOKSA (Google Play Console Ayarları Tamamlanmamışsa)
                  if (_packages.isEmpty)
                    const Text(
                      "Şu an mağazaya ulaşılamıyor. Google Play Console ayarlarının yapılması gerekiyor.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.redAccent),
                    )
                  else
                    // PAKETLERİ LİSTELE
                    Expanded(
                      child: ListView.builder(
                        itemCount: _packages.length,
                        itemBuilder: (context, index) {
                          final package = _packages[index];
                          return Card(
                            color: AppTheme.cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: AppTheme.accentGold.withOpacity(0.5)),
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              title: Text(
                                package.storeProduct.title,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                package.storeProduct.description,
                                style: const TextStyle(color: Colors.white54),
                              ),
                              trailing: _isPurchasing 
                                ? const CircularProgressIndicator(color: AppTheme.accentGold)
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.accentGold,
                                      foregroundColor: Colors.black,
                                    ),
                                    onPressed: () => _buyPackage(package),
                                    child: Text(package.storeProduct.priceString), // Gerçek fiyat burada yazacak (örn: ₺49.99)
                                  ),
                            ),
                          ).animate().fade(delay: (400 + (index * 100)).ms).slideX();
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
    );
  }
}