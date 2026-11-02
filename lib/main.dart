import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/phone/nokia_phone_casing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI style for immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF14191E),
    ),
  );

  runApp(
    const ProviderScope(
      child: NokiaSnakeApp(),
    ),
  );
}

class NokiaSnakeApp extends StatelessWidget {
  const NokiaSnakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brick Snake: 1100 Edition',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF181E24),
      ),
      home: const Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              // Phone Casing
              NokiaPhoneCasing(),

              // Quick Desktop Key Help (subtle at bottom corner)
              Positioned(
                bottom: 8,
                left: 12,
                child: Opacity(
                  opacity: 0.45,
                  child: Text(
                    'Keys: Arrows/WASD or 2,4,6,8 | OK: Enter/Space/5 | Back: Esc/C | Light: L',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
