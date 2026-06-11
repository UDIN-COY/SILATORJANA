import 'package:flutter/material.dart';

/// Landing view — splash/redirect page.
/// In mobile app, the SplashView handles this role, so this is minimal.
class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    // Mobile apps typically handle landing in SplashView.
    // This exists for structural parity but redirects immediately.
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF047857)),
      ),
    );
  }
}
