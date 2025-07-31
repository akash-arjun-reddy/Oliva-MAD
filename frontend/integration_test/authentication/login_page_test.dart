import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login Page displays correctly', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // TODO: Navigate to Login Page if not the default
    // await tester.tap(find.byKey(Key('goToLogin')));
    // await tester.pumpAndSettle();

    // Example: Check for expected widgets
    expect(find.text('Login'), findsOneWidget);
    // Add more checks as needed
  });
} 