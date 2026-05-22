import 'package:flutter/material.dart';

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
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? trailingIcon;

    switch (state) {
      case OptionState.correct:
        backgroundColor = const Color(0xFFD1FAE5);
        borderColor = const Color(0xFF10B981);
        textColor = const Color(0xFF065F46);
        trailingIcon = Icons.check_circle;
        break;
      case OptionState.incorrect:
        backgroundColor = const Color(0xFFFEE2E2);
        borderColor = const Color(0xFFEF4444);
        textColor = const Color(0xFF991B1B);
        trailingIcon = Icons.cancel;
        break;
      case OptionState.selected:
        backgroundColor = const Color(0xFFE0E7FF);
        borderColor = const Color(0xFF6366F1);
        textColor = const Color(0xFF3730A3);
        trailingIcon = isMultiSelect ? Icons.check_box : Icons.radio_button_checked;
        break;
      case OptionState.normal:
      default:
        backgroundColor = Colors.white;
        borderColor = const Color(0xFFE5E7EB);
        textColor = const Color(0xFF374151);
        trailingIcon = isMultiSelect ? Icons.check_box_outline_blank : null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(12),
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
                            : const Color(0xFF6366F1),
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
