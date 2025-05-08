import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  const TitleText({
    super.key,
    required this.title,
    this.subtitle,
    this.spacer = 2,
    this.fontSizeTitle = 33,
    this.fontSizeSubtitle = 20,
    this.centerText = false,
    this.colorTitle,
    this.colorSubtitle = Colors.black38,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final double spacer;
  final Color? colorTitle, colorSubtitle;
  final double fontSizeTitle, fontSizeSubtitle;
  final bool centerText;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment:
            centerText ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
            child: Text(
              title,
              textAlign: centerText ? TextAlign.center : TextAlign.left,
              style: TextStyle(
                color: colorTitle,
                fontSize: fontSizeTitle,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: spacer),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
              child: Text(
                subtitle!,
                textAlign: centerText ? TextAlign.center : TextAlign.left,
                style: TextStyle(
                  color:
                      colorSubtitle?.withValues(alpha: (0.8 * 255).toDouble()),
                  fontSize: fontSizeSubtitle,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
