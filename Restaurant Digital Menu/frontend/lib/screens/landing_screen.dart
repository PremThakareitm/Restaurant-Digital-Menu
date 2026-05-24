import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/test_ids.dart';
import 'about_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF6EE), Color(0xFFFFE8D9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Semantics(
                  identifier: TestIds.landingHero,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.restaurant_menu,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bites & Brilliance',
                                style: GoogleFonts.playfairDisplay(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary)),
                            Text('Modern dining made simple',
                                style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                        Semantics(
                          identifier: TestIds.landingAboutButton,
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AboutScreen()),
                            ),
                            child: const Text('About'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Semantics(
                  identifier: TestIds.landingAboutTab,
                  child: const TabBar(
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: AppTheme.textSecondary,
                    indicatorColor: AppTheme.primary,
                    tabs: [
                      Tab(text: 'Home'),
                      Tab(text: 'About'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _LandingHomeTab(
                        onLogin: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        ),
                        onSignup: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SignupScreen()),
                        ),
                      ),
                      const AboutScreen(embedInLanding: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LandingHomeTab extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onSignup;

  const _LandingHomeTab({required this.onLogin, required this.onSignup});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            identifier: TestIds.landingHero,
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppTheme.primaryShadow(alpha: 55),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Taste, browse, and order with clarity',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      height: 1.1,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Explore the menu, save favourites, track past orders, and manage your profile from one polished experience.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white.withAlpha(235),
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          identifier: TestIds.landingSignupButton,
                          child: ElevatedButton(
                            onPressed: onSignup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primary,
                            ),
                            child: const Text('Sign Up'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Semantics(
                          identifier: TestIds.landingLoginButton,
                          child: OutlinedButton(
                            onPressed: onLogin,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                            ),
                            child: const Text('Login'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _FeatureCard(
            icon: Icons.restaurant_menu_rounded,
            title: 'Menu first',
            description: 'Browse dishes by category with a clean mobile-first layout.',
          ),
          _FeatureCard(
            icon: Icons.person_outline_rounded,
            title: 'Profile and history',
            description: 'Keep your account details and past orders in one place after login.',
          ),
          _FeatureCard(
            icon: Icons.local_fire_department_outlined,
            title: 'Fast ordering',
            description: 'Place orders quickly and review them later from your account page.',
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.dividerLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(description,
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        height: 1.5,
                        color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}