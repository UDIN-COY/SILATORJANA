import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/views/splash_view.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/kegiatan/viewmodels/kegiatan_viewmodel.dart';
import 'features/chat/viewmodels/chat_viewmodel.dart';
import 'features/profile/viewmodels/profile_viewmodel.dart';
import 'features/master_data/viewmodels/master_data_viewmodel.dart';
import 'core/utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => KegiatanViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => MasterDataViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Si-LATORJANA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF047857)), // emerald-700
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      builder: (context, child) {
        return _ResponsiveLayoutWrapper(child: child!);
      },
      home: const SplashView(),
    );
  }
}

class _ResponsiveLayoutWrapper extends StatelessWidget {
  final Widget child;
  const _ResponsiveLayoutWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Determine if we should show the mockup. Threshold: screen is wider than 500
        // and the ratio width/height is wider than 0.65.
        final isWidescreen = screenWidth > 500 && (screenWidth / screenHeight) > 0.65;

        if (isWidescreen) {
          // Leave some padding for the device frame mockup (e.g. 64px vertical space)
          double targetHeight = screenHeight - 64;
          double targetWidth = targetHeight * (9.0 / 16.0);

          // If calculated target width is too wide for screen, constrain by width instead
          if (targetWidth > screenWidth - 64) {
            targetWidth = screenWidth - 64;
            targetHeight = targetWidth * (16.0 / 9.0);
          }

          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF064E3B), // Deep emerald green
                    Color(0xFF0F172A), // Deep slate blue/black
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: targetWidth + 24, // 12px bezel on each side
                  height: targetHeight + 24, // 12px bezel on top/bottom
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B), // Slate 800 phone frame
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: const Color(0xFF475569), // Slate 600 outer metal rim
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x99000000),
                        blurRadius: 40,
                        spreadRadius: 5,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0), // bezel thickness
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              size: Size(targetWidth, targetHeight),
                              padding: const EdgeInsets.only(top: 32, bottom: 20),
                            ),
                            child: child,
                          ),
                          // Premium phone dynamic-island/notch mockup
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                width: 80,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF047857), // emerald reflection
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // On mobile, just render normally
        return child;
      },
    );
  }
}
