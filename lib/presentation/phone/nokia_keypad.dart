import 'package:flutter/material.dart';
import '../../core/constants/nokia_colors.dart';

class NokiaKeypad extends StatelessWidget {
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onSelect;
  final VoidCallback onBack;
  final Function(String) onNumericKey;

  const NokiaKeypad({
    super.key,
    required this.onUp,
    required this.onDown,
    required this.onLeft,
    required this.onRight,
    required this.onSelect,
    required this.onBack,
    required this.onNumericKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Nokia 1100 Top Function Keys Row: [Navi / Menu] [Scroll Rocker Up/Down] [C / Back]
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Navi/Menu Key
              _buildSoftButton(
                label: 'MENU',
                subLabel: '—',
                color: NokiaColors.casingRubberKey,
                width: 68,
                height: 44,
                onPressed: onSelect,
              ),

              // Center 2-Way Scroll Rocker Key (Nokia 1100 signature rocker)
              Container(
                width: 72,
                height: 48,
                decoration: BoxDecoration(
                  color: NokiaColors.casingBezel,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      offset: Offset(0, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: onUp,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(24),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_drop_up,
                            color: Colors.white70,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    Container(width: 1, height: 26, color: Colors.white24),
                    Expanded(
                      child: InkWell(
                        onTap: onDown,
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(24),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white70,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right "C" Key
              _buildSoftButton(
                label: 'C',
                subLabel: '—',
                color: NokiaColors.casingRubberKey,
                width: 68,
                height: 44,
                onPressed: onBack,
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // 2. Numeric Keypad 3x4 Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              _buildKeyRow([
                _KeyData(key: '1', sub: 'oo', onPressed: () => onNumericKey('1')),
                _KeyData(
                  key: '2',
                  sub: 'abc ▲',
                  onPressed: () {
                    onUp();
                    onNumericKey('2');
                  },
                ),
                _KeyData(key: '3', sub: 'def', onPressed: () => onNumericKey('3')),
              ]),
              const SizedBox(height: 5),
              _buildKeyRow([
                _KeyData(
                  key: '4',
                  sub: '◄ ghi',
                  onPressed: () {
                    onLeft();
                    onNumericKey('4');
                  },
                ),
                _KeyData(
                  key: '5',
                  sub: 'jkl OK',
                  onPressed: () {
                    onSelect();
                    onNumericKey('5');
                  },
                ),
                _KeyData(
                  key: '6',
                  sub: 'mno ►',
                  onPressed: () {
                    onRight();
                    onNumericKey('6');
                  },
                ),
              ]),
              const SizedBox(height: 5),
              _buildKeyRow([
                _KeyData(key: '7', sub: 'pqrs', onPressed: () => onNumericKey('7')),
                _KeyData(
                  key: '8',
                  sub: 'tuv ▼',
                  onPressed: () {
                    onDown();
                    onNumericKey('8');
                  },
                ),
                _KeyData(key: '9', sub: 'wxyz', onPressed: () => onNumericKey('9')),
              ]),
              const SizedBox(height: 5),
              _buildKeyRow([
                _KeyData(key: '*', sub: '+', onPressed: () => onNumericKey('*')),
                _KeyData(key: '0', sub: '␣', onPressed: () => onNumericKey('0')),
                _KeyData(key: '#', sub: '⇧', onPressed: () => onNumericKey('#')),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyRow(List<_KeyData> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: keys.map((k) => _buildNumpadButton(k)).toList(),
    );
  }

  Widget _buildNumpadButton(_KeyData data) {
    return _TactileButton(
      width: 74,
      height: 42,
      onPressed: data.onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data.key,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: NokiaColors.casingKeyText,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            data.sub,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoftButton({
    required String label,
    required String subLabel,
    required Color color,
    required double width,
    required double height,
    required VoidCallback onPressed,
  }) {
    return _TactileButton(
      width: width,
      height: height,
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: NokiaColors.casingKeyText,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            subLabel,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyData {
  final String key;
  final String sub;
  final VoidCallback onPressed;

  const _KeyData({
    required this.key,
    required this.sub,
    required this.onPressed,
  });
}

class _TactileButton extends StatefulWidget {
  final double width;
  final double height;
  final Widget child;
  final VoidCallback onPressed;

  const _TactileButton({
    required this.width,
    required this.height,
    required this.child,
    required this.onPressed,
  });

  @override
  State<_TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<_TactileButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: widget.width,
        height: widget.height,
        transform: _isPressed
            ? Matrix4.translationValues(0.0, 1.5, 0.0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: _isPressed
              ? const Color(0xFFBAC0CA)
              : NokiaColors.casingRubberKey,
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isPressed
                ? [const Color(0xFFB5BAC4), const Color(0xFFCAD0DA)]
                : [const Color(0xFFE4E8EE), const Color(0xFFBAC0CA)],
          ),
          boxShadow: _isPressed
              ? [
                  const BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 1,
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Colors.black45,
                    offset: Offset(0, 2.5),
                    blurRadius: 2,
                  ),
                  const BoxShadow(
                    color: Colors.white70,
                    offset: Offset(0, -1),
                    blurRadius: 1,
                  ),
                ],
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}
