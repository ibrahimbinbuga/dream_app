import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  // DİKKAT: Bu anahtarları RevenueCat panelinden alacağız.
  static const String _googleApiKey = 'goog_BURAYA_REVENUECAT_ANDROID_KEY_GELECEK';
  
  // YENİ: Apple App Store için RevenueCat Anahtarı
  static const String _appleApiKey = 'appl_BURAYA_REVENUECAT_IOS_KEY_GELECEK'; 
  
  // RevenueCat üzerinde oluşturacağımız "Yetki" (Entitlement) adı
  static const String _entitlementId = 'premium'; 

  // RevenueCat'i Başlat (Bunu main.dart'ta çağırıyoruz)
  static Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;

    // Hangi cihazdaysak onun API anahtarını kullanıyoruz
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_googleApiKey);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_appleApiKey); // iOS için aktif edildi
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
    }
  }

  // Kullanıcı Premium mu kontrol et
  static Future<bool> isPremiumUser() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      // 'premium' yetkisi aktif mi bakıyoruz
      return customerInfo.entitlements.all[_entitlementId]?.isActive == true;
    } catch (e) {
      return false;
    }
  }

  // Satışa sunulan paketleri getir
  static Future<List<Package>> fetchOffers() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages;
      }
      return [];
    } on PlatformException catch (e) {
      print("Paketler getirilemedi: $e");
      return [];
    }
  }

  // Satın alma işlemini tetikle
  static Future<bool> purchasePackage(Package package) async {
    try {
      // purchaseResult içinden customerInfo'yu alıyoruz
      final purchaseResult = await Purchases.purchasePackage(package);
      final customerInfo = purchaseResult.customerInfo;
      
      return customerInfo.entitlements.all[_entitlementId]?.isActive == true;
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        print("Satın alma hatası: $e");
      }
      return false;
    }
  }
}