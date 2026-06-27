import 'package:flutter/material.dart';
import '../../widgets/common_bottom_nav_bar.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [
    {
      'text': '새우랑 베타 같이 키워도 되나요?',
      'isUser': true,
    },
    {
      'text': '가능은 하지만 베타의 성격에 따라 새우를 공격할 수 있어 주의가 필요합니다.',
      'isUser': false,
    },
  ];

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void sendMessage() {
    final String text = messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    setState(() {
      messages.add({
        'text': text,
        'isUser': true,
      });

      messages.add({
        'text': '입력하신 내용을 바탕으로 답변을 준비할게요.',
        'isUser': false,
      });
    });

    messageController.clear();
    scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 58,
              color: Colors.white,
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 17,
                        color: Color(0xFF8FA8D8),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/community');
                      },
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Chat GPT',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D3E5F),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFBFE4FF),
                      Color(0xFF8FC4F7),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];

                          return ChatBubble(
                            text: message['text'],
                            isUser: message['isUser'],
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: TextField(
                                  controller: messageController,
                                  maxLines: 1,
                                  cursorColor: const Color(0xFF8FA8D8),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.0,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3E5F),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '메시지를 입력해주세요.',
                                    hintStyle: TextStyle(
                                      fontSize: 11,
                                      height: 1.0,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF8FA8D8)
                                          .withOpacity(0.75),
                                    ),
                                    border: InputBorder.none,
                                    isCollapsed: true,
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(
                                      14,
                                      1,
                                      14,
                                      0,
                                    ),
                                  ),
                                  onSubmitted: (_) {
                                    sendMessage();
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              splashColor:
                                  const Color(0xFF8FA8D8).withOpacity(0.18),
                              highlightColor:
                                  const Color(0xFF8FA8D8).withOpacity(0.08),
                              onTap: sendMessage,
                              child: const SizedBox(
                                width: 42,
                                height: 34,
                                child: Center(
                                  child: Text(
                                    '전송',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF8FA8D8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const CommonBottomNavBar(
              selectedIndex: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final Color bubbleColor =
        isUser ? const Color(0xFFDDF3FF) : Colors.white;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.74,
        ),
        margin: const EdgeInsets.only(bottom: 14),
        child: CustomPaint(
          painter: ChatBubblePainter(
            color: bubbleColor,
            isUser: isUser,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isUser ? 12 : 18,
              7,
              isUser ? 18 : 12,
              9,
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                height: 1.25,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3E5F),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatBubblePainter extends CustomPainter {
  final Color color;
  final bool isUser;

  ChatBubblePainter({
    required this.color,
    required this.isUser,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.04)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        3,
      );

    final Paint bubblePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Path createLeftBubblePath(Size size) {
      const double radius = 8;
      const double tailWidth = 5;
      const double tailHeight = 4;
      const double tailStartY = 20;

      final Path path = Path();

      path.moveTo(radius, 0);

      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(
        size.width,
        0,
        size.width,
        radius,
      );

      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      );

      path.lineTo(radius, size.height);
      path.quadraticBezierTo(
        0,
        size.height,
        0,
        size.height - radius,
      );

      path.lineTo(0, tailStartY + tailHeight);

      path.lineTo(-tailWidth, tailStartY + tailHeight + 2);
      path.lineTo(0, tailStartY);

      path.lineTo(0, radius);
      path.quadraticBezierTo(
        0,
        0,
        radius,
        0,
      );

      path.close();

      return path;
    }

    final Path path = createLeftBubblePath(size);

    if (isUser) {
      canvas.save();

      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);

      canvas.drawPath(path.shift(const Offset(0, 1)), shadowPaint);
      canvas.drawPath(path, bubblePaint);

      canvas.restore();
    } else {
      canvas.drawPath(path.shift(const Offset(0, 1)), shadowPaint);
      canvas.drawPath(path, bubblePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ChatBubblePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isUser != isUser;
  }
}