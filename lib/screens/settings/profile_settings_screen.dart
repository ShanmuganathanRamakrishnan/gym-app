import 'package:flutter/material.dart';
import '../../theme/gym_theme.dart';
import '../../services/settings_service.dart';
import '../../widgets/avatar_picker.dart';

/// Profile settings screen for editing user profile.
///
/// Refined UI to match Hevy's clean, card-based form design.
class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = SettingsService();

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _linkController;

  String? _avatarPath;
  String? _sex;
  DateTime? _birthday;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _linkController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    await _service.init();
    final profile = _service.getProfile();

    if (mounted) {
      setState(() {
        _nameController.text = profile.name;
        _bioController.text = profile.bio ?? '';
        _linkController.text = profile.link ?? '';
        _avatarPath = profile.avatarPath;
        _sex = profile.sex;
        _birthday = profile.birthday;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = UserProfile(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
      link: _linkController.text.trim().isEmpty
          ? null
          : _linkController.text.trim(),
      avatarPath: _avatarPath,
      sex: _sex,
      birthday: _birthday,
    );

    await _service.saveProfile(profile);

    if (mounted) {
      Navigator.pop(context);
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
        title: Text('Edit Profile', style: GymTheme.text.screenTitle),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: Text(
              'Done',
              style: TextStyle(
                color: _loading
                    ? GymTheme.colors.textMuted
                    : GymTheme.colors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: GymTheme.colors.accent),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(GymTheme.spacing.md),
                children: [
                  const SizedBox(height: 16),
                  // Avatar
                  Center(
                    child: AvatarPicker(
                      currentPath: _avatarPath,
                      onChanged: (path) => setState(() => _avatarPath = path),
                      size: 100, // Larger size
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Public Profile Data section
                  _buildSectionHeader('Public profile data'),
                  const SizedBox(height: 12),
                  _buildFormGroup([
                    _buildTextField(
                      label: 'Name',
                      controller: _nameController,
                      required: true,
                      placeholder: 'Your full name',
                    ),
                    _buildTextField(
                      label: 'Bio',
                      controller: _bioController,
                      placeholder: 'Describe yourself',
                      maxLines: 2,
                    ),
                    _buildTextField(
                      label: 'Link',
                      controller: _linkController,
                      placeholder: 'https://example.com',
                      keyboardType: TextInputType.url,
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // Private Data section
                  _buildSectionHeader('Private data 🔒'),
                  const SizedBox(height: 12),
                  _buildFormGroup([
                    _buildSelectableRow(
                      label: 'Sex',
                      value: _sex ?? 'Select',
                      onTap: _showSexPicker,
                    ),
                    _buildSelectableRow(
                      label: 'Birthday',
                      value: _birthday != null
                          ? '${_birthday!.day}/${_birthday!.month}/${_birthday!.year}'
                          : 'Select',
                      onTap: _showDatePicker,
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

  /// Refined card container for form groups without internal dividers
  Widget _buildFormGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: GymTheme.colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? placeholder,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Padding(
              padding: const EdgeInsets.only(top: 3), // Align with text
              child: Text(
                label,
                style: TextStyle(
                  color: GymTheme.colors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              style: TextStyle(color: GymTheme.colors.textPrimary),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(
                  color: GymTheme.colors.textMuted.withAlpha(100),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              validator: required
                  ? (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '$label is required';
                      }
                      return null;
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                label,
                style: TextStyle(
                  color: GymTheme.colors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: value == 'Select'
                      ? GymTheme.colors.accent
                      : GymTheme.colors.textPrimary,
                  fontSize: 14,
                  fontWeight:
                      value == 'Select' ? FontWeight.w500 : FontWeight.normal,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSexPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: GymTheme.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sex',
                style: TextStyle(
                  color: GymTheme.colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              for (final option in [
                'Male',
                'Female',
                'Other',
                'Prefer not to say'
              ])
                InkWell(
                  onTap: () {
                    setState(() => _sex = option);
                    Navigator.pop(ctx);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: _sex == option
                          ? GymTheme.colors.accent.withAlpha(25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option,
                          style: TextStyle(
                            color: _sex == option
                                ? GymTheme.colors.accent
                                : GymTheme.colors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_sex == option)
                          Icon(Icons.check, color: GymTheme.colors.accent),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: GymTheme.themeData.copyWith(
            colorScheme: ColorScheme.dark(
              primary: GymTheme.colors.accent,
              surface: GymTheme.colors.surface,
              onSurface: GymTheme.colors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _birthday = picked);
    }
  }
}
