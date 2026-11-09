/// Configuration for the mock environment.
///
/// Active when built with: `flutter run --dart-define=USE_MOCKS=true`
/// In production builds, defaults to false — and all mock code is
/// tree-shaken by the compiler.
class MockConfig {
  const MockConfig._();

  /// Whether the app should use mock API responses instead of real HTTP.
  static const bool useMocks = bool.fromEnvironment('USE_MOCKS', defaultValue: false);
}
