import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../services/app_data.dart';
import '../widgets/gradient_button.dart';

class GratitudeEntry {
  final String date; // e.g. "Aug 2"
  final List<String> items;

  GratitudeEntry({required this.date, required this.items});

  Map<String, dynamic> toJson() => {'date': date, 'items': items};

  factory GratitudeEntry.fromJson(Map<String, dynamic> json) {
    return GratitudeEntry(
      date: json['date'] as String,
      items: List<String>.from(json['items'] as List),
    );
  }
}

class GratitudeScreen extends StatefulWidget {
  const GratitudeScreen({super.key});

  @override
  State<GratitudeScreen> createState() => _GratitudeScreenState();
}

class _GratitudeScreenState extends State<GratitudeScreen> {
  static const _storageKey = 'gratitude_entries';

  final _controllers = List.generate(3, (_) => TextEditingController());
  List<GratitudeEntry> _entries = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    setState(() {
      _entries = raw
          .map((e) => GratitudeEntry.fromJson(jsonDecode(e)))
          .toList()
          .reversed
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _saveEntry() async {
    final items = _controllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (items.isEmpty) return;

    setState(() => _isSaving = true);

    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateLabel = '${months[now.month - 1]} ${now.day}';

    final entry = GratitudeEntry(date: dateLabel, items: items);

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    raw.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_storageKey, raw);

    for (final c in _controllers) {
      c.clear();
    }

    setState(() {
      _entries.insert(0, entry);
      _isSaving = false;
    });

    await AppData.instance.recordActivity();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved 🌿'),
          backgroundColor: AppColors.cardBackground,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text('Gratitude',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.purple))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Three good things today',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Text(
                      'Small or big, write what made today a little better.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    for (int i = 0; i < 3; i++) ...[
                      _GratitudeField(
                        controller: _controllers[i],
                        hint: [
                          'Something that made you smile...',
                          'A person you\'re thankful for...',
                          'A small win today...',
                        ][i],
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 8),
                    GradientButton(
                      icon: Icons.favorite_rounded,
                      label: _isSaving ? 'Saving...' : 'Save entry',
                      onTap: _isSaving ? () {} : _saveEntry,
                    ),
                    const SizedBox(height: 32),
                    if (_entries.isNotEmpty) ...[
                      const Text('Past entries',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      for (final entry in _entries) _EntryCard(entry: entry),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _GratitudeField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _GratitudeField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        maxLines: 2,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final GratitudeEntry entry;
  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.date,
              style: const TextStyle(
                  color: AppColors.teal,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          for (final item in entry.items)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🌿 ', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Text(item,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
