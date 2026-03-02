import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munturai/core/app_export.dart';
import 'package:munturai/screens/presentation.dart';
import 'package:munturai/screens/home.dart';
import 'package:munturai/features/auth/presentation/providers/auth_provider.dart';

class SplashscreenScreen extends ConsumerStatefulWidget {
  const SplashscreenScreen({super.key});

  @override
  ConsumerState<SplashscreenScreen> createState() => Animated();
}

class Animated extends ConsumerState<SplashscreenScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    loadNext();
  }

  void loadNext() {
    Timer(const Duration(seconds: 3), () async {
      try {
        // Checking authentication state via Riverpod
        final user = await ref.read(authStateProvider.future);

        if (!mounted) return;

        if (user != null) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => PresentationScreen()));
        }
      } catch (e) {
        // If profile fetch fails or there is no local token
        if (!mounted) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => PresentationScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Center(
            child: Image.asset(
              ImageConstant.logo_white,
              height: 250,
              width: 250,
            ),
          ),
        ));
  }
}
