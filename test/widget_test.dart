import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nokia_snake/main.dart';
import 'package:nokia_snake/presentation/phone/nokia_keypad.dart';
import 'package:nokia_snake/presentation/screen/nokia_lcd_display.dart';

void main() {
  testWidgets('NokiaSnakeApp renders phone casing, LCD screen, and keypad', (WidgetTester tester) async {
    // Provide a sufficiently large canvas for the phone frame
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: NokiaSnakeApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Nokia branding
    expect(find.text('NOKIA'), findsOneWidget);

    // Verify LCD Display is present
    expect(find.byType(NokiaLcdDisplay), findsOneWidget);

    // Verify Keypad is present
    expect(find.byType(NokiaKeypad), findsOneWidget);

    // Verify menu items on keypad
    expect(find.text('MENU'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });
}
