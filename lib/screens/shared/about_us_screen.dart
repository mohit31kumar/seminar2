// lib/screens/shared/about_us_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:seminar_booking_app/widgets/member_grid_card.dart';
import 'package:seminar_booking_app/widgets/member_detail_dialog.dart';
import 'package:seminar_booking_app/widgets/text.dart'; // ✅ Import AppText
import 'package:seminar_booking_app/widgets/container.dart'; // ✅ Import GlassContainer

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  // --- Data remains the same ---
  static const List<Map<String, String?>> teamMembers = [
     {
      'name': 'Sameer Beniwal',
      'role': 'Lead Developer',
      'course': 'B.Tech AIML',
      'regNo': '2024PUFCEBAMX17768',
      'email': '2024btechaimlsameer17768@poornima.edu.in',
      'avatarAssetPath': 'assets/images/sameer_avatar.jpg',
      'linkedinUrl': 'LINKEDIN_URL',
      'githubUrl': 'GITHUB_URL',
    },
    {
      'name': 'Mohit Kumar',
      'role': 'Backend Developer',
      'course': 'B.Tech AIML',
      'regNo': 'PUAIML2024-002',
      'avatarAssetPath': 'assets/images/mohit_avatar.jpg',
      'linkedinUrl': 'LINKEDIN_URL',
      'githubUrl': 'GITHUB_URL',
    },
    {
      'name': 'Aryan Gaikwad',
      'role': 'UI/UX Designer',
      'course': 'B.Tech AIML',
      'regNo': 'PUAIML2024-003',
      'avatarAssetPath': 'assets/images/aryan_avatar.jpg',
      'linkedinUrl': 'LINKEDIN_URL',
      'githubUrl': 'GITHUB_URL',
    },
    {
      'name': 'Kshitij Soni',
      'role': 'Frontend Developer',
      'course': 'B.Tech AIML',
      'regNo': 'PUAIML2024-004',
      'avatarAssetPath': 'assets/images/kshitij_avatar.jpg',
      'linkedinUrl': 'LINKEDIN_URL',
      'githubUrl': 'GITHUB_URL',
    },
  ];

  void _showMemberDetails(BuildContext context, Map<String, String?> memberData) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return MemberDetailDialog(
          name: memberData['name'] ?? 'N/A',
          role: memberData['role'] ?? 'N/A',
          course: memberData['course'] ?? 'N/A',
          regNo: memberData['regNo'] ?? 'N/A',
          avatarAssetPath: memberData['avatarAssetPath'] ?? '',
          email: memberData['email'] ?? 'N/A',
          linkedinUrl: memberData['linkedinUrl'],
          githubUrl: memberData['githubUrl'],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // No theme needed directly, AppText handles it
    return Scaffold(
      extendBodyBehindAppBar: true, // Keep AppBar transparent overlay
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make AppBar see-through
        elevation: 0,
        // Use AppText for title for consistency, though standard Text is fine too
        title: const AppText('About Us', color: Colors.white), // White title
        centerTitle: true,
        // Ensure back button is visible against gradient
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        // Keep the gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2C), Color(0xFF23233A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          // Adjust top padding to account for transparent AppBar
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 20, // Status bar + AppBar + spacing
            bottom: 40,
          ),
          children: [
            // --- Header Title ---
            Column(
              children: [
                // ✅ Use AppText
                const AppText(
                  "Team Shunya", // Corrected spelling
                  variant: AppTextVariant.h1, // Use displaySmall equivalent
                  textAlign: TextAlign.center,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.2, curve: Curves.easeOut),
                const SizedBox(height: 8),
                // ✅ Use AppText
                const AppText(
                  "Innovators behind P.U. Booking",
                  variant: AppTextVariant.body, // Use titleMedium equivalent
                  textAlign: TextAlign.center,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ).animate().fadeIn(delay: 300.ms),
              ],
            ),
            const SizedBox(height: 30),

            // --- Tagline / Mission Card ---
            // ✅ Use GlassContainer
            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(20), // Slightly more padding
              backgroundColor: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              child: const Column(
                children: [
                  // ✅ Use AppText
                  AppText(
                    "“From Zero Comes Innovation — That’s Shunya.”", // Corrected
                    variant: AppTextVariant.body, // titleMedium equivalent
                    textAlign: TextAlign.center,
                    color: Colors.white,
                    style: TextStyle(fontStyle: FontStyle.italic), // Apply italic via style
                  ),
                  SizedBox(height: 12),
                  // ✅ Use AppText
                  AppText(
                    "We’re a group of AI enthusiasts from Poornima University dedicated to creating efficient and impactful digital solutions.",
                    variant: AppTextVariant.body, // bodyMedium equivalent
                    textAlign: TextAlign.center,
                    color: Colors.white70,
                    style: TextStyle(height: 1.4), // Line height
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.95, 0.95)),
            const SizedBox(height: 40),

            // --- Meet the Team Title ---
            // ✅ Use AppText
            const AppText(
              "Meet the Team",
              variant: AppTextVariant.h2, // headlineSmall equivalent
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 20), // More space before grid

            // --- Team Grid ---
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8, // Adjust ratio if needed with GlassContainer
              ),
              itemCount: teamMembers.length,
              itemBuilder: (context, index) {
                final member = teamMembers[index];
                // Use Animate widget from flutter_animate
                return Animate(
                  effects: [
                    FadeEffect(delay: (index * 150).ms, duration: 500.ms),
                    const ScaleEffect(begin: Offset(0.9, 0.9)),
                    // Add a slight slide-up effect
                    const MoveEffect(begin: Offset(0, 20), curve: Curves.easeOutQuart)
                  ],
                  child: MemberGridCard( // This now uses GlassContainer internally
                    name: member['name'] ?? 'N/A',
                    role: member['role'] ?? 'N/A',
                    avatarAssetPath: member['avatarAssetPath'] ?? '',
                    onTap: () => _showMemberDetails(context, member),
                  ),
                );
              },
            ),
            const SizedBox(height: 50),

            // --- Footer / Thank You ---
            Column(
              children: [
                // ✅ Use AppText
                const AppText(
                  "Thank You!",
                  variant: AppTextVariant.h3, // headlineMedium equivalent
                  textAlign: TextAlign.center,
                  color: Colors.white, // Or theme.colorScheme.primary if preferred
                  fontWeight: FontWeight.bold,
                )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .scale(begin: const Offset(0.9, 0.9)),
                const SizedBox(height: 8),
                // ✅ Use AppText
                const AppText(
                  "© 2025 Team Shunya | Poornima University", // Corrected
                  variant: AppTextVariant.small, // bodySmall equivalent
                  textAlign: TextAlign.center,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}