import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/test_ids.dart';

class AboutScreen extends StatelessWidget {
  final bool embedInLanding;

  const AboutScreen({super.key, this.embedInLanding = false});

  @override
  Widget build(BuildContext context) {
    final body = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Semantics(
        identifier: TestIds.aboutScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppTheme.dividerLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About the restaurant',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bites & Brilliance blends bold North Indian flavors with polished service and a smooth digital menu experience.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      height: 1.6,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _AboutBullet(
              icon: Icons.schedule_rounded,
              title: 'Quick service',
              description: 'Order faster and reduce table waiting time.',
              testId: TestIds.aboutQuickService,
            ),
            _AboutBullet(
              icon: Icons.health_and_safety_outlined,
              title: 'Clear ingredients',
              description: 'See what is inside each dish before you order.',
              testId: TestIds.aboutClearIngredients,
            ),
            _AboutBullet(
              icon: Icons.workspace_premium_outlined,
              title: 'Premium experience',
              description:
                  'A warm visual language, crisp typography, and simple account tools.',
              testId: TestIds.aboutPremiumExperience,
            ),
          ],
        ),
      ),
    );

    if (embedInLanding) {
      return body;
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('About')),
      body: body,
    );
  }
}

class _AboutBullet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String testId;

  const _AboutBullet({
    required this.icon,
    required this.title,
    required this.description,
    required this.testId,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: testId,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.dividerLight),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          height: 1.5,
                          color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}