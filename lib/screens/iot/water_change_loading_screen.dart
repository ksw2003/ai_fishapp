import 'dart:async';
import 'package:ai_fishapp/services/socket_service.dart';
import 'package:ai_fishapp/widgets/rotating_loading_icon.dart';
import 'package:flutter/material.dart';

class WaterChangeLoadingScreen extends StatefulWidget {
  const WaterChangeLoadingScreen({super.key});

  @override
  State<WaterChangeLoadingScreen> createState() =>
      _WaterChangeLoadingScreenState();
}

class _WaterChangeLoadingScreenState
    extends State<WaterChangeLoadingScreen> {

  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();

    // 환수 결과 수신
    _subscription = SocketService.instance.stream?.listen((data) {
      print(data);

      if (data['type'] == 'waterChangeResult') {
        if (!mounted) return;

        final bool success = data['success'] == true;
        final String message = data['message'] ?? '';

        Navigator.pop(context, {
          'success': success,
          'message': message,
        });
      }
    });

    // 환수 명령 전송
    SocketService.instance.send({
      'type': 'waterChange',
    });
  }

  @override
  void dispose() {
    print('환수 WebSocket 구독 종료');

    _subscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 뒤로가기 버튼
            Positioned(
              top: 18,
              left: 18,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Color(0xFF8FA8D8),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            // 환수 로딩 화면
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 공통 로딩 아이콘
                  RotatingLoadingIcon(),

                  SizedBox(height: 24),

                  Text(
                    '환수중입니다...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CB8E8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}