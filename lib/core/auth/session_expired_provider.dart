import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier responsible for managing the "session expired" state.
/// 
/// When the user's tokens are invalidated server-side (e.g., account deleted),
/// this notifier is triggered to notify the app to navigate to the Login screen.
class SessionExpiredNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Triggers the session expired state.
  void expire() => state = true;

  /// Resets the session expired state.
  void reset() => state = false;
}

/// Riverpod provider for [SessionExpiredNotifier].
final sessionExpiredProvider = NotifierProvider<SessionExpiredNotifier, bool>(() {
  return SessionExpiredNotifier();
});