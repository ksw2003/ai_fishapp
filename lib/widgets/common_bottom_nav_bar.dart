import 'package:flutter/material.dart';

class CommonBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const CommonBottomNavBar({
    super.key,
    required this.selectedIndex,
  });

  void _movePage(BuildContext context, int index) {
    String routeName;

    if (index == 0) {
      routeName = '/home';
    } else if (index == 1) {
      routeName = '/calendar';
    } else if (index == 2) {
      routeName = '/community';
    } else {
      routeName = '/settings';
    }

    // 현재 route 확인
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    // 진짜 같은 화면일 때만 이동 막기
    // 예: /home에서 홈 누름 -> 이동 X
    // 예: /live-video에서 홈 누름 -> /home으로 이동 O
    if (currentRoute == routeName) return;

    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  context: context,
                  icon: Icons.home_outlined,
                  index: 0,
                  iconSize: 30,
                  selectedIconSize: 31,
                ),
                _navItem(
                  context: context,
                  icon: Icons.calendar_today_outlined,
                  index: 1,
                  iconSize: 24,
                  selectedIconSize: 25,
                ),
                _navItem(
                  context: context,
                  icon: Icons.chat_bubble_outline,
                  index: 2,
                  iconSize: 24,
                  selectedIconSize: 25,
                ),
                _navItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  index: 3,
                  iconSize: 24,
                  selectedIconSize: 25,
                ),
              ],
            ),
          ),

          // 하단 검정 바
          Container(
            width: 120,
            height: 4,
            margin: const EdgeInsets.only(bottom: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required BuildContext context,
    required IconData icon,
    required int index,
    required double iconSize,
    required double selectedIconSize,
  }) {
    final bool isSelected = selectedIndex == index;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),

        // 누를 때 효과
        splashColor: const Color(0xFF8FA8D8).withOpacity(0.18),
        highlightColor: const Color(0xFF8FA8D8).withOpacity(0.08),

        onTap: () => _movePage(context, index),

        // 누르는 영역 = 선택된 파란 박스랑 같은 크기
        child: SizedBox(
          width: 52,
          height: 42,
          child: Center(
            child: isSelected
                ? Container(
                    width: 52,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC7E5FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      icon,
                      size: selectedIconSize,
                      color: const Color(0xFF6CAAEF),
                    ),
                  )
                : Icon(
                    icon,
                    size: iconSize,
                    color: const Color(0xFFB7C6DD),
                  ),
          ),
        ),
      ),
    );
  }
}