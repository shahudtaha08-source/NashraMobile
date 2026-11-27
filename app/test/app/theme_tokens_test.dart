import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meri_nashra/app/theme/nashra_tokens.dart';

void main() {
  test('theme tokens preserve the current Nashra palette', () {
    expect(NashraColors.olive, const Color(0xFF68745A));
    expect(NashraColors.softBlue, const Color(0xFFE8EFF2));
    expect(NashraColors.background, const Color(0xFFF7F7F2));
    expect(NashraColors.text, const Color(0xFF30352E));
    expect(NashraColors.mutedText, const Color(0xFF858B80));
    expect(NashraColors.divider, const Color(0xFFEAECE5));
    expect(NashraColors.inputBorder, const Color(0xFFE5E8DF));
    expect(NashraColors.hint, const Color(0xFF9A9F96));
  });

  test('theme tokens preserve typography and strings', () {
    expect(NashraTypography.fontFamily, 'Roboto');
    expect(NashraTypography.title.fontSize, 19);
    expect(NashraTypography.title.fontWeight, FontWeight.w700);
    expect(NashraTypography.subtitle.fontSize, 11);
    expect(NashraTypography.subtitle.fontWeight, FontWeight.w400);
    expect(NashraTypography.hint.fontSize, 14);
    expect(NashraTypography.userMessage.fontSize, 14);
    expect(NashraTypography.userMessage.height, 1.5);
    expect(NashraTypography.assistantMessage.height, 1.5);

    expect(NashraStrings.appTitle, 'Meri Nashra');
    expect(NashraStrings.subtitle, 'Your personal companion');
    expect(
      NashraStrings.greeting,
      "Assalamu Alaikum! I'm Nashra. How can I help you today?",
    );
    expect(
      NashraStrings.placeholderReply,
      "I'm here. AI connection will be added in a later step.",
    );
    expect(NashraStrings.inputHint, 'Message Nashra...');
  });

  test('theme tokens preserve spacing and sizes', () {
    expect(NashraSpacing.appBarTitleSpacing, 20);
    expect(NashraSpacing.appBarIconGap, 12);
    expect(NashraSpacing.appBarActionsTrailing, 6);
    expect(NashraSpacing.titleSubtitleGap, 2);
    expect(NashraSpacing.avatarGap, 9);
    expect(NashraSpacing.inputGap, 10);
    expect(NashraSpacing.listPadding, const EdgeInsets.fromLTRB(16, 24, 16, 20));
    expect(NashraSpacing.messagePadding, const EdgeInsets.only(bottom: 16));
    expect(
      NashraSpacing.bubblePadding,
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
    expect(
      NashraSpacing.inputBarPadding,
      const EdgeInsets.fromLTRB(14, 12, 14, 16),
    );
    expect(
      NashraSpacing.inputContentPadding,
      const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
    );

    expect(NashraSizes.appBarIcon, 42);
    expect(NashraSizes.appBarIconRadius, 14);
    expect(NashraSizes.appBarIconGlyph, 23);
    expect(NashraSizes.appBarDividerHeight, 1);
    expect(NashraSizes.avatar, 30);
    expect(NashraSizes.avatarRadius, 10);
    expect(NashraSizes.avatarGlyph, 16);
    expect(NashraSizes.bubbleMaxWidth, 290);
    expect(NashraSizes.bubbleRadius, 18);
    expect(NashraSizes.bubbleTailRadius, 5);
    expect(NashraSizes.inputRadius, 24);
    expect(NashraSizes.sendButton, 48);
    expect(NashraSizes.sendButtonRadius, 17);
  });
}
