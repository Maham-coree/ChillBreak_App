import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/app_data.dart';
import '../widgets/gradient_button.dart';

class _Phase {
  final String label;
  final int seconds;
  const _Phase(this.label, this.seconds);
}

const List<_Phase> _phases = [
  _Phase('Inhale', 4),
  _Phase('Hold', 7),
  _Phase('Exhale', 8),
  _Phase('Hold', 1),
];

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  int _phaseIndex = 0;
  int _secondsInPhase = 0;
  int _totalSeconds = 0;
  int _cycles = 0;
  bool _isRunning = false;

  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Single persistent ticker — only advances state while _isRunning is true.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _tick() {
    if (!_isRunning || !mounted) return;
    setState(() {
      _secondsInPhase++;
      _totalSeconds++;
      if (_secondsInPhase >= _phases[_phaseIndex].seconds) {
        _secondsInPhase = 0;
        _phaseIndex = (_phaseIndex + 1) % _phases.length;
        if (_phaseIndex == 0) {
          _cycles++;
          AppData.instance.recordActivity();
        }
      }
    });
    AppData.instance.addBreathingSeconds(1);
  }

  void _toggleRunning() {
    setState(() => _isRunning = !_isRunning);
  }

  void _reset() {
    setState(() {
      _isRunning = false;
      _phaseIndex = 0;
      _secondsInPhase = 0;
      _totalSeconds = 0;
      _cycles = 0;
    });
  }

  double _currentScale() {
    final phase = _phases[_phaseIndex];
    final progress = (_secondsInPhase / phase.seconds).clamp(0.0, 1.0);
    switch (_phaseIndex) {
      case 0: // Inhale: grow
        return 0.85 + (1.15 - 0.85) * progress;
      case 1: // Hold after inhale: stay big
        return 1.15;
      case 2: // Exhale: shrink
        return 1.15 - (1.15 - 0.85) * progress;
      default: // Hold after exhale: stay small
        return 0.85;
    }
  }

  String get _circleLabel {
    if (_totalSeconds == 0 && !_isRunning) return 'Ready';
    return _phases[_phaseIndex].label;
  }

  String get _durationLabel {
    final m = (_totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _buttonLabel {
    if (_isRunning) return 'Pause';
    if (_totalSeconds > 0) return 'Resume';
    return 'Start breathing';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        // No explicit `leading` — Flutter shows a back arrow automatically
        // when this screen is pushed (from Home), and hides it when it's
        // shown as the Relax tab (no route to pop).
        title: const Text('Breathing',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              const Text('Relax',
                  style: TextStyle(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              const SizedBox(height: 8),
              const Text('4-7-8 Breathing',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
            const Text('A calming technique to reduce anxiety',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 40),
            AnimatedScale(
              scale: _currentScale(),
              duration: const Duration(milliseconds: 950),
              curve: Curves.easeInOut,
              child: Container(
                width: 220,
                height: 220,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.purple.withOpacity(0.3), width: 2),
                ),
                child: Container(
                  width: 160,
                  height: 160,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.purple.withOpacity(0.5),
                        AppColors.purple.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Text(
                    _circleLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PhaseTick(label: '4s', active: _isRunning && _phaseIndex == 0),
                _PhaseTick(label: '7s', active: _isRunning && _phaseIndex == 1),
                _PhaseTick(label: '8s', active: _isRunning && _phaseIndex == 2),
                _PhaseTick(label: '1s', active: _isRunning && _phaseIndex == 3),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                    child: _StatBox(label: 'DURATION', value: _durationLabel)),
                const SizedBox(width: 10),
                Expanded(child: _StatBox(label: 'CYCLES', value: '$_cycles')),
                const SizedBox(width: 10),
                Expanded(
                    child: _StatBox(
                        label: 'PHASE', value: _phases[_phaseIndex].label)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: _reset,
                  child: Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Icon(Icons.replay_rounded,
                        color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientButton(
                    icon: _isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    label: _buttonLabel,
                    onTap: _toggleRunning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Breathe in for 4s, hold for 7s, exhale for 8s, hold for 1s.\nThe circle grows and shrinks with your breath.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _PhaseTick extends StatelessWidget {
  final String label;
  final bool active;
  const _PhaseTick({required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 3,
          decoration: BoxDecoration(
            color: active ? AppColors.teal : AppColors.cardBorder,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                color: active ? AppColors.teal : AppColors.textMuted,
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
