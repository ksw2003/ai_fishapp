
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:ai_fishapp/api/api_client.dart';
import 'package:ai_fishapp/widgets/rotating_loading_icon.dart';

class LiveVideoScreen extends StatefulWidget {
  const LiveVideoScreen({super.key});

  @override
  State<LiveVideoScreen> createState() => _LiveVideoScreenState();
}

class _LiveVideoScreenState extends State<LiveVideoScreen> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    getUserName();
  }

  // 로그인한 사용자 닉네임 가져오기
  Future<void> getUserName() async {
    try {
      final response = await ApiClient.get(
        '/api/auth/myinfo',
        token: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          userName = data['user']?['nickname']?.toString() ?? '';
        });
      }
    } catch (e) {
      debugPrint('사용자 이름 조회 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // .env에서 AWS MediaMTX 주소 가져오기
    final String videoBaseUrl =
        dotenv.env['VIDEO_BASE_URL'] ?? '';

    // AWS MediaMTX WebRTC 주소
    final String videoUrl = '$videoBaseUrl/cam/';

    final DateTime now = DateTime.now();

    final String todayText =
        '${now.year}년 ${now.month}월 ${now.day}일 '
        '(${getKoreanWeekday(now.weekday)})';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 뒤로가기 버튼
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 24,
                  color: Color(0xFF8FA8D8),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 30),

              // 로그인한 사용자 환영 문구
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D3E5F),
                  ),
                  children: [
                    const TextSpan(text: '환영합니다 '),
                    TextSpan(
                      text: userName,
                      style: const TextStyle(
                        color: Color(0xFF25A8F2),
                      ),
                    ),
                    const TextSpan(text: '님'),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 날짜 그라데이션 박스
              Container(
                width: double.infinity,
                height: 54,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF238BFF),
                      Color(0xFF25C6F2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        todayText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.photo_camera_outlined,
                      size: 28,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 실시간 영상 영역
              // 화면 너비에 따라 16:9 비율 자동 조절
              RealtimeVideoBox(
                videoUrl: videoUrl,
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  '실시간 어항 영상',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
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

// 실시간 WebRTC 영상 위젯
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

  // 실제 영상 재생 상태
  bool _isLoading = true;
  bool _hasError = false;

  // 영상 연결 제한 시간
  Timer? _timeoutTimer;

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

      // JavaScript에서 Flutter로 영상 상태 전달
      ..addJavaScriptChannel(
        'VideoStatus',
        onMessageReceived: (message) {
          if (!mounted) return;

          if (message.message == 'READY') {
            debugPrint('WebRTC 실제 영상 재생 시작');

            _timeoutTimer?.cancel();

            setState(() {
              _isLoading = false;
              _hasError = false;
            });
          }
        },
      )

      ..setNavigationDelegate(
        NavigationDelegate(
          // 페이지 로딩 시작
          onPageStarted: (url) {
            if (!mounted) return;

            setState(() {
              _isLoading = true;
              _hasError = false;
            });

            _startTimeout();
          },

          // 페이지 로딩 완료
          onPageFinished: (url) async {
            debugPrint('WebView 페이지 로딩 완료');

            if (!mounted) return;

            // WebView 내부 영상 영역 꽉 채우기
            await _fitVideoToBox();

            if (!mounted) return;

            // 실제 영상 재생 감지 시작
            await _monitorVideoPlayback();
          },

          // WebView 리소스 오류
          onWebResourceError: (error) {
            if (!mounted) return;

            debugPrint(
              'WebView 오류: ${error.description}',
            );

            // 리소스 오류만으로 연결 실패 처리하지 않음
            // 최종 연결 실패 여부는 타임아웃에서 판단
          },
        ),
      );

    _loadVideo();
  }

  // WebView 영상 페이지 불러오기
  void _loadVideo() {
    final uri = Uri.tryParse(widget.videoUrl);

    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      _timeoutTimer?.cancel();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
      });

      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    _startTimeout();

    _controller.loadRequest(uri);
  }

  // 영상 연결 제한 시간 (30초)
  void _startTimeout() {
    _timeoutTimer?.cancel();

    _timeoutTimer = Timer(
      const Duration(seconds: 30),
      () {
        if (!mounted || !_isLoading) return;

        debugPrint('WebRTC 영상 연결 시간 초과');

        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      },
    );
  }

  // WebView 내부 영상 크기 조절
  Future<void> _fitVideoToBox() async {
    const String script = r'''
      (function() {
        if (document.getElementById('flutter-video-style')) {
          return;
        }

        const style = document.createElement('style');
        style.id = 'flutter-video-style';

        style.textContent = `
          html, body {
            margin: 0 !important;
            padding: 0 !important;
            width: 100% !important;
            height: 100% !important;
            overflow: hidden !important;
            background-color: black !important;
          }

          #video, video {
            position: fixed !important;
            top: 0 !important;
            left: 0 !important;
            width: 100% !important;
            height: 100% !important;
            max-width: none !important;
            max-height: none !important;
            margin: 0 !important;
            padding: 0 !important;
            object-fit: cover !important;
          }
        `;

        document.head.appendChild(style);
      })();
    ''';

    try {
      await _controller.runJavaScript(script);
      debugPrint('WebView 영상 크기 조절 적용');
    } catch (e) {
      debugPrint('영상 크기 조절 오류: $e');
    }
  }

  // 실제 영상 프레임 재생 감지
  Future<void> _monitorVideoPlayback() async {
    const String script = r'''
      (function() {
        // 중복 감시 방지
        if (window.__flutterVideoMonitorStarted) return;
        window.__flutterVideoMonitorStarted = true;

        let notified = false;
        let watchingFrames = false;
        let lastTime = -1;

        function notifyReady() {
          if (notified) return;

          notified = true;

          if (window.VideoStatus) {
            window.VideoStatus.postMessage('READY');
          }
        }

        function checkVideo() {
          const video = document.getElementById('video');

          if (!video || notified) return;

          // 실제 영상 데이터가 준비되었는지 확인
          if (
            video.readyState >= 2 &&
            video.videoWidth > 0 &&
            video.videoHeight > 0 &&
            !video.paused
          ) {
            // 실제 영상 프레임 확인
            if (
              typeof video.requestVideoFrameCallback === 'function'
            ) {
              if (!watchingFrames) {
                watchingFrames = true;

                video.requestVideoFrameCallback(function() {
                  notifyReady();
                });
              }
            } else {
              // 지원하지 않는 WebView 대체 방식
              if (
                lastTime >= 0 &&
                video.currentTime > lastTime
              ) {
                notifyReady();
              }

              lastTime = video.currentTime;
            }
          }
        }

        // 0.25초마다 영상 상태 확인
        const interval = setInterval(function() {
          if (notified) {
            clearInterval(interval);
            return;
          }

          checkVideo();
        }, 250);

        // 영상 재생 이벤트 감지
        const video = document.getElementById('video');

        if (video) {
          video.addEventListener('playing', checkVideo);
          video.addEventListener('loadeddata', checkVideo);
          video.addEventListener('timeupdate', checkVideo);
        }

        // 이미 영상이 재생 중인 경우 확인
        checkVideo();
      })();
    ''';

    try {
      await _controller.runJavaScript(script);
    } catch (e) {
      debugPrint('영상 재생 감지 스크립트 오류: $e');
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),

      // 고정 높이 대신 16:9 비율 적용
      child: AspectRatio(
        aspectRatio: 16 / 9,

        child: Stack(
          children: [
            // WebView 영상
            Positioned.fill(
              child: WebViewWidget(
                controller: _controller,
              ),
            ),

            // 실제 영상이 재생될 때까지
            // 파란색 로딩 동그라미 표시
            if (_isLoading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.white,
                  child: Center(
                    child: RotatingLoadingIcon(),
                  ),
                ),
              ),

            // 영상 연결 실패
            if (_hasError)
              Positioned.fill(
                child: ColoredBox(
                  color: Color(0xFFF8FAFD),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '영상을 불러올 수 없습니다.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8FA8D8),
                          ),
                        ),

                        SizedBox(height: 10),

                        TextButton(
                          onPressed: _loadVideo,
                          child: Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 요일 한글 변환
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
