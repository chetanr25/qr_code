import 'package:flutter/material.dart';

/// Curated gradient presets used as QR backgrounds.
class AppGradients {
  static const Map<String, List<Color>> presets = {
    'Indigo Pop': [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
    'Timber': [Color(0xfffc00ff), Color(0xff00dbde)],
    'Racker': [Color(0xfffc466b), Color(0xff3f5efb)],
    'Omolon': [Color(0xff091e3a), Color(0xff2f80ed), Color(0xff2d9ee0)],
    'The Sky & Sea': [Color(0xfffd8112), Color(0xff0085ca)],
    'Passion': [Color(0xfff43b47), Color(0xff453a94)],
    'Lunada': [Color(0xff5433ff), Color(0xff20bdff), Color(0xffa5fecb)],
    'Rose Water': [Color(0xffe55d87), Color(0xff5fc3e4)],
    'Mantle': [Color(0xff24c6dc), Color(0xff514a9d)],
    'Dracula': [Color(0xffdc2424), Color(0xff4a569d)],
    'Sunrise': [Color(0xffc21500), Color(0xffffc500)],
    'Atlas': [Color(0xfffeac5e), Color(0xffc779d0), Color(0xff4bc0c8)],
    'Instagram': [Color(0xff833ab4), Color(0xfffd1d1d), Color(0xfffcb045)],
    'Netflix': [Color(0xff8e0e00), Color(0xff1f1c18)],
    'Deep Space': [Color(0xff000000), Color(0xff434343)],
    'Cosmic Fusion': [Color(0xffff00cc), Color(0xff333399)],
    'Dawn': [Color(0xfff3904f), Color(0xff3b4371)],
    'Vice City': [Color(0xff3494e6), Color(0xffec6ead)],
    'Relay': [Color(0xff3a1c71), Color(0xffd76d77), Color(0xffffaf7b)],
    'King Yna': [Color(0xff1a2a6c), Color(0xffb21f1f), Color(0xfffdbb2d)],
    'Argon': [
      Color(0xff03001e),
      Color(0xff7303c0),
      Color(0xffec38bc),
      Color(0xfffdeff9)
    ],
    'JShine': [Color(0xff12c2e9), Color(0xffc471ed), Color(0xfff64f59)],
    'Wiretap': [Color(0xff8a2387), Color(0xffe94057), Color(0xfff27121)],
    'Mojito': [Color(0xff1d976c), Color(0xff93f9b9)],
    'Bloody Mary': [Color(0xffff512f), Color(0xffdd2476)],
    'Moonlit Asteroid': [Color(0xff0f2027), Color(0xff203a43), Color(0xff2c5364)],
  };

  static List<Color> colorsFor(String name) =>
      presets[name] ?? presets['Indigo Pop']!;

  static LinearGradient of(String name) => LinearGradient(
        colors: colorsFor(name),
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
