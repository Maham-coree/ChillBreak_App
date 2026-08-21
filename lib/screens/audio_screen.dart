import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';
import '../data/motivational_audio_lines.dart';
import '../services/app_data.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _isUrdu = false;
  int _index = 0;
  bool _isSpeaking = false;

  List<String> get _lines => _isUrdu ? urduAffirmations : englishAffirmations;

  @override
  void initState() {
    super.initState();
    _tts.setSpeechRate(0.42); // slower, calmer pace
    _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _tts.setErrorHandler((msg) {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speakCurrent() async {
    final langCode = _isUrdu ? 'ur-PK' : 'en-US';

    bool available = true;
    try {
      final result = await _tts.isLanguageAvailable(langCode);
      available = result == true || result == 1;
    } catch (_) {
      available = true;
    }

    // Try to speak regardless of availability — most TTS engines will
    // still attempt the text with the closest voice they have instead of
    // staying silent, even if pronunciation isn't perfect.
    await _tts.setLanguage(langCode);
    if (!mounted) return;
    setState(() => _isSpeaking = true);
    await _tts.speak(_lines[_index]);
    AppData.instance.recordActivity();

    if (!available && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Native Urdu awaaz is phone mein installed nahi hai, isliye '
            'default awaaz se padha ja raha hai. Behtar pronunciation ke '
            'liye Settings > Language > Text-to-Speech mein Urdu voice '
            'download kar sakti ho.',
          ),
          backgroundColor: AppColors.cardBackground,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _stop() async {
    await _tts.stop();
    setState(() => _isSpeaking = false);
  }

  void _next() {
    _stop();
    setState(() => _index = (_index + 1) % _lines.length);
  }

  void _switchLanguage(bool urdu) {
    if (_isUrdu == urdu) return;
    _stop();
    setState(() {
      _isUrdu = urdu;
      _index = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text('Motivational Audio',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              // Language toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    _LangTab(
                      label: 'English',
                      selected: !_isUrdu,
                      onTap: () => _switchLanguage(false),
                    ),
                    _LangTab(
                      label: 'اردو',
                      selected: _isUrdu,
                      onTap: () => _switchLanguage(true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 320),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: AppColors.purpleTealGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isSpeaking
                                ? Icons.graphic_eq_rounded
                                : Icons.headphones_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _lines[_index],
                            key: ValueKey('$_isUrdu-$_index'),
                            textAlign: TextAlign.center,
                            textDirection: _isUrdu
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: _isUrdu ? 20 : 18,
                              fontWeight: FontWeight.w600,
                              height: 1.7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_isSpeaking)
                          const Text('Speaking…',
                              style: TextStyle(
                                  color: AppColors.teal, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.skip_next_rounded,
                          color: AppColors.textSecondary),
                      onPressed: _next,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      icon: _isSpeaking
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded,
                      label: _isSpeaking ? 'Stop' : 'Play',
                      onTap: _isSpeaking ? _stop : _speakCurrent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Uses your phone\'s built-in voice — works fully offline.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangTab(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.purpleTealGradient : null,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textMuted,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
