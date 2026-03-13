import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/responsive_helper.dart';

class RestaurantInfoScreen extends StatelessWidget {
  const RestaurantInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: ResponsiveBuilder(
        builder: (context, screenType, screenWidth) {
          final horizontalPad =
              ResponsiveHelper.getHorizontalPadding(screenWidth);
          final maxContentWidth =
              ResponsiveHelper.getMaxContentWidth(screenWidth);

          return CustomScrollView(
            slivers: [
              // ─── Hero Header ─────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: AppTheme.primaryDark,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.restaurantName,
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'North Indian · Pan-Asian',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withAlpha(180),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/hero.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primary,
                                AppTheme.primaryDark
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.restaurant,
                                size: 80, color: Colors.white38),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(180),
                            ],
                            stops: const [0.3, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Padding(
                      padding: EdgeInsets.all(horizontalPad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ─── Quick Stats Row ──────────────────────────
                          Row(
                            children: const [
                              Expanded(
                                child: _StatCard(
                                  emoji: '⭐',
                                  value: '4.8',
                                  label: 'Rating',
                                  color: AppTheme.gold,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: _StatCard(
                                  emoji: '⏱️',
                                  value: '25–35',
                                  label: 'Minutes',
                                  color: AppTheme.primary,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: _StatCard(
                                  emoji: '🛵',
                                  value: 'Free',
                                  label: 'Delivery',
                                  color: AppTheme.vegGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // ─── About ────────────────────────────────────
                          const _SectionTitle('About Us'),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.dividerLight),
                            ),
                            child: Text(
                              'Welcome to Bites & Brilliance — where culinary artistry meets everyday joy. '
                              'Nestled in the heart of New Delhi, we have been crafting unforgettable dining '
                              'experiences since 2015. Our passionate chefs blend the richness of North Indian '
                              'tradition with bold Pan-Asian influences, using the finest seasonal ingredients '
                              'sourced from trusted local farms and spice artisans.\n\n'
                              'Whether you crave a hearty family feast, a romantic dinner for two, or a '
                              'quick power lunch, Bites & Brilliance promises flavours that linger, '
                              'service that delights, and an ambiance that feels like home — only better.',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                height: 1.75,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ─── Opening Hours ────────────────────────────
                          const _SectionTitle('Opening Hours'),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.dividerLight),
                            ),
                            child: Column(
                              children: [
                                ...AppConstants.openingHours
                                    .asMap()
                                    .entries
                                    .map(
                                  (entry) {
                                    final isLast = entry.key ==
                                        AppConstants.openingHours.length - 1;
                                    final h = entry.value;
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.access_time_outlined,
                                                size: 16,
                                                color: AppTheme.primary,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  h['day']!,
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.textPrimary,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                h['hours']!,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 13,
                                                  color: AppTheme.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!isLast)
                                          const Divider(
                                            height: 1,
                                            color: AppTheme.dividerLight,
                                            indent: 42,
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ─── Contact ─────────────────────────────────
                          const _SectionTitle('Contact Us'),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.dividerLight),
                            ),
                            child: Column(
                              children: const [
                                _ContactTile(
                                  icon: Icons.phone_outlined,
                                  label: 'Phone',
                                  value: AppConstants.restaurantPhone,
                                  isFirst: true,
                                ),
                                _ContactTile(
                                  icon: Icons.email_outlined,
                                  label: 'Email',
                                  value: AppConstants.restaurantEmail,
                                ),
                                _ContactTile(
                                  icon: Icons.language_rounded,
                                  label: 'Website',
                                  value: AppConstants.restaurantWebsite,
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ─── Address ─────────────────────────────────
                          const _SectionTitle('Location'),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.dividerLight),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CachedNetworkImage(
                                  imageUrl:
                                      'https://picsum.photos/seed/map_placeholder/500/160',
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    height: 160,
                                    color: AppTheme.dividerLight,
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    height: 160,
                                    color: AppTheme.dividerLight,
                                    child: const Center(
                                      child: Icon(Icons.map_outlined,
                                          size: 40,
                                          color: AppTheme.textSecondary),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color:
                                              AppTheme.primary.withAlpha(15),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                            Icons.location_on_rounded,
                                            size: 18,
                                            color: AppTheme.primary),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          AppConstants.restaurantAddress,
                                          style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            color: AppTheme.textSecondary,
                                            height: 1.6,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ─── Gallery ──────────────────────────────────
                          const _SectionTitle('Gallery'),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              final int columns =
                                  width < 480 ? 2 : width < 960 ? 3 : 4;
                              return GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: columns,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                children: [
                                  'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400&h=400&fit=crop',
                                  'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400&h=400&fit=crop',
                                  'https://images.unsplash.com/photo-1565557623262-b51477827a1b?w=400&h=400&fit=crop',
                                  'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400&h=400&fit=crop',
                                  'https://images.unsplash.com/photo-1601050690117-94f5f7a5b57d?w=400&h=400&fit=crop',
                                  'https://images.unsplash.com/photo-1527661591475-527312dd65f5?w=400&h=400&fit=crop',
                                ]
                                    .map(
                                      (url) => ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: url,
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) => Container(
                                              color: AppTheme.dividerLight),
                                          errorWidget: (_, __, ___) =>
                                              Container(
                                                color: AppTheme.dividerLight,
                                                child: const Icon(Icons.image,
                                                    color: AppTheme
                                                        .textSecondary),
                                              ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 32),

                          // ─── Footer ───────────────────────────────────
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 1,
                                  color: AppTheme.divider,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '© 2024 ${AppConstants.restaurantName}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                Text(
                                  'All rights reserved.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    color: AppTheme.textHint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;
  const _StatCard(
      {required this.emoji,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(13),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 17, color: AppTheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppTheme.textHint),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
              height: 1, color: AppTheme.dividerLight, indent: 56),
      ],
    );
  }
}
