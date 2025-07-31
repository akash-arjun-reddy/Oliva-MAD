import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Dashboard Page displays correctly', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // TODO: Navigate to Dashboard Page if not the default
    // await tester.tap(find.byKey(Key('goToDashboard')));
    // await tester.pumpAndSettle();

    // Example: Check for expected widgets
    expect(find.text('Dashboard'), findsOneWidget);
    // Add more checks as needed
  });
} 