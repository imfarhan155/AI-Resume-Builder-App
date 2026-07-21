import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'repositories/auth_repository.dart';
import 'repositories/resume_repository.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/ai_service.dart';
import 'services/pdf_service.dart';
import 'theme/app_theme.dart';
import 'utils/app_config.dart'; // <-- ADD

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // TEMP DEBUG (key aa rahi hai ya nahi)
  // ignore: avoid_print
  print('GROQ KEY LEN => ${AppConfig.groqApiKey.length}');

  runApp(const AIResumeBuilderApp());
}

class AIResumeBuilderApp extends StatelessWidget {
  const AIResumeBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        Provider<ResumeRepository>(create: (_) => ResumeRepository()),
        Provider<AIService>(create: (_) => AIService()),
        Provider<PDFService>(create: (_) => PDFService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AI Resume Builder',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/auth':
              return _route(const AuthScreen());
            case '/home':
              return _route(const HomeScreen());
            default:
              return _route(const SplashScreen());
          }
        },
      ),
    );
  }

  PageRouteBuilder _route(Widget child) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(begin: const Offset(0, 0.05), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }
}
