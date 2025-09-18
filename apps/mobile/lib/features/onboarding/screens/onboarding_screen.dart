import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../ui/components/shad/shad_components.dart';
import '../../../ui/responsive/responsive_builder.dart';
import '../../../ui/theme/shadcn_theme_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../categories/providers/category_provider.dart';
import '../models/onboarding_step.dart';

/// Provider for onboarding completion status
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_completed') ?? false;
});

/// Onboarding screen for first-time users
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
          _isLastPage = page == DefaultOnboardingSteps.steps.length - 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? ReceiptColors.backgroundDark : ReceiptColors.background,
      body: SafeArea(
        child: ResponsiveBuilder(
          mobile: _buildMobileLayout(),
          tablet: _buildTabletLayout(),
          desktop: _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildSkipButton(),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: DefaultOnboardingSteps.steps.length,
            itemBuilder: (context, index) {
              return _buildOnboardingPage(DefaultOnboardingSteps.steps[index]);
            },
          ),
        ),
        _buildBottomControls(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildSkipButton(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: DefaultOnboardingSteps.steps.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(DefaultOnboardingSteps.steps[index]);
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildProgressIndicator(),
              const SizedBox(height: 32),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: _buildMobileLayout(),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AppTextButton(
          onPressed: _skipOnboarding,
          child: const Text('Skip'),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingStep step) {
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: (step.color ?? ReceiptColors.primary).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              step.icon,
              size: 60,
              color: step.color ?? ReceiptColors.primary,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            step.title,
            style: TextStyle(
              fontSize: Responsive.value(
                context,
                mobile: 24,
                tablet: 28,
                desktop: 32,
              ),
              fontWeight: FontWeight.bold,
              color: isDark ? ReceiptColors.textPrimaryDark : ReceiptColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            step.description,
            style: TextStyle(
              fontSize: Responsive.value(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
              color: isDark ? ReceiptColors.textSecondaryDark : ReceiptColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (step.customWidget != null) ...[
            const SizedBox(height: 32),
            step.customWidget!,
          ],
          // Special content for the last page
          if (_isLastPage) ...[
            const SizedBox(height: 32),
            _buildSetupOptions(),
          ],
        ],
      ),
    );
  }

  Widget _buildSetupOptions() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Setup (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: true,
            onChanged: null,
            title: const Text('Create default categories'),
            subtitle: const Text('Business Meals, Travel, Office Supplies, etc.'),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
          CheckboxListTile(
            value: true,
            onChanged: null,
            title: const Text('Enable smart OCR'),
            subtitle: const Text('Automatically extract text from receipts'),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
          CheckboxListTile(
            value: false,
            onChanged: (value) {},
            title: const Text('Enable cloud backup'),
            subtitle: const Text('Sync across devices (requires account)'),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildProgressIndicator(),
          const SizedBox(height: 24),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        DefaultOnboardingSteps.steps.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? ReceiptColors.primary
                : ReceiptColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentPage > 0)
          AppOutlineButton(
            onPressed: _previousPage,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, size: 18),
                SizedBox(width: 8),
                Text('Previous'),
              ],
            ),
          )
        else
          const SizedBox(width: 100),
        const Spacer(),
        AppButton(
          onPressed: _isLastPage ? _completeOnboarding : _nextPage,
          size: ShadButtonSize.lg,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isLastPage ? 'Get Started' : 'Next',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 8),
              Icon(
                _isLastPage ? Icons.check : Icons.arrow_forward,
                size: 18,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    // Mark onboarding as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    // Create default categories
    await ref.read(categoryManagementProvider.notifier).createDefaultCategories();

    // Navigate to login or home
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Future<void> _skipOnboarding() async {
    final shouldSkip = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Onboarding?'),
        content: const Text(
          'You can always access these features from settings. Continue without setup?'
        ),
        actions: [
          AppTextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          AppButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Skip'),
          ),
        ],
      ),
    );

    if (shouldSkip == true) {
      await _completeOnboarding();
    }
  }
}

/// Widget to check if onboarding should be shown
class OnboardingWrapper extends ConsumerWidget {
  final Widget child;

  const OnboardingWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);

    return onboardingCompleted.when(
      data: (completed) {
        if (!completed) {
          return const OnboardingScreen();
        }
        return child;
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => child,
    );
  }
}