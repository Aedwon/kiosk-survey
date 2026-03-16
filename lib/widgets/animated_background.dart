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
            'assets/HOK Background.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.black87),
          ),
        ),
        
        // 2. Branding Layer
        Positioned(
          top: 32,
          left: 48,
          right: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: Image.asset('assets/HOK Logo.png', height: 100, fit: BoxFit.contain, errorBuilder: (_,__,___) => const SizedBox(height: 100))),
              Flexible(flex: 2, child: Image.asset('assets/HOK Festival of Lanterns text.png', height: 140, fit: BoxFit.contain, errorBuilder: (_,__,___) => const SizedBox(height: 140))),
              Flexible(child: Image.asset('assets/HOK Benefits Logo.png', height: 100, fit: BoxFit.contain, errorBuilder: (_,__,___) => const SizedBox(height: 100))),
            ],
          ),
        ),
        
        // 3/4/5. Animated Layers
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Hover value: 0.0 (bottom) to 1.0 (top)
              final hoverVal = _controller.value;
              final translateY = hoverVal * -30.0;
              final shadowScale = 1.0 - (hoverVal * 0.2); // 1.0 to 0.8
              final shadowOpacity = 1.0 - (hoverVal * 0.4); // 1.0 to 0.6
              final glowOpacity = 0.4 + (hoverVal * 0.6); // 0.4 to 1.0
              
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Shadow Layer
                  Positioned(
                    bottom: 20, 
                    child: Transform.translate(
                      offset: const Offset(-160, 0), // Shift slightly right from previous
                      child: Transform.scale(
                        scale: shadowScale,
                        child: Opacity(
                          opacity: shadowOpacity,
                          child: Image.asset('assets/HOK Character shadow.png', width: 500, errorBuilder: (_,__,___) => const SizedBox()),
                        ),
                      ),
                    ),
                  ),
                  
                  // Character Layer
                  Positioned(
                    bottom: -20, // Slightly off bottom depending on crops
                    child: Transform.translate(
                      offset: Offset(0, translateY),
                      child: Image.asset('assets/HOK Character.png', width: 700, errorBuilder: (_,__,___) => const SizedBox(width: 700)),
                    ),
                  ),
                  
                  // Glow Layer
                  Positioned(
                    bottom: -20,
                    child: Transform.translate(
                      offset: Offset(0, translateY),
                      child: Opacity(
                        opacity: glowOpacity,
                        child: Image.asset('assets/HOK Character eye glow.png', width: 700, errorBuilder: (_,__,___) => const SizedBox()),
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
