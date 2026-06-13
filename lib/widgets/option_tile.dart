import 'package:flutter/material.dart';
import 'app_components.dart';

enum OptionState { normal, correct, incorrect, selected }

class OptionTile extends StatelessWidget {
  final String text;
  final OptionState state;
  final VoidCallback? onTap;
  final bool isMultiSelect;
  final bool isSelected;

  const OptionTile({
    super.key,
    required this.text,
    this.state = OptionState.normal,
    this.onTap,
    this.isMultiSelect = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? trailingIcon;

    switch (state) {
      case OptionState.correct:
        backgroundColor = isDark
            ? const Color(0xFF064E3B)
            : const Color(0xFFD1FAE5);
        borderColor = const Color(0xFF10B981);
        textColor = isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46);
        trailingIcon = Icons.check_circle;
        break;
      case OptionState.incorrect:
        backgroundColor = isDark
            ? const Color(0xFF7F1D1D)
            : const Color(0xFFFEE2E2);
        borderColor = const Color(0xFFEF4444);
        textColor = isDark ? const Color(0xFFFECACA) : const Color(0xFF991B1B);
        trailingIcon = Icons.cancel;
        break;
      case OptionState.selected:
        backgroundColor = colors.primaryContainer.withValues(alpha: 0.72);
        borderColor = colors.primary;
        textColor = colors.onPrimaryContainer;
        trailingIcon = isMultiSelect
            ? Icons.check_box
            : Icons.radio_button_checked;
        break;
      default:
        backgroundColor = isDark
            ? (theme.cardTheme.color ?? colors.surfaceContainerHighest)
            : Colors.white;
        borderColor = colors.outlineVariant.withValues(alpha: 0.62);
        textColor = colors.onSurface;
        trailingIcon = isMultiSelect ? Icons.check_box_outline_blank : null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor, width: 1.4),
              borderRadius: BorderRadius.circular(20),
              boxShadow: state == OptionState.normal
                  ? AppShadows.soft(context)
                  : const [],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                if (trailingIcon != null)
                  Icon(
                    trailingIcon,
                    color: state == OptionState.correct
                        ? const Color(0xFF10B981)
                        : state == OptionState.incorrect
                        ? const Color(0xFFEF4444)
                        : colors.primary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
