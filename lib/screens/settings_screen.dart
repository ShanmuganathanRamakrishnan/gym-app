import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';
import '../widgets/settings_row.dart';

/// Settings screen matching Hevy visual structure.
///
/// Navigation uses nested navigator within Profile tab (no rootNavigator).
/// All sub-screens push onto the same navigator stack.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymTheme.colors.background,
      appBar: AppBar(
        backgroundColor: GymTheme.colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(),
        title: Text('Settings', style: GymTheme.text.screenTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: GymTheme.spacing.md,
            vertical: GymTheme.spacing.sm,
          ),
          children: [
            // PRO Unlock Banner (Hevy style)
            _buildProBanner(context),
            const SizedBox(height: 24),

            // Section: Account
            _buildSectionHeader('Account'),
            const SizedBox(height: 8),

            SettingsRow(
              title: 'Profile',
              subtitle: 'Edit your profile details',
              leadingIcon: Icons.person_outline,
              onTap: () => _navigateTo(context, '/settings/profile'),
            ),
            const SizedBox(height: 8),

            SettingsRow(
              title: 'Account',
              subtitle: 'Email, password, security',
              leadingIcon: Icons.shield_outlined,
              onTap: () => _navigateTo(context, '/settings/account'),
            ),
            const SizedBox(height: 8),

            SettingsRow(
              title: 'Manage Subscription',
              leadingIcon: Icons.workspace_premium_outlined,
              trailingWidget: const ProBadge(),
              onTap: () => _navigateTo(context, '/settings/subscription'),
            ),
            const SizedBox(height: 8),

            SettingsRow(
              title: 'Notifications',
              leadingIcon: Icons.notifications_outlined,
              onTap: () => _navigateTo(context, '/settings/notifications'),
            ),

            const SizedBox(height: 24),

            // Section: Preferences
            _buildSectionHeader('Preferences'),
            const SizedBox(height: 8),

            SettingsRow(
              title: 'Workouts',
              leadingIcon: Icons.fitness_center,
              onTap: () => _navigateTo(context, '/settings/workouts'),
            ),
            const SizedBox(height: 8),

            SettingsRow(
              title: 'Privacy & Social',
              leadingIcon: Icons.lock_outline,
              onTap: () => _navigateTo(context, '/settings/privacy'),
            ),
            const SizedBox(height: 8),

            SettingsRow(
              title: 'Units',
              leadingIcon: Icons.straighten,
              onTap: () => _navigateTo(context, '/settings/units'),
            ),
            const SizedBox(height: 8),

            SettingsRow(
              title: 'Language',
              leadingIcon: Icons.language,
              onTap: () => _navigateTo(context, '/settings/language'),
            ),

            // Bottom padding for nav bar
            SizedBox(
              height: MediaQuery.of(context).padding.bottom +
                  kBottomNavigationBarHeight +
                  24,
            ),
          ],
        ),
      ),
    );
  }

  /// PRO banner at top matching Hevy "HEVY PRO | Unlock" style
  Widget _buildProBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: GymTheme.colors.surface,
        borderRadius: BorderRadius.circular(GymTheme.radius.md),
      ),
      child: Row(
        children: [
          // App branding + PRO badge
          Row(
            children: [
              Text(
                'HEVY',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: GymTheme.colors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: GymTheme.colors.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Unlock button
          TextButton(
            onPressed: () => _navigateTo(context, '/settings/subscription'),
            style: TextButton.styleFrom(
              backgroundColor: GymTheme.colors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Unlock',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: GymTheme.colors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    // Nested navigation: uses Profile tab's navigator stack
    // Placeholder screens will be created in subsequent prompts
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coming soon: $route'),
        backgroundColor: GymTheme.colors.surface,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
