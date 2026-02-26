import 'package:http/http.dart' as http;

class DreamService {
  
  Future<String> interpretDream(String dreamDescription, String style) async {
    print("------------------------------------------------");
    print("🚀 YENİ SERVİS BAŞLADI: Pollinations AI - Stil: $style");
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

      final encodedPrompt = Uri.encodeComponent(prompt);
      // Pollinations.ai ile ücretsiz gönderim
      final url = Uri.parse('https://text.pollinations.ai/$encodedPrompt');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        print("✅ CEVAP GELDİ: ${response.body}");
        return response.body;
      } else {
        return "Yıldızlar şu an cevap veremiyor. (Hata: ${response.statusCode})";
      }
    } catch (e) {
      print("❌ BAĞLANTI HATASI: $e");
      return "Bağlantı hatası. İnternetini kontrol et.";
    }
  }
}