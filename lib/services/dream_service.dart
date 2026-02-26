import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DreamService {
  late final GenerativeModel _model;

  DreamService() {
    final apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GOOGLE_API_KEY çevre değişkeni ayarlanmamış');
    }
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: apiKey,
    );
  }

  Future<String> interpretDream(String dreamDescription, String style) async {
    print("------------------------------------------------");
    print("🚀 YENİ SERVİS BAŞLADI: Google Gemini AI - Stil: $style");
    print("------------------------------------------------");

    if (dreamDescription.trim().isEmpty) return "Lütfen rüyanı anlat...";

    // Seçilen stile göre Yapay Zeka'nın kişiliğini değiştiriyoruz
    String stylePrompt = "";
    
    switch (style) {
      case 'İslami (Dini)':
        stylePrompt = "Rüyayı İslami kaynaklara, rüya tabirleri külliyatına ve dini sembollere göre yorumla. Manevi bir dil kullan.";
        break;
      case 'Eski Türk (Şamanik)':
        stylePrompt = "Rüyayı Eski Türk mitolojisi, şamanik semboller ve doğa ruhlarına göre yorumla. Mistik ve köklü bir dil kullan.";
        break;
      case 'Modern & Bilimsel':
        stylePrompt = "Rüyayı modern psikoloji ve nörobilim açısından, güncel hayat stresi ve bilinçaltı yansımaları olarak yorumla. Gerçekçi ol.";
        break;
      default: // Psikolojik (Jung)
        stylePrompt = "Rüyayı Carl Jung psikolojisi, arketipler ve kolektif bilinçaltı sembolleriyle yorumla. Derin ve bilge bir dil kullan.";
        break;
    }

    try {
      // Prompt'u birleştiriyoruz
      String prompt = "Sen 'Dream Oracle' adında mistik bir rüya yorumcususun. "
          "$stylePrompt " // Dinamik kısım burası
          "Kullanıcı sana rüyasını anlatacak. "
          "Türkçe konuş. Cevabın en fazla 4 cümle olsun. "
          "Yorumun en sonunda mutlaka 'Şanslı Sayıların: X, Y, Z' formatında 3 sayı ver. "
          "Rüya: $dreamDescription";

      // Google Gemini API'yi çağırıyoruz
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        print("✅ CEVAP GELDİ: ${response.text}");
        return response.text!;
      } else {
        return "Yıldızlar şu an cevap veremiyor. Lütfen tekrar dene.";
      }
    } catch (e) {
      print("❌ BAĞLANTI HATASI: $e");
      return "Bağlantı hatası. API anahtarını kontrol et ve interneti sağla.";
    }
  }
}