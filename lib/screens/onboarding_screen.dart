import 'package:flutter/material.dart';
import '../models/onboarding_item.dart';
import '../widgets/language_selector.dart';
import '../widgets/onboarding_icon.dart';
import '../utils/localization_helper.dart';
import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  late PageController _pageController;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      iconType: OnboardingIconType.airplane,
      titleRu: 'Добро пожаловать в AbuExpress',
      titleEn: 'Welcome to AbuExpress',
      titleUz: 'AbuExpress\'ga xush kelibsiz',
      descriptionRu: 'Быстрая международная доставка посылок с отслеживанием в реальном времени',
      descriptionEn: 'Fast international parcel delivery with real-time tracking',
      descriptionUz: 'Real vaqtda kuzatuv bilan tez xalqaro yuk tashish',
    ),
    OnboardingItem(
      iconType: OnboardingIconType.box,
      titleRu: 'Отслеживайте посылки',
      titleEn: 'Track packages',
      titleUz: 'Yuklamalarni kuzatib boring',
      descriptionRu: 'Следите за статусом ваших посылок от отправки до получения',
      descriptionEn: 'Monitor the status of your packages from dispatch to receipt',
      descriptionUz: 'Yuklamalaringiz holatini yuborishdan qabul qilishgacha kuzatib boring',
    ),
    OnboardingItem(
      iconType: OnboardingIconType.shoppingBag,
      titleRu: 'Покупайте онлайн',
      titleEn: 'Shop online',
      titleUz: 'Onlayn xarid qiling',
      descriptionRu: 'Заказывайте товары из нашего магазина с доставкой до двери',
      descriptionEn: 'Order goods from our store with door-to-door delivery',
      descriptionUz: 'Do\'konimizdan eshikdan eshigacha yetkazib berish bilan mahsulotlar buyurtma qiling',
    ),
    OnboardingItem(
      iconType: OnboardingIconType.globe,
      titleRu: 'Глобальная сеть',
      titleEn: 'Global network',
      titleUz: 'Global tarmoq',
      descriptionRu: 'Офисы по всему миру для вашего удобства',
      descriptionEn: 'Offices worldwide for your convenience',
      descriptionUz: 'Qulayligingiz uchun butun dunyo bo\'ylab ofislar',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to main app
      _skipOnboarding();
    }
  }

  void _skipOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _onboardingItems.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _skipOnboarding,
                    child: Text(
                      context.l10n.translate('skip'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const LanguageSelector(),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingItems.length,
                itemBuilder: (context, index) {
                  final item = _onboardingItems[index];
                  return _buildOnboardingPage(item);
                },
              ),
            ),

            // Pagination dots
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingItems.length,
                  (index) => _buildPaginationDot(index == _currentPage),
                ),
              ),
            ),

            // Next/Start button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: _buildActionButton(isLastPage),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OnboardingIcon(iconType: item.iconType),
          const SizedBox(height: 60),
          Text(
            _getOnboardingTitle(item.iconType),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _getOnboardingDescription(item.iconType),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFFD700) : const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  String _getOnboardingTitle(OnboardingIconType iconType) {
    switch (iconType) {
      case OnboardingIconType.airplane:
        return context.l10n.translate('onboarding_title_1');
      case OnboardingIconType.box:
        return context.l10n.translate('onboarding_title_2');
      case OnboardingIconType.shoppingBag:
        return context.l10n.translate('onboarding_title_3');
      case OnboardingIconType.globe:
        return context.l10n.translate('onboarding_title_4');
    }
  }

  String _getOnboardingDescription(OnboardingIconType iconType) {
    switch (iconType) {
      case OnboardingIconType.airplane:
        return context.l10n.translate('onboarding_description_1');
      case OnboardingIconType.box:
        return context.l10n.translate('onboarding_description_2');
      case OnboardingIconType.shoppingBag:
        return context.l10n.translate('onboarding_description_3');
      case OnboardingIconType.globe:
        return context.l10n.translate('onboarding_description_4');
    }
  }

  Widget _buildActionButton(bool isLastPage) {
    final buttonText = isLastPage
        ? context.l10n.translate('start')
        : context.l10n.translate('next');

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _nextPage,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  buttonText,
                  style: const TextStyle(
                    color: Color(0xFF0A0E27),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward,
                  color: Color(0xFF0A0E27),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

