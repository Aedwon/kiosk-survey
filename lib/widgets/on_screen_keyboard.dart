import 'package:flutter/material.dart';

class OnScreenKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onDismiss;

  const OnScreenKeyboard({
    super.key,
    required this.controller,
    required this.onDismiss,
  });

  @override
  State<OnScreenKeyboard> createState() => _OnScreenKeyboardState();
}

class _OnScreenKeyboardState extends State<OnScreenKeyboard> {
  bool _isShift = true; // Start with uppercase
  bool _isSymbols = false; // Start with letters

  void _insertText(String text) {
    String processedText = text;
    // Apply shift if it's a letter and we're on the letter keyboard
    if (!_isSymbols && text.length == 1 && text.toLowerCase() != text.toUpperCase()) {
      processedText = _isShift ? text.toUpperCase() : text.toLowerCase();
      // Auto-release shift after typing a letter (like a phone keyboard)
      if (_isShift) {
        setState(() => _isShift = false);
      }
    }

    final int cursorPos = widget.controller.selection.base.offset;
    final String currentText = widget.controller.text;

    if (cursorPos >= 0) {
      final newText = currentText.substring(0, cursorPos) +
          processedText +
          currentText.substring(cursorPos);
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: cursorPos + processedText.length),
      );
    } else {
      widget.controller.text += processedText;
      widget.controller.selection = TextSelection.collapsed(offset: widget.controller.text.length);
    }
  }

  void _backspace() {
    final int cursorPos = widget.controller.selection.base.offset;
    final String currentText = widget.controller.text;

    if (cursorPos > 0) {
      final newText = currentText.substring(0, cursorPos - 1) +
          currentText.substring(cursorPos);
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: cursorPos - 1),
      );
    } else if (currentText.isNotEmpty && cursorPos == -1) {
      // If no cursor selection, just backspace the end
      widget.controller.text = currentText.substring(0, currentText.length - 1);
      widget.controller.selection = TextSelection.collapsed(offset: widget.controller.text.length);
    }
  }

  Widget _buildKey(String label, {double flex = 1, VoidCallback? onTap, Color? color}) {
    String displayLabel = label;
    if (!_isSymbols && label.length == 1 && label.toLowerCase() != label.toUpperCase()) {
      displayLabel = _isShift ? label.toUpperCase() : label.toLowerCase();
    }

    return Expanded(
      flex: (flex * 10).toInt(),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          color: color ?? Colors.black87,
          borderRadius: BorderRadius.circular(8),
          elevation: 4,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap ?? () => _insertText(displayLabel),
            child: Container(
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                displayLabel,
                style: const TextStyle(
                  color: Color(0xFFFFFdd0),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconKey(IconData icon, VoidCallback onTap, {double flex = 1, Color? color}) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          color: color ?? Colors.black87,
          borderRadius: BorderRadius.circular(8),
          elevation: 4,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Container(
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFFFFFdd0), size: 32),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      padding: const EdgeInsets.all(8.0).copyWith(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _isSymbols ? _buildSymbolsLayout() : _buildQwertyLayout(),
      ),
    );
  }

  List<Widget> _buildQwertyLayout() {
    return [
      Row(
        children: [
          _buildKey('1'), _buildKey('2'), _buildKey('3'), _buildKey('4'), _buildKey('5'),
          _buildKey('6'), _buildKey('7'), _buildKey('8'), _buildKey('9'), _buildKey('0'),
        ],
      ),
      Row(
        children: [
          _buildKey('q'), _buildKey('w'), _buildKey('e'), _buildKey('r'), _buildKey('t'),
          _buildKey('y'), _buildKey('u'), _buildKey('i'), _buildKey('o'), _buildKey('p'),
        ],
      ),
      Row(
        children: [
          const Spacer(flex: 5), // Half key spacer
          _buildKey('a'), _buildKey('s'), _buildKey('d'), _buildKey('f'), _buildKey('g'),
          _buildKey('h'), _buildKey('j'), _buildKey('k'), _buildKey('l'),
          const Spacer(flex: 5),
        ],
      ),
      Row(
        children: [
          _buildIconKey(
            _isShift ? Icons.arrow_upward : Icons.keyboard_arrow_up,
            () {
              setState(() => _isShift = !_isShift);
            },
            flex: 1.5,
            color: _isShift ? Colors.white24 : Colors.black87,
          ),
          _buildKey('z'), _buildKey('x'), _buildKey('c'), _buildKey('v'), _buildKey('b'),
          _buildKey('n'), _buildKey('m'), _buildKey(','), _buildKey('.'),
          _buildIconKey(Icons.backspace, _backspace, flex: 1.5, color: Colors.red[900]),
        ],
      ),
      Row(
        children: [
          _buildKey('?123', flex: 2, onTap: () => setState(() => _isSymbols = true)),
          _buildKey('SPACE', flex: 6, onTap: () => _insertText(' ')),
          _buildKey('DONE', flex: 2, onTap: widget.onDismiss, color: Colors.green[900]),
        ],
      )
    ];
  }

  List<Widget> _buildSymbolsLayout() {
    return [
      Row(
        children: [
          _buildKey('!'), _buildKey('@'), _buildKey('#'), _buildKey('\$'), _buildKey('%'),
          _buildKey('^'), _buildKey('&'), _buildKey('*'), _buildKey('('), _buildKey(')'),
        ],
      ),
      Row(
        children: [
          _buildKey('-'), _buildKey('_'), _buildKey('='), _buildKey('+'), _buildKey('['),
          _buildKey(']'), _buildKey('{'), _buildKey('}'), _buildKey('\\'), _buildKey('|'),
        ],
      ),
      Row(
        children: [
          const Spacer(flex: 5), // Half key spacer
          _buildKey(';'), _buildKey(':'), _buildKey('\''), _buildKey('"'), _buildKey('<'),
          _buildKey('>'), _buildKey('/'), _buildKey('?'), _buildKey('`'),
          const Spacer(flex: 5),
        ],
      ),
      Row(
        children: [
          const Spacer(flex: 15), // Empty space matching Shift length
          _buildKey('~'), _buildKey(','), _buildKey('.'),
          const Spacer(flex: 40),
          _buildIconKey(Icons.backspace, _backspace, flex: 1.5, color: Colors.red[900]),
        ],
      ),
      Row(
        children: [
          _buildKey('ABC', flex: 2, onTap: () => setState(() => _isSymbols = false)),
          _buildKey('SPACE', flex: 6, onTap: () => _insertText(' ')),
          _buildKey('DONE', flex: 2, onTap: widget.onDismiss, color: Colors.green[900]),
        ],
      )
    ];
  }
}
