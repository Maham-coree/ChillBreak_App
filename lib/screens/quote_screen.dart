import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';
import '../data/motivational_lines.dart';
import '../services/app_data.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  late int _index;
  final Set<int> _favorites = {};
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _index = _random.nextInt(motivationalLines.length);
    AppData.instance.recordActivity();
  }

  void _nextQuote() {
    setState(() {
      int next;
      do {
        next = _random.nextInt(motivationalLines.length);
      } while (next == _index && motivationalLines.length > 1);
      _index = next;
    });
  }

  void _toggleFavorite() {
    setState(() {
      if (_favorites.contains(_index)) {
        _favorites.remove(_index);
      } else {
        _favorites.add(_index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = _favorites.contains(_index);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Daily Quote',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? AppColors.orange : AppColors.textMuted,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: AppColors.purpleTealGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.format_quote_rounded,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            motivationalLines[_index],
                            key: ValueKey(_index),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GradientButton(
                icon: Icons.refresh_rounded,
                label: 'New quote',
                onTap: _nextQuote,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
