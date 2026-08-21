import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/app_data.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppData.instance,
      builder: (context, _) {
        final data = AppData.instance;
        final week = data.thisWeekActivity;
        const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final todayIndex = DateTime.now().weekday - 1; // 0 = Mon
        final activeDaysThisWeek = week.where((a) => a).length;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text('Progress',
                      style: TextStyle(
                          color: AppColors.purple,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                ),
                const SizedBox(height: 12),
                const Text('Your progress',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
                const Text('Keep building the habit 🌱',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        emoji: '🔥',
                        label: 'DAY STREAK',
                        value: '${data.currentStreak}',
                        unit: 'days',
                        valueColor: AppColors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        emoji: '🧘',
                        label: 'SESSIONS',
                        value: '${data.totalSessions}',
                        unit: 'total',
                        valueColor: AppColors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        emoji: '💨',
                        label: 'BREATHING',
                        value: data.breathingHours.toStringAsFixed(1),
                        unit: 'hrs',
                        valueColor: AppColors.teal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        emoji: '⭐',
                        label: 'BEST STREAK',
                        value: '${data.bestStreak}',
                        unit: 'days',
                        valueColor: AppColors.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('This week',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (i) {
                          return _DayBar(
                            label: dayLabels[i],
                            active: week[i],
                            isToday: i == todayIndex,
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Active days: $activeDaysThisWeek/7',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                          Text('Current streak: ${data.currentStreak}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Har din jab tum koi bhi activity karogi (mood log, breathing, gratitude, etc), wo din yahan active ho jayega.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_monthLabel(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                          const Row(
                            children: [
                              Icon(Icons.circle,
                                  color: AppColors.teal, size: 8),
                              SizedBox(width: 4),
                              Text('Active',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11)),
                              SizedBox(width: 10),
                              Icon(Icons.circle,
                                  color: AppColors.textMuted, size: 8),
                              SizedBox(width: 4),
                              Text('No activity',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const _MiniCalendar(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _monthLabel() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.year}';
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final String unit;
  final Color valueColor;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.unit,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: TextStyle(
                      color: valueColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              Text(unit,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  final String label;
  final bool active;
  final bool isToday;

  const _DayBar(
      {required this.label, required this.active, required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 18,
          height: active ? 48 : 16,
          decoration: BoxDecoration(
            color: active ? AppColors.teal : AppColors.purple.withOpacity(0.25),
            borderRadius: BorderRadius.circular(6),
            border: isToday
                ? Border.all(color: Colors.white.withOpacity(0.6), width: 1.2)
                : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                color: isToday ? Colors.white : AppColors.textMuted,
                fontSize: 10,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400)),
      ],
    );
  }
}

class _MiniCalendar extends StatelessWidget {
  const _MiniCalendar();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final sessionDays = AppData.instance.activeDaysInMonth(now);
    const weekLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    // Dart weekday: Mon=1..Sun=7 → convert so Sunday=0 (matches weekLabels).
    final startOffset = firstDayOfMonth.weekday % 7;
    final totalDays = DateTime(now.year, now.month + 1, 0).day;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekLabels
              .map((l) => Text(l,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11)))
              .toList(),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: startOffset + totalDays,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 4,
          ),
          itemBuilder: (context, index) {
            final day = index - startOffset + 1;
            if (day < 1) return const SizedBox.shrink();
            final hasSession = sessionDays.contains(day);
            final isToday = day == now.day;
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasSession
                    ? AppColors.teal.withOpacity(0.25)
                    : Colors.transparent,
                border: isToday
                    ? Border.all(color: AppColors.purple, width: 1.2)
                    : null,
              ),
              child: Text('$day',
                  style: TextStyle(
                      color: hasSession ? AppColors.teal : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight:
                          hasSession ? FontWeight.w600 : FontWeight.w400)),
            );
          },
        ),
      ],
    );
  }
}
