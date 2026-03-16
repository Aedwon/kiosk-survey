import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/on_screen_keyboard.dart';
import '../main.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen>
    with TickerProviderStateMixin {
  // ── Questions (text-only input) ──
  final List<String> _questions = [
    'What improvements would you like to see in HOK Benefits?',
    'What new feature would you like to see added in the future for HOK Benefits?',
    'What redeemable prizes would you like to be added on HOK Benefits?',
  ];

  // ── State ──
  int _currentStep = 0;
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  bool _showKeyboard = false; // hidden by default, shown on tap
  bool _isSubmitting = false;

  // ── Animation ──
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: 1.0,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    for (final c in _controllers) {
      c.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _fadeController.dispose();
    for (final c in _controllers) {
      c.removeListener(_onTextChanged);
      c.dispose();
    }
    super.dispose();
  }

  bool get _canProceed => _controllers[_currentStep].text.trim().isNotEmpty;

  Future<void> _goToStep(int step) async {
    if (step < 0 || step >= _questions.length) return;
    if (_fadeController.isAnimating) return;
    await _fadeController.reverse();
    setState(() {
      _currentStep = step;
      _showKeyboard = false; // Hide when moving to next step
    });
    _fadeController.forward();
  }

  void _hideKeyboard() {
    setState(() => _showKeyboard = false);
    FocusScope.of(context).unfocus();
  }

  void _showKeyboardPanel() {
    setState(() => _showKeyboard = true);
  }

  Future<void> _submitSurvey() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    final entry = {
      'Q1_Answer': _controllers[0].text.trim(),
      'Q2_Answer': _controllers[1].text.trim(),
      'Q3_Answer': _controllers[2].text.trim(),
    };
    await surveyRepo.saveEntry(entry);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/thank_you');
    }
  }

  // ── Progress Bar ──
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Row(
        children: List.generate(_questions.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepBefore = i ~/ 2;
            final completed = stepBefore < _currentStep;
            return Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: completed
                      ? AppTheme.gold
                      : Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final isActive = stepIndex == _currentStep;
          final isCompleted = stepIndex < _currentStep;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isActive ? 44 : 16,
            height: 16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isActive
                  ? AppTheme.gold
                  : isCompleted
                      ? AppTheme.gold.withOpacity(0.7)
                      : Colors.white.withOpacity(0.2),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.gold.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
          );
        }),
      ),
    );
  }

  // ── Themed Response Box (matches key visual) ──
  Widget _buildResponseBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 100),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppTheme.gold,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28), // Slightly less than 30 to account for border width
        child: TextField(
          controller: _controllers[_currentStep],
          style: const TextStyle(
            color: Color(0xFF2C2C2C),
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
          readOnly: true,
          showCursor: true,
          onTap: _showKeyboardPanel,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'Type your answer here…',
            hintStyle: TextStyle(
              color: Colors.grey.withOpacity(0.5),
              fontSize: 20,
              fontStyle: FontStyle.italic,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // ── Submit / Next Button (themed like key visual) ──
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    bool isSubmit = false,
    bool isLoading = false,
  }) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        decoration: BoxDecoration(
          color: enabled
              ? Colors.white.withOpacity(0.85)
              : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: enabled ? AppTheme.gold : Colors.white.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppTheme.gold.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Color(0xFF2C2C2C),
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: enabled
                          ? const Color(0xFF2C2C2C)
                          : Colors.grey.withOpacity(0.5),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    icon,
                    color: enabled
                        ? AppTheme.gold
                        : Colors.grey.withOpacity(0.5),
                    size: 22,
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentStep == _questions.length - 1;
    final isFirst = _currentStep == 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // Main content column
              Column(
                children: [
                  const SizedBox(height: 12),
                  _buildProgressBar(),
                  const SizedBox(height: 6),

                  // Step label
                  Text(
                    'QUESTION ${_currentStep + 1} OF ${_questions.length}',
                    style: TextStyle(
                      color: AppTheme.parchment.withOpacity(0.5),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                    ),
                  ),

                  // Question + Response area (floats over background)
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Question text with text shadow for legibility
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 100),
                            child: Text(
                              _questions[_currentStep],
                              style: TextStyle(
                                color: AppTheme.parchment,
                                fontSize: 36, // Increased font size
                                fontWeight: FontWeight.bold,
                                height: 1.25,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.7),
                                    blurRadius: 12,
                                  ),
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 24,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Themed response box
                          _buildResponseBox(),

                          const SizedBox(height: 20),

                          // Navigation row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Back button
                              if (!isFirst)
                                Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: GestureDetector(
                                    onTap: () =>
                                        _goToStep(_currentStep - 1),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 28, vertical: 14),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(30),
                                        border: Border.all(
                                          color:
                                              Colors.white.withOpacity(0.25),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.arrow_back_rounded,
                                              color: AppTheme.parchment,
                                              size: 20),
                                          const SizedBox(width: 6),
                                          Text(
                                            'BACK',
                                            style: TextStyle(
                                              color: AppTheme.parchment,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              // Next / Submit
                              isLast
                                  ? _buildActionButton(
                                      label: 'SUBMIT',
                                      icon: Icons.send_rounded,
                                      onTap: _canProceed
                                          ? _submitSurvey
                                          : null,
                                      isSubmit: true,
                                      isLoading: _isSubmitting,
                                    )
                                  : _buildActionButton(
                                      label: 'NEXT',
                                      icon: Icons.arrow_forward_rounded,
                                      onTap: _canProceed
                                          ? () =>
                                              _goToStep(_currentStep + 1)
                                          : null,
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Text field above keyboard (for display when keyboard open)
                  // (the themed box above IS the text field now)

                  // Keyboard
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _showKeyboard
                        ? OnScreenKeyboard(
                            controller: _controllers[_currentStep],
                            onDismiss: _hideKeyboard,
                          )
                        : const SizedBox.shrink(),
                  ),

                  if (!_showKeyboard) const SizedBox(height: 8),
                ],
              ),

              // Home / Reset Button
              Positioned(
                top: 20,
                right: 24,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/'),
                    borderRadius: BorderRadius.circular(30),
                    splashColor: AppTheme.gold.withOpacity(0.3),
                    highlightColor: AppTheme.gold.withOpacity(0.1),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.15)),
                      ),
                      child: const Icon(
                        Icons.home_rounded,
                        color: AppTheme.parchment,
                        size: 28,
                      ),
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
