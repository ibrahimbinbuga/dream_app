import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import 'result_screen.dart';
import 'profile_screen.dart';
import 'paywall_screen.dart';

// Servisler
import '../services/dream_service.dart';
import '../services/ad_service.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Kontrolcüler ve Servisler
  final TextEditingController _dreamController = TextEditingController();
  final DreamService _dreamService = DreamService();
  final AdService _adService = AdService();
  
  bool _isLoading = false;

  // --- PREMIUM SİMÜLASYONU ---
  // Şimdilik 'false' yapıyoruz. Test etmek için bunu 'true' yapabilirsin.
  // İleride burayı gerçek satın alma sistemine bağlayacağız.
  bool isPremium = false; 

  // Seçilen Yorum Stili
  String _selectedStyle = 'Psikolojik (Jung)';
  
  // Stil Listesi
  final List<String> _styles = [
    'Psikolojik (Jung)', // Ücretsiz (Varsayılan)
    'İslami (Dini)',     // Premium
    'Eski Türk (Şamanik)', // Premium
    'Modern & Bilimsel'  // Premium
  ];

  @override
  void initState() {
    super.initState();
    // Eğer kullanıcı Premium değilse reklamları yükle
    if (!isPremium) {
      _adService.loadAd();
    }
  }

  Future<void> _analyzeDream() async {
    if (_dreamController.text.isEmpty) return;

    // GÜVENLİK KONTROLÜ: Eğer premium değilse, seçili ne olursa olsun zorla varsayılanı kullan
    String styleToSend = isPremium ? _selectedStyle : 'Psikolojik (Jung)';

    final String currentDream = _dreamController.text;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    // Servise stili gönderiyoruz
    String result = await _dreamService.interpretDream(currentDream, styleToSend);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    _dreamController.clear();

    // --- SONUÇ GÖSTERME MANTIĞI ---
    if (isPremium) {
      // PREMIUM KULLANICI: Reklam yok, direkt sonuç ve veritabanı
      await DatabaseService().saveDream(currentDream, result);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultScreen(dreamText: result)),
      );
    } else {
      // ÜCRETSİZ KULLANICI: Kapıyı tutuyoruz (Reklam veya Premium teklifi)
      _showGatekeeperDialog(currentDream, result);
    }
  }

  // Kapı Tutucu Diyalog (Sadece ücretsiz kullanıcılar görür)
  void _showGatekeeperDialog(String dream, String result) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text("Yorum Hazır!", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Kahin rüyanı yorumladı. Sonucu görmek için bir seçim yapmalısın.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          // SEÇENEK A: REKLAM İZLE
          TextButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext); 
              _adService.showAd(
                onRewardEarned: () async {
                  await DatabaseService().saveDream(dream, result);
                  if (!mounted) return;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ResultScreen(dreamText: result)));
                },
                onAdFailed: () async {
                  await DatabaseService().saveDream(dream, result);
                  if (!mounted) return;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ResultScreen(dreamText: result)));
                },
              );
            },
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: const Text("Reklam İzle (Ücretsiz)", style: TextStyle(color: Colors.white)),
          ),
          
          // SEÇENEK B: PREMIUM AL
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _openPaywall(); // Premium ekranını açan fonksiyon
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold),
            child: const Text("Premium'a Geç", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  void _openPaywall() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaywallScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: AppTheme.accentGold),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ).animate().fade(delay: 500.ms).scale()
        ],
      ),
      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // --- KENDİ LOGOMUZ ---
              Image.asset('assets/icon.png', width: 70, height: 70)
                  .animate().fade().scale(delay: 200.ms),
              const SizedBox(height: 10),
              Text("Dream Oracle", style: AppTheme.darkTheme.textTheme.displayLarge).animate().fade().slideY(begin: -0.5, end: 0),
              const SizedBox(height: 8),
              Text(
                "Bilinçaltının gizemini çöz...",
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(color: Colors.white54, fontSize: 14),
              ).animate().fade(delay: 300.ms),
              
              const SizedBox(height: 40),

              // --- GİRİŞ KARTI ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    // --- YORUM STİLİ SEÇİMİ (Premium Kilitli) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Yorum Stili:", style: TextStyle(color: Colors.white70, fontSize: 14)),
                        
                        DropdownButton<String>(
                          value: _selectedStyle,
                          dropdownColor: AppTheme.cardColor,
                          style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold),
                          underline: Container(height: 1, color: AppTheme.accentGold),
                          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.accentGold),
                          
                          // Değişim Mantığı: Premium değilse kilitli olana izin verme
                          onChanged: (String? newValue) {
                            if (newValue == null) return;

                            // Eğer seçilen stil "Standart" değilse VE kullanıcı Premium değilse
                            if (newValue != 'Psikolojik (Jung)' && !isPremium) {
                              // Değiştirmek yerine Satış Ekranını aç
                              _openPaywall(); 
                            } else {
                              // İzin ver
                              setState(() {
                                _selectedStyle = newValue;
                              });
                            }
                          },
                          
                          // Menü Elemanlarını Oluşturma
                          items: _styles.map<DropdownMenuItem<String>>((String value) {
                            // Bu seçenek kilitli mi?
                            bool isLocked = (value != 'Psikolojik (Jung)' && !isPremium);

                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  Text(
                                    value,
                                    // Kilitliyse rengi soluk yap
                                    style: TextStyle(
                                      color: isLocked ? Colors.white38 : AppTheme.accentGold
                                    ),
                                  ),
                                  if (isLocked) ...[
                                    const SizedBox(width: 8),
                                    const Icon(Icons.lock, size: 14, color: Colors.white38), // Kilit İkonu
                                  ]
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 10),

                    const Text("Rüyanı Anlat", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 15),
                    Container(
                      height: 120,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(color: AppTheme.inputColor, borderRadius: BorderRadius.circular(15)),
                      child: TextField(
                        controller: _dreamController,
                        maxLines: null,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Ormanda yürüyordum...",
                          hintStyle: TextStyle(color: Colors.white30),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fade(delay: 400.ms).slideY(begin: 0.2),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _analyzeDream,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: AppTheme.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppTheme.background)
                      : const Text("Yorumla", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(delay: 2000.ms, duration: 1500.ms, color: Colors.white38).animate().fade(delay: 600.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }
}