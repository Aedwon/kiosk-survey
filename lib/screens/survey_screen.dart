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

class _SurveyScreenState extends State<SurveyScreen> with TickerProviderStateMixin {
  // ── Data ──
  final List<_QuestionData> _questions = [
    _QuestionData(
      question: 'What improvements would you like to see in HOK Benefits?',
      chips: ['More Skins', 'Merch', 'In-game Currency', 'Physical Events'],
      icons: [Icons.auto_awesome, Icons.shopping_bag_outlined, Icons.monetization_on_outlined, Icons.celebration_outlined],
    ),
    _QuestionData(
      question: 'What new feature would you like to see added in the future for HOK Benefits?',
      chips: ['Daily Login Rewards', 'Mini-games', 'Community Tourneys', 'Friend Gifts'],
      icons: [Icons.calendar_today_outlined, Icons.sports_esports_outlined, Icons.emoji_events_outlined, Icons.card_giftcard_outlined],
    ),
    _QuestionData(
      question: 'What redeemable prizes would you like to be added on HOK Benefits?',
      chips: ['Exclusive Avatar', 'Epic Skin', 'Diamonds', 'Limited UI Theme'],
      icons: [Icons.face_outlined, Icons.shield_outlined, Icons.diamond_outlined, Icons.palette_outlined],
    ),
  ];

  // ── State ──
  int _currentStep = 0;
  final List<Set<String>> _selectedChips = [{}, {}, {}];
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  bool _showKeyboard = false;
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

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _fadeController.dispose();
    for (final c in _controllers) {
      c.removeListener(_onTextChanged);
      c.dispose();
    }
    super.dispose();
  }

  bool get _canProceed {
    return _selectedChips[_currentStep].isNotEmpty ||
        _controllers[_currentStep].text.trim().isNotEmpty;
  }

  void _toggleChip(String chip) {
    setState(() {
      if (_selectedChips[_currentStep].contains(chip)) {
        _selectedChips[_currentStep].remove(chip);
      } else {
        _selectedChips[_currentStep].add(chip);
      }
    });
  }

  Future<void> _goToStep(int step) async {
    if (step < 0 || step >= _questions.length) return;
    if (_fadeController.isAnimating) return;

    await _fadeController.reverse();

    setState(() {
      _currentStep = step;
      _showKeyboard = false;
    });

    _fadeController.forward();
  }

  void _toggleKeyboard() {
    setState(() {
      _showKeyboard = !_showKeyboard;
    });
  }

  void _hideKeyboard() {
    setState(() {
      _showKeyboard = false;
    });
    FocusScope.of(context).unfocus();
  }

  String _buildAnswer(int index) {
    final parts = <String>[];
    if (_selectedChips[index].isNotEmpty) {
      parts.add(_selectedChips[index].join(', '));
    }
    final typed = _controllers[index].text.trim();
    if (typed.isNotEmpty) {
      parts.add(typed);
    }
    return parts.join(', ');
  }

  Future<void> _submitSurvey() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final entry = {
      'Q1_Answer': _buildAnswer(0),
      'Q2_Answer': _buildAnswer(1),
      'Q3_Answer': _buildAnswer(2),
    };

    await surveyRepo.saveEntry(entry);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/thank_you');
    }
  }

  // ── UI Builders ──

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Row(
        children: List.generate(_questions.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepBefore = i ~/ 2;
            final completed = stepBefore < _currentStep;
            return Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: completed
                      ? const LinearGradient(
                          colors: [AppTheme.gold, AppTheme.gold],
                        )
                      : null,
                  color: completed ? null : Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }
          // Step dot
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

  Widget _buildChipCard(String chip, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleChip(chip),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.gold.withOpacity(0.25),
                    AppTheme.gold.withOpacity(0.10),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.03),
                  ],
                ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppTheme.gold : AppTheme.gold.withOpacity(0.25),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.gold.withOpacity(0.25),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with glow when selected
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppTheme.gold.withOpacity(0.2)
                    : Colors.white.withOpacity(0.06),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.gold : AppTheme.parchment.withOpacity(0.6),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                chip,
                style: TextStyle(
                  color: isSelected ? AppTheme.gold : AppTheme.parchment,
                  fontSize: 20,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            // Check indicator
            AnimatedOpacity(
              opacity: isSelected ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.gold.withOpacity(0.2),
                  border: Border.all(color: AppTheme.gold, width: 2),
                ),
                child: const Icon(Icons.check, color: AppTheme.gold, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipGrid(List<String> chips, List<IconData> icons) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 16,
      childAspectRatio: 4.0,
      children: List.generate(chips.length, (i) {
        final isSelected = _selectedChips[_currentStep].contains(chips[i]);
        return _buildChipCard(chips[i], icons[i], isSelected);
      }),
    );
  }

  Widget _buildTypeOwnButton() {
    return GestureDetector(
      onTap: _toggleKeyboard,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _showKeyboard
                ? AppTheme.gold.withOpacity(0.5)
                : Colors.white.withOpacity(0.15),
            width: 1.5,
          ),
          color: _showKeyboard
              ? AppTheme.gold.withOpacity(0.08)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _showKeyboard ? Icons.keyboard_hide_outlined : Icons.edit_outlined,
              color: _showKeyboard ? AppTheme.gold : AppTheme.parchment.withOpacity(0.5),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _showKeyboard ? 'Hide keyboard' : 'or type your own answer…',
              style: TextStyle(
                color: _showKeyboard ? AppTheme.gold : AppTheme.parchment.withOpacity(0.5),
                fontSize: 17,
                fontStyle: _showKeyboard ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 6),
      child: TextField(
        controller: _controllers[_currentStep],
        style: const TextStyle(color: Colors.white, fontSize: 20),
        readOnly: true,
        showCursor: true,
        decoration: InputDecoration(
          hintText: 'Your suggestion...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          filled: true,
          fillColor: Colors.black.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppTheme.gold.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppTheme.gold.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.gold, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    bool iconRight = false,
    bool isSubmit = false,
    bool isLoading = false,
  }) {
    final enabled = onTap != null;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          gradient: isSubmit && enabled
              ? const LinearGradient(
                  colors: [Color(0xFFB81C1C), Color(0xFF8B0000)],
                )
              : enabled
                  ? LinearGradient(
                      colors: [
                        AppTheme.gold.withOpacity(0.15),
                        AppTheme.gold.withOpacity(0.05),
                      ],
                    )
                  : null,
          color: (!isSubmit && !enabled) ? Colors.white.withOpacity(0.05) : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSubmit && enabled
                ? const Color(0xFFB81C1C)
                : enabled
                    ? AppTheme.gold.withOpacity(0.4)
                    : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: isSubmit && enabled
              ? [
                  BoxShadow(
                    color: AppTheme.deepRed.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : enabled
                  ? [
                      BoxShadow(
                        color: AppTheme.gold.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: AppTheme.parchment, strokeWidth: 2.5),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!iconRight) Icon(icon, color: enabled ? AppTheme.parchment : Colors.white24, size: 22),
                  if (!iconRight) const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: enabled ? AppTheme.parchment : Colors.white24,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  if (iconRight) const SizedBox(width: 8),
                  if (iconRight) Icon(icon, color: enabled ? AppTheme.parchment : Colors.white24, size: 22),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentStep];
    final isLast = _currentStep == _questions.length - 1;
    final isFirst = _currentStep == 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
              const SizedBox(height: 12),

              // Progress bar with connected dots
              _buildProgressBar(),

              const SizedBox(height: 6),

              // Step label
              Text(
                'QUESTION ${_currentStep + 1} OF ${_questions.length}',
                style: TextStyle(
                  color: AppTheme.parchment.withOpacity(0.45),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 8),

              // Main content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: AppTheme.frostedGlass(
                      opacity: 0.25,
                      padding: const EdgeInsets.fromLTRB(36, 24, 36, 20),
                      child: Column(
                        children: [
                          // Question
                          Text(
                            q.question,
                            style: const TextStyle(
                              color: AppTheme.parchment,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 6),

                          // Subtitle
                          Text(
                            'Select options and/or type your own answer',
                            style: TextStyle(
                              color: AppTheme.parchment.withOpacity(0.4),
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Chips + type own
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  _buildChipGrid(q.chips, q.icons),
                                  const SizedBox(height: 14),
                                  _buildTypeOwnButton(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Navigation row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back
                    AnimatedOpacity(
                      opacity: isFirst ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: IgnorePointer(
                        ignoring: isFirst,
                        child: _buildNavButton(
                          label: 'BACK',
                          icon: Icons.arrow_back_rounded,
                          onTap: () => _goToStep(_currentStep - 1),
                        ),
                      ),
                    ),
                    // Next / Submit
                    isLast
                        ? _buildNavButton(
                            label: 'SUBMIT',
                            icon: Icons.send_rounded,
                            iconRight: true,
                            onTap: _canProceed ? _submitSurvey : null,
                            isSubmit: true,
                            isLoading: _isSubmitting,
                          )
                        : _buildNavButton(
                            label: 'NEXT',
                            icon: Icons.arrow_forward_rounded,
                            iconRight: true,
                            onTap: _canProceed ? () => _goToStep(_currentStep + 1) : null,
                          ),
                  ],
                ),
              ),

              // Text field (sits above keyboard, always visible when typing)
              if (_showKeyboard) _buildTextField(),

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
                onTap: () => Navigator.pushReplacementNamed(context, '/'),
                borderRadius: BorderRadius.circular(30),
                splashColor: AppTheme.gold.withOpacity(0.3),
                highlightColor: AppTheme.gold.withOpacity(0.1),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
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

// ── Helper data class ──

class _QuestionData {
  final String question;
  final List<String> chips;
  final List<IconData> icons;

  const _QuestionData({
    required this.question,
    required this.chips,
    required this.icons,
  });
}
