import 'package:material_ui/material_ui.dart';

import 'app/theme/nashra_tokens.dart';

void main() {
  runApp(const NashraApp());
}

class NashraApp extends StatelessWidget {
  const NashraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: NashraStrings.appTitle,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: NashraColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: NashraColors.olive,
          brightness: Brightness.light,
        ),
        fontFamily: NashraTypography.fontFamily,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  const ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    const ChatMessage(
      text: NashraStrings.greeting,
      isUser: false,
    ),
  ];

  void _sendMessage() {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true),
      );

      _messages.add(
        const ChatMessage(
          text: NashraStrings.placeholderReply,
          isUser: false,
        ),
      );
    });

    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: NashraColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: NashraSpacing.appBarTitleSpacing,
        title: Row(
          children: [
            Container(
              width: NashraSizes.appBarIcon,
              height: NashraSizes.appBarIcon,
              decoration: BoxDecoration(
                color: NashraColors.olive.withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(NashraSizes.appBarIconRadius),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: NashraColors.olive,
                size: NashraSizes.appBarIconGlyph,
              ),
            ),
            SizedBox(width: NashraSpacing.appBarIconGap),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  NashraStrings.appTitle,
                  style: NashraTypography.title,
                ),
                SizedBox(height: NashraSpacing.titleSubtitleGap),
                Text(
                  NashraStrings.subtitle,
                  style: NashraTypography.subtitle,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert_rounded,
              color: NashraColors.text,
            ),
          ),
          SizedBox(width: NashraSpacing.appBarActionsTrailing),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(NashraSizes.appBarDividerHeight),
          child: Container(
            height: NashraSizes.appBarDividerHeight,
            color: NashraColors.divider,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: NashraSpacing.listPadding,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];

                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: NashraSpacing.messagePadding,
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: NashraSizes.avatar,
              height: NashraSizes.avatar,
              decoration: BoxDecoration(
                color: NashraColors.olive.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(NashraSizes.avatarRadius),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: NashraSizes.avatarGlyph,
                color: NashraColors.olive,
              ),
            ),
            SizedBox(width: NashraSpacing.avatarGap),
          ],
          Flexible(
            child: Container(
              constraints:
                  const BoxConstraints(maxWidth: NashraSizes.bubbleMaxWidth),
              padding: NashraSpacing.bubblePadding,
              decoration: BoxDecoration(
                color: isUser ? NashraColors.olive : NashraColors.softBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(NashraSizes.bubbleRadius),
                  topRight: Radius.circular(NashraSizes.bubbleRadius),
                  bottomLeft:
                      Radius.circular(isUser ? NashraSizes.bubbleRadius : NashraSizes.bubbleTailRadius),
                  bottomRight:
                      Radius.circular(isUser ? NashraSizes.bubbleTailRadius : NashraSizes.bubbleRadius),
                ),
              ),
              child: Text(
                message.text,
                style: isUser
                    ? NashraTypography.userMessage
                    : NashraTypography.assistantMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: NashraSpacing.inputBarPadding,
      decoration: BoxDecoration(
        color: NashraColors.background,
        border: Border(
          top: BorderSide(color: NashraColors.divider),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(NashraSizes.inputRadius),
                  border: Border.all(
                    color: NashraColors.inputBorder,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: NashraStrings.inputHint,
                    hintStyle: NashraTypography.hint,
                    contentPadding: NashraSpacing.inputContentPadding,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: NashraSpacing.inputGap),
            SizedBox(
              width: NashraSizes.sendButton,
              height: NashraSizes.sendButton,
              child: IconButton.filled(
                onPressed: _sendMessage,
                style: IconButton.styleFrom(
                  backgroundColor: NashraColors.olive,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(NashraSizes.sendButtonRadius),
                  ),
                ),
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
