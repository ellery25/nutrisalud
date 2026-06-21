import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/assets.dart';
import '../../../core/themes/app_spacing.dart';
import '../data/onboarding_state.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.asset,
    required this.title,
    required this.body,
  });

  final String asset;
  final String title;
  final String body;
}

const _pages = <_OnboardingPage>[
  _OnboardingPage(
    asset: AppAssets.introFoods,
    title: "Discover meals you'll love",
    body: 'Search thousands of recipes, filter by ingredient or category, '
        'and save your favorites.',
  ),
  _OnboardingPage(
    asset: AppAssets.introCommunity,
    title: 'Track how food makes you feel',
    body: 'Keep a food & symptom journal, set nutrition goals and build '
        'healthy streaks.',
  ),
  _OnboardingPage(
    asset: AppAssets.introDoctor,
    title: 'Learn from trusted sources',
    body: 'Evidence-based guides on digestive health, gut wellness and '
        'everyday nutrition.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Router redirect reacts to onboardingDoneProvider; no manual navigation.
  Future<void> _complete() =>
      ref.read(onboardingDoneProvider.notifier).complete();

  void _next() {
    if (_isLastPage) {
      _complete();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: TextButton(
                      onPressed: _complete,
                      child: const Text('Skip'),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) =>
                        _PageContent(page: _pages[index]),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _pages.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs),
                        width: i == _currentPage ? AppSpacing.lg : AppSpacing.sm,
                        height: AppSpacing.sm,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _next,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                        child: Text(_isLastPage ? 'Get started' : 'Next'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Expanded(
            child: Image.asset(
              page.asset,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.image_not_supported_outlined,
                size: 96,
                color: colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
