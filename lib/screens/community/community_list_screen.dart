import 'package:flutter/material.dart';
import './community_post.dart';
import 'post_card.dart';
import 'community_detail_screen.dart';
import '../../widgets/common_bottom_nav_bar.dart';
class CommunityListScreen extends StatefulWidget {
  const CommunityListScreen({super.key});

  @override
  State<CommunityListScreen> createState() =>
      _CommunityListScreenState();
}

class _CommunityListScreenState
    extends State<CommunityListScreen> {
  final searchController = TextEditingController();

  final List<CommunityPost> posts = [
    CommunityPost(
      author: "한경이1",
      title: "구피 키우시는 분 계시나요?",
      content: "며칠째 밥도 안먹고 잘 움직이지도 않네요...",
      tag: "구피",
      commentCount: 2,
      isMine: true,
    ),
    CommunityPost(
      author: "한경이1",
      title: "금붕어 집사 3개월차",
      content: "금붕어 너무 귀여워요!",
      tag: "금붕어",
      commentCount: 1,
      isMine: true,
    ),
    CommunityPost(
      author: "한경이1",
      title: "테트라 키우시는 분 계시나요?",
      content: "요즘 밥을 안먹어요",
      tag: "테트라",
      commentCount: 5,
      isMine: true,
    ),
  ];

  List<CommunityPost> get filteredPosts {
    final keyword = searchController.text.trim().toLowerCase();

    if (keyword.isEmpty) {
      return posts;
    }

    return posts.where((post) {
      return post.title
          .toLowerCase()
          .contains(keyword);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: "write",
              elevation: 3,
              shape: const CircleBorder(),
              backgroundColor: const Color(0xffBCC4D4),
              onPressed: () {
                Navigator.pushNamed(context, '/post-writing');
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 32,
              ),
            ),

            const SizedBox(height: 14),

            FloatingActionButton(
              heroTag: "chat",
              elevation: 4,
              backgroundColor: Colors.transparent,
              onPressed: () {
                Navigator.pushNamed(context, '/chatbot');
              },
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment(0.0, 0.35),
                    end: Alignment(1.23, 0.78),
                    colors: [
                      Color(0xff00C2FA),
                      Color(0xff005FEA),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.chat_bubble,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [

            /// 상단
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.menu),
                  ),
                ],
              ),
            ),

            /// 검색창
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 27),
              child: SizedBox(
                height: 49,
                child: TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "검색",
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color(0xffF5F5F5),
                        width: 3,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color(0xff94ABCC),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// 태그
            Padding(
              padding: const EdgeInsets.only(
                right: 30,
                top: 10,
                bottom: 8,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    "태그 : 전체",
                    style: TextStyle(
                      color: Color(0xff94ABCC),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            /// 게시글 목록
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: filteredPosts.length,
                itemBuilder: (context, index) {
                  final post = filteredPosts[index];

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CommunityDetailScreen(
                                post: post,
                              ),
                        ),
                      );
                    },
                    child: PostCard(
                      post: post,
                      keyword: searchController.text,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const CommonBottomNavBar(
        selectedIndex: 2,
      ),
    );
  }
}