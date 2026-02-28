import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Kullanıcının anlık durumunu dinleyen stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // YENİ EKLENEN: Profil ekranı için mevcut kullanıcıyı döndürür
  User? get currentUser => _auth.currentUser;

  // E-posta ve Şifre ile Giriş
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Başarılı, hata yok
    } on FirebaseAuthException catch (e) {
      return e.message; // Hata mesajını döndür
    }
  }

  // E-posta ve Şifre ile Kayıt
  Future<String?> signUp({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Google ile Giriş Yap
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Kullanıcı iptal etti

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Apple ile Giriş Yap
  Future<String?> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      final AuthCredential credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await _auth.signInWithCredential(credential);
      return null; // Başarılı
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Apple ile giriş yapılamadı veya iptal edildi.";
    }
  }

  // Çıkış Yap
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // YENİ EKLENEN: Hesabı Sil (Dönüş tipi bool olarak güncellendi)
  Future<bool> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
      return true; // İşlem başarılı
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print("Güvenlik nedeniyle hesabınızı silmeden önce çıkış yapıp tekrar giriş yapmalısınız.");
      } else {
        print("Hesap silme hatası: ${e.message}");
      }
      return false; // İşlem başarısız
    } catch (e) {
      print("Hesap silinirken bir hata oluştu: $e");
      return false; // İşlem başarısız
    }
  }
}