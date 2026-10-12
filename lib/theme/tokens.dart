import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens eyeballed from the Figma mockup. If you have the exact hex
/// values in Figma, change them here and the whole app follows.
class Tifo {
  Tifo._();

  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const yellow = Color(0xFFD4AF11);
  static const blue = Color(0xFF5E8BFF);
  static const red = Color(0xFFE52B2E);

  /// Dark text and buttons on the red breach screen.
  static const ink = Color(0xFF2B2727);
  static const grey = Color(0xFF8C8C8C);

  /// Hairlines on black.
  static const rule = Color(0xFF3A3A3A);

  /// The mockup's typeface looks like JetBrains Mono. Swap it here if not.
  static TextStyle mono({
    double size = 12,
    FontWeight weight = FontWeight.w400,
    Color color = white,
    double letterSpacing = 0,
    double height = 1.25,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Small grey caption, e.g. "DEVICE 0482 / LOCAL CONNECTION".
  static TextStyle label({Color color = grey}) =>
      mono(size: 10, color: color, letterSpacing: 0.8);

  /// Yellow breadcrumb above every screen title.
  static TextStyle crumb() => mono(size: 10, color: yellow, letterSpacing: 0.8);

  /// Big screen titles.
  static TextStyle display({Color color = white, double size = 40}) =>
      mono(size: size, weight: FontWeight.w800, color: color, height: 1.1);
}
