import 'package:flutter/material.dart';
import 'ui/game_screen.dart';

void main() {
  runApp(const SpaceGenApp());
}

class SpaceGenApp extends StatelessWidget {
  const SpaceGenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpaceGen',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4FC3F7),
          secondary: Color(0xFF81C784),
          surface: Color(0xFF1A1A2E),
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _fadeIn = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn));
    _fadeOut = CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeOut));
    _controller.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const GameScreen(),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => Opacity(
            opacity: _fadeIn.value * (1.0 - _fadeOut.value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'SPACEGEN',
                  style: TextStyle(
                    color: Color(0xFF4FC3F7),
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 12,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'A PROCEDURAL SPACE CIVILIZATION SIMULATOR',
                  style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
