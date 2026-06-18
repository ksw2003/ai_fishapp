import 'dart:async';
import 'package:flutter/material.dart';

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

                        onPressed: () {},

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
                        onPressed: () {},

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