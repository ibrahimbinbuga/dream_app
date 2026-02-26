import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  // Veritabanı koleksiyonumuzun adı
  final CollectionReference dreamsCollection = 
      FirebaseFirestore.instance.collection('dreams');

  // RÜYAYI KAYDET
  Future<void> saveDream(String dreamText, String interpretation) async {
    User? user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      await dreamsCollection.add({
        'userId': user.uid, // Hangi kullanıcıya ait?
        'dreamText': dreamText, // Kullanıcının yazdığı rüya
        'interpretation': interpretation, // Yapay zekanın yorumu
        'date': Timestamp.now(), // Kayıt tarihi
      });
    }
  }

  // KULLANICININ RÜYALARINI GETİR (CANLI YAYIN)
  Stream<QuerySnapshot> getDreams() {
    User? user = FirebaseAuth.instance.currentUser;

    // Sadece giriş yapan kullanıcının rüyalarını getir ve tarihe göre sırala
    return dreamsCollection
        .where('userId', isEqualTo: user?.uid)
        .orderBy('date', descending: true) // En yenisi en üstte
        .snapshots();
  }
  
  // RÜYA SİL (Opsiyonel)
  Future<void> deleteDream(String docId) async {
    await dreamsCollection.doc(docId).delete();
  }
}