import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/app_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context) async {
    final controller = TextEditingController(text: AppData.instance.userName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Your name',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: AppColors.textMuted),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.cardBorder)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.purple)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child:
                const Text('Save', style: TextStyle(color: AppColors.teal)),
          ),
        ],
      ),
    );
    if (result != null) {
      await AppData.instance.setName(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppData.instance,
      builder: (context, _) {
        final data = AppData.instance;
        final streak = data.currentStreak;
        final sessions = data.totalSessions;

        final badges = [
          _BadgeData(
              emoji: '🔥', label: '14-day streak', unlocked: streak >= 14),
          _BadgeData(
              emoji: '🧘', label: '50 sessions', unlocked: sessions >= 50),
          _BadgeData(emoji: '💤', label: 'Breath master', unlocked: false),
          _BadgeData(emoji: '📖', label: '7-day journal', unlocked: false),
          _BadgeData(
              emoji: '⭐', label: '21-day streak', unlocked: streak >= 21),
          _BadgeData(emoji: '🌙', label: 'Night owl', unlocked: false),
        ];
        final badgeCount = badges.where((b) => b.unlocked).length;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              children: [
                const Text('Profile',
                    style: TextStyle(
                        color: AppColors.purple,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 20),
                Container(
                  width: 84,
                  height: 84,
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.purpleTealGradient,
                  ),
                  child: const CircleAvatar(
                    backgroundColor: AppColors.cardBackground,
                    child: Icon(Icons.person, color: Colors.white, size: 36),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _editName(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(data.userName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 6),
                      const Icon(Icons.edit_rounded,
                          color: AppColors.textMuted, size: 15),
                    ],
                  ),
                ),
                const Text('Keep up the great work 🌿',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ProfileStat(value: '$sessions', label: 'Sessions'),
                    _ProfileStat(value: '$streak', label: 'Streak'),
                    _ProfileStat(value: '$badgeCount', label: 'Badges'),
                  ],
                ),
                const SizedBox(height: 28),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Achievements',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                  children:
                      badges.map((b) => _Badge(data: b)).toList(),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Breath master, 7-day journal aur Night owl abhi demo hain — inhe bhi real data se jodna agla step ho sakta hai.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                const SizedBox(height: 28),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Preferences',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),
                const _PreferenceTile(
                    emoji: '🔔',
                    title: 'Notifications',
                    subtitle: 'Daily at 3 PM'),
                const SizedBox(height: 10),
                const _PreferenceTile(
                    emoji: '⏰',
                    title: 'Break reminders',
                    subtitle: 'Every 45 min'),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BadgeData {
  final String emoji;
  final String label;
  final bool unlocked;
  const _BadgeData(
      {required this.emoji, required this.label, required this.unlocked});
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: AppColors.purple,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final _BadgeData data;
  const _Badge({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: data.unlocked ? 1 : 0.3,
            child: Text(data.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 6),
          Text(data.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color:
                      data.unlocked ? Colors.white70 : AppColors.textMuted,
                  fontSize: 10)),
          const SizedBox(height: 4),
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.unlocked ? AppColors.teal : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _PreferenceTile(
      {required this.emoji, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
