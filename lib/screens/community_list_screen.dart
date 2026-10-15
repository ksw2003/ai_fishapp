import 'dart:convert';
import 'package:ai_fishapp/api/api_client.dart';
import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../../services/community_service.dart';
import '../../widgets/common_bottom_nav_bar.dart';
import 'community/community_detail_screen.dart';
import 'community/post_card.dart';
class CommunityListScreen extends StatefulWidget {
  const CommunityListScreen({super.key});
  @override
  State<CommunityListScreen> createState() =>
      _CommunityListScreenState();
}
class _CommunityListScreenState extends State<CommunityListScreen> {
  final searchController = TextEditingController();
  List<Post> posts = [];
  bool isLoading = true;
  bool isTagEditing = false;
  String selectedTag = "전체";
  final tagController = TextEditingController();
  final FocusNode tagFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    loadPosts();
  }
  Future<void> loadPosts() async {
    try {
      final result = await CommunityService.getPosts();
      setState(() {
        posts = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }
  List<Post> get filteredPosts {
    final keyword =
    searchController.text.trim().toLowerCase();
    return posts.where((post) {
      final matchKeyword =
          keyword.isEmpty ||
              post.title.toLowerCase().contains(keyword) ||
              post.content.toLowerCase().contains(keyword) ||
                post.nickname.toLowerCase().contains(keyword);
      final matchTag =
          selectedTag == "전체" ||
              post.fishType == selectedTag;
      return matchKeyword && matchTag;
    }).toList();
  }
  @override
  void dispose() {
    searchController.dispose();
    tagController.dispose();
    tagFocusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fabSize = (screenWidth * 0.14).clamp(52.0, 64.0);
    final fabSpacing = (screenWidth * 0.03).clamp(10.0, 18.0);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
        if (isTagEditing) {
          setState(() {
            tagController.clear();
            isTagEditing = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButtonLocation:
        FloatingActionButtonLocation.endFloat,
        floatingActionButton: Padding(
          padding: EdgeInsets.only(right: screenWidth * 0.01, bottom: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: "write",
                elevation: 3,
                shape: const CircleBorder(),
                backgroundColor: const Color(0xffBCC4D4),
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/post-writing',
                  );
                  if (result == true) {
                    loadPosts();
                  }
                },
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: fabSize * 0.55,
                ),
              ),
              const SizedBox(height: 14),
              FloatingActionButton(
                heroTag: "chat",
                elevation: 4,
                backgroundColor: Colors.transparent,
                onPressed: () async{
                  final response = await ApiClient.post('/api/chatbot', null,token:true);
                  final data = jsonDecode(response.body);
                  final int roomId = data['chatid'];
                  if(response.statusCode != 200){
                    print("생성 실패");
                  }else{
                    Navigator.pushNamed(context, '/chatbot',arguments: roomId);
                  }
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/alert',
                        );
                      },
                      icon: const Icon(
                        Icons.notifications_none,
                          size: 30,
                          color: Color(0xFF2D3E5F),
                      ),
                    ),
                  ],
                ),
              ),
              /// 검색창
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 27),
                child: SizedBox(
                  height: 49,
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "검색",
                      prefixIcon:
                      const Icon(Icons.search),
                      contentPadding:
                      const EdgeInsets.symmetric(
                          vertical: 0),
                      enabledBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(15),
                        borderSide:
                        const BorderSide(
                          color: Color(0xffF5F5F5),
                          width: 3,
                        ),
                      ),
                      focusedBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(15),
                        borderSide:
                        const BorderSide(
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      "태그 : ",
                      style: TextStyle(
                        color: Color(0xff94ABCC),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (!isTagEditing) {
                          tagController.text =
                          selectedTag == "전체"
                              ? ""
                              : selectedTag;
                          setState(() {
                            isTagEditing = true;
                          });
                          Future.delayed(Duration.zero, () {
                            tagFocusNode.requestFocus();
                          });
                        }
                      },
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 180,
                        ),
                        child: isTagEditing
                            ? IntrinsicWidth(
                          child: TextField(
                            controller: tagController,
                            focusNode: tagFocusNode,
                            autofocus: true,
                            textAlign: TextAlign.left,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              constraints: BoxConstraints(
                                minWidth: 10,
                              ),
                            ),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            onSubmitted: (value) {
                              setState(() {
                                selectedTag =
                                value.trim().isEmpty
                                    ? "전체"
                                    : value.trim();
                                isTagEditing = false;
                              });
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        )
                            : Text(
                          selectedTag,
                          overflow: TextOverflow.visible,
                          softWrap: false,
                          style: TextStyle(
                            color: selectedTag == "전체"
                                ? const Color(0xff94ABCC)
                                : Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              /// 게시글 목록
              Expanded(
                child: isLoading
                    ? const Center(
                  child:
                  CircularProgressIndicator(),
                )
                    : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount:
                  filteredPosts.length,
                  itemBuilder:
                      (context, index) {
                    final post =
                    filteredPosts[index];
                    return InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CommunityDetailScreen(
                              postId: post.postId,
                            ),
                          ),
                        );
                        if (result == true) {
                          loadPosts(); // 또는 fetchPosts()
                        }
                      },
                      child: PostCard(
                        post: post,
                        keyword:
                        searchController
                            .text,
                        selectedTag: selectedTag,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar:
        const CommonBottomNavBar(
          selectedIndex: 2,
        ),
      ),
    );
  }
}