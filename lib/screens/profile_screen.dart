import 'package:dream_app/screens/history_screen.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Profil", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.cardColor,
              child: Icon(Icons.person, size: 50, color: AppTheme.accentGold),
            ),
            const SizedBox(height: 20),
            Text(
              user?.email ?? "Misafir",
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            
            const SizedBox(height: 40),

            // RÜYA GÜNLÜĞÜ BUTONU
            ListTile(
              tileColor: AppTheme.accentGold.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.book, color: AppTheme.accentGold),
              title: const Text("Rüya Günlüğü", style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
              onTap: () {
                // Günlük sayfasına git (Import etmeyi unutma!)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
            ),
            
            const SizedBox(height: 20),
            // ÇIKIŞ YAP BUTONU
            ListTile(
              tileColor: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text("Çıkış Yap", style: TextStyle(color: Colors.white)),
              onTap: () {
                _authService.signOut();
                Navigator.pop(context); // Ana sayfadan çıkıp login'e düşer
              },
            ),

            const SizedBox(height: 20),

            // HESAP SİL BUTONU (Kırmızı ve Tehlikeli)
            ListTile(
              tileColor: Colors.red.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("Hesabımı Sil", style: TextStyle(color: Colors.red)),
              onTap: () => _showDeleteConfirmDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text("Emin misin?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Hesabın kalıcı olarak silinecek. Bu işlem geri alınamaz.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Vazgeç", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              bool success = await _authService.deleteAccount();
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Güvenlik gereği önce çıkış yapıp tekrar girmelisin."))
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("SİL", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}