import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:setorantif/main.dart';

void main() {
  testWidgets('App starts and shows login page', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.byType(TextField), findsNWidgets(2)); // username dan password
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.text('Login'), findsNWidgets(2)); // jika tetap ingin memverifikasi keduanya
  });
}
