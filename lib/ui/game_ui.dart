import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class GameUi {
  static const panelBg = Color(0xFF3A3F4B);
  static const panelBorder = Color(0xFF1A1A1A);
  static const titleCoral = Color(0xFFF07167);
  static const labelGray = Color(0xFFADB5BD);
  static const btnYellow = Color(0xFFFFC832);
  static const btnYellowDark = Color(0xFFE5A820);

  static TextStyle lilita({
    required double size,
    Color color = Colors.white,
    double height = 1.0,
    double letterSpacing = 0,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.lilitaOne(
      fontSize: size,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      shadows: shadows,
      decoration: TextDecoration.none,
      decorationColor: Colors.transparent,
    );
  }
}
