import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child; // We will overlay the foreground onto this.
  
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    // 1.5s up, 1.5s down = 3s full cycle
    _controller = AnimationController(
       vsync: this, 
       duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Base Layer
        Positioned.fill(
          child: Image.asset(
            'assets/HOK BLUE Background.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.black87),
          ),
        ),
        
        // 2. Branding Layers (Absolute Positioning)
        // Top Left: Gold Logo
        Positioned(
          top: 32,
          left: 48,
          child: Image.asset('assets/HOK BLUE Gold logo.png', height: 120, fit: BoxFit.contain, errorBuilder: (_,__,___) => const SizedBox(height: 120)),
        ),
        
        // Top Right: Benefits Logo
        Positioned(
          top: 56, // Moved lower (was 32)
          right: 48,
          child: Image.asset('assets/HOK BLUE Benefits logo.png', height: 110, fit: BoxFit.contain, errorBuilder: (_,__,___) => const SizedBox(height: 130)), // Made larger (was 90)
        ),
        
        // Bottom Right: Level Infinite Logo
        Positioned(
          bottom: 32,
          right: 48,
          child: Image.asset('assets/HOK BLUE LEVEL INFINITE & TIMI Logo.png', height: 50, fit: BoxFit.contain, errorBuilder: (_,__,___) => const SizedBox(height: 50)),
        ),
        
        // 3/4/5. Animated Layers (Sparkles and Character)
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final val = _controller.value;
              final breathScale = 1.0 + (val * 0.05); // Subtle scale breathing 1.0 to 1.05
              final breathOpacity = 0.6 + (val * 0.4); // Breathing opacity 0.6 to 1.0
              
              return Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  // Sparkle 2 Radial (Background glow) - Maxed out, radiating from character, turned white
                  Positioned.fill(
                    child: Transform.scale(
                      scale: breathScale,
                      child: Opacity(
                        opacity: breathOpacity,
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          child: Image.asset(
                            'assets/HOK BLUE Sparkle 2 radial.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (_,__,___) => const SizedBox(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Character Layer - Maxed out and centered, static for now
                  Positioned.fill(
                    child: Image.asset(
                      'assets/HOK BLUE Character.png', 
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (_,__,___) => const SizedBox(),
                    ),
                  ),
                  
                  // Foreground Sparkle 1 - Maxed and breathing
                  Positioned.fill(
                    child: Transform.scale(
                      scale: breathScale,
                      child: Opacity(
                        opacity: breathOpacity,
                        child: Image.asset(
                          'assets/HOK BLUE Sparkle 1.png', 
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (_,__,___) => const SizedBox(),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        
        // 6. Overlay Layer
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.25),
          ),
        ),
        
        // The foreground content
        Positioned.fill(
          child: widget.child,
        ),
      ],
    );
  }
}
