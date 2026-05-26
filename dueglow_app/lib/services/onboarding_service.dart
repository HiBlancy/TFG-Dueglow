import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Persists whether the user has finished or skipped the app tutorial.
class OnboardingService {
  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.prefOnboardingComplete) ?? false;
  }

  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefOnboardingComplete, true);
  }

  static Future<void> resetForDebug() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefOnboardingComplete);
  }
}
