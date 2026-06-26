import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/chatbot_screen.dart';

import 'screens/iot/live_video_screen.dart';
import 'screens/iot/water_temp_detail_screen.dart';
import 'screens/iot/daily_temp_detail_screen.dart';
import 'screens/iot/water_change_loading_screen.dart';
import 'screens/iot/feeding_loading_screen.dart';
import 'screens/iot/fish_info_management_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        // 하단 네비게이션바 메인 화면들
        '/home': (context) => const HomeScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/chatbot': (context) => const ChatbotScreen(),


        // 설정 화면에서 이동되는 화면
        '/fish-info': (context) => const FishInfoManagementScreen(),

        // 홈 화면에서 이동되는 상세 화면들
        '/live-video': (context) => const LiveVideoScreen(),
        '/water-temp': (context) => const WaterTempDetailScreen(),

        // 달력 화면에서 이동되는 상세 화면
        '/daily-temp-detail': (context) => const DailyTempDetailScreen(),

        // 환수 / 먹이 로딩 화면
        '/water-change-loading': (context) =>
            const WaterChangeLoadingScreen(),
        '/feeding-loading': (context) => const FeedingLoadingScreen(),

        // 아직 미완성 화면은 임시로 홈 연결
        '/community': (context) => const HomeScreen(),
      },
    );
  }
}