import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Booking Success Page displays correctly', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // TODO: Navigate to Booking Success Page if not the default
    // await tester.tap(find.byKey(Key('goToBookingSuccess')));
    // await tester.pumpAndSettle();

    // Example: Check for expected widgets
    expect(find.text('Booking Successful'), findsOneWidget);
    // Add more checks as needed
  });
} 