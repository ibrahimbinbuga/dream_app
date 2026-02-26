import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  // Google'ın Test Reklam ID'leri (Bunlar para kazandırmaz, test içindir)
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  // Reklamı Yükle (Hazırda beklet)
  void loadAd() {
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print("Reklam başarıyla yüklendi!");
          _rewardedAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          print("Reklam yüklenemedi: $error");
          _isAdLoaded = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  // Reklamı Göster
  void showAd({required Function onRewardEarned, required Function onAdFailed}) {
    if (_isAdLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadAd(); // Bir sonraki için yenisini yükle
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadAd();
          onAdFailed(); // Hata olursa kullanıcıyı mağdur etme, içeriği göster
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          // Kullanıcı reklamı sonuna kadar izledi!
          print("Ödül kazanıldı!");
          onRewardEarned();
        },
      );
      
      // Gösterdikten sonra yüklü durumu false yap
      _isAdLoaded = false; 
      _rewardedAd = null;
    } else {
      // Reklam hazır değilse bekletmeyelim, direkt geçsin (veya hata versin)
      print("Reklam hazır değil, direkt geçiliyor.");
      onAdFailed(); // Veya onRewardEarned() çağırıp kıyak geçebilirsin
      loadAd(); // Tekrar yüklemeyi dene
    }
  }
}