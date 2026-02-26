import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // GoogleSignIn nesnesi (Parametresiz en sade haliyle)
  // Scopes varsayılan olarak zaten email bilgisini içerir.
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Şu anki kullanıcıyı getir
  User? get currentUser => _auth.currentUser;

  // Kullanıcı durumunu dinle (Giriş/Çıkış takibi)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- GOOGLE İLE GİRİŞ FONKSİYONU ---
  Future<String?> signInWithGoogle() async {
    try {
      // 1. Google penceresini aç
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // Kullanıcı pencereyi kapattı
      }

      // 2. Google'dan yetki belgelerini al
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Firebase için kimlik kartı oluştur
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Firebase'e giriş yap
      await _auth.signInWithCredential(credential);
      
      return null; // Başarılı
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Google girişi başarısız oldu: $e";
    }
  }

  // --- DİĞER FONKSİYONLAR ---

  // Kayıt Ol
  Future<String?> signUp({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Giriş Yap (Email ile)
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Çıkış Yap
  Future<void> signOut() async {
    try {
      // Önce Google'dan çıkmayı dene, hata olursa önemseme
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      
      await _auth.signOut(); // Firebase'den çık
    } catch (e) {
      print("Çıkış hatası: $e");
    }
  }

  // Hesabı Sil
  Future<bool> deleteAccount() async {
    try {
      // Önce Google'dan bağlantıyı kes (İsteğe bağlı ama temiz olur)
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }
      
      await _auth.currentUser?.delete();
      return true;
    } catch (e) {
      print("Hesap silinemedi: $e");
      return false;
    }
  }
}