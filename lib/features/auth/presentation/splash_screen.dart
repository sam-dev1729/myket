import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/presentation/profile_controller.dart';
import 'auth_controller.dart';

/// The Splash screen shown on app startup.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  // انیمیشن موج (فقط حالت رفت - بزرگ شدن)
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // پالت رنگی
  final Color _centerColor = const Color(0xFF2E7D32); // سبز زمردی
  final Color _edgeColor = const Color(0xFF06120C); // سبز تقریباً سیاه (لجنی)
  final Color _goldColor = const Color(0xFFFFD700); // طلایی برای متن

  @override
  void initState() {
    super.initState();

    // 1. تنظیم انیمیشن موج (بدون reverse)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // زمان بزرگ شدن دایره
    );

    // شعاع از 0 شروع شده و تا 1.2 بزرگ می‌شود
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));

    // 👈 فقط یک بار به جلو (رفت) حرکت می‌کند و در همان حالت می‌ماند
    _pulseController.forward();

    _navigateAfterDelay();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: AppConstants.splashDelaySeconds));

    if (!mounted) return;

    final isLoggedIn = await ref.read(authControllerProvider.notifier).isLoggedIn();

    if (!mounted) return;

    if (!isLoggedIn) {
      context.go(AppConstants.loginRoute);
      return;
    }

    try {
      await ref
          .refresh(profileControllerProvider.future)
          .timeout(const Duration(seconds: AppConstants.splashTimeoutSeconds));
      if (!mounted) return;
      context.go(AppConstants.mainRoute);
    } on DioException catch (e) {
      if (!mounted) return;
      final apiError = e.error as ApiException?;
      if (apiError?.type == ApiErrorType.timeout ||
          apiError?.type == ApiErrorType.noInternet ||
          apiError?.type == ApiErrorType.unknown) {
        context.go(AppConstants.mainRoute);
      } else {
        context.go(AppConstants.loginRoute);
      }
    } catch (_) {
      if (!mounted) return;
      context.go(AppConstants.loginRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _edgeColor,
      body: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: _pulseAnimation.value,
                colors: [_centerColor, _edgeColor],
                stops: const [0.0, 1.0],
              ),
            ),
            // 👇 استفاده از TweenAnimationBuilder برای تغییر رنگ متن
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(
                begin: Colors.white, // شروع از سفید
                end: _goldColor, // پایان با طلایی
              ),
              duration: const Duration(seconds: 3), // همگام با باز شدن موج
              curve: Curves.easeInOut,
              builder: (context, color, _) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.biotech, color: color, size: 100),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Text(
                        l10n.appName,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w300,
                          color: color, // 👈 رنگ داینامیک
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
