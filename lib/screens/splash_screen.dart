import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'onboarding_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 SplashScreen: initState started');
    // Полноэкранный режим без статус-бара
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    // Инициализация видео
    debugPrint('📹 SplashScreen: Initializing video...');
    _videoController = VideoPlayerController.asset('lib/assets/intro.mp4');
    
    // Резервный таймер: если видео не загрузится за 5 секунд, идем дальше
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_isVideoInitialized) {
        debugPrint('⚠️ SplashScreen: Видео не успело инициализироваться, переходим по таймеру');
        _navigateToNext();
      }
    });

    _videoController.initialize().then((_) {
      debugPrint('📹 SplashScreen: Video initialized successfully');
      if (!mounted) return;
      
      setState(() {
        _isVideoInitialized = true;
      });

      // Запускаем видео
      debugPrint('📹 SplashScreen: Playing video');
      _videoController.play();
      _videoController.setLooping(false);

      // Синхронизируем звук и вибрацию с реальным стартом видео
      _playIntroSound();
      _startVibrationSequence();

      // Отменяем старый резервный таймер и ставим новый на конец видео
      _timer?.cancel();
      final videoDuration = _videoController.value.duration;
      debugPrint('📹 SplashScreen: Video duration is $videoDuration');
      
      _timer = Timer(videoDuration + const Duration(milliseconds: 500), () {
        debugPrint('⏰ SplashScreen: Video finished, navigating...');
        if (mounted) {
          _navigateToNext();
        }
      });
    }).catchError((error) {
      debugPrint('❌ SplashScreen: Ошибка инициализации видео: $error');
      if (mounted) {
        _navigateToNext();
      }
    });
  }

  Future<void> _playIntroSound() async {
    try {
      debugPrint('🎵 SplashScreen: Preparing to play intro sound');
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(AssetSource('audio/airplane_sound.mp3'));
      debugPrint('🎵 SplashScreen: Intro sound playing');
    } catch (e) {
      debugPrint('❌ SplashScreen: Ошибка звука: $e');
    }
  }

  Future<void> _startVibrationSequence() async {
    try {
      debugPrint('📳 SplashScreen: Starting ultra-realistic vibration sequence');
      if (!mounted) return;

      // --- ФАЗА 1: Раскрутка турбин (0 - 1.5 сек) ---
      // Очень быстрые, почти незаметные щелчки (эффект набора оборотов вала)
      for (int i = 0; i < 12; i++) {
        if (!mounted) break;
        HapticFeedback.selectionClick(); 
        await Future.delayed(Duration(milliseconds: 150 - (i * 10)));
      }

      // --- ФАЗА 2: Нагнетание давления (1.5 - 4.0 сек) ---
      // Смесь легких и средних ударов, имитация дрожи корпуса
      for (int i = 0; i < 18; i++) {
        if (!mounted) break;
        if (i % 3 == 0) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.lightImpact();
        }
        await Future.delayed(const Duration(milliseconds: 120));
      }

      // --- ФАЗА 3: ВЗЛЕТ / ФОРСАЖ (4.0 - 7.5 сек) ---
      // Самая мощная фаза. Используем Heavy Impact для ощущения мощи двигателей
      for (int i = 0; i < 45; i++) {
        if (!mounted) break;
        if (i % 4 == 0) {
          HapticFeedback.heavyImpact(); // Мощный толчок
        } else if (i % 2 == 0) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.lightImpact();
        }
        await Future.delayed(const Duration(milliseconds: 70));
      }

      // --- ФАЗА 4: ОТРЫВ И УХОД В НЕБО (7.5 - 9.4 сек) ---
      // Постепенное затухание, переход в мягкое гудение
      for (int i = 0; i < 10; i++) {
        if (!mounted) break;
        HapticFeedback.lightImpact();
        await Future.delayed(Duration(milliseconds: 100 + (i * 40)));
      }

      debugPrint('📳 SplashScreen: Ultra-realistic vibration sequence finished');
    } catch (e) {
      debugPrint('❌ SplashScreen: Vibration error: $e');
    }
  }

  Future<void> _navigateToNext() async {
    debugPrint('➡️ SplashScreen: _navigateToNext called');
    // Возвращаем системные элементы интерфейса перед уходом со сплэша
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    if (!mounted) return;

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final apiService = ApiService(); // Or get from provider if available
      
      // Check if we have a token
      final hasToken = await userProvider.checkAuth();
      
      if (hasToken) {
         // Передаем токен в ApiService
         apiService.setAuthToken(userProvider.authToken);

         // Refresh user info
         try {
           final userInfo = await apiService.getMe();
           userProvider.setUserInfo(userInfo);
           
           if (!mounted) return;
           debugPrint('➡️ SplashScreen: User logged in, pushing MainScreen');
           Navigator.of(context).pushReplacement(
             MaterialPageRoute(
               builder: (context) => const MainScreen(),
             ),
           );
           return;
         } catch (e) {
           debugPrint('❌ SplashScreen: Failed to refresh user info, forcing logout: $e');
           userProvider.clearUser();
         }
      }
    } catch (e) {
       debugPrint('❌ SplashScreen: Auth check failed: $e');
    }
    
    if (mounted) {
      debugPrint('➡️ SplashScreen: Not logged in, pushing OnboardingScreen');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: SizedBox.expand(
        child: _isVideoInitialized
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFD700),
                ),
              ),
      ),
    );
  }
}