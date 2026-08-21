import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single source of truth for the user's name, streak, and session count.
/// Every screen listens to this — call `AppData.instance.recordActivity()`
/// whenever the user completes something (mood log, breathing session,
/// gratitude entry, etc.) and Home/Profile/Progress all update automatically.
class AppData extends ChangeNotifier {
  AppData._();
  static final AppData instance = AppData._();

  String userName = 'Friend';
  int totalSessions = 0;
  int bestStreak = 0;
  int totalBreathingSeconds = 0;
  Set<String> _activeDates = {};
  bool isLoaded = false;

  static const _kName = 'user_name';
  static const _kActiveDates = 'active_dates';
  static const _kBestStreak = 'best_streak';
  static const _kTotalSessions = 'total_sessions';
  static const _kBreathingSeconds = 'total_breathing_seconds';

  /// Call once at app startup, before runApp().
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString(_kName) ?? 'Friend';
    totalSessions = prefs.getInt(_kTotalSessions) ?? 0;
    bestStreak = prefs.getInt(_kBestStreak) ?? 0;
    totalBreathingSeconds = prefs.getInt(_kBreathingSeconds) ?? 0;
    _activeDates = (prefs.getStringList(_kActiveDates) ?? []).toSet();
    isLoaded = true;
    notifyListeners();
  }

  double get breathingHours => totalBreathingSeconds / 3600;

  /// Called once per second while a breathing session is actively running.
  Future<void> addBreathingSeconds(int seconds) async {
    totalBreathingSeconds += seconds;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kBreathingSeconds, totalBreathingSeconds);
    notifyListeners();
  }

  /// Which day-of-month numbers were active in the given month — used to
  /// draw the real calendar on the Progress screen.
  Set<int> activeDaysInMonth(DateTime month) {
    final prefix =
        '${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}-';
    final days = <int>{};
    for (final key in _activeDates) {
      if (key.startsWith(prefix)) {
        final day = int.tryParse(key.substring(prefix.length));
        if (day != null) days.add(day);
      }
    }
    return days;
  }

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Consecutive days ending today (or yesterday, if today isn't logged yet).
  int get currentStreak {
    int streak = 0;
    DateTime cursor = DateTime.now();
    if (!_activeDates.contains(_dateKey(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    while (_activeDates.contains(_dateKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  bool get loggedToday => _activeDates.contains(_dateKey(DateTime.now()));

  /// 7 booleans for Mon..Sun of the current week — used for the streak
  /// dots on Home and the weekly bar chart on Progress.
  List<bool> get thisWeekActivity {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return _activeDates.contains(_dateKey(day));
    });
  }

  Future<void> setName(String name) async {
    userName = name.trim().isEmpty ? 'Friend' : name.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, userName);
    notifyListeners();
  }

  /// Call this any time the user completes an activity — mood log,
  /// breathing session, gratitude entry, quote viewed, game played,
  /// audio played. Marks today active, bumps session count, updates streak.
  Future<void> recordActivity() async {
    final prefs = await SharedPreferences.getInstance();

    _activeDates.add(_dateKey(DateTime.now()));
    await prefs.setStringList(_kActiveDates, _activeDates.toList());

    totalSessions++;
    await prefs.setInt(_kTotalSessions, totalSessions);

    final streak = currentStreak;
    if (streak > bestStreak) {
      bestStreak = streak;
      await prefs.setInt(_kBestStreak, bestStreak);
    }

    notifyListeners();
  }
}
