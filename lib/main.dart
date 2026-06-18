import 'package:flutter/material.dart';
import 'screens/start_screen.dart';
import 'screens/community_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/community',

      routes: {
        '/community': (context) =>
        const CommunityListScreen(),
      },
    );
  }
}