import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/database_service.dart';
import 'result_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rüya Günlüğü", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder(
        stream: DatabaseService().getDreams(),
        builder: (context, snapshot) {
          // 1. Yükleniyor mu?
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accentGold));
          }

          // 2. Hata var mı?
          if (snapshot.hasError) {
            return Center(child: Text("Hata oluştu: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
          }

          // 3. Veri boş mu?
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.book, size: 60, color: Colors.white24),
                  const SizedBox(height: 10),
                  Text("Henüz kaydedilmiş rüyan yok.", style: AppTheme.darkTheme.textTheme.bodyMedium),
                ],
              ),
            );
          }

          // 4. Listeyi Göster
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // Veriyi çek
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              
              // Tarihi formatla (Basitçe)
              Timestamp t = data['date'];
              DateTime date = t.toDate();
              String dateStr = "${date.day}.${date.month}.${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}";

              return Card(
                color: AppTheme.cardColor,
                margin: const EdgeInsets.only(bottom: 16),
                // --- DÜZELTME BURADA YAPILDI ---
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.white10), // Border.all DEĞİL, BorderSide olmalı
                ),
                // -------------------------------
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    data['dreamText'], // Rüyadan kısa bir kesit
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(
                        dateStr,
                        style: const TextStyle(color: Colors.white30, fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Yorumu görmek için dokun...",
                        style: TextStyle(color: AppTheme.accentGold.withOpacity(0.7), fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                       DatabaseService().deleteDream(doc.id);
                    },
                  ),
                  onTap: () {
                    // Tıklayınca detay sayfasına git
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultScreen(dreamText: data['interpretation']),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}