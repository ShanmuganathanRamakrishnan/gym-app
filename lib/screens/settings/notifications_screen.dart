// ignore_for_file: deprecated_member_use
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../theme/gym_theme.dart';
import '../../services/settings_service.dart';

/// Notifications settings screen with grouped toggles.
///
/// Refined UI matching Hevy's flat, calm design.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = SettingsService();
  bool _loading = true;

  // Toggle states
  final Map<String, bool> _toggles = {};

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    await _service.init();
    final prefs = await _service.getAllNotifications();

    if (mounted) {
      setState(() {
        _toggles.addAll(prefs);
        _loading = false;
      });
    }
  }

  Future<void> _setToggle(String key, bool value) async {
    setState(() => _toggles[key] = value);
    await _service.setNotification(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymTheme.colors.background,
      appBar: AppBar(
        backgroundColor: GymTheme.colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(),
        title: Text('Push Notifications', style: GymTheme.text.screenTitle),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: GymTheme.colors.accent),
            )
          : ListView(
              padding: EdgeInsets.zero, // Flat list edge-to-edge look generally
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: GymTheme.spacing.md),
                  child: _buildWarningBanner(),
                ),
                const SizedBox(height: 32),

                // General section
                _buildSectionHeader('General'),
                _buildToggleRow(
                  key: 'rest_timer',
                  title: 'Rest Timer',
                ),
                _buildToggleRow(
                  key: 'follows',
                  title: 'Follows',
                ),
                _buildToggleRow(
                  key: 'monthly_report',
                  title: 'Monthly Report',
                  subtitle:
                      'Get a notification when your monthly report is ready',
                ),
                _buildToggleRow(
                  key: 'subscribe_emails',
                  title: 'Subscribe to Hevy emails',
                  subtitle: 'Tips, new feature announcements, offers and more',
                ),

                const SizedBox(height: 32),

                // Likes section
                _buildSectionHeader('Likes'),
                _buildToggleRow(
                  key: 'likes_workouts',
                  title: 'Likes on your workouts',
                ),
                _buildToggleRow(
                  key: 'likes_comments',
                  title: 'Likes on your comments',
                ),

                const SizedBox(height: 32),

                // Comments section
                _buildSectionHeader('Comments'),
                _buildToggleRow(
                  key: 'comments',
                  title: 'Comments',
                ),

                // Bottom padding
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom +
                      kBottomNavigationBarHeight +
                      32,
                ),
              ],
            ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: GymTheme.colors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber.withOpacity(0.8),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: GymTheme.colors.textSecondary,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(
                    text:
                        'Your phone notifications are turned off. Enable them by adjusting your ',
                  ),
                  TextSpan(
                    text: 'phone settings.',
                    style: TextStyle(
                      color: GymTheme.colors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // TODO: Open app settings
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13, // Slightly bumped for readability
          fontWeight: FontWeight.w600,
          color: GymTheme.colors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String key,
    required String title,
    String? subtitle,
  }) {
    return InkWell(
      onTap: () => _setToggle(key, !(_toggles[key] ?? true)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align to top if text wraps
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.2,
                      color: GymTheme.colors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.3,
                        color: GymTheme.colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              // Constrain switch size to prevent layout jumps
              height: 24,
              child: Switch(
                value: _toggles[key] ?? true,
                onChanged: (value) => _setToggle(key, value),
                activeColor: Colors.white,
                activeTrackColor: GymTheme.colors.accent,
                inactiveThumbColor: GymTheme.colors.textMuted,
                inactiveTrackColor: GymTheme.colors.surfaceElevated,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
