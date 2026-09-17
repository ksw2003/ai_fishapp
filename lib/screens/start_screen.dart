import 'dart:async';
import 'dart:convert';
import 'package:ai_fishapp/api/api_client.dart';
import 'package:ai_fishapp/services/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool isLoading = true;
  bool showLogin = false;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> kakaoLogin(BuildContext context)async{
    try{
      print(1);
      final data = await UserApi.instance.loginWithKakaoAccount();
      print(2);
      final (success,hasUsernickname) = await getToken(data.accessToken,'kakao');
      if(success){
        if(hasUsernickname){
          //관찰화면으로 이동 /home
          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        }else{
          //설정 화면으로 이동 /make-profile
          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, '/make-profile');
        }
      }else{
        print('로그인 실패');
      }
    }catch(e){
      print('카카오 로그인 오류: $e');
    }
  }

  Future<void> googleLogin(BuildContext context)async{
    try{
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
      print(googleUser);
      final authorization = await googleUser.authorizationClient.authorizationForScopes([
        'openid',
        'email',
        'profile',
      ]);
      final accesstoken = authorization?.accessToken;
      if (accesstoken == null) {
        print('구글 ID Token 없음');
        return;
      }
      final (success,hasUsernickname) = await getToken(accesstoken,'google');
      if(success){
        if(hasUsernickname){
          //관찰화면으로 이동 /home
          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        }else{
          //설정 화면으로 이동 /make-profile
          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, '/make-profile');
        }
      }else{
        print('로그인 실패');
      }
    } on GoogleSignInException catch (e) {
        print('===== GoogleSignInException =====');
        print('code: ${e.code}');
        print('description: ${e.description}');
        print('details: ${e.details}');
      }catch(e){
      print('구글 로그인 오류: $e');
    }
  }

  Future<(bool, dynamic)> getToken(String accesstoken,provider) async{
    final response = await ApiClient.post('/api/auth/login',
      jsonEncode({'accesstoken':accesstoken,'provider':provider})
    );
    await TokenStorage.deleteDeviceId();
    final tankid = await TokenStorage.getdeviceId();
    print(tankid); 
    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      TokenStorage.saveTokens(data['accesstoken'],data['refreshtoken']);
      if(data['device_id']!=null){
        print("들어감");
        TokenStorage.savedeviceId(data['device_id']);
      }
      return (true,data['exNickname']);
    }else{
      print('로그인 실패');
      return (false,false);
    }

  }


  void openLoginPanel() {
    if (isLoading) return;

    setState(() {
      showLogin = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 배경
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF5EA8FF),
                  Color(0xFF79D7FF),
                ],
              ),
            ),
          ),

          /// 로고 영역
          Center(
            child: GestureDetector(
              onTap: openLoginPanel,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/fish_logo.png',
                    width: 260,
                  ),

                  const Text(
                    'FISH LOGO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 30),

                  if (isLoading)
                    const SizedBox(
                      width: 35,
                      height: 35,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),

                  if (!isLoading)
                    const Text(
                      '화면을 터치해주세요',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),

          /// 로그인 패널
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),

            left: 0,
            right: 0,

            bottom: showLogin ? 0 : -450,

            child: Container(
              height: 400,

              decoration: const BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, -3),
                  ),
                ],
              ),

              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 30,
                ),

                child: Column(
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFF0342AB),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 40),

                    const Text(
                      'SNS로 간편 가입하기',
                      style: TextStyle(
                        color: Color(0xFF50576B),
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEE500),
                          foregroundColor: Colors.black,
                        ),

                        onPressed: () {
                          kakaoLogin(context);
                        },

                        child: const Text(
                          '카카오 로그인',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: OutlinedButton(
                        onPressed: () {
                          googleLogin(context);
                        },

                        child: const Text(
                          '구글 로그인',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}