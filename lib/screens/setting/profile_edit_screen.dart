import 'package:flutter/material.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() =>
      _ProfileEditScreenState();
}

class _ProfileEditScreenState
    extends State<ProfileEditScreen> {

  //-----------------------------------------
  // 임시 데이터
  //-----------------------------------------

  final TextEditingController nicknameController =
  TextEditingController(
    text: "한경이",
  );

  bool canUseNickname = true;

  String profileImage =
      "https://i.pravatar.cc/300";

  @override
  void dispose() {
    nicknameController.dispose();
    super.dispose();
  }

  void checkNickname() {

    // TODO : 백엔드 연결

    setState(() {

      if (nicknameController.text.length >= 2) {
        canUseNickname = true;
      } else {
        canUseNickname = false;
      }

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

        backgroundColor: Colors.white,

        body: SafeArea(

        child: SingleChildScrollView(

        padding: const EdgeInsets.symmetric(
        horizontal: 22,
    ),

    child: Column(

    children: [

    //---------------------------------
    // 상단
    //---------------------------------

    const SizedBox(height: 12),

    Row(

    children: [

    IconButton(

    onPressed: () {

    Navigator.pop(context);

    },

    icon: const Icon(
    Icons.arrow_back_ios_new,
    color: Color(0xff8FA8D8),
    ),
    ),

    const Spacer(),

    GestureDetector(

    onTap: () {

    // TODO : 저장

    },

    child: const Text(

    "저장",

    style: TextStyle(
    color: Color(0xff9BA9B0),
    fontSize: 18,
    fontWeight: FontWeight.w700,
    ),
    ),
    ),
    ],
    ),

    const SizedBox(height: 28),

    //---------------------------------
    // 프로필 사진
    //---------------------------------

    Stack(

    children: [

    CircleAvatar(

    radius: 75,

    backgroundColor:
    const Color(0xffBCC4D4),

    child: CircleAvatar(

    radius: 72,

    backgroundImage:
    NetworkImage(profileImage),

    ),
    ),

    Positioned(

    right: 0,
    bottom: 0,

    child: GestureDetector(

    onTap: () {

    // 2/2에서 구현

    },

    child: Container(

    width: 48,
    height: 48,

    decoration: const BoxDecoration(

    color: Color(0xffD9D9D9),

    shape: BoxShape.circle,

    ),

    child: const Icon(
    Icons.photo_camera_outlined,
    color: Colors.white,
    size: 24,
    ),

    ),
    ),
    ),
    ],
    ),

    const SizedBox(height: 28),

    //---------------------------------
    // 닉네임
    //---------------------------------

    Row(

    children: [

    const Text(

    "닉네임",

    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Color(0xff393C43),
    ),
    ),

    const SizedBox(width: 6),

    const Icon(
    Icons.check_circle,
    color: Color(0xff00C2FA),
    size: 18,
    ),

    const Spacer(),

    Text(

    canUseNickname
    ? "사용 가능"
        : "중복된 닉네임",

    style: TextStyle(

    color: canUseNickname
    ? const Color(0xff00C2FA)
        : Colors.red,

    fontWeight: FontWeight.w600,

    ),
    ),
    ],
    ),

    const SizedBox(height: 10),

    Container(

    height: 52,

    decoration: BoxDecoration(

    borderRadius:
    BorderRadius.circular(16),

    border: Border.all(
    color: const Color(0xffF2F2F2),
    width: 2,
    ),

    ),

    child: TextField(

    controller: nicknameController,

    onChanged: (_) {

    checkNickname();

    },

    decoration: const InputDecoration(

    border: InputBorder.none,

    contentPadding:
    EdgeInsets.symmetric(
    horizontal: 16,
    ),

    ),
    ),
    ),

      const SizedBox(height: 32),

      //---------------------------------
      // 저장 버튼 (선택)
      //---------------------------------

      SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: canUseNickname
              ? () {
            // TODO : 저장 API
            Navigator.pop(context);
          }
              : null,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xff2DA5F7),
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            "저장",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),

      const SizedBox(height: 40),
    ],
    ),
        ),
        ),
    );
  }
}