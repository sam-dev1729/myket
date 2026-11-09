import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Centralized string and duration constants for widget-test channel mocking.
///
/// Extracting these values here keeps tests free of magic strings/numbers
/// (project rules #4 and #5) while preserving readability.
class TestChannelConstants {
  const TestChannelConstants._();

  /// Method channel for the `flutter_secure_storage` plugin.
  static const String secureStorageChannel = 'plugins.it_nomads.com/flutter_secure_storage';

  /// Method channel for the `app_links` plugin (v6.x).
  static const String appLinksChannel = 'com.llfbandit.app_links/messages';

  /// Method channel for the `smart_auth` plugin.
  static const String smartAuthChannel = 'smart_auth';

  /// Time to advance [WidgetTester.pump] to pass the splash delay.
  static const Duration splashAdvance = Duration(seconds: 3);

  /// Default timeout used while waiting for a Riverpod provider to settle.
  static const Duration providerSettleTimeout = Duration(seconds: 5);
}

/// Helpers to install/remove method-channel mocks so widget tests can boot
/// [MedicMetaverseApp] without hitting `MissingPluginException`.
///
/// Also provides [disabledRetry], a callback that disables Riverpod 3's
/// automatic retry mechanism so tests that exercise failed
/// `AsyncNotifier` builds can deterministically observe `AsyncError`.
///
/// Usage:
/// ```dart
/// setUp(TestChannelMocks.installAll);
/// tearDown(TestChannelMocks.removeAll);
///
/// final container = ProviderContainer(
///   overrides: [...],
///   retry: TestChannelMocks.disabledRetry,
/// );
/// ```
class TestChannelMocks {
  const TestChannelMocks._();

  static TestDefaultBinaryMessenger get _messenger =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  /// Callback that disables Riverpod 3's auto-retry mechanism.
  ///
  /// Returning `null` from this function instructs Riverpod not to retry a
  /// failed provider build. Without this, a failed build stays in
  /// `AsyncLoading(error: ..., retrying: true)` and never settles on
  /// `AsyncError` — which breaks tests that assert on the final failed state.
  static Duration? disabledRetry(int retryCount, Object error) => null;

  /// Installs no-op mocks for every platform channel the app boots with.
  static void installAll() {
    _messenger.setMockMethodCallHandler(
      const MethodChannel(TestChannelConstants.secureStorageChannel),
      (call) async {
        switch (call.method) {
          case 'read':
          case 'readAll':
            return null;
          case 'containsKey':
            return false;
          case 'write':
          case 'delete':
          case 'deleteAll':
            return null;
          default:
            return null;
        }
      },
    );

    _messenger.setMockMethodCallHandler(
      const MethodChannel(TestChannelConstants.appLinksChannel),
      (call) async => null,
    );

    _messenger.setMockMethodCallHandler(
      const MethodChannel(TestChannelConstants.smartAuthChannel),
      (call) async => null,
    );
  }

  /// Removes every mock installed by [installAll].
  static void removeAll() {
    _messenger.setMockMethodCallHandler(
      const MethodChannel(TestChannelConstants.secureStorageChannel),
      null,
    );
    _messenger.setMockMethodCallHandler(
      const MethodChannel(TestChannelConstants.appLinksChannel),
      null,
    );
    _messenger.setMockMethodCallHandler(
      const MethodChannel(TestChannelConstants.smartAuthChannel),
      null,
    );
  }
}
