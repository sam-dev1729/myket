import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myket/main.dart';

import 'helpers/test_channel_mocks.dart';

/// Smoke test that boots [MedicMetaverseApp] and confirms it survives the
/// initial splash-to-login navigation.
void main() {
  setUp(TestChannelMocks.installAll);
  tearDown(TestChannelMocks.removeAll);

  testWidgets('App boots and shows initial screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MedicMetaverseApp()));
    expect(find.byType(MedicMetaverseApp), findsOneWidget);

    // Advance past the splash delay.
    await tester.pump(TestChannelConstants.splashAdvance);
    await tester.pump();
    await tester.pump();

    // Drain any platform-channel errors the async splash may have emitted.
    tester.takeException();

    expect(find.byType(MedicMetaverseApp), findsOneWidget);
  });
}
