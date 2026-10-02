import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/socket_service.dart';
import '../../widgets/common_bottom_nav_bar.dart';

class FishInfoManagementScreen extends StatefulWidget {
  const FishInfoManagementScreen({super.key});

  @override
  State<FishInfoManagementScreen> createState() =>
      _FishInfoManagementScreenState();
}

class _FishInfoManagementScreenState
    extends State<FishInfoManagementScreen> {
  // ==========================================
  // 물고기 목록
  // ==========================================

  List<Map<String, dynamic>> fishList = [
    {'name': '구피', 'count': 10},
    {'name': '네온 테트라', 'count': 5},
    {'name': '금붕어', 'count': 3},
  ];

  bool isLoading = false;

  StreamSubscription<Map<String, dynamic>>? _subscription;

  @override
  void initState() {
    super.initState();

    // 이미 로그인 후 연결되어 있는 공용 WebSocket 사용
    _subscription = SocketService.instance.stream.listen(
      _handleWebSocketMessage,
    );
  }

  // ==========================================
  // Node -> Flutter 메시지 처리
  // ==========================================

  void _handleWebSocketMessage(
    Map<String, dynamic> message,
  ) {
    final type = message['type'];

    if (type != 'species_result') {
      return;
    }

    print('어종 분석 결과 수신: $message');

    final rawData = message['data'];

    if (rawData is! Map) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      return;
    }

    final data =
        Map<String, dynamic>.from(rawData);

    // 오류 메시지가 온 경우
    if (data['message'] != null) {
      final errorMessage =
          data['message'].toString();

      print('어종 분석 실패: $errorMessage');

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );

      return;
    }

    final rawSpeciesCount =
        data['speciesCount'];

    if (rawSpeciesCount is! Map) {
      print('speciesCount가 없습니다.');

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      return;
    }

    final speciesCount =
        Map<String, dynamic>.from(
      rawSpeciesCount,
    );

    final newFishList =
        <Map<String, dynamic>>[];

    speciesCount.forEach(
      (species, countValue) {
        final count =
            countValue is int
                ? countValue
                : int.tryParse(
                      countValue.toString(),
                    ) ??
                    0;

        newFishList.add({
          'name': species.toString(),
          'count': count,
        });
      },
    );

    if (!mounted) {
      return;
    }

    setState(() {
      fishList = newFishList;
      isLoading = false;
    });

    print(
      '어종 분석 결과 화면 반영 완료: $newFishList',
    );
  }

  // ==========================================
  // 갱신하기
  // ==========================================

  Future<void> refreshFishInfo() async {
    if (!SocketService.instance.isConnected) {
      print('WebSocket이 연결되어 있지 않습니다.');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '서버 연결을 확인해주세요.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    print('어종 갱신 요청');

    // Flutter -> Node.js
    SocketService.instance.send({
      'type': 'species',
    });
  }

  // ==========================================
  // 수정 버튼
  // ==========================================

  void onEditTap() {
    print('수정 버튼 클릭');
  }

  // ==========================================
  // 화면 종료
  // ==========================================

  @override
  void dispose() {
    // 이 화면에서 사용하던 수신만 종료
    // 공용 WebSocket 자체는 끊지 않음
    _subscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // ==================================
            // 상단 버튼 영역
            // ==================================

            SizedBox(
              height: 76,
              child: Stack(
                children: [
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

                  Positioned(
                    top: 18,
                    right: 18,
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkResponse(
                        radius: 24,
                        containedInkWell: false,
                        splashColor:
                            const Color(0xFF8FA8D8)
                                .withOpacity(0.18),
                        highlightColor:
                            const Color(0xFF8FA8D8)
                                .withOpacity(0.08),
                        onTap: onEditTap,
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: Text(
                              '수정',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    Color(0xFF8FA8D8),
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================
            // 본문
            // ==================================

            Expanded(
              child: SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                  28,
                  22,
                  28,
                  28,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '나의 물고기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D3E5F),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ==================================
                    // 물고기 목록
                    // ==================================

                    ...fishList.map(
                      (fish) => Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: FishInfoRow(
                          name:
                              fish['name'].toString(),
                          count:
                              fish['count'] is int
                                  ? fish['count']
                                  : int.tryParse(
                                        fish['count']
                                            .toString(),
                                      ) ??
                                      0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // ==================================
                    // 갱신하기 버튼
                    // ==================================

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            isLoading
                                ? null
                                : refreshFishInfo,
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                            0xFFC7E5FF,
                          ),
                          disabledBackgroundColor:
                              const Color(
                            0xFFC7E5FF,
                          ),
                          foregroundColor:
                              const Color(
                            0xFF2D3E5F,
                          ),
                          disabledForegroundColor:
                              const Color(
                            0xFF2D3E5F,
                          ),
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              13,
                            ),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color:
                                      Color(0xFF6CAAEF),
                                ),
                              )
                            : const Text(
                                '갱신하기',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar:
          const CommonBottomNavBar(
        selectedIndex: 3,
      ),
    );
  }
}

class FishInfoRow extends StatelessWidget {
  final String name;
  final int count;

  const FishInfoRow({
    super.key,
    required this.name,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 물고기 이름
        Expanded(
          child: Container(
            height: 42,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(13),
              border: Border.all(
                color:
                    const Color(0xFFE8EEF7),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(
                    0.03,
                  ),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3E5F),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 개수
        Container(
          width: 66,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(13),
            border: Border.all(
              color:
                  const Color(0xFFE8EEF7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(
                  0.03,
                ),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3E5F),
            ),
          ),
        ),
      ],
    );
  }
}