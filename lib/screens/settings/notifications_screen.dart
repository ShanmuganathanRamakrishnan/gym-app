// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../theme/gym_theme.dart';
import '../../services/settings_service.dart';

/// Notifications settings screen with grouped toggles.
///
/// All preferences persist via SettingsService.
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
              padding: EdgeInsets.all(GymTheme.spacing.md),
              children: [
                // Warning banner
                _buildWarningBanner(),
                const SizedBox(height: 24),

                // General section
                _buildSectionHeader('General'),
                const SizedBox(height: 8),
                _buildCard([
                  _buildToggleRow(
                    key: 'rest_timer',
                    title: 'Rest Timer',
                    subtitle: null,
                  ),
                  _buildDivider(),
                  _buildToggleRow(
                    key: 'follows',
                    title: 'Follows',
                    subtitle: null,
                  ),
                  _buildDivider(),
                  _buildToggleRow(
                    key: 'monthly_report',
                    title: 'Monthly Report',
                    subtitle:
                        'Get a notification when your monthly report is ready',
                    hasInfo: true,
                  ),
                  _buildDivider(),
                  _buildToggleRow(
                    key: 'subscribe_emails',
                    title: 'Subscribe to Hevy emails',
                    subtitle:
                        'Tips, new feature announcements, offers and more',
                  ),
                ]),

                const SizedBox(height: 24),

                // Likes section
                _buildSectionHeader('Likes'),
                const SizedBox(height: 8),
                _buildCard([
                  _buildToggleRow(
                    key: 'likes_workouts',
                    title: 'Likes on your workouts',
                    subtitle: null,
                  ),
                  _buildDivider(),
                  _buildToggleRow(
                    key: 'likes_comments',
                    title: 'Likes on your comments',
                    subtitle: null,
                  ),
                ]),

                const SizedBox(height: 24),

                // Comments section
                _buildSectionHeader('Comments'),
                const SizedBox(height: 8),
                _buildCard([
                  _buildToggleRow(
                    key: 'comments',
                    title: 'Comments',
                    subtitle: null,
                  ),
                ]),

                // Bottom padding
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom +
                      kBottomNavigationBarHeight +
                      24,
                ),
              ],
            ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(26),
        borderRadius: BorderRadius.circular(GymTheme.radius.md),
        border: Border.all(color: Colors.amber.withAlpha(77)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your phone notifications are turned off. Enable them by adjusting your phone settings.',
                  style: TextStyle(
                    fontSize: 13,
                    color: GymTheme.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    // TODO: Open app settings
                  },
                  child: Text(
                    'phone settings',
                    style: TextStyle(
                      fontSize: 13,
                      color: GymTheme.colors.accent,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: GymTheme.colors.textMuted,
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: GymTheme.colors.surface,
        borderRadius: BorderRadius.circular(GymTheme.radius.md),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: GymTheme.colors.divider,
      indent: 16,
    );
  }

  Widget _buildToggleRow({
    required String key,
    required String title,
    String? subtitle,
    bool hasInfo = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        color: GymTheme.colors.textPrimary,
                      ),
                    ),
                    if (hasInfo) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _showInfoDialog(title, subtitle ?? ''),
                        child: Icon(
                          Icons.info_outline,
                          size: 16,
                          color: GymTheme.colors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle != null && !hasInfo) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: GymTheme.colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: _toggles[key] ?? true,
            onChanged: (value) => _setToggle(key, value),
            activeColor: GymTheme.colors.accent,
            inactiveThumbColor: GymTheme.colors.textMuted,
            inactiveTrackColor: GymTheme.colors.surfaceElevated,
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GymTheme.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GymTheme.radius.md),
        ),
        title: Text(
          title,
          style: TextStyle(color: GymTheme.colors.textPrimary),
        ),
        content: Text(
          message,
          style: TextStyle(color: GymTheme.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'OK',
              style: TextStyle(color: GymTheme.colors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
