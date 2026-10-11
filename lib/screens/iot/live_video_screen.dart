import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LiveVideoScreen extends StatelessWidget {
  const LiveVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 지금은 화면 구현용 가짜 사용자 이름
    // 나중에 로그인 정보 or 백엔드에서 받은 이름으로 교체
    const String userName = '한경이';

    // .env에서 AWS Public IP 가져오기
    final String videoBaseUrl = dotenv.env['VIDEO_BASE_URL'] ?? '';

    // AWS MediaMTX WebRTC 주소
    final String videoUrl = '$videoBaseUrl/cam/';

    final DateTime now = DateTime.now();
    final String todayText =
        '${now.year}년 ${now.month}월 ${now.day}일 (${getKoreanWeekday(now.weekday)})';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 뒤로가기 버튼
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Color(0xFF8FA8D8),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 30),

              // 상단 환영 문구
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D3E5F),
                  ),
                  children: [
                    TextSpan(text: '환영합니다 '),
                    TextSpan(
                      text: userName,
                      style: TextStyle(
                        color: Color(0xFF25A8F2),
                      ),
                    ),
                    TextSpan(text: '님'),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 날짜 그라데이션 박스
              Container(
                width: double.infinity,
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF238BFF),
                      Color(0xFF25C6F2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        todayText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.photo_camera_outlined,
                      size: 25,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 실시간 영상 영역
              RealtimeVideoBox(
                videoUrl: videoUrl,
              ),

              const SizedBox(height: 18),

              const Center(
                child: Text(
                  '실시간 어항 영상',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF222222),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RealtimeVideoBox extends StatefulWidget {
  final String videoUrl;

  const RealtimeVideoBox({
    super.key,
    required this.videoUrl,
  });

  @override
  State<RealtimeVideoBox> createState() =>
      _RealtimeVideoBoxState();
}

class _RealtimeVideoBoxState extends State<RealtimeVideoBox> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )
      ..setBackgroundColor(
        Colors.black,
      )
      ..loadRequest(
        Uri.parse(widget.videoUrl),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: double.infinity,
        height: 155,
        child: WebViewWidget(
          controller: _controller,
        ),
      ),
    );
  }
}

String getKoreanWeekday(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return '월';

    case DateTime.tuesday:
      return '화';

    case DateTime.wednesday:
      return '수';

    case DateTime.thursday:
      return '목';

    case DateTime.friday:
      return '금';

    case DateTime.saturday:
      return '토';

    case DateTime.sunday:
      return '일';

    default:
      return '';
  }
}