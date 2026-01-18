import 'package:shared_preferences/shared_preferences.dart';
import '../data/prebuilt_routines.dart';

const String _kExperienceLevelKey = 'user_experience_level';
const String _kOnboardingCompletedKey = 'onboarding_completed';

/// Service for managing user preferences persistence
class UserPreferences {
  static final UserPreferences _instance = UserPreferences._internal();
  factory UserPreferences() => _instance;
  UserPreferences._internal();

  bool _initialized = false;
  ExperienceLevel? _experienceLevel;
  bool _onboardingCompleted = false;

  /// Get user experience level
  ExperienceLevel? get experienceLevel => _experienceLevel;

  /// Check if onboarding is completed
  bool get onboardingCompleted => _onboardingCompleted;

  /// Initialize preferences from storage
  Future<void> init() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load experience level
      final levelString = prefs.getString(_kExperienceLevelKey);
      if (levelString != null) {
        _experienceLevel = _parseLevel(levelString);
      }

      // Load onboarding status
      _onboardingCompleted = prefs.getBool(_kOnboardingCompletedKey) ?? false;

      _initialized = true;
    } catch (e) {
      _initialized = true;
    }
  }

  /// Set user experience level
  Future<void> setExperienceLevel(ExperienceLevel level) async {
    _experienceLevel = level;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kExperienceLevelKey, level.name);
    } catch (e) {
      // Silently fail
    }
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    _onboardingCompleted = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kOnboardingCompletedKey, true);
    } catch (e) {
      // Silently fail
    }
  }

  /// Parse experience level from string
  ExperienceLevel? _parseLevel(String value) {
    switch (value) {
      case 'beginner':
        return ExperienceLevel.beginner;
      case 'intermediate':
        return ExperienceLevel.intermediate;
      case 'advanced':
        return ExperienceLevel.advanced;
      default:
        return null;
    }
  }

  /// Get experience level with fallback
  ExperienceLevel getExperienceLevelOrDefault() {
    return _experienceLevel ?? ExperienceLevel.intermediate;
  }
}
