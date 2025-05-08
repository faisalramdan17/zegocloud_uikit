import 'package:flutter/material.dart';
import 'package:zegocloud_uikit/core/core.dart';

class AppRoundedButton extends StatelessWidget {
  const AppRoundedButton({
    super.key,
    this.onPressed,
    required this.label,
    this.labelStyle,
    this.icon,
    this.color,
    this.labelColor,
    this.padding,
    this.height = 47,
    this.width,
    this.useBorder = false,
    this.expanded = true,
  });

  final VoidCallback? onPressed;
  final String label;
  final TextStyle? labelStyle;
  final Widget? icon;
  final Color? color, labelColor;
  final EdgeInsetsGeometry? padding;
  final double? height, width;
  final bool useBorder, expanded;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(30);
    final colorButton = onPressed == null
        ? context.theme.shadowColor.withValues(alpha: (0.5 * 255).toDouble())
        : (color ??
            (useBorder
                ? context.theme.appBarTheme.backgroundColor
                : context.theme.colorScheme.primary));

    return Padding(
      padding: !expanded
          ? const EdgeInsets.all(0)
          : (padding ??
              const EdgeInsets.symmetric(horizontal: 30, vertical: 8)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: colorButton,
            borderRadius: borderRadius,
            border: colorButton!.computeLuminance() >= 0.5 && useBorder
                ? Border.all(color: Colors.grey)
                : null,
          ),
          height: height,
          width: width ?? context.screenWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: icon!,
                ),
              Text(
                label,
                style: labelStyle ??
                    TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: labelColor ??
                          (colorButton.computeLuminance() >= 0.5
                              ? Colors.black87
                              : Colors.white),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
