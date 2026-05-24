import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'landing_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _dotsController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _taglineOpacity;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
    _titleSlide =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _textController,
          curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 1600));
    if (mounted) {
      final isLoggedIn = await AuthService().isLoggedIn();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) =>
              isLoggedIn ? const HomeScreen() : const LandingScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _dotsController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD55A3A),  // warm coral top
              Color(0xFFC84B31),  // primary
              Color(0xFF882010),  // deep mahogany
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ─── Decorative background circles ──────────────────────────
              Positioned(
                top: -120,
                right: -80,
                child: _DecorativeCircle(size: 320, opacity: 0.07),
              ),
              Positioned(
                top: 60,
                right: -140,
                child: _DecorativeCircle(size: 240, opacity: 0.05),
              ),
              Positioned(
                bottom: -80,
                left: -100,
                child: _DecorativeCircle(size: 300, opacity: 0.07),
              ),
              Positioned(
                bottom: 120,
                left: -60,
                child: _DecorativeCircle(size: 160, opacity: 0.05),
              ),
              Positioned(
                bottom: 200,
                right: 30,
                child: _DecorativeCircle(size: 80, opacity: 0.08),
              ),
              // ─── Food emoji accents ──────────────────────────────────────
              const Positioned(
                  top: 90, left: 24, child: _FoodEmoji(emoji: '🍛', size: 28)),
              const Positioned(
                  top: 150, right: 36, child: _FoodEmoji(emoji: '🫕', size: 22)),
              const Positioned(
                  bottom: 180, left: 40, child: _FoodEmoji(emoji: '🥘', size: 24)),
              const Positioned(
                  bottom: 250, right: 28, child: _FoodEmoji(emoji: '🍜', size: 22)),
              const Positioned(
                  top: 220, left: 60, child: _FoodEmoji(emoji: '✨', size: 16)),
              const Positioned(
                  bottom: 140, right: 55, child: _FoodEmoji(emoji: '✨', size: 14)),

              // ─── Main content ───────────────────────────────────────────
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ─── Animated Logo ────────────────────────────────────
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (_, __) => Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: AnimatedBuilder(
                            animation: _pulse,
                            builder: (_, child) => Transform.scale(
                              scale: _pulse.value,
                              child: child,
                            ),
                            child: Container(
                              width: 124,
                              height: 124,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(60),
                                    blurRadius: 40,
                                    spreadRadius: 4,
                                    offset: const Offset(0, 12),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withAlpha(40),
                                    blurRadius: 0,
                                    spreadRadius: 6,
                                    offset: Offset.zero,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.restaurant_menu,
                                size: 62,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ─── Title + Tagline ──────────────────────────────────
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (_, __) => SlideTransition(
                        position: _titleSlide,
                        child: FadeTransition(
                          opacity: _titleOpacity,
                          child: Column(
                            children: [
                              Text(
                                'Bites & Brilliance',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withAlpha(90),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              FadeTransition(
                                opacity: _taglineOpacity,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 9),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white.withAlpha(70),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    color: Colors.white.withAlpha(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '✦',
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          color: Colors.white.withAlpha(200),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Where Every Bite Shines',
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          color: Colors.white,
                                          letterSpacing: 1.2,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '✦',
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          color: Colors.white.withAlpha(200),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // ─── Animated Loading Dots ────────────────────────────
                    AnimatedBuilder(
                      animation: _dotsController,
                      builder: (_, __) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (i) {
                            final offset = (i * 0.33);
                            final v = ((_dotsController.value - offset) % 1.0)
                                .clamp(0.0, 1.0);
                            final bounce =
                                v < 0.5 ? v * 2 : (1.0 - v) * 2;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withAlpha(
                                    (80 + (bounce * 175)).toInt()),
                              ),
                              transform: Matrix4.translationValues(
                                  0, -bounce * 8, 0),
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ─── Bottom brand text ───────────────────────────────────────
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Text(
                  'North Indian · Pan-Asian · New Delhi',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: Colors.white.withAlpha(120),
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────────────────

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorativeCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );
}

class _FoodEmoji extends StatelessWidget {
  final String emoji;
  final double size;
  const _FoodEmoji({required this.emoji, required this.size});

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: 0.35,
        child: Text(
          emoji,
          style: TextStyle(fontSize: size),
        ),
      );
}
