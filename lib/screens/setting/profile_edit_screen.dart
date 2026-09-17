import 'dart:convert';

import 'package:ai_fishapp/api/api_client.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserInfo();
  }

  bool canUseNickname = true;

  String profileImage =
      "https://i.pravatar.cc/300";

  final ImagePicker _picker = ImagePicker();

    XFile? selectedImage;

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

  void makeProfile(BuildContext context) async{
    try{
      final response = await ApiClient.postMultipart('/api/auth/profile',fields: {'nickname':nicknameController.text},
      images: selectedImage != null ? [selectedImage!]: null,imageField: 'image',token: true);
      print(response.body);
      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(
          context,
          '/home',
        );
      } else {
        print('프로필 등록 실패: ${response.statusCode}');
      }
    }catch(e){
      print(e);
    }
  }

  Future<void> getUserInfo()async{
    final response = await ApiClient.get('/api/auth/myinfo',token: true);
    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      if (!mounted) return;
      setState(() {
        nicknameController.text = data["user"]["nickname"];
        profileImage = data["image"];
      });
    }
  }

  Future<void> pickImage() async {
  final XFile? image = await _picker.pickImage(
    source: ImageSource.gallery,
  );

    if (image == null) {
      return;
    }

    setState(() {
      selectedImage = image;
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

    backgroundImage: selectedImage != null
              ? FileImage(
                  File(selectedImage!.path),
                )
              : NetworkImage(profileImage)
                  as ImageProvider,

    ),
    ),

    Positioned(

    right: 0,
    bottom: 0,

    child: GestureDetector(

    onTap: () async {
            await pickImage();
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
            makeProfile(context);
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