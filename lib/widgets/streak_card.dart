import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StreakCard extends StatelessWidget {
  final int currentStreak;
  final int bestStreak;
  final List<bool> weekActive; // exactly 7 items, Mon -> Sun

  const StreakCard({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
    required this.weekActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.purpleTealGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text('🔥', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CURRENT STREAK',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Best',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 11)),
                        Text('${bestStreak}d',
                            style: const TextStyle(
                                color: AppColors.teal,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                      ],
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('$currentStreak',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    const Text('days',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(7, (i) {
                    final active = weekActive[i];
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active
                              ? AppColors.teal
                              : AppColors.textMuted.withOpacity(0.25),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
