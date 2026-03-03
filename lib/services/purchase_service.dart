import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  // RevenueCat panelinden aldığımız API Anahtarı
  static const String _apiKey = 'test_DOAUsJDZpDWboRIbDFQsNfZhCoN'; 

  // Uygulama açıldığında kasiyeri uyandıran fonksiyon
  static Future<void> init() async {
    if (Platform.isIOS) {
      // Test aşamasında logları görmek için detay seviyesini artırıyoruz
      await Purchases.setLogLevel(LogLevel.debug);
      
      // Kasiyeri anahtarla yapılandırıyoruz
      await Purchases.configure(PurchasesConfiguration(_apiKey));
    }
  }

  // App Store'daki "Kahin'in Gözü" paketini getirir
  static Future<List<Package>> fetchOffers() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages;
      }
    } on PlatformException catch (e) {
      print("Teklifler alınırken hata oluştu: $e");
    }
    return [];
  }

  // Kullanıcı "Satın Al" butonuna bastığında çalışır (V8 GÜNCELLEMESİ)
  static Future<bool> purchasePackage(Package package) async {
    try {
      // Yeni sürümde PurchaseResult dönüyor, CustomerInfo'yu onun içinden alıyoruz
      final PurchaseResult result = await Purchases.purchasePackage(package);
      final CustomerInfo customerInfo = result.customerInfo;
      
      // Satın alma başarılıysa kullanıcının "premium" yetkisi (entitlement) aktif mi kontrol et
      return customerInfo.entitlements.all["premium"]?.isActive == true;
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      // Kullanıcı işlemi bilerek iptal etmediyse hatayı yazdır
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        print("Satın alma hatası: $e");
      }
      return false;
    }
  }

  // Uygulamanın herhangi bir yerinde kullanıcının Premium olup olmadığını kontrol eder
  static Future<bool> checkPremiumStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all["premium"]?.isActive == true;
    } on PlatformException catch (e) {
      print("Premium durum kontrolü hatası: $e");
      return false;
    }
  }

  // Geçmişteki satın alımları geri yükleme (Apple'ın zorunlu kıldığı "Restore" butonu için)
  static Future<bool> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all["premium"]?.isActive == true;
    } on PlatformException catch (e) {
      print("Geri yükleme hatası: $e");
      return false;
    }
  }
}