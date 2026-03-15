import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';
import 'data/survey_repository.dart';
import 'screens/welcome_screen.dart';
import 'screens/survey_screen.dart';
import 'screens/thank_you_screen.dart';
import 'screens/admin_screen.dart';

final surveyRepo = SurveyRepository();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientation to landscape
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Hide system UI for true kiosk mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await surveyRepo.init();
  runApp(const KioskApp());
}

class KioskApp extends StatefulWidget {
  const KioskApp({super.key});

  @override
  State<KioskApp> createState() => _KioskAppState();
}

class _KioskAppState extends State<KioskApp> {
  Timer? _idleTimer;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _resetIdleTimer();
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 45), _handleTimeout);
  }

  void _handleTimeout() {
    // Pop back to Welcome Screen if we aren't already there.
    if (_navigatorKey.currentState?.canPop() ?? false) {
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
  }

  void _handleUserInteraction(PointerEvent details) {
    _resetIdleTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handleUserInteraction,
      onPointerMove: _handleUserInteraction,
      onPointerUp: _handleUserInteraction,
      behavior: HitTestBehavior.translucent,
      child: MaterialApp(
        title: 'HOK Survey Kiosk',
        theme: AppTheme.theme,
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/survey': (context) => const SurveyScreen(),
          '/thank_you': (context) => const ThankYouScreen(),
          '/admin': (context) => const AdminScreen(),
        },
      ),
    );
  }
}
