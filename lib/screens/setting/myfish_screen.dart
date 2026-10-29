
import 'dart:async';

import 'package:ai_fishapp/services/socket_service.dart';
import 'package:flutter/material.dart';

import '../../widgets/common_bottom_nav_bar.dart';
import '../../services/fishinfo_service.dart';
import '../../../models/fishinfo.dart';

class FishRowData {
  final int? fishId;

  final TextEditingController speciesController;
  final TextEditingController countController;

  bool isNew;

  FishRowData({
    this.fishId,
    required String species,
    required int count,
    this.isNew = false,
  })  : speciesController = TextEditingController(
          text: species,
        ),
        countController = TextEditingController(
          text: count == 0 ? "" : count.toString(),
        );

  void dispose() {
    speciesController.dispose();
    countController.dispose();
  }
}

class MyFishScreen extends StatefulWidget {
  const MyFishScreen({super.key});

  @override
  State<MyFishScreen> createState() => _MyFishScreenState();
}

class _MyFishScreenState extends State<MyFishScreen> {
  bool isEdit = false;

  StreamSubscription<Map<String, dynamic>>? _subscription;

  final List<FishRowData> fishes = [];

  // DB에 저장된 어종과 ID를 유지하여 AI 갱신 결과 저장 시 재사용
  final Map<String, int> _savedFishIds = {};

  String _speciesKey(String species) => species.trim().toLowerCase();

  bool isLoading = true;
  bool isRefreshing = false;

  OverlayEntry? _toastEntry;
  Timer? _toastTimer;

  // =========================================================
  // 중앙 Toast 알림
  // =========================================================
  void showCenterToast(String message) {
    if (!mounted) return;

    _removeToast();

    final overlay = Overlay.of(context);

    final entry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF393C43)
                      .withOpacity(0.90),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    _toastEntry = entry;
    overlay.insert(entry);

    _toastTimer = Timer(
      const Duration(seconds: 2),
      _removeToast,
    );
  }

  void _removeToast() {
    _toastTimer?.cancel();
    _toastTimer = null;

    final entry = _toastEntry;
    _toastEntry = null;

    if (entry != null) {
      entry.remove();
      entry.dispose();
    }
  }

  @override
  void initState() {
    super.initState();

    loadFish();

    _subscription = SocketService.instance.stream.listen(
      handleWebSocketMessage,
    );
  }

  // =========================================================
  // Node -> Flutter WebSocket 메시지 처리
  // =========================================================
  Future<void> handleWebSocketMessage(
    Map<String, dynamic> message,
  ) async {
    final type = message['type'];

    if (type != 'species_result' || !isRefreshing) {
      return;
    }

    print('어종 분석 결과 수신: $message');

    final rawData = message['data'];

    if (rawData is! Map) {
      print('species_result의 data가 올바르지 않습니다.');

      if (mounted) {
        setState(() {
          isRefreshing = false;
        });
      }

      return;
    }

    final data = Map<String, dynamic>.from(rawData);

    // Node에서 오류 메시지를 보낸 경우
    if (data['message'] != null) {
      final errorMessage = data['message'].toString();

      print('어종 분석 실패: $errorMessage');

      if (!mounted) return;

      setState(() {
        isRefreshing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );

      return;
    }

    final rawSpeciesCount = data['speciesCount'];

    if (rawSpeciesCount is! Map) {
      print('speciesCount가 없습니다.');

      if (mounted) {
        setState(() {
          isRefreshing = false;
        });
      }

      return;
    }

    final speciesCount = Map<String, dynamic>.from(
      rawSpeciesCount,
    );

    if (!mounted) return;

    final newFishes = <FishRowData>[];

    // AI 결과를 화면 목록으로 변환
    speciesCount.forEach((species, countValue) {
      final count = countValue is int
          ? countValue
          : int.tryParse(countValue.toString()) ?? 0;

      // 기존 DB에 있던 어종이라면 fish_id를 유지
      final existingId = _savedFishIds[_speciesKey(species)];

      newFishes.add(
        FishRowData(
          fishId: existingId,
          species: species,
          count: count,
          isNew: existingId == null,
        ),
      );
    });

    final oldFishes = List<FishRowData>.from(fishes);

    setState(() {
      fishes
        ..clear()
        ..addAll(newFishes);

    });

    // 기존 Controller 정리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final fish in oldFishes) {
        fish.dispose();
      }
    });

    // ==========================================
    // 탐지된 물고기가 없을 때 중앙 Toast
    // ==========================================
    if (newFishes.isEmpty) {
      showCenterToast('탐지된 물고기가 없어 자동 저장하지 않았습니다.');
      if (mounted) setState(() => isRefreshing = false);
      return;
    }

    // 갱신하기 결과를 기존 '완료' 저장 동작과 동일하게 DB에 저장
    final saved = await saveFish();
    if (!mounted) return;

    setState(() => isRefreshing = false);
    if (saved) {
      showCenterToast('AI 분석 결과가 저장되었습니다.');
    }

    print('AI 어종 결과 자동 저장 ${saved ? '완료' : '실패'}');
  }

  // =========================================================
  // 기존 DB 물고기 정보 조회
  // =========================================================
  Future<void> loadFish() async {
    try {
      final List<Fish> fishList =
          await FishService.getFishList();

      if (!mounted) return;

      // 실제 저장된 DB 정보로 ID 목록을 갱신
      _savedFishIds.clear();
      for (final fish in fishList) {
        if (fish.fishId != null) {
          _savedFishIds[_speciesKey(fish.fishType)] = fish.fishId!;
        }
      }

      final newFishes = fishList.map((fish) {
        return FishRowData(
          fishId: fish.fishId,
          species: fish.fishType,
          count: fish.fishCount,
        );
      }).toList();

      final oldFishes = List<FishRowData>.from(fishes);

      setState(() {
        fishes
          ..clear()
          ..addAll(newFishes);

        isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final fish in oldFishes) {
          fish.dispose();
        }
      });
    } catch (e) {
      print("물고기 정보 조회 실패: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // =========================================================
  // AI 어종 갱신 요청
  // Flutter -> Node
  // =========================================================
  Future<void> refreshFish() async {
    if (isRefreshing) return;

    if (!SocketService.instance.isConnected) {
      print('WebSocket이 연결되어 있지 않습니다.');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('서버 연결을 확인해주세요.'),
        ),
      );

      return;
    }

    setState(() {
      isRefreshing = true;
    });

    print('AI 어종 분석 요청');

    SocketService.instance.send({
      'type': 'species',
    });
  }

  // =========================================================
  // 물고기 정보 저장
  // =========================================================
  Future<bool> saveFish() async {
    final fishlist = fishes
        .map((fish) {
          return {
            'fish_id': fish.fishId,
            'fish_type':
                fish.speciesController.text.trim(),
            'fish_count': int.tryParse(
                  fish.countController.text,
                ) ??
                0,
          };
        })
        .where((fish) => fish['fish_type'] != '')
        .toList();

    try {
      await FishService.postFishList(
        fishes: fishlist,
      );

      if (!mounted) return false;

      await loadFish();

      if (!mounted) return false;

      setState(() {
        isEdit = false;
      });
      return true;
    } catch (e) {
      print('물고기 정보 저장 실패: $e');

      if (!mounted) return false;

      showCenterToast('저장에 실패했습니다.');
      return false;
    }
  }

  // =========================================================
  // 종료
  // =========================================================
  @override
  void dispose() {
    _subscription?.cancel();
    _removeToast();

    for (final fish in fishes) {
      fish.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),

      bottomNavigationBar: const CommonBottomNavBar(
        selectedIndex: 3,
      ),

      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  // ==================================
                  // 상단
                  // ==================================
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Color(0xff8FA8D8),
                          ),
                        ),

                        const Spacer(),

                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            splashColor: const Color(0xFF8FA8D8)
                                .withOpacity(0.20),
                            highlightColor: const Color(0xFF8FA8D8)
                                .withOpacity(0.10),
                            onTap: () async {
                              if (isEdit) {
                                await saveFish();
                              } else {
                                setState(() {
                                  isEdit = true;
                                });
                              }
                            },
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Center(
                                child: Text(
                                  isEdit ? "완료" : "수정",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff9BA9B0),
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
                  // 제목
                  // ==================================
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "나의 물고기",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff393C43),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================
                  // 물고기 목록
                  // ==================================
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                      ),
                      children: [
                        ...List.generate(
                          fishes.length,
                          (index) => Padding(
                            padding: EdgeInsets.only(
                              bottom: isEdit &&
                                      index == fishes.length - 1
                                  ? 22
                                  : 12,
                            ),
                            child: FishRowWidget(
                              data: fishes[index],
                              isEdit: isEdit,
                              onDelete: () {
                                final fish = fishes[index];

                                setState(() {
                                  fishes.removeAt(index);
                                });

                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  fish.dispose();
                                });
                              },
                            ),
                          ),
                        ),

                        // ==================================
                        // 수정 모드 - 추가하기
                        // ==================================
                        if (isEdit)
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              setState(() {
                                fishes.add(
                                  FishRowData(
                                    fishId: null,
                                    species: "",
                                    count: 0,
                                    isNew: true,
                                  ),
                                );
                              });
                            },
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xff2DA5F7),
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "추가하기 +",
                                  style: TextStyle(
                                    color: Color(0xff2DA5F7),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        SizedBox(
                          height: isEdit ? 12 : 22,
                        ),

                        // ==================================
                        // AI 갱신하기
                        // ==================================
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: isRefreshing || isEdit
                                ? null
                                : refreshFish,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor:
                                  const Color(0xff2DA5F7),
                              disabledBackgroundColor:
                                  const Color(0xffD9D9D9),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                            child: isRefreshing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Color(0xffFFFFFF),
                                    ),
                                  )
                                : const Text(
                                    "갱신하기",
                                    style: TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// =========================================================
// 물고기 행 UI
// =========================================================
class FishRowWidget extends StatelessWidget {
  final FishRowData data;
  final bool isEdit;
  final VoidCallback onDelete;

  const FishRowWidget({
    super.key,
    required this.data,
    required this.isEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ----------------------------------
        // 물고기 종류
        // ----------------------------------
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xffF2F2F2),
                width: 2,
              ),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            child: isEdit
                ? TextField(
                    controller: data.speciesController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "어종",
                      hintStyle: TextStyle(
                        color: Color(0xffBCC4D4),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  )
                : Text(
                    data.speciesController.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff393C43),
                    ),
                  ),
          ),
        ),

        const SizedBox(width: 10),

        // ----------------------------------
        // 개수
        // ----------------------------------
        Container(
          width: 82,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xffF2F2F2),
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: isEdit
              ? TextField(
                  controller: data.countController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "마릿수",
                    hintStyle: TextStyle(
                      color: Color(0xffBCC4D4),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : Text(
                  data.countController.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff393C43),
                  ),
                ),
        ),

        if (isEdit)
          const SizedBox(width: 8),

        // ----------------------------------
        // 삭제 버튼
        // ----------------------------------
        if (isEdit)
          GestureDetector(
            onTap: onDelete,
            child: const SizedBox(
              width: 24,
              child: Center(
                child: Text(
                  "-",
                  style: TextStyle(
                    color: Color(0xffFFB7C3),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
