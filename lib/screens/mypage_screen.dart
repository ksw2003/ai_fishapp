import 'dart:convert';

import 'package:ai_fishapp/api/api_client.dart';
import 'package:ai_fishapp/screens/start_screen.dart';
import 'package:ai_fishapp/services/socket_service.dart';
import 'package:ai_fishapp/services/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/common_bottom_nav_bar.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});
  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}
class _MyPageScreenState extends State<MyPageScreen>{
 // ===============================
  // 임시 데이터
  // 나중에 UserModel(API)로 교체
  // ===============================

  String nickname = "한경이";

  String profileImage =
      "https://i.pravatar.cc/300";

  @override
  void initState(){
    super.initState();
    getUserInfo();
  }
  
  Future<void> getUserInfo()async{
    final response = await ApiClient.get('/api/auth/myinfo',token: true);
    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      if (!mounted) return;
      setState(() {
        nickname = data["user"]["nickname"];
        profileImage = data["image"];
      });
    }
  }

  Future<void>logout(BuildContext context)async{
    final response = await ApiClient.post('/api/auth/logout',null,token: true);
    if(response.statusCode == 204){
      await TokenStorage.deleteTokens();
      await TokenStorage.deleteTokens();
      SocketService.instance.disconnect();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> const StartScreen()),(route)=>false);
    }else{
      print('로그아웃 실패');
    }
  }

  Future<void> showTankSettingDialog(BuildContext context) async {
    final tankId = await TokenStorage.getdeviceId();
    final response = await ApiClient.get('/api/tank/setting/$tankId',token: true);
    final data = jsonDecode(response.body);
    final tankNameController = TextEditingController(text:data['tank_name'] ?? '');
    final minTempController =
        TextEditingController(text: data['min_temp']?.toString() ?? '');
    final maxTempController =
        TextEditingController(text: data['max_temp']?.toString() ?? '');
    final normalWaterController =
        TextEditingController(text: data['normal_waterquality']?.toString() ?? '');
    final warningWaterController =
        TextEditingController(text: data['warning_waterquality']?.toString() ?? '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('어항 설정 변경'),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tankNameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: '어항 이름'
                  ),
                ),
                TextField(
                  controller: minTempController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: '최저 온도',
                    suffixText: '℃',
                  ),
                ),

                TextField(
                  controller: maxTempController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: '최고 온도',
                    suffixText: '℃',
                  ),
                ),

                TextField(
                  controller: normalWaterController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '정상 수질 기준',
                  ),
                ),

                TextField(
                  controller: warningWaterController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '위험 수질 기준',
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),

            ElevatedButton(
              onPressed: () async {
                final tankName = tankNameController.text.trim();
                final minTemp =
                    double.tryParse(minTempController.text);
                final maxTemp =
                    double.tryParse(maxTempController.text);
                final normalWater =
                    int.tryParse(normalWaterController.text);
                final warningWater =
                    int.tryParse(warningWaterController.text);

                if (minTemp == null ||
                    maxTemp == null ||
                    normalWater == null ||
                    warningWater == null) {
                  return;
                }

                // 여기에서 서버에 수정 요청

                
                final response = await ApiClient.post(
                    '/api/tank/setting/$tankId',
                    jsonEncode({
                      "min_temp": minTemp,
                      "max_temp": maxTemp,
                      "tank_name": tankName,
                      "normal_waterquality": normalWater,
                      "warning_waterquality": warningWater,
                    }),
                    token: true,
                  );

                  if (!context.mounted) return;

                  if (response.statusCode == 204) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('어항 설정이 변경되었습니다.'),
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('어항 설정 변경에 실패했습니다.'),
                      ),
                    );
                  
                }
              },
              child: const Text('변경'),
            ),
          ],
        );
      },
    );
  }



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

    //--------------------------------
    // 어항 설정 화면
    //--------------------------------

    const SizedBox(height: 18),

    MyPageButton(title: "어항 설정", onTap: (){
      showTankSettingDialog(context);
    }),

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
                logout(context);
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
