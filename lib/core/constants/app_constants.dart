/// Centralized constants used throughout the application.
class AppConstants {
  const AppConstants._();

  // ─────────────────────────────────────────────────────────────
  // Navigation Route Names
  // ─────────────────────────────────────────────────────────────

  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String googlePhoneRoute = '/google-phone';
  static const String verificationRoute = '/verification';
  static const String signUpRoute = '/signup';
  static const String mainRoute = '/main';
  static const String editProfileRoute = '/edit-profile';
  static const String uploadLabTestRoute = '/upload-lab-test';
  static const String topupRoute = '/topup';
  static const String transactionsRoute = '/transactions';
  static const String packagesRoute = '/packages';
  static const String buyPackageRoute = '/buy-package';
  static const String paymentStatusRoute = '/payment/status/:status';
  static const String paymentStatusRouteTemplate = '/payment/status/:status';
  static const String notificationsRoute = '/notifications';
  static const String supportRoute = '/support';
  static const String cardInfoRoute = '/card-info';
    static const String packageHistoryRoute = '/package-history';
  static const String settingsRoute = '/settings';
  // ─────────────────────────────────────────────────────────────
  // Gate Route Names (NEW)
  // ─────────────────────────────────────────────────────────────

  static const String mustFillProfileRoute = '/must-fill-profile';
  static const String emptyPackageRoute = '/empty-package';
  static const String personalInfoRoute = '/personal-info';
  // ─────────────────────────────────────────────────────────────
  // Lab Test Detail Route Names (NEW)
  // ─────────────────────────────────────────────────────────────

  static const String labTestDetailRoute = '/lab-test-detail/:id';
  static const String labTestDetailRouteTemplate = '/lab-test-detail/:id';
  static const String labOverviewRoute = '/lab-overview';
  // ─────────────────────────────────────────────────────────────
  // Edit Lab Test Route Names (NEW — PKG-002)
  // ─────────────────────────────────────────────────────────────

  static const String editLabTestRoute = '/edit-lab-test/:id';
  static const String editLabTestRouteTemplate = '/edit-lab-test/:id';
  // ─────────────────────────────────────────────────────────────
  // Series Analytics (NEW)
  // ─────────────────────────────────────────────────────────────

  static const String analyteSeriesRoute = '/analyte-series';

  /// Search debounce for analyzer picker.
  static const Duration searchDebounceDuration = Duration(milliseconds: 300);

  /// Chart-specific dimensions.
  static const double chartHeight = 320.0;
  static const int chartMaxXLabels = 4;
  // ─────────────────────────────────────────────────────────────
  // API Base URL
  // ─────────────────────────────────────────────────────────────

  static const String baseUrl = 'https://api.medicmetaverse.com';

  // ─────────────────────────────────────────────────────────────
  // Auth Config
  // ─────────────────────────────────────────────────────────────

  static const String googleWebClientId =
      '289678019987-m0ab36se67qv1hq6vq8ikptvt26a8l2m.apps.googleusercontent.com';

  // ─────────────────────────────────────────────────────────────
  // Auth Endpoints
  // ─────────────────────────────────────────────────────────────

  static const String sendOtpEndpoint = '/user/send-otp';
  static const String validateOtpEndpoint = '/user/validate-otp';
  static const String registerPatientEndpoint = '/user/register-patient';
  static const String loginWithGoogleEndpoint = '/user/login-with-google';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String logoutEndpoint = '/auth/logout';

  // ─────────────────────────────────────────────────────────────
  // User Profile Endpoints
  // ─────────────────────────────────────────────────────────────

  static const String profileEndpoint = '/user/profile';
  static const String profileGoogleAttachEndpoint = '/user/profile/google-account/attach';
  static const String profileGoogleDetachEndpoint = '/user/profile/google-account/detach';
  static const String profileAllergyAddEndpoint = '/user/profile/allergy/add';
  static const String profileAllergyRemoveEndpoint = '/user/profile/allergy/remove';
  static const String profileDiseaseAddEndpoint = '/user/profile/underlying-disease/add';
  static const String profileDiseaseRemoveEndpoint = '/user/profile/underlying-disease/remove';
  static const String profileHistoryAddEndpoint = '/user/profile/medical-history/add';
  static const String profileHistoryRemoveEndpoint = '/user/profile/medical-history/remove';

  // ─────────────────────────────────────────────────────────────
  // Medical Catalogs Endpoints
  // ─────────────────────────────────────────────────────────────

  static const String allergyCatalogEndpoint = '/allergy';
  static const String underlyingDiseaseCatalogEndpoint = '/underlying-disease';
  static const String medicalHistoryCatalogEndpoint = '/medical-history';

  // ─────────────────────────────────────────────────────────────
  // Geo Endpoints
  // ─────────────────────────────────────────────────────────────

  static const String geoCountryEndpoint = '/geo/country';
  static const String geoProvinceEndpoint = '/geo/province';
  static const String geoCityEndpoint = '/geo/city';
  static const String geoInternationalEthnicityEndpoint = '/geo/international-ethnicity';
  static const String geoLocalEthnicityEndpoint = '/geo/local-ethnicity';

  // ─────────────────────────────────────────────────────────────
  // File Upload Endpoints
  // ─────────────────────────────────────────────────────────────

  static const String fileUploadInitEndpoint = '/file/upload/init';
  static const String fileUploadBaseEndpoint = '/file/upload';

  // ─────────────────────────────────────────────────────────────
  // Lab Test Endpoints
  // ─────────────────────────────────────────────────────────────

  static const String labTestEndpoint = '/lab-test';
  static const String labTestExtractEndpoint = '/lab-test/extract';
  static const String labTestOverviewEndpoint = '/lab-test/overview';
  static const String labTestHealthEndpoint = '/lab-test/overview/health';
  static const String labTestParametersEndpoint = '/lab-test/overview/parameters';
  static const String labTestCompareEndpoint = '/lab-test/compare';
  static const String labTestSeriesEndpoint = '/lab-test/series';
  static const String labTestAnalytesEndpoint = '/lab-test/analytes';

  /// Sub-path appended to a lab test for granular category CRUD.
  static const String labTestCategoryEndpoint = '/categories';

  /// Sub-path appended to a lab test for granular parameter CRUD.
  static const String labTestParameterEndpoint = '/parameters';

  // ─────────────────────────────────────────────────────────────
  // Financial Endpoints
  // ─────────────────────────────────────────────────────────────

  static const String packageEndpoint = '/package';
  static const String orderCreateEndpoint = '/order/create';
  static const String orderCreateMultiEndpoint = '/order/create-multi';
  static const String walletEndpoint = '/wallet';
  static const String walletTopupEndpoint = '/wallet/topup';
  static const String walletTransactionsEndpoint = '/wallet/transactions';
  static const String walletBankEndpoint = '/wallet/bank';
  static const String userPackageActiveEndpoint = '/user-package/active';
  static const String userPackageHistoryEndpoint = '/user-package/history';
  static const String gatewayStatusEndpoint = '/gateway/status';

  // ─────────────────────────────────────────────────────────────
  // Notifications Endpoints
  // ─────────────────────────────────────────────────────────────

  static const String notificationsEndpoint = '/notification';
  static const String notificationsUnreadCountEndpoint = '/notification/unread-count';
  static const String notificationsReadEndpoint = '/notification/read';
  static const String notificationsReadAllEndpoint = '/notification/read-all';

  // ─────────────────────────────────────────────────────────────
  // Support Endpoints
  // ─────────────────────────────────────────────────────────────

  static const String goftinoStartChatEndpoint = '/goftino/start/chat';

  // ─────────────────────────────────────────────────────────────
  // HTTP Headers & Values
  // ─────────────────────────────────────────────────────────────

  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerAuthorization = 'Authorization';
  static const String contentTypeJson = 'application/json';
  static const String bearerPrefix = 'Bearer ';

  // ─────────────────────────────────────────────────────────────
  // API Error Codes
  // ─────────────────────────────────────────────────────────────

  static const String errorCodeOtpInvalid = 'OTP_INVALID';
  static const String errorCodeOtpRateLimit = 'OTP_RATE_LIMIT_EXCEEDED';
  static const String errorCodeOtpNotExpired = 'OTP_NOT_EXPIRED';
  static const String errorCodeRegistrationTokenInvalid = 'REGISTRATION_TOKEN_INVALID';
  static const String errorCodeBadRequest = 'BAD_REQUEST';
  static const String errorCodeUnauthorized = 'UNAUTHORIZED';
  static const String errorCodePackageNotFound = 'PACKAGE_NOT_FOUND';
  static const String errorCodeCompareIdsRequired = 'COMPARE_IDS_REQUIRED';

  // ─────────────────────────────────────────────────────────────
  // API Value Strings — Transaction
  // ─────────────────────────────────────────────────────────────

  static const String transactionTypeDeposit = 'DEPOSIT';
  static const String transactionTypeWithdrawal = 'WITHDRAWAL';
  static const String transactionReasonWalletTopup = 'WALLET_TOPUP';
  static const String transactionReasonPackagePurchase = 'PACKAGE_PURCHASE';
  static const String paymentMethodWallet = 'WALLET';
  static const String paymentMethodGateway = 'GATEWAY';
  static const String paymentMethodMixed = 'MIXED';

  // ─────────────────────────────────────────────────────────────
  // API Value Strings — Payment Gateway
  // ─────────────────────────────────────────────────────────────

  static const String gatewayZarinpal = 'ZARINPAL';
  static const String gatewayAp = 'AP';

  // ─────────────────────────────────────────────────────────────
  // API Value Strings — Status
  // ─────────────────────────────────────────────────────────────

  static const String statusPending = 'PENDING';
  static const String statusSuccess = 'SUCCESS';
  static const String statusFailed = 'FAILED';
  static const String statusCancelled = 'CANCELLED';

  // ─────────────────────────────────────────────────────────────
  // API Value Strings — Package Types
  // ─────────────────────────────────────────────────────────────

  static const String packageTypeBlood = 'BLOOD';
  static const String packageTypeGenetic = 'GENETIC';
  static const String packageTypeGenealogy = 'GENEALOGY';

  // ─────────────────────────────────────────────────────────────
  // API Value Strings — User-Package Status
  // ─────────────────────────────────────────────────────────────

  static const String userPackageStatusActive = 'ACTIVE';
  static const String userPackageStatusExpired = 'EXPIRED';
  static const String userPackageStatusCancelled = 'CANCELLED';

  // ─────────────────────────────────────────────────────────────
  // Deep Link Configuration
  // ─────────────────────────────────────────────────────────────

  static const String deepLinkScheme = 'medicmetaverse';
  static const String deepLinkPaymentHost = 'payment';
  static const String deepLinkStatusSegment = 'status';

  // ─────────────────────────────────────────────────────────────
  // Payment Status Values
  // ─────────────────────────────────────────────────────────────

  static const String paymentStatusSuccess = 'success';
  static const String paymentStatusFailed = 'failed';
  static const String paymentStatusPending = 'pending';

  // ─────────────────────────────────────────────────────────────
  // URL Launcher Configuration
  // ─────────────────────────────────────────────────────────────

  static const String logTagUrlLauncher = 'UrlLauncher';
  static const String urlSchemeHttpsPrefix = 'https://';

  // ─────────────────────────────────────────────────────────────
  // Timeouts & Durations
  // ─────────────────────────────────────────────────────────────

  static const int apiTimeoutSeconds = 15;
  static const int splashDelaySeconds = 2;
  static const int splashTimeoutSeconds = 10;
  static const int fileChunkSize = 8388608;
  static const String fileSourceLabTest = 'LAB_TEST';

  // ─────────────────────────────────────────────────────────────
  // Retry Mechanism
  // ─────────────────────────────────────────────────────────────

  static const int maxRetryAttempts = 2;
  static const int retryDelayBaseMs = 500;
  static const String extraKeyRetryCount = 'retry_count';
  static const String extraKeyRetryAttempted = 'retry_attempted';

  // ─────────────────────────────────────────────────────────────
  // HTTP Status Codes
  // ─────────────────────────────────────────────────────────────

  static const int statusUnauthorized = 401;
  static const int statusServerErrorMin = 500;

  // ─────────────────────────────────────────────────────────────
  // OTP Config
  // ─────────────────────────────────────────────────────────────

  static const int otpLength = 5;
  static const int otpTimerSeconds = 120;

  // ─────────────────────────────────────────────────────────────
  // Date Picker Limits
  // ─────────────────────────────────────────────────────────────

  static const int minBirthYearFa = 1300;
  static const int minBirthYearEn = 1920;

  // ─────────────────────────────────────────────────────────────
  // Router Extra Keys
  // ─────────────────────────────────────────────────────────────

  static const String extraKeyToken = 'token';
  static const String extraKeyPhone = 'phone';
  static const String extraKeyPackage = 'package';
  static const String extraKeyPackageId = 'package_id';

  // ─────────────────────────────────────────────────────────────
  // Financial — Amounts & Currency
  // ─────────────────────────────────────────────────────────────

  static const int rialToTomanDivisor = 10;
  static const String amountFormatLocale = 'en_US';
  static const String amountFormatPattern = '#,###';

  // مقادیر قبلی که فراموش شده بودند:
  static const int topupPreset50kToman = 500000;
  static const int topupPreset100kToman = 1000000;
  static const int topupPreset200kToman = 2000000;
  static const int topupPreset500kToman = 5000000;
  static const int topupPreset1000kToman = 10000000;

  static const int transactionsPageSize = 20;
  static const int packagesPageSize = 20;
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;
  static const int walletRecentTransactionCount = 5;
  static const double infiniteScrollThreshold = 200.0;

  // ─────────────────────────────────────────────────────────────
  // App Info
  // ─────────────────────────────────────────────────────────────

  static const String appVersion = '0.2.7';

  // ─────────────────────────────────────────────────────────────
  // SharedPreferences Keys
  // ─────────────────────────────────────────────────────────────

  /// Key used to persist the dark-mode preference.
  static const String prefKeyDarkMode = 'pref_dark_mode';

  /// Key used to persist the selected language code.
  static const String prefKeyLanguage = 'pref_language';

  // ─────────────────────────────────────────────────────────────
  // Language
  // ─────────────────────────────────────────────────────────────

  /// Default language code when no preference has been persisted.
  static const String defaultLanguageCode = 'fa';

  /// Persian language code.
  static const String languageCodeFa = 'fa';

  /// English language code.
  static const String languageCodeEn = 'en';

  /// Arabic language code.
  static const String languageCodeAr = 'ar';

  // ─────────────────────────────────────────────────────────────
  // UI Dimensions
  // ─────────────────────────────────────────────────────────────

  static const double paddingTiny = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double buttonHeight = 55.0;
  static const double financialButtonHeight = 52.0;
  static const double financialButtonHeightSmall = 44.0;

  static const double borderRadius = 12.0;
  static const double cardRadius = 20.0;
  static const double largeCardRadius = 24.0;
  static const double pillRadius = 30.0;

  static const double avatarRadius = 24.0;
  static const double largeAvatarRadius = 40.0;

  static const double bottomNavHeight = 70.0;
  static const double iconContainerSize = 50.0;

  static const double screenPadding = 20.0;

  static const double financialCardRadius = 20.0;
  static const double paymentStatusIconSize = 100.0;
  static const double walletBalanceFontSize = 26.0;
  static const double largeAmountFontSize = 18.0;

  static const double healthGaugeSize = 280.0;
  static const double healthGaugeStrokeWidth = 24.0;
  static const double bottomSheetHeightFactor = 0.8;
  static const double notificationCardImageSize = 100.0;
  static const double blogCardImageSize = 100.0;
  
  // ─────────────────────────────────────────────────────────────
  // Border Widths (added in PKG-013-001 — Sprint 9.b)
  // ─────────────────────────────────────────────────────────────

  /// Border width used for focused input fields
  /// (e.g. `InputDecoration.focusedBorder`).
  static const double borderWidthFocused = 2.0;

  // ─────────────────────────────────────────────────────────────
  // Snackbar & Toasts (added in PKG-013-001 — Sprint 9.b)
  // ─────────────────────────────────────────────────────────────

  /// Default display duration for informational snackbars
  /// (e.g. "previous OTP is still valid").
  static const Duration snackbarDuration = Duration(seconds: 4);

  // ─────────────────────────────────────────────────────────────
  // Icon Sizes (added in PKG-013-001 — Sprint 9.b)
  // ─────────────────────────────────────────────────────────────

  /// Hero icon size used in empty/error illustration states
  /// (e.g. `Icons.upload_file` on an upload screen).
  static const double iconSizeHero = 80.0;

  // ─────────────────────────────────────────────────────────────
  // Font Sizes (added in PKG-013-001 — Sprint 9.b)
  // ─────────────────────────────────────────────────────────────

  /// Preview header font size used above extracted lab-test data.
  /// Used with `textTheme.titleLarge?.copyWith(fontSize: ...)` to keep
  /// the color theme-aware.
  static const double fontSizePreviewHeader = 20.0;
    // ─────────────────────────────────────────────────────────────
  // Blog / WordPress (added in PKG-013-003-C)
  // ─────────────────────────────────────────────────────────────

  // ─────────────────────────────────────────────────────────────
  // Blog / WordPress (added in PKG-013-003-C)
  // ─────────────────────────────────────────────────────────────

  /// Base URL of the WordPress REST API (wp-json/wp/v2/).
  ///
  /// The blog is hosted at `https://medicmetaverse.com/blog/`, but the
  /// REST API is served from the domain root.
  static const String wordpressBaseUrl = 'https://medicmetaverse.com/wp-json/wp/v2/';
  /// Blog list screen route.
  static const String blogListRoute = '/blog';

  /// Blog detail screen route template (path parameter `:id`).
  static const String blogDetailRouteTemplate = '/blog/:id';

  /// Number of blog posts requested per page.
  static const int blogPostsPerPage = 10;

  /// Maximum number of blog categories requested in one fetch
  /// (WordPress caps `per_page` at 100).
  static const int blogCategoriesPerPage = 100;
}