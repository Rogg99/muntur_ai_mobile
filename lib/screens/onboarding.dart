import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import 'package:munturai/screens/register.dart';
import '../widgets/primary_button.dart';
import 'login.dart';

class _OnboardingStep {
  final String image;
  final String title;
  final String body;
  const _OnboardingStep({
    required this.image,
    required this.title,
    required this.body,
  });
}

// Built per-build from AppLocalizations rather than as a static/const list,
// since the copy must follow the app's current locale (see @onboarding_*
// keys in lib/l10n/app_en.arb and app_fr.arb).
List<_OnboardingStep> _buildSteps(AppLocalizations translator) => [
      _OnboardingStep(
        image: ImageConstant.onboardingGarage,
        title: translator.onboarding_garage_title,
        body: translator.onboarding_garage_body,
      ),
      _OnboardingStep(
        image: ImageConstant.onboardingChat,
        title: translator.onboarding_chat_title,
        body: translator.onboarding_chat_body,
      ),
      _OnboardingStep(
        image: ImageConstant.onboardingCommunity,
        title: translator.onboarding_community_title,
        body: translator.onboarding_community_body,
      ),
      _OnboardingStep(
        image: ImageConstant.onboardingPremium,
        title: translator.onboarding_premium_title,
        body: translator.onboarding_premium_body,
      ),
    ];

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => OnBoardingState();
}

class OnBoardingState extends State<OnBoarding> {
  final PageController _controller = PageController();
  int pageIndex = 0;
  late List<_OnboardingStep> _steps;

  bool get _isLastStep => pageIndex == _steps.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToSignup() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Signup2()));
  }

  void _next() {
    if (_isLastStep) {
      _goToSignup();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appStyle = AppStyle.of(context);
    final translator = AppLocalizations.of(context)!;
    final photoHeight = MediaQuery.of(context).size.height * 0.6;
    _steps = _buildSteps(translator);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // ── Photo plein cadre, 60% de la hauteur ────────────────────────
          SizedBox(
            width: double.infinity,
            height: photoHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: _steps.length,
                  onPageChanged: (i) => setState(() => pageIndex = i),
                  itemBuilder: (context, i) => Image.asset(
                    _steps[i].image,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 90,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Theme.of(context).colorScheme.background,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  right: 20,
                  child: _isLastStep
                      ? const SizedBox.shrink()
                      : TextButton(
                          onPressed: _goToSignup,
                          child: Text(
                            translator.onboarding_skip,
                            style: appStyle.H6(color: Colors.white),
                          ),
                        ),
                ),
              ],
            ),
          ),

          // ── Texte + contrôles ────────────────────────────────────────────
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < _steps.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: pageIndex == i ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: pageIndex == i
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.25),
                            ),
                          ),
                      ],
                    ),
                    Padding(padding: getPadding(top: 22)),
                    Text(
                      _steps[pageIndex].title,
                      textAlign: TextAlign.center,
                      style: appStyle.H3(
                        weight: 'bold',
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    Padding(padding: getPadding(top: 10)),
                    Text(
                      _steps[pageIndex].body,
                      textAlign: TextAlign.center,
                      style: appStyle.H6(),
                    ),
                    Padding(padding: getPadding(top: 26)),
                    PrimaryButton(
                      text: _isLastStep
                          ? translator.create_account
                          : translator.onboarding_next,
                      onPressed: _next,
                    ),
                    Padding(padding: getPadding(top: 16)),
                    RichText(
                      text: TextSpan(
                        text: translator.already_have_account,
                        style: appStyle.H6(),
                        children: [
                          TextSpan(
                            text: translator.login_here,
                            style: appStyle.H6(
                              color: Theme.of(context).colorScheme.secondary,
                              weight: 'bold',
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Login()),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
