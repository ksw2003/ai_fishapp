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

  bool isLoading = true;

  // AI 어종 갱신 중인지
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();

    // 기존 DB 물고기 정보 불러오기
    loadFish();

    // 이미 연결되어 있는 공용 WebSocket의 메시지 수신
    _subscription = SocketService.instance.stream.listen(
      handleWebSocketMessage,
    );
  }

  // =========================================================
  // Node -> Flutter WebSocket 메시지 처리
  // =========================================================
  void handleWebSocketMessage(
    Map<String, dynamic> message,
  ) {
    final type = message['type'];

    // 어종 분석 결과가 아니면 무시
    if (type != 'species_result') {
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

    final data = Map<String, dynamic>.from(
      rawData,
    );

    // Node에서 오류 메시지를 보낸 경우
    if (data['message'] != null) {
      final errorMessage =
          data['message'].toString();

      print('어종 분석 실패: $errorMessage');

      if (!mounted) {
        return;
      }

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

    final rawSpeciesCount =
        data['speciesCount'];

    if (rawSpeciesCount is! Map) {
      print('speciesCount가 없습니다.');

      if (mounted) {
        setState(() {
          isRefreshing = false;
        });
      }

      return;
    }

    final speciesCount =
        Map<String, dynamic>.from(
      rawSpeciesCount,
    );

    // 기존 화면 Controller 정리
    for (final fish in fishes) {
      fish.speciesController.dispose();
      fish.countController.dispose();
    }

    fishes.clear();

    // AI 결과를 화면 목록으로 변환
    speciesCount.forEach(
      (species, countValue) {
        final count =
            countValue is int
                ? countValue
                : int.tryParse(
                      countValue.toString(),
                    ) ??
                    0;

        fishes.add(
          FishRowData(
            fishId: null,
            species: species,
            count: count,
          ),
        );
      },
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isRefreshing = false;
    });

    print('AI 어종 결과 화면 반영 완료');
  }

  // =========================================================
  // 기존 DB 물고기 정보 조회
  // =========================================================
  Future<void> loadFish() async {
    try {
      final List<Fish> fishList =
          await FishService.getFishList();

      // 기존 Controller 정리
      for (final fish in fishes) {
        fish.speciesController.dispose();
        fish.countController.dispose();
      }

      fishes.clear();

      for (final fish in fishList) {
        fishes.add(
          FishRowData(
            fishId: fish.fishId,
            species: fish.fishType,
            count: fish.fishCount,
          ),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("물고기 정보 조회 실패: $e");

      if (!mounted) {
        return;
      }

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
    // 공용 WebSocket 연결 확인
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
      isRefreshing = true;
    });

    print('AI 어종 분석 요청');

    // Flutter -> Node
    SocketService.instance.send({
      'type': 'species',
    });
  }

  @override
  void dispose() {
    // 이 화면이 듣고 있던 Stream만 해제
    // 공용 WebSocket 자체는 끊지 않음
    _subscription?.cancel();

    for (final fish in fishes) {
      fish.speciesController.dispose();
      fish.countController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xffF7F7F7,
      ),

      bottomNavigationBar:
          const CommonBottomNavBar(
        selectedIndex: 3,
      ),

      body: SafeArea(
        child: isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : Column(
                children: [
                  // ==================================
                  // 상단
                  // ==================================
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () =>
                              Navigator.pop(
                            context,
                          ),
                          icon: const Icon(
                            Icons
                                .arrow_back_ios_new,
                            color: Color(
                              0xff8FA8D8,
                            ),
                          ),
                        ),

                        const Spacer(),

                        GestureDetector(
                          onTap: () async {
                            if (isEdit) {
                              final fishlist =
                                  fishes
                                      .map(
                                (fish) {
                                  return {
                                    'fish_id':
                                        fish.fishId,
                                    'fish_type':
                                        fish
                                            .speciesController
                                            .text
                                            .trim(),
                                    'fish_count':
                                        int.tryParse(
                                              fish
                                                  .countController
                                                  .text,
                                            ) ??
                                            0,
                                  };
                                },
                              )
                                      .where(
                                (fish) =>
                                    fish[
                                        'fish_type'] !=
                                    '',
                              )
                                      .toList();

                              await FishService
                                  .postFishList(
                                fishes:
                                    fishlist,
                              );

                              await loadFish();
                            }

                            if (!mounted) {
                              return;
                            }

                            setState(() {
                              isEdit =
                                  !isEdit;
                            });
                          },
                          child: Text(
                            isEdit
                                ? "완료"
                                : "수정",
                            style:
                                const TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              color: Color(
                                0xff9BA9B0,
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
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 28,
                    ),
                    child: Align(
                      alignment:
                          Alignment.centerLeft,
                      child: Text(
                        "나의 물고기",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight:
                              FontWeight.w700,
                          color: Color(
                            0xff50576B,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // ==================================
                  // 물고기 목록
                  // ==================================
                  Expanded(
                    child: ListView(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 14,
                      ),
                      children: [
                        ...List.generate(
                          fishes.length,
                          (index) =>
                              Padding(
                            padding:
                                const EdgeInsets
                                    .only(
                              bottom: 12,
                            ),
                            child:
                                FishRowWidget(
                              data:
                                  fishes[index],
                              isEdit:
                                  isEdit,
                              onDelete:
                                  () async {
                                final fish =
                                    fishes[
                                        index];

                                setState(() {
                                  fish
                                      .speciesController
                                      .dispose();

                                  fish
                                      .countController
                                      .dispose();

                                  fishes
                                      .removeAt(
                                    index,
                                  );
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
                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),
                            onTap: () {
                              setState(() {
                                fishes.add(
                                  FishRowData(
                                    fishId:
                                        null,
                                    species:
                                        "",
                                    count:
                                        0,
                                    isNew:
                                        true,
                                  ),
                                );
                              });
                            },
                            child: Container(
                              height: 48,
                              decoration:
                                  BoxDecoration(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  16,
                                ),
                                border:
                                    Border.all(
                                  color:
                                      const Color(
                                    0xffCCE6FF,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child:
                                  const Center(
                                child: Text(
                                  "추가하기 +",
                                  style:
                                      TextStyle(
                                    color:
                                        Color(
                                      0xff94ABCC,
                                    ),
                                    fontSize:
                                        17,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(
                          height: 22,
                        ),

                        // ==================================
                        // AI 갱신하기
                        // ==================================
                        SizedBox(
                          height: 44,
                          child:
                              ElevatedButton(
                            onPressed:
                                isRefreshing ||
                                        isEdit
                                    ? null
                                    : refreshFish,
                            style:
                                ElevatedButton
                                    .styleFrom(
                              elevation: 0,
                              backgroundColor:
                                  const Color(
                                0xffCCE6FF,
                              ),
                              disabledBackgroundColor:
                                  const Color(
                                0xffCCE6FF,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                              ),
                            ),
                            child:
                                isRefreshing
                                    ? const SizedBox(
                                        width:
                                            20,
                                        height:
                                            20,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth:
                                              2.5,
                                          color:
                                              Color(
                                            0xff50576B,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        "갱신하기",
                                        style:
                                            TextStyle(
                                          color:
                                              Color(
                                            0xff50576B,
                                          ),
                                          fontWeight:
                                              FontWeight
                                                  .w700,
                                        ),
                                      ),
                          ),
                        ),

                        const SizedBox(
                          height: 24,
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
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
              border: Border.all(
                color:
                    const Color(
                  0xffF1F1F1,
                ),
                width: 2,
              ),
            ),
            alignment:
                Alignment.centerLeft,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            child: isEdit
                ? TextField(
                    controller:
                        data.speciesController,
                    decoration:
                        const InputDecoration(
                      border:
                          InputBorder.none,
                      hintText:
                          "어종",
                      hintStyle:
                          TextStyle(
                        color: Color(
                          0xffBCC4D4,
                        ),
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  )
                : Text(
                    data
                        .speciesController
                        .text,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w700,
                      color: Color(
                        0xff50576B,
                      ),
                    ),
                  ),
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        // ----------------------------------
        // 개수
        // ----------------------------------
        Container(
          width: 60,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(
              16,
            ),
            border: Border.all(
              color:
                  const Color(
                0xffF1F1F1,
              ),
              width: 2,
            ),
          ),
          alignment:
              Alignment.center,
          child: isEdit
              ? TextField(
                  controller:
                      data.countController,
                  keyboardType:
                      TextInputType.number,
                  textAlign:
                      TextAlign.center,
                  decoration:
                      const InputDecoration(
                    border:
                        InputBorder.none,
                    hintText:
                        "마릿수",
                    hintStyle:
                        TextStyle(
                      color: Color(
                        0xffBCC4D4,
                      ),
                      fontSize: 12,
                    ),
                  ),
                )
              : Text(
                  data
                      .countController
                      .text,
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                    color: Color(
                      0xff50576B,
                    ),
                  ),
                ),
        ),

        const SizedBox(
          width: 8,
        ),

        // ----------------------------------
        // 삭제 버튼
        // ----------------------------------
        if (isEdit)
          GestureDetector(
            onTap: onDelete,
            child:
                const SizedBox(
              width: 24,
              child: Center(
                child: Text(
                  "-",
                  style:
                      TextStyle(
                    color:
                        Color(
                      0xffFFB7C3,
                    ),
                    fontSize:
                        28,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),
              ),
            ),
          )
        else
          const SizedBox(
            width: 24,
          ),
      ],
    );
  }
}