import 'package:flutter/material.dart';
import '../widgets/common_bottom_nav_bar.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  // ===============================
  // 임시 데이터
  // 나중에 UserModel(API)로 교체
  // ===============================

  final String nickname = "한경이";

  final String profileImage =
      "https://i.pravatar.cc/300";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),

      bottomNavigationBar: const CommonBottomNavBar(
        selectedIndex: 3,
      ),

      body: SafeArea(
      child: Stack(
      children: [

      //----------------------------------------
      // 뒤로가기
      //----------------------------------------

      Positioned(
      top: 18,
      left: 12,
      child: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Color(0xff8FA8D8),
        ),
      ),
    ),

    //----------------------------------------
    // 내용
    //----------------------------------------

    SingleChildScrollView(
    child: Padding(
    padding: const EdgeInsets.only(
    top: 70,
    left: 28,
    right: 28,
    bottom: 30,
    ),
    child: Column(
    children: [

    //--------------------------------
    // 프로필 사진
    //--------------------------------

    CircleAvatar(
    radius: 50,
    backgroundColor: const Color(0xffBCC4D4),
    child: CircleAvatar(
    radius: 47,
    backgroundImage: NetworkImage(profileImage),
    ),
    ),

    const SizedBox(height: 12),

    //--------------------------------
    // 닉네임
    //--------------------------------

    Text(
    nickname,
    style: const TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    ),
    ),

    const SizedBox(height: 40),

    //--------------------------------
    // 프로필 변경 버튼
    //--------------------------------

    MyPageButton(
    title: "프로필 변경",
    onTap: () {
    Navigator.pushNamed(
    context,
    "/profile-edit",
    );
    },
    ),

    const SizedBox(height: 18),

    //--------------------------------
    // 나의 물고기 버튼
    //--------------------------------

    MyPageButton(
    title: "나의 물고기",
    onTap: () {
    Navigator.pushNamed(
    context,
    "/my-fish",
    );
    },
    ),

    const SizedBox(height: 28),
      //--------------------------------
      // 로그아웃 버튼
      //--------------------------------

      SizedBox(
        width: double.infinity,
        height: 58,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [
                Color(0xff2D9CFF),
                Color(0xff3CC8F2),
              ],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  "/start",
                );
              },
              child: const Center(
                child: Text(
                  "로그아웃",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      const SizedBox(height: 40),
    ],
    ),
    ),
    ),
      ],
      ),
      ),
    );
  }
}

class MyPageButton extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const MyPageButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  State<MyPageButton> createState() => _MyPageButtonState();
}

class _MyPageButtonState extends State<MyPageButton> {
  bool isPressed = false;

  void setPressed(bool value) {
    setState(() {
      isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isPressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.white,
        elevation: isPressed ? 2 : 6,
        shadowColor: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setPressed(true),
          onTapUp: (_) => setPressed(false),
          onTapCancel: () => setPressed(false),
          splashColor: const Color(0xff8FA8D8).withOpacity(0.15),
          highlightColor: const Color(0xff8FA8D8).withOpacity(0.05),
          child: Ink(
            height: 68,
            decoration: BoxDecoration(
              color: isPressed
                  ? const Color(0xffF4F8FF)
                  : Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff50576B),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
