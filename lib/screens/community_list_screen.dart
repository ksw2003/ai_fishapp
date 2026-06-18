import 'package:flutter/material.dart';

import '../models/community_post.dart';
import './post_card.dart';

class CommunityListScreen extends StatefulWidget {
  const CommunityListScreen({super.key});

  @override
  State<CommunityListScreen> createState() =>
      _CommunityListScreenState();
}

class _CommunityListScreenState
    extends State<CommunityListScreen> {
  final searchController =
      TextEditingController();

  final tagController =
      TextEditingController();

  final List<CommunityPost> posts = [
    CommunityPost(
      author: "한경이1",
      title: "구피 키우시는 분 계시나요?",
      content:
          "며칠째 밥도 안먹고 잘 움직이지도 않네요...",
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
      isMine: false,
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
    return posts.where((post) {
      final titleKeyword =
          searchController.text.toLowerCase();

      final tagKeyword =
          tagController.text.toLowerCase();

      final titleMatch =
          post.title
              .toLowerCase()
              .contains(titleKeyword);

      final tagMatch =
          tagKeyword.isEmpty ||
          post.tag
              .toLowerCase()
              .contains(tagKeyword);

      return titleMatch && tagMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: Column(
        FloatingActionButton(
              heroTag: "AIchat",
          onPressed: () {},
          shape: CircleBorder(),
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: "write",
          onPressed: () {},
          shape: CircleBorder(),
          child: const Icon(Icons.add),
        ),
      )

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: TextField(
                controller: searchController,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: "게시글 검색",
                  prefixIcon:
                      const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                            15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: TextField(
                controller: tagController,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: "태그 검색",
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                            15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount:
                    filteredPosts.length,
                itemBuilder:
                    (context, index) {
                  return PostCard(
                    post:
                        filteredPosts[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}