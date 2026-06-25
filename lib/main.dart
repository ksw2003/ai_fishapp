import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/iot/live_video_screen.dart';
import 'screens/iot/water_temp_detail_screen.dart';
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
        '/home': (context) => const HomeScreen(),

        // 홈 화면에서 이동되는 화면들
        '/live-video': (context) => const LiveVideoScreen(),
        '/water-temp': (context) => const WaterTempDetailScreen(),
        '/water-change-loading': (context) =>
            const WaterChangeLoadingScreen(),
        '/feeding-loading': (context) => const FeedingLoadingScreen(),

        // 하단 네비게이션바 설정/관리
        '/fish-info': (context) => const FishInfoManagementScreen(),

        // 아직 미완성 화면들은 임시로 홈 연결
        '/calendar': (context) => const HomeScreen(),
        '/community': (context) => const HomeScreen(),
      },
    );
  }
}