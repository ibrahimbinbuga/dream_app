import 'dart:io'; // Platform kontrolü için eklendi
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; 
import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // YENİ: Apple Sign in UI için
import '../core/theme.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isLoading = false;
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  Future<void> _submit() async {
    setState(() => isLoading = true);
    
    String? error;
    if (isLogin) {
      error = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } else {
      error = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }

    setState(() => isLoading = false);

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => isLoading = true);
    String? error = await _authService.signInWithGoogle();
    setState(() => isLoading = false);

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  // Apple ile Giriş Butonunu Tetikleyen Fonksiyon
  Future<void> _appleSignIn() async {
    setState(() => isLoading = true);
    String? error = await _authService.signInWithApple();
    setState(() => isLoading = false);

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Butonların köşe yuvarlaklık standartını belirliyoruz (12 pixel)
    final shapeStandard = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050A30), Color(0xFF1C1C3D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icon.png', width: 120, height: 120)
                .animate().fade(duration: 600.ms).scale(delay: 200.ms, duration: 400.ms),
                
                const SizedBox(height: 20),
                
                Text(
                  isLogin ? "Giriş Yap" : "Kahin'e Katıl",
                  style: AppTheme.darkTheme.textTheme.displayLarge,
                ).animate().fade().slideY(begin: 0.3, end: 0),

                const SizedBox(height: 40),

                _buildTextField(_emailController, "E-posta", Icons.email)
                    .animate().fade(delay: 200.ms).slideX(begin: -0.2),
                
                const SizedBox(height: 16),
                
                _buildTextField(_passwordController, "Şifre", Icons.lock, isPassword: true)
                    .animate().fade(delay: 300.ms).slideX(begin: -0.2),

                const SizedBox(height: 30),

                // --- GİRİŞ / KAYIT BUTONU ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      shape: shapeStandard, // Standart köşe
                    ),
                    child: isLoading 
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(isLogin ? "Giriş" : "Kayıt Ol", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ).animate().fade(delay: 400.ms).slideY(begin: 0.2),

                const SizedBox(height: 20),

                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("VEYA", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                    ),
                    const Expanded(child: Divider(color: Colors.white24)),
                  ],
                ).animate().fade(delay: 500.ms),

                const SizedBox(height: 20),

                // --- SOSYAL GİRİŞ BUTONLARI ---
                
                // GOOGLE BUTONU
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _googleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: shapeStandard, // Standart köşe
                    ),
                    icon: const Icon(Icons.g_mobiledata, size: 40, color: Colors.red), 
                    label: const Text("Google ile Devam Et", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ).animate().fade(delay: 600.ms).slideY(begin: 0.2),

                const SizedBox(height: 15),

                // APPLE BUTONU (Sadece iOS cihazlarda gösterilir)
                if (Platform.isIOS || Platform.isMacOS) 
                  SizedBox(
                    height: 50,
                    child: SignInWithAppleButton(
                      text: "Apple ile Devam Et",
                      onPressed: isLoading ? () {} : _appleSignIn,
                      style: SignInWithAppleButtonStyle.white, 
                      borderRadius: const BorderRadius.all(Radius.circular(12.0)), // Standart köşe
                    ),
                  ).animate().fade(delay: 700.ms).slideY(begin: 0.2),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin ? "Hesabın yok mu? Kayıt Ol" : "Zaten üye misin? Giriş Yap",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ).animate().fade(delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12), // Textfield'lar da 12px
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white54),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}