import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/google_phone_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/verification_screen.dart';
import '../../features/financial/presentation/buy_package_screen.dart';
import '../../features/financial/presentation/card_info_screen.dart';
import '../../features/financial/presentation/packages_screen.dart';
import '../../features/financial/presentation/payment_status_screen.dart';
import '../../features/financial/presentation/topup_screen.dart';
import '../../features/financial/presentation/transactions_screen.dart';
import '../../features/lab_test/presentation/analyte_series_screen.dart';
import '../../features/lab_test/presentation/edit_lab_test_screen.dart';
import '../../features/lab_test/presentation/lab_overview_screen.dart';
import '../../features/lab_test/presentation/lab_test_detail_screen.dart';
import '../../features/lab_test/presentation/screens/empty_package_screen.dart';
import '../../features/lab_test/presentation/upload_lab_test_screen.dart';
import '../../features/main/presentation/main_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/financial/presentation/package_history_screen.dart';

import '../../features/blog/presentation/blog_detail_screen.dart';
import '../../features/blog/presentation/blog_list_screen.dart';

import '../../features/profile/presentation/screens/must_fill_profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/support/presentation/support_screen.dart';
import '../../features/profile/presentation/personal_info_screen.dart';
import '../constants/app_constants.dart';

/// Global application router using [GoRouter].
final appRouter = GoRouter(
  initialLocation: AppConstants.splashRoute,
  routes: [
    GoRoute(path: AppConstants.splashRoute, builder: (_, _) => const SplashScreen()),
    GoRoute(path: AppConstants.loginRoute, builder: (_, _) => const LoginScreen()),
    GoRoute(path: AppConstants.googlePhoneRoute, builder: (_, _) => const GooglePhoneScreen()),
    GoRoute(
      path: AppConstants.verificationRoute,
      builder: (_, state) {
        final phone = state.extra as String? ?? '';
        return VerificationScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: AppConstants.signUpRoute,
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final token = extra?[AppConstants.extraKeyToken] as String? ?? '';
        final phone = extra?[AppConstants.extraKeyPhone] as String?;
        return SignUpScreen(registrationToken: token, phoneNumber: phone);
      },
    ),
    GoRoute(path: AppConstants.mainRoute, builder: (_, _) => const MainScreen()),
    GoRoute(path: AppConstants.editProfileRoute, builder: (_, _) => const EditProfileScreen()),
    GoRoute(path: AppConstants.personalInfoRoute, builder: (_, __) => const PersonalInfoScreen()),
    GoRoute(path: AppConstants.uploadLabTestRoute, builder: (_, _) => const UploadLabTestScreen()),
    GoRoute(path: AppConstants.notificationsRoute, builder: (_, _) => const NotificationsScreen()),
    GoRoute(path: AppConstants.supportRoute, builder: (_, _) => const SupportScreen()),
    GoRoute(path: AppConstants.settingsRoute, builder: (_, _) => const SettingsScreen()),

    GoRoute(
      path: AppConstants.blogListRoute,
      builder: (_, _) => const BlogListScreen(),
    ),
    GoRoute(
      path: AppConstants.blogDetailRouteTemplate,
      builder: (_, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return BlogDetailScreen(postId: id);
      },
    ),
    // ─────────────────────────────────────────────────────────
    // Gate routes (MustFillProfile / EmptyPackage)
    // ─────────────────────────────────────────────────────────
    GoRoute(
      path: AppConstants.mustFillProfileRoute,
      builder: (_, state) {
        final nextRoute = state.extra as String?;
        return MustFillProfileScreen(nextRoute: nextRoute);
      },
    ),
    GoRoute(path: AppConstants.emptyPackageRoute, builder: (_, _) => const EmptyPackageScreen()),

    GoRoute(
      path: AppConstants.labTestDetailRouteTemplate,
      builder: (_, state) {
        final id = state.pathParameters['id'] ?? '';
        return LabTestDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: AppConstants.editLabTestRouteTemplate,
      builder: (_, state) {
        final id = state.pathParameters['id'] ?? '';
        return EditLabTestScreen(id: id);
      },
    ),
    GoRoute(path: AppConstants.labOverviewRoute, builder: (_, _) => const LabOverviewScreen()),

    GoRoute(path: AppConstants.analyteSeriesRoute, builder: (_, _) => const AnalyteSeriesScreen()),
    // ─────────────────────────────────────────────────────────
    // Financial routes
    // ─────────────────────────────────────────────────────────
    GoRoute(path: AppConstants.topupRoute, builder: (_, _) => const TopupScreen()),
    GoRoute(path: AppConstants.transactionsRoute, builder: (_, _) => const TransactionsScreen()),
    GoRoute(path: AppConstants.packagesRoute, builder: (_, _) => const PackagesScreen()),
    GoRoute(
      path: AppConstants.buyPackageRoute,
      builder: (_, state) {
        final initialPackageId = state.extra as String?;
        return BuyPackageScreen(initialPackageId: initialPackageId);
      },
    ),
    GoRoute(path: AppConstants.cardInfoRoute, builder: (_, _) => const CardInfoScreen()),
    GoRoute(
      path: AppConstants.packageHistoryRoute,
      builder: (_, _) => const PackageHistoryScreen(),
    ),
    // ─────────────────────────────────────────────────────────
    // Payment status (also reachable via deep link)
    // ─────────────────────────────────────────────────────────
    GoRoute(
      path: AppConstants.paymentStatusRouteTemplate,
      builder: (_, state) {
        final status = state.pathParameters['status'] ?? AppConstants.paymentStatusPending;
        return PaymentStatusScreen(status: status);
      },
    ),
  ],
);
