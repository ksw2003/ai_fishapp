import 'package:flutter/material.dart';
import '../../widgets/common_bottom_nav_bar.dart';

class FishInfoManagementScreen extends StatefulWidget {
  const FishInfoManagementScreen({super.key});

  @override
  State<FishInfoManagementScreen> createState() =>
      _FishInfoManagementScreenState();
}

class _FishInfoManagementScreenState extends State<FishInfoManagementScreen> {
  List<Map<String, dynamic>> fishList = [
    {'name': '구피', 'count': 10},
    {'name': '네온 테트라', 'count': 5},
    {'name': '금붕어', 'count': 3},
  ];

  bool isLoading = false;

  Future<void> refreshFishInfo() async {
    setState(() {
      isLoading = true;
    });

    // 지금은 화면 구현용 가짜 대기
    // 나중에 여기를 백엔드 API 호출로 바꾸면 됨
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      fishList = [
        {'name': '구피', 'count': 11},
        {'name': '네온 테트라', 'count': 5},
        {'name': '금붕어', 'count': 2},
      ];

      isLoading = false;
    });
  }

  void onEditTap() {
    // 나중에 수정 화면 이동 or 수정모드 켜기
    print('수정 버튼 클릭');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // 상단 버튼 영역
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
                            const Color(0xFF8FA8D8).withOpacity(0.18),
                        highlightColor:
                            const Color(0xFF8FA8D8).withOpacity(0.08),
                        onTap: onEditTap,
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: Text(
                              '수정',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8FA8D8),
                                fontWeight: FontWeight.w600,
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

            // 본문
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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

                    ...fishList.map(
                      (fish) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: FishInfoRow(
                          name: fish['name'],
                          count: fish['count'],
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : refreshFishInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC7E5FF),
                          disabledBackgroundColor: const Color(0xFFC7E5FF),
                          foregroundColor: const Color(0xFF2D3E5F),
                          disabledForegroundColor: const Color(0xFF2D3E5F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Color(0xFF6CAAEF),
                                ),
                              )
                            : const Text(
                                '갱신하기',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
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

      // 공통 하단 네비게이션바
      bottomNavigationBar: const CommonBottomNavBar(
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
        // 물고기 이름 박스
        Expanded(
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: const Color(0xFFE8EEF7),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
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

        // 개수 박스
        Container(
          width: 66,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: const Color(0xFFE8EEF7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
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