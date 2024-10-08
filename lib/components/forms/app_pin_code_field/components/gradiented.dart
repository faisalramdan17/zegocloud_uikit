part of '../app_pin_code_field.dart';

/// Don't forget to set a child foreground color to white
class Gradiented extends StatelessWidget {
  final Gradient gradient;
  final Widget child;

  const Gradiented({super.key, required this.child, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(shaderCallback: gradient.createShader, child: child);
  }
}
