
import 'dart:async';
import 'dart:convert';

import 'package:ai_fishapp/api/api_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService {
  SocketService._();

  static final SocketService instance = SocketService._();
  WebSocketChannel? _channel;

  int? _userId;

  Timer? _reconnectTimer;

  bool _isReconnecting = false;
  bool _manualDisconnect = false;

  final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();

  bool get isConnected => _channel != null;

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  Future<void> connect(int userId) async {
    if (_channel != null) {
      return;
    }

    _userId = userId;
    _manualDisconnect = false;

    try {
      final channel = WebSocketChannel.connect(
        Uri.parse('ws://192.168.56.1:3000'),
      );

      await channel.ready;

      if (_manualDisconnect) {
        await channel.sink.close();
        return;
      }

      _channel = channel;

      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      _isReconnecting = false;

      print('WebSocket 연결 성공');

      // 서버에 사용자 등록
      send({
        'type': 'registerUser',
        'user_id': userId,
      });

      // 서버에서 오는 메시지는 여기서 한 번만 받음
      channel.stream.listen(
        (message) {
          try {
            final decoded = jsonDecode(message);

            if (decoded is Map<String, dynamic>) {
              _controller.add(decoded);
            }
          } catch (e) {
            print('WebSocket 데이터 변환 실패: $e');
          }
        },
        onError: (error) {
          print('WebSocket 오류: $error');

          if (_channel == channel) {
            _channel = null;
          }

          _reconnect();
        },
        onDone: () {
          print('WebSocket 연결 종료됨');

          if (_channel == channel) {
            _channel = null;
          }
           _reconnect();
        },
      );
    } catch (error) {
      print('WebSocket 연결 실패: $error');

      _channel = null;
      
       _reconnect();
    }
  }

   void _reconnect() {
    // 사용자가 직접 disconnect 한 경우
    if (_manualDisconnect) {
      return;
    }

    // 이미 재연결 대기 중
    if (_isReconnecting) {
      return;
    }

    // userId가 없으면 재연결 불가능
    final userId = _userId;

    if (userId == null) {
      return;
    }

    _isReconnecting = true;

    print('3초 후 WebSocket 재연결 시도');

    _reconnectTimer?.cancel();

    _reconnectTimer = Timer(
      const Duration(seconds: 3),
      () async {
        _isReconnecting = false;

        if (_manualDisconnect) {
          return;
        }

        print('WebSocket 재연결 중...');

        await connect(userId);
      },
    );
  }


  void send(Map<String, dynamic> data) {
    final channel = _channel;

    if (channel == null) {
      print('WebSocket이 연결되어 있지 않습니다.');
      return;
    }

    channel.sink.add(
      jsonEncode(data),
    );
  }
  
    Future<void> disconnect() async {
    _manualDisconnect = true;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _isReconnecting = false;

    final channel = _channel;

    _channel = null;
    _userId = null;

    if (channel != null) {
      await channel.sink.close();
    }

    print('WebSocket 연결 종료');
  }
}