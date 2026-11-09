import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/session_expired_provider.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/providers/dark_mode_provider.dart';
import 'features/settings/presentation/providers/language_provider.dart';
import 'l10n/app_localizations.dart';

/// Application entry point.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MedicMetaverseApp()));
}

/// Root widget of the application.
class MedicMetaverseApp extends ConsumerStatefulWidget {
  /// Creates a [MedicMetaverseApp] instance.
  const MedicMetaverseApp({super.key});

  /// Creates the mutable state for this widget.
  @override
  ConsumerState<MedicMetaverseApp> createState() => _MedicMetaverseAppState();
}

/// Mutable state for [MedicMetaverseApp] that manages deep links.
class _MedicMetaverseAppState extends ConsumerState<MedicMetaverseApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  /// Initializes deep-link handling for both cold and warm starts.
  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _handleDeepLink(initial);
    } catch (_) {}
    _linkSub = _appLinks.uriLinkStream.listen(_handleDeepLink, onError: (_) {});
  }

  /// Parses [uri] and navigates to the corresponding in-app route if it
  /// matches the payment deep link scheme.
  void _handleDeepLink(Uri uri) {
    if (uri.scheme != AppConstants.deepLinkScheme) return;
    if (uri.host != AppConstants.deepLinkPaymentHost) return;

    String? status;
    if (uri.pathSegments.length == 1) {
      status = uri.pathSegments.first;
    } else if (uri.pathSegments.length == 2 &&
        uri.pathSegments.first == AppConstants.deepLinkStatusSegment) {
      status = uri.pathSegments[1];
    }

    if (status != null && status.isNotEmpty) {
      final path = AppConstants.paymentStatusRouteTemplate.replaceFirst(':status', status);
      appRouter.go(path);
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  /// Builds the app shell.
  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(sessionExpiredProvider, (previous, next) {
      if (next == true) {
        ref.read(sessionExpiredProvider.notifier).reset();
        final currentPath = appRouter.routerDelegate.currentConfiguration.uri.path;
        if (currentPath != AppConstants.splashRoute && currentPath != AppConstants.loginRoute) {
          appRouter.go(AppConstants.loginRoute);
        }
      }
    });

    final isDarkMode = ref.watch(isDarkModeProvider);
    final locale = ref.watch(currentLocaleProvider);

    return MaterialApp.router(
      title: 'Medic Metaverse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fa', 'IR'), Locale('en', 'US'), Locale('ar', 'SA')],
      locale: locale,
    );
  }
}
