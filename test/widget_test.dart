import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lunotebook/main.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LUNotebook());

    // Verify that the login page is displayed.
    expect(find.text('Login'), findsWidgets);
  });
}

void setupFirebaseCoreMocks() {
  const MethodChannel channel = MethodChannel('plugins.flutter.io/firebase_core');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    if (methodCall.method == 'Firebase#initializeApp') {
      return {
        'name': methodCall.arguments['appName'] ?? '[DEFAULT]',
        'options': methodCall.arguments['options'],
        'pluginConstants': {},
      };
    }
    return null;
  });
}
