import 'dart:convert';
import 'dart:io';
import 'package:ai_fishapp/api/api_client.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MakeProfileScreen extends StatefulWidget {
  const MakeProfileScreen({super.key});

  @override
  State<MakeProfileScreen> createState() =>
      _MakeProfileScreenState();
}

class _MakeProfileScreenState
    extends State<MakeProfileScreen> {

  final TextEditingController nicknameController =
      TextEditingController();

  bool canUseNickname = false;

  String profileImage =
      "https://i.pravatar.cc/300";

  final ImagePicker _picker = ImagePicker();

  XFile? selectedImage;

  @override
  void dispose() {
    nicknameController.dispose();
    super.dispose();
  }

  void makeProfile(BuildContext context) async {
    final response = await ApiClient.postMultipart(
      '/api/auth/profile',
      fields: {'nickname': nicknameController.text},
      images: selectedImage != null ? [selectedImage!] : null,
      imageField: 'image',
      token: true,
    );

    if (response.statusCode == 200) {
      Navigator.pushNamed(context, "/home");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('데이터 저장에 실패하였습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void checkNickname() {
    setState(() {
      canUseNickname =
          nicknameController.text.trim().length >= 2;
    });
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
          padding:
              const EdgeInsets.symmetric(horizontal: 22),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //----------------------------------
              // 상단
              //----------------------------------

              const SizedBox(height: 12),

              // 뒤로가기 버튼 삭제

              const SizedBox(height: 20),

              const Text(
                "프로필 생성",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff50576B),
                ),
              ),

              const SizedBox(height: 28),

              //----------------------------------
              // 프로필 사진
              //----------------------------------

              Center(
                child: Stack(
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

                          decoration:
                              const BoxDecoration(
                            color: Color(0xffD9D9D9),
                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.photo_camera_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              //----------------------------------
              // 닉네임
              //----------------------------------

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
                        : "",

                    style: const TextStyle(
                      color: Color(0xff00C2FA),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Container(
                height: 55,

                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(20),

                  border: Border.all(
                    color: const Color(0xffF5F5F5),
                    width: 3,
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
                      horizontal: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 45),

              //----------------------------------
              // 생성하기 버튼
              //----------------------------------

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

                    backgroundColor:
                        const Color(0xff00C2FA),

                    disabledBackgroundColor:
                        Colors.grey.shade300,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),

                  child: const Text(
                    "생성하기",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
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