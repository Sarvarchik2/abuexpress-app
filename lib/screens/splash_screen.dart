import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _hasPlayedSound = false;

  @override
  void initState() {
    super.initState();
    _playSoundAndVibrate();
    
    // Переходим на экран онбординга после завершения GIF (увеличено время для полного проигрывания)
    _timer = Timer(const Duration(milliseconds: 8000), () {
      if (mounted) {
        _audioPlayer.dispose();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen(),
          ),
        );
      }
    });
  }

  Future<void> _playSoundAndVibrate() async {
    try {
      // Вибрация когда самолет пролетает (примерно через 2-3 секунды после начала)
      Timer(const Duration(milliseconds: 2500), () async {
        if (mounted) {
          try {
            // Используем встроенную вибрацию Flutter
            HapticFeedback.mediumImpact();
            debugPrint('Haptic feedback triggered');
          } catch (e) {
            debugPrint('Vibration error: $e');
          }
        }
      });

      // Воспроизводим звук самолета сразу при запуске
      if (!_hasPlayedSound) {
        _hasPlayedSound = true;
        // Небольшая задержка для инициализации
        await Future.delayed(const Duration(milliseconds: 100));
        try {
          // Пытаемся воспроизвести звук из assets
          debugPrint('🎵 Attempting to play audio: audio/airplane_sound.mp3');
          
          // Устанавливаем громкость
          await _audioPlayer.setVolume(1.0);
          
          // Воспроизводим звук
          await _audioPlayer.play(AssetSource('audio/airplane_sound.mp3'));
          debugPrint('🎵 Audio playback started successfully');
        } catch (e, stackTrace) {
          // Если файл не найден или ошибка воспроизведения
          debugPrint('❌ Audio playback error: $e');
          debugPrint('❌ Stack trace: $stackTrace');
          // В симуляторе может не работать, это нормально
        }
      }
    } catch (e) {
      debugPrint('Error in _playSoundAndVibrate: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Center(
        child: Image.asset(
          'lib/assets/intro.gif',
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
