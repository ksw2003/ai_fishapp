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
    final double screenHeight = MediaQuery.of(context).size.height;

    // 화면 높이에 따라 자동 조정
    final double navHeight = (screenHeight * 0.0923).clamp(56.0, 68.0);
    final double itemWidth = (screenHeight * 0.2).clamp(48.0, 69.0);
    final double itemHeight = (screenHeight * 0.055).clamp(36.0, 48.0);

    return Container(
      height: navHeight,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            context: context,
            icon: Icons.home_outlined,
            index: 0,
            iconSize: 38,
            selectedIconSize: 39,
            itemWidth: itemWidth,
            itemHeight: itemHeight,
          ),
          _navItem(
            context: context,
            icon: Icons.calendar_today_outlined,
            index: 1,
            iconSize: 30,
            selectedIconSize: 31,
            itemWidth: itemWidth,
            itemHeight: itemHeight,
          ),
          _navItem(
            context: context,
            icon: Icons.chat_bubble_outline,
            index: 2,
            iconSize: 30,
            selectedIconSize: 31,
            itemWidth: itemWidth,
            itemHeight: itemHeight,
          ),
          _navItem(
            context: context,
            icon: Icons.settings_outlined,
            index: 3,
            iconSize: 30,
            selectedIconSize: 31,
            itemWidth: itemWidth,
            itemHeight: itemHeight,
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
    required double itemWidth,
    required double itemHeight,
  }) {
    final bool isSelected = selectedIndex == index;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        splashColor: const Color(0xFF8FA8D8).withOpacity(0.18),
        highlightColor: const Color(0xFF8FA8D8).withOpacity(0.08),
        onTap: () => _movePage(context, index),
        child: SizedBox(
          width: itemWidth,
          height: itemHeight,
          child: Center(
            child: isSelected
                ? Container(
                    width: itemWidth,
                    height: itemHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC7E5FF),
                      borderRadius: BorderRadius.circular(20),
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