import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/app_data.dart';
import '../widgets/streak_card.dart';
import '../widgets/mood_slider_card.dart';
import '../widgets/activity_card.dart';
import 'quote_screen.dart';
import 'mini_game_screen.dart';
import 'audio_screen.dart';
import 'gratitude_screen.dart';
import 'breathing_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _handleLogMood(BuildContext context, double moodValue) async {
    await AppData.instance.recordActivity();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mood logged 🌿 — ${AppData.instance.currentStreak} day streak',
        ),
        backgroundColor: AppColors.cardBackground,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppData.instance,
      builder: (context, _) {
        final data = AppData.instance;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Good morning 👋',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            'Ready to recharge,\n${data.userName}?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.cardBackground,
                      child:
                          Icon(Icons.person, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StreakCard(
                  currentStreak: data.currentStreak,
                  bestStreak: data.bestStreak,
                  weekActive: data.thisWeekActivity,
                ),
                const SizedBox(height: 16),
                MoodSliderCard(
                  onLogMood: (value) => _handleLogMood(context, value),
                ),
                const SizedBox(height: 24),
                const Text('Take a break 🌿',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                ActivityCard(
                  icon: Icons.self_improvement_rounded,
                  title: 'Breathing',
                  subtitle: '4-7-8 technique',
                  badge: '5 min',
                  large: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BreathingScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ActivityCard(
                        icon: Icons.headphones_rounded,
                        title: 'Motivational Audio',
                        subtitle: 'Spoken affirmations',
                        badge: '',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AudioScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ActivityCard(
                        icon: Icons.format_quote_rounded,
                        title: 'Daily Quote',
                        subtitle: 'Spark some motivation',
                        badge: '1 min',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const QuoteScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ActivityCard(
                        icon: Icons.sports_esports_rounded,
                        title: 'Mini Game',
                        subtitle: 'Quick brain reset',
                        badge: '3 min',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const MiniGameScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ActivityCard(
                        icon: Icons.favorite_rounded,
                        title: 'Gratitude',
                        subtitle: 'Three good things',
                        badge: '2 min',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const GratitudeScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
