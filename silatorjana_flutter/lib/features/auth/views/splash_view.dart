import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Memberikan durasi tayang splash screen selama 2.5 detik
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;
    
    // Lanjut ke LoginView
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => const LoginView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF022C22), // emerald-950 (Sesuai tema web)
      body: Stack(
        children: [
          // Efek pattern latar belakang (opsional, jika ingin tambah estetika)
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: SvgPicture.asset(
                'assets/svg/pattern-bg.svg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Svg yang baru saja diperbaiki
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: SvgPicture.asset(
                    'assets/svg/app-logo.svg',
                    height: 96,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Si-LATORJANA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sistem Layanan Terpadu Administrasi',
                  style: TextStyle(
                    color: Color(0xFF6EE7B7), // emerald-300
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const Text(
                  'Politeknik Negeri Jakarta',
                  style: TextStyle(
                    color: Color(0xFFA7F3D0), // emerald-200
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
