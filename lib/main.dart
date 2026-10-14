import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'screens/start_screen.dart';
import 'screens/make_profile_screen.dart';

import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/community_list_screen.dart';

import 'screens/community/post_writing_screen.dart';
import 'screens/chatbot_screen.dart';

import 'screens/iot/live_video_screen.dart';
import 'screens/iot/water_temp_detail_screen.dart';
import 'screens/iot/daily_temp_detail_screen.dart';
import 'screens/iot/water_change_loading_screen.dart';
import 'screens/iot/feeding_loading_screen.dart';
import 'screens/iot/fish_info_management_screen.dart';
import 'screens/iot/alert_screen.dart';

import 'screens/mypage_screen.dart';
import 'screens/setting/myfish_screen.dart';
import 'screens/setting/profile_edit_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await GoogleSignIn.instance.initialize(
      serverClientId: dotenv.env['GOOGLE_KEY']
  );
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']);
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/start',
      routes: {
        '/start': (context) => const StartScreen(),
        '/make-profile': (context) => const MakeProfileScreen(),
        // 하단 네비게이션바 메인 화면들
        '/home': (context) => const HomeScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/community': (context) => const CommunityListScreen(),
        //post-writing:글쓰기 화면
        '/post-writing': (context) => const PostWritingScreen(),
        '/chatbot': (context){
          final roomId = ModalRoute.of(context)!.settings.arguments as int;
          return ChatbotScreen(roomId:roomId);
        },

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
        '/alert': (context) => const AlertScreen(),

        //설정변경
        '/settings': (context) => const MyPageScreen(),
        '/my-fish': (context) => const MyFishScreen(),
        '/profile-edit': (context) => const ProfileEditScreen(),
        // 아직 미완성 화면은 임시로 홈 연결
        '/Home': (context) => const HomeScreen(),
      },
    );
  }
}