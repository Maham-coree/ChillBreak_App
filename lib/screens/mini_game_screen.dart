import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/app_data.dart';
import '../widgets/gradient_button.dart';

class _Bubble {
  final int id;
  final Offset position;
  final double size;
  final Color color;
  _Bubble({
    required this.id,
    required this.position,
    required this.size,
    required this.color,
  });
}

class MiniGameScreen extends StatefulWidget {
  const MiniGameScreen({super.key});

  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen> {
  static const int _gameDuration = 30;
  static const List<Color> _bubbleColors = [
    AppColors.purple,
    AppColors.teal,
    AppColors.orange,
    AppColors.gold,
  ];

  final Random _random = Random();
  final List<_Bubble> _bubbles = [];
  int _nextId = 0;
  int _score = 0;
  int _timeLeft = _gameDuration;
  bool _isPlaying = false;
  bool _isGameOver = false;
  Size _boardSize = Size.zero;

  Timer? _spawnTimer;
  Timer? _countdownTimer;

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = _gameDuration;
      _bubbles.clear();
      _isPlaying = true;
      _isGameOver = false;
    });

    _spawnTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      _spawnBubble();
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) _endGame();
    });
  }

  void _spawnBubble() {
    if (!mounted || _boardSize == Size.zero) return;
    final size = 48.0 + _random.nextDouble() * 24;
    final dx = _random.nextDouble() * (_boardSize.width - size).clamp(0, double.infinity);
    final dy = _random.nextDouble() * (_boardSize.height - size).clamp(0, double.infinity);

    final bubble = _Bubble(
      id: _nextId++,
      position: Offset(dx.toDouble(), dy.toDouble()),
      size: size,
      color: _bubbleColors[_random.nextInt(_bubbleColors.length)],
    );

    setState(() => _bubbles.add(bubble));

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _bubbles.removeWhere((b) => b.id == bubble.id));
    });
  }

  void _popBubble(int id) {
    setState(() {
      _bubbles.removeWhere((b) => b.id == id);
      _score += 10;
    });
  }

  void _endGame() {
    _spawnTimer?.cancel();
    _countdownTimer?.cancel();
    AppData.instance.recordActivity();
    if (!mounted) return;
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
      _bubbles.clear();
    });
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text('Mini Game',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoChip(label: 'SCORE', value: '$_score'),
                  _InfoChip(label: 'TIME', value: '${_timeLeft}s'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    _boardSize =
                        Size(constraints.maxWidth, constraints.maxHeight);
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            for (final bubble in _bubbles)
                              Positioned(
                                left: bubble.position.dx,
                                top: bubble.position.dy,
                                child: GestureDetector(
                                  onTap: () => _popBubble(bubble.id),
                                  child: Container(
                                    width: bubble.size,
                                    height: bubble.size,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: bubble.color.withOpacity(0.85),
                                      boxShadow: [
                                        BoxShadow(
                                          color: bubble.color.withOpacity(0.5),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (!_isPlaying && !_isGameOver)
                              const Center(
                                child: Text(
                                  'Tap Start to pop bubbles!',
                                  style: TextStyle(
                                      color: AppColors.textMuted, fontSize: 13),
                                ),
                              ),
                            if (_isGameOver)
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "Time's up! 🎉",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Score: $_score',
                                      style: const TextStyle(
                                          color: AppColors.teal,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                icon: _isPlaying ? null : Icons.play_arrow_rounded,
                label: _isPlaying
                    ? 'Playing...'
                    : (_isGameOver ? 'Play again' : 'Start'),
                onTap: _isPlaying ? () {} : _startGame,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 10, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
