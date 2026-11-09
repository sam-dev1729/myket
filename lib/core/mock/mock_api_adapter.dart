import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'handlers/auth_handler.dart';
import 'handlers/catalog_handler.dart';
import 'handlers/file_handler.dart';
import 'handlers/financial_handler.dart';
import 'handlers/geo_handler.dart';
import 'handlers/lab_test_handler.dart';
import 'handlers/mock_handler.dart';
import 'handlers/notification_handler.dart';
import 'handlers/profile_handler.dart';
import 'handlers/support_handler.dart';

/// A Dio [HttpClientAdapter] that returns mock responses instead of
/// performing real HTTP requests.
///
/// Activate with `flutter run --dart-define=USE_MOCKS=true`.
class MockApiAdapter implements HttpClientAdapter {
  /// Registered mock handlers, checked in order.
  ///
  /// Order matters: [`LabTestHandler`] is registered last because it owns
  /// the broadest matcher (`/lab-test/*`). Other handlers use disjoint
  /// paths and would never be shadowed, but keeping this ordering is a
  /// safety convention. [`FileHandler`] sits right before it since its
  /// matcher (`/file/upload*`) is also broad.
  final List<MockHandler> _handlers = [
    AuthHandler(),
    ProfileHandler(),
    CatalogHandler(),
    NotificationHandler(),
    SupportHandler(),
    FinancialHandler(),
    GeoHandler(),
    FileHandler(),
    LabTestHandler(),
  ];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    // Small delay to simulate network.
    await Future.delayed(const Duration(milliseconds: 150));

    for (final handler in _handlers) {
      if (handler.matches(options.method, options.path)) {
        return handler.handle(options);
      }
    }

    return mockError(
      statusCode: 404,
      code: 'MOCK_NOT_FOUND',
      message: 'No mock handler for ${options.method} ${options.path}',
    );
  }

  @override
  void close({bool force = false}) {}
}
