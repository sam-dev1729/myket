import '../../features/financial/data/models/package_models.dart';
import '../../features/financial/data/models/wallet_models.dart';
import '../../features/lab_test/data/models/lab_test_models.dart';
import '../../features/profile/data/models/geo_models.dart';
import '../../features/profile/data/models/user_profile.dart';
import 'data/mock_catalog.dart';
import 'data/mock_financial.dart';
import 'data/mock_geo.dart';
import 'data/mock_lab_tests.dart';
import 'data/mock_notifications.dart';
import 'data/mock_users.dart';

/// In-memory storage for the mock environment.
///
/// Holds mutable state (users, lab tests, wallet, catalogs, etc.) so that
/// mutations persist across requests within the same app run. Resets to
/// seed data on app restart.
class MockStorage {
  MockStorage._();

  /// Singleton instance used by all mock handlers.
  static final MockStorage instance = MockStorage._();

  /// All registered users, keyed by mobile.
  final Map<String, UserProfile> users = {};

  /// Access tokens → mobile mapping.
  final Map<String, String> accessTokens = {};

  /// Refresh tokens → mobile mapping.
  final Map<String, String> refreshTokens = {};

  /// Currently registered mobile numbers that have received an OTP.
  final Map<String, String> otpCodes = {};

  /// Registration tokens → mobile.
  final Map<String, String> registrationTokens = {};

  /// All lab tests, keyed by test id.
  final Map<String, LabTestDetail> labTests = {};

  /// Catalog items for allergies.
  final List<MedicalCatalogItem> allergies = [];

  /// Catalog items for underlying diseases.
  final List<MedicalCatalogItem> underlyingDiseases = [];

  /// Catalog items for medical histories.
  final List<MedicalCatalogItem> medicalHistories = [];

  /// User-uploaded files (fake metadata).
  final Map<String, MockUploadedFile> uploadedFiles = {};

  /// Ongoing upload sessions (fake).
  final Map<String, MockUploadSession> uploadSessions = {};

  /// Wallet balance for each user (mobile → balance in IRR).
  final Map<String, int> walletBalances = {};

  /// All packages (catalog).
  final List<PackageModel> packages = [];

  /// User packages (mobile → list of entitlements).
  final Map<String, List<UserPackageModel>> userPackages = {};

  /// All wallet transactions (mobile → list).
  final Map<String, List<WalletTransactionModel>> transactions = {};

  /// Countries (static).
  final List<Country> countries = [];

  /// Provinces (static).
  final List<Province> provinces = [];

  /// Cities (static).
  final List<City> cities = [];

  /// Notifications per user (mobile → list).
  final Map<String, List<MockNotification>> notifications = {};

  /// Goftino chat URL.
  String goftinoChatUrl = 'https://www.goftino.com/c/MOCK';

  /// Whether the storage has been seeded.
  bool _seeded = false;

  /// Seeds the storage with fake data (idempotent).
  void ensureSeeded() {
    if (_seeded) return;
    _seeded = true;

    for (final user in mockSeedUsers()) {
      users[user.mobile] = user;
      walletBalances[user.mobile] = 2500000; // ۲۵۰ هزار تومان
      userPackages[user.mobile] = [];
      transactions[user.mobile] = [];
      notifications[user.mobile] = mockSeedNotifications();
    }
    for (final test in mockSeedLabTests()) {
      labTests[test.id] = test;
    }
    allergies.addAll(mockSeedAllergies());
    underlyingDiseases.addAll(mockSeedUnderlyingDiseases());
    medicalHistories.addAll(mockSeedMedicalHistories());
    packages.addAll(mockSeedPackages());
    countries.addAll(mockSeedCountries());
    provinces.addAll(mockSeedProvinces());
    cities.addAll(mockSeedCities());
  }

  /// Resets all state back to seed (for debug).
  void reset() {
    users.clear();
    accessTokens.clear();
    refreshTokens.clear();
    otpCodes.clear();
    registrationTokens.clear();
    labTests.clear();
    allergies.clear();
    underlyingDiseases.clear();
    medicalHistories.clear();
    uploadedFiles.clear();
    uploadSessions.clear();
    walletBalances.clear();
    packages.clear();
    userPackages.clear();
    transactions.clear();
    countries.clear();
    provinces.clear();
    cities.clear();
    notifications.clear();
    goftinoChatUrl = 'https://www.goftino.com/c/MOCK';
    _seeded = false;
    ensureSeeded();
  }
}

/// Metadata for a fake uploaded file.
class MockUploadedFile {
  final String id;
  final String originalName;
  final String mimeType;
  final int size;
  final String source;
  MockUploadedFile({
    required this.id,
    required this.originalName,
    required this.mimeType,
    required this.size,
    required this.source,
  });
}

/// State for a fake chunked upload session.
class MockUploadSession {
  final String uploadId;
  final String name;
  final int totalSize;
  int receivedBytes;
  bool completed;
  MockUploadSession({
    required this.uploadId,
    required this.name,
    required this.totalSize,
    this.receivedBytes = 0,
    this.completed = false,
  });
}
