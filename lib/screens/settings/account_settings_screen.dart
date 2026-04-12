// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../../theme/gym_theme.dart';
import '../../services/settings_service.dart';
import '../../widgets/settings_row.dart';

/// Account settings screen for managing credentials and account actions.
///
/// Features username/email change, password update, and account deletion.
/// Uses nested navigation within Profile tab.
class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _service = SettingsService();
  bool _loading = true;
  late UserAccount _account;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    await _service.init();
    if (mounted) {
      setState(() {
        _account = _service.getAccount();
        _loading = false;
      });
    }
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
        title: Text('Account', style: GymTheme.text.screenTitle),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: GymTheme.colors.accent),
            )
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 24),
                _buildSectionHeader('Security'),
                _buildSecurityGroup(),
                const SizedBox(height: 48),
                _buildSectionHeader('Danger zone'),
                _buildDangerZone(),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom +
                      kBottomNavigationBarHeight +
                      24,
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: GymTheme.colors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSecurityGroup() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SettingsRow(
            title: 'Change Username',
            leadingIcon: Icons.person_outline,
            onTap: _showChangeUsernameDialog,
          ),
          const SizedBox(height: 8),
          SettingsRow(
            title: 'Change Email',
            leadingIcon: Icons.email_outlined,
            onTap: _showChangeEmailDialog,
          ),
          const SizedBox(height: 8),
          SettingsRow(
            title: 'Update Password',
            leadingIcon: Icons.lock_outline,
            onTap: _showUpdatePasswordDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const _DeleteAccountScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red[400],
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, color: Colors.red[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Dialogs remain unchanged...
  void _showChangeUsernameDialog() {
    final controller = TextEditingController(text: _account.username);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GymTheme.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GymTheme.radius.md),
        ),
        title: Text(
          'Change Username',
          style: TextStyle(color: GymTheme.colors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: GymTheme.colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'New username',
            hintStyle: TextStyle(color: GymTheme.colors.textMuted),
            filled: true,
            fillColor: GymTheme.colors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: GymTheme.colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newUsername = controller.text.trim();
              if (newUsername.isNotEmpty) {
                await _service.updateUsername(newUsername);
                if (mounted) {
                  Navigator.pop(ctx);
                  _loadAccount();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Username updated'),
                      backgroundColor: GymTheme.colors.surface,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Save',
              style: TextStyle(color: GymTheme.colors.accent),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog() {
    final emailController = TextEditingController(text: _account.email);
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GymTheme.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GymTheme.radius.md),
        ),
        title: Text(
          'Change Email',
          style: TextStyle(color: GymTheme.colors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: GymTheme.colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'New email',
                hintStyle: TextStyle(color: GymTheme.colors.textMuted),
                filled: true,
                fillColor: GymTheme.colors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: TextStyle(color: GymTheme.colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Current password',
                hintStyle: TextStyle(color: GymTheme.colors.textMuted),
                filled: true,
                fillColor: GymTheme.colors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: GymTheme.colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newEmail = emailController.text.trim();
              final password = passwordController.text;
              if (newEmail.isNotEmpty && password.isNotEmpty) {
                await _service.updateEmail(newEmail, password);
                if (mounted) {
                  Navigator.pop(ctx);
                  _loadAccount();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Email updated'),
                      backgroundColor: GymTheme.colors.surface,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Save',
              style: TextStyle(color: GymTheme.colors.accent),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdatePasswordDialog() {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: GymTheme.colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GymTheme.radius.md),
          ),
          title: Text(
            'Update Password',
            style: TextStyle(color: GymTheme.colors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: oldController,
                obscureText: true,
                style: TextStyle(color: GymTheme.colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Current password',
                  hintStyle: TextStyle(color: GymTheme.colors.textMuted),
                  filled: true,
                  fillColor: GymTheme.colors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newController,
                obscureText: true,
                style: TextStyle(color: GymTheme.colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'New password (min 8 chars)',
                  hintStyle: TextStyle(color: GymTheme.colors.textMuted),
                  filled: true,
                  fillColor: GymTheme.colors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                obscureText: true,
                style: TextStyle(color: GymTheme.colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Confirm new password',
                  hintStyle: TextStyle(color: GymTheme.colors.textMuted),
                  filled: true,
                  fillColor: GymTheme.colors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(color: GymTheme.colors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                final newPass = newController.text;
                final confirm = confirmController.text;

                if (newPass.length < 8) {
                  setDialogState(() =>
                      errorText = 'Password must be at least 8 characters');
                  return;
                }
                if (newPass != confirm) {
                  setDialogState(() => errorText = 'Passwords do not match');
                  return;
                }

                await _service.updatePassword(oldController.text, newPass);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Password updated'),
                      backgroundColor: GymTheme.colors.surface,
                    ),
                  );
                }
              },
              child: Text(
                'Update',
                style: TextStyle(color: GymTheme.colors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteAccountScreen extends StatelessWidget {
  const _DeleteAccountScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymTheme.colors.background,
      appBar: AppBar(
        backgroundColor: GymTheme.colors.background,
        elevation: 0,
        leading: const BackButton(),
        title: Text('Delete Account', style: GymTheme.text.screenTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(26),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.warning_amber_rounded,
                  size: 48, color: Colors.red[400]),
            ),
            const SizedBox(height: 24),
            Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: GymTheme.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'This action is irreversible. All your workouts, measurements, and history will be permanently deleted.',
              style: TextStyle(
                fontSize: 16,
                color: GymTheme.colors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GymTheme.colors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: GymTheme.colors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Stub action - no actual delete call yet as per instructions
                Navigator.pop(context);
              },
              child: Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[400],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}
