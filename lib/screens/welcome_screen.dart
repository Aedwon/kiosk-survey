import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/animated_background.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseOpacity = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleAdminTap() {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(seconds: 1)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    _lastTapTime = now;

    if (_tapCount >= 5) {
      _tapCount = 0;
      Navigator.pushNamed(context, '/admin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: Stack(
          children: [
            // Main content (Tap anywhere detector)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pushNamed(context, '/survey');
                },
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),

            // Hidden Admin Trigger
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _handleAdminTap,
                child: const SizedBox(
                  width: 150,
                  height: 150,
                ),
              ),
            ),

            // Center Content: QR, Text, and CTA
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // QR and Text Row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // QR Code Container with white background and padding
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/qr_code_image.JPEG',
                            width: 220,
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                      // Text next to QR, wrapped in Flexible and FittedBox for single-line scaling
                      Flexible(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 800), // Prevent it from getting absurdly wide
                          child: FittedBox(
                            fit: BoxFit.scaleDown, // Shrinks text if it exceeds available space
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'TRY HOK BENEFITS NOW!', // Removed \n
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 96, // Started larger; FittedBox will scale it down if needed
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                color: AppTheme.parchment,
                                shadows: [
                                  Shadow(
                                    color: AppTheme.gold.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                  const Shadow(
                                    color: Colors.black54,
                                    blurRadius: 10,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                  // Enloged CTA Button Centered Underneath
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/survey');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.gold.withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/HOK BLUE CTA.png',
                        width: 580, // Enlarged significantly
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.touch_app,
                          size: 120,
                          color: AppTheme.parchment,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer Text
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _pulseOpacity.value,
                      child: Text(
                        'TAP ANYWHERE TO PLAY',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 42,
                          color: AppTheme.parchment,
                          letterSpacing: 2.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
