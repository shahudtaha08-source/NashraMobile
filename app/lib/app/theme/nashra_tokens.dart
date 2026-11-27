import 'package:material_ui/material_ui.dart';

/// Exact colors used by the existing Nashra chat interface.
abstract final class NashraColors {
  static const Color olive = Color(0xFF68745A);
  static const Color softBlue = Color(0xFFE8EFF2);
  static const Color background = Color(0xFFF7F7F2);
  static const Color text = Color(0xFF30352E);
  static const Color mutedText = Color(0xFF858B80);
  static const Color divider = Color(0xFFEAECE5);
  static const Color inputBorder = Color(0xFFE5E8DF);
  static const Color hint = Color(0xFF9A9F96);
}

/// Typography preserved from the existing chat interface.
abstract final class NashraTypography {
  static const String fontFamily = 'Roboto';

  static const TextStyle title = TextStyle(
    color: NashraColors.text,
    fontSize: 19,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle subtitle = TextStyle(
    color: NashraColors.mutedText,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle hint = TextStyle(
    color: NashraColors.hint,
    fontSize: 14,
  );

  static const TextStyle userMessage = TextStyle(
    color: Colors.white,
    fontSize: 14,
    height: 1.5,
  );

  static const TextStyle assistantMessage = TextStyle(
    color: NashraColors.text,
    fontSize: 14,
    height: 1.5,
  );
}

/// Spacing preserved from the existing chat interface.
abstract final class NashraSpacing {
  static const double appBarTitleSpacing = 20;
  static const double appBarIconGap = 12;
  static const double appBarActionsTrailing = 6;
  static const double titleSubtitleGap = 2;
  static const double avatarGap = 9;
  static const double inputGap = 10;

  static const EdgeInsets listPadding = EdgeInsets.fromLTRB(16, 24, 16, 20);
  static const EdgeInsets messagePadding = EdgeInsets.only(bottom: 16);
  static const EdgeInsets bubblePadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const EdgeInsets inputBarPadding =
      EdgeInsets.fromLTRB(14, 12, 14, 16);
  static const EdgeInsets inputContentPadding =
      EdgeInsets.symmetric(horizontal: 18, vertical: 13);
}

/// Sizes and corner radii preserved from the existing chat interface.
abstract final class NashraSizes {
  static const double appBarIcon = 42;
  static const double appBarIconRadius = 14;
  static const double appBarIconGlyph = 23;
  static const double appBarDividerHeight = 1;

  static const double avatar = 30;
  static const double avatarRadius = 10;
  static const double avatarGlyph = 16;

  static const double bubbleMaxWidth = 290;
  static const double bubbleRadius = 18;
  static const double bubbleTailRadius = 5;

  static const double inputRadius = 24;
  static const double sendButton = 48;
  static const double sendButtonRadius = 17;
}

/// User-facing strings preserved from the existing chat interface.
abstract final class NashraStrings {
  static const String appTitle = 'Meri Nashra';
  static const String subtitle = 'Your personal companion';
  static const String greeting =
      "Assalamu Alaikum! I'm Nashra. How can I help you today?";
  static const String placeholderReply =
      "I'm here. AI connection will be added in a later step.";
  static const String inputHint = 'Message Nashra...';
}
