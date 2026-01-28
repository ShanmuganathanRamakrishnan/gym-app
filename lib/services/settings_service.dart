import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String _kProfileKey = 'gym_app_user_profile';
const String _kAccountKey = 'gym_app_user_account';

/// User profile data model for settings.
class UserProfile {
  final String name;
  final String? bio;
  final String? link;
  final String? avatarPath;
  final String? sex;
  final DateTime? birthday;

  const UserProfile({
    required this.name,
    this.bio,
    this.link,
    this.avatarPath,
    this.sex,
    this.birthday,
  });

  UserProfile copyWith({
    String? name,
    String? bio,
    String? link,
    String? avatarPath,
    String? sex,
    DateTime? birthday,
  }) {
    return UserProfile(
      name: name ?? this.name,
      bio: bio ?? this.bio,
      link: link ?? this.link,
      avatarPath: avatarPath ?? this.avatarPath,
      sex: sex ?? this.sex,
      birthday: birthday ?? this.birthday,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'bio': bio,
        'link': link,
        'avatarPath': avatarPath,
        'sex': sex,
        'birthday': birthday?.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String? ?? 'Athlete',
        bio: json['bio'] as String?,
        link: json['link'] as String?,
        avatarPath: json['avatarPath'] as String?,
        sex: json['sex'] as String?,
        birthday: json['birthday'] != null
            ? DateTime.tryParse(json['birthday'] as String)
            : null,
      );

  static UserProfile empty() => const UserProfile(name: 'Athlete');
}

/// User account data model.
class UserAccount {
  final String username;
  final String email;

  const UserAccount({
    required this.username,
    required this.email,
  });

  UserAccount copyWith({String? username, String? email}) {
    return UserAccount(
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
      };

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
        username: json['username'] as String? ?? 'user',
        email: json['email'] as String? ?? 'user@example.com',
      );

  static UserAccount empty() =>
      const UserAccount(username: 'user', email: 'user@example.com');
}

/// Settings service for user profile and account management.
///
/// Abstracts all SharedPreferences access from UI layer.
/// Network calls are stubs (marked with TODO for backend integration).
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  UserProfile? _profile;
  UserAccount? _account;
  bool _initialized = false;

  /// Initialize and load stored data.
  Future<void> init() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load profile
      final profileJson = prefs.getString(_kProfileKey);
      if (profileJson != null && profileJson.isNotEmpty) {
        _profile = UserProfile.fromJson(
          jsonDecode(profileJson) as Map<String, dynamic>,
        );
      } else {
        _profile = UserProfile.empty();
      }

      // Load account
      final accountJson = prefs.getString(_kAccountKey);
      if (accountJson != null && accountJson.isNotEmpty) {
        _account = UserAccount.fromJson(
          jsonDecode(accountJson) as Map<String, dynamic>,
        );
      } else {
        _account = UserAccount.empty();
      }
    } catch (e) {
      _profile = UserProfile.empty();
      _account = UserAccount.empty();
    }

    _initialized = true;
  }

  // --- Profile API ---

  UserProfile getProfile() {
    return _profile ?? UserProfile.empty();
  }

  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kProfileKey, jsonEncode(profile.toJson()));
    } catch (e) {
      // Log error silently
    }
  }

  // --- Account API ---

  UserAccount getAccount() {
    return _account ?? UserAccount.empty();
  }

  /// Update username (stub for backend).
  Future<bool> updateUsername(String newUsername) async {
    // TODO: Implement backend API call
    _account = _account?.copyWith(username: newUsername);
    await _saveAccount();
    return true;
  }

  /// Update email (stub for backend).
  /// In production, this would require password verification.
  Future<bool> updateEmail(String newEmail, String password) async {
    // TODO: Implement backend API call with password verification
    _account = _account?.copyWith(email: newEmail);
    await _saveAccount();
    return true;
  }

  /// Update password (stub for backend).
  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    // TODO: Implement backend API call
    // Stub: Always returns success for UI testing
    return true;
  }

  /// Delete account (stub for backend).
  /// CRITICAL: This is a destructive action requiring confirmation.
  Future<bool> deleteAccount() async {
    // TODO: Implement backend account deletion
    // For now, clear local data only
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kProfileKey);
      await prefs.remove(_kAccountKey);
      _profile = null;
      _account = null;
      _initialized = false;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveAccount() async {
    if (_account == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kAccountKey, jsonEncode(_account!.toJson()));
    } catch (e) {
      // Log error silently
    }
  }

  // --- Notification Preferences API ---

  /// Get a notification preference by key.
  /// Defaults to true for most notifications.
  Future<bool> getNotification(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('gym_app_notif_$key') ?? true;
    } catch (e) {
      return true;
    }
  }

  /// Set a notification preference.
  Future<void> setNotification(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('gym_app_notif_$key', value);
    } catch (e) {
      // Log error silently
    }
  }

  /// Get all notification preferences as a map.
  Future<Map<String, bool>> getAllNotifications() async {
    final keys = [
      'rest_timer',
      'follows',
      'monthly_report',
      'subscribe_emails',
      'likes_workouts',
      'likes_comments',
      'comments',
    ];

    final result = <String, bool>{};
    for (final key in keys) {
      result[key] = await getNotification(key);
    }
    return result;
  }
}
