import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/lab_test_repository.dart';
import '../data/models/lab_test_models.dart';

/// Riverpod [FutureProvider] that loads the current user's health overview
/// (`GET /lab-test/overview/health`).
///
/// Consumed by the Health Record tab. Call `ref.invalidate(healthOverviewProvider)`
/// after any lab test is created, deleted, or edited so the gauge and key
/// markers reflect the latest state.
final healthOverviewProvider = FutureProvider<HealthOverview>((ref) async {
  return ref.read(labTestRepositoryProvider).getHealthOverview();
});

/// Status-string constants returned by the backend's `overall_status` field.
class HealthOverviewStatus {
  const HealthOverviewStatus._();

  static const String green = 'green';
  static const String orange = 'orange';
  static const String red = 'red';
}
