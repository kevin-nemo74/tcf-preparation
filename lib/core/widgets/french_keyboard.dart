import 'package:flutter/material.dart';

class FrenchKeyboardToolbar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onClose;

  const FrenchKeyboardToolbar({
    super.key,
    required this.controller,
    this.onClose,
  });

  @override
  State<FrenchKeyboardToolbar> createState() => _FrenchKeyboardToolbarState();
}

class _FrenchKeyboardToolbarState extends State<FrenchKeyboardToolbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isCapsLock = false;

  static const List<List<String>> _lowercaseRows = [
    ['é', 'è', 'ê', 'ë', 'à', 'â', 'ä', 'ï', 'î', 'ô', 'û', 'ü'],
    ['ç', 'œ', 'æ', 'ÿ', '«', '»', '…', '–', '—', '’', 'æ', 'œ'],
  ];

  static const List<List<String>> _uppercaseRows = [
    ['É', 'È', 'Ê', 'Ë', 'À', 'Â', 'Ä', 'Ï', 'Î', 'Ô', 'Û', 'Ü'],
    ['Ç', 'Œ', 'Æ', 'Ÿ', '«', '»', '…', '–', '—', '’', 'Æ', 'Œ'],
  ];

  List<List<String>> get _currentRows =>
      _isCapsLock ? _uppercaseRows : _lowercaseRows;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _insertCharacter(String char) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final newText = text.replaceRange(selection.start, selection.end, char);
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + char.length),
    );
  }

  void _toggleCaps() {
    setState(() {
      _isCapsLock = !_isCapsLock;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 60),
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          border: Border(
            top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
          ),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.keyboard_alt_outlined,
                      size: 16,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Caractères français',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _CapsToggleButton(
                      isCapsLock: _isCapsLock,
                      onToggle: _toggleCaps,
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        _animationController.reverse().then((_) {
                          widget.onClose?.call();
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ..._currentRows.map((row) => _buildKeyRow(row, cs)),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyRow(List<String> chars, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: chars.map((char) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Material(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => _insertCharacter(char),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      char,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CapsToggleButton extends StatelessWidget {
  final bool isCapsLock;
  final VoidCallback onToggle;

  const _CapsToggleButton({required this.isCapsLock, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: isCapsLock ? cs.primaryContainer : cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCapsLock
                  ? cs.primary
                  : cs.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.text_fields,
                size: 14,
                color: isCapsLock
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                isCapsLock ? 'MAJ' : 'maj',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isCapsLock
                      ? cs.primary
                      : cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
