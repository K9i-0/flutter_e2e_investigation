// Basic widget test for Todo app

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_e2e_investigation/app.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TodoApp(),
      ),
    );

    // Just verify the app builds without error
    await tester.pump();
  });
}
