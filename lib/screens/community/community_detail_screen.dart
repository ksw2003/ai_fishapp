import 'package:flutter/material.dart';
import './community_post.dart';

class CommunityDetailScreen extends StatefulWidget {
  final CommunityPost post;

  const CommunityDetailScreen({
    super.key,
    required this.post,
  });

  @override
  State<CommunityDetailScreen> createState() =>
      _CommunityDetailScreenState();
}

class _CommunityDetailScreenState
    extends State<CommunityDetailScreen> {

  final TextEditingController commentController =
  TextEditingController();

  final List<Map<String, dynamic>> comments = [

    {
      "author": "바우덕이",
      "content": "혹시 환수는 자주 해주셨나요?",
      "like": 1,
      "mine": false,
    },

    {
      "author": "한경이1",
      "content": "일주일에 한 번씩 해줬어요",
      "like": 0,
      "mine": true,
    },

  ];

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final post = widget.post;

    return Scaffold(

        backgroundColor: Colors.white,

        bottomNavigationBar: SafeArea(

        child: Padding(

        padding: const EdgeInsets.fromLTRB(
        18,
        10,
        18,
        12,
    ),

    child: Row(

    children: [

    Expanded(

    child: Container(

    height: 42,

    decoration: BoxDecoration(

    color: const Color(0xffF5F5F5),

    borderRadius:
    BorderRadius.circular(20),

    ),

    child: TextField(

    controller: commentController,

    decoration: const InputDecoration(

    hintText: "댓글을 입력해주세요.",

    hintStyle: TextStyle(
    color: Color(0xffB8B8B8),
    ),

    border: InputBorder.none,

    contentPadding:
    EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 11,
    ),

    ),
    ),
    ),
    ),

    const SizedBox(width: 10),

    SizedBox(

    width: 60,
    height: 40,

    child: ElevatedButton(

    style: ElevatedButton.styleFrom(

    elevation: 0,

    backgroundColor:
    const Color(0xffF5F5F5),

    foregroundColor:
    const Color(0xff9BA9B0),

    shape: RoundedRectangleBorder(

    borderRadius:
    BorderRadius.circular(15),

    ),
    ),

    onPressed: () {},

    child: const Text("등록"),

    ),
    ),

    ],
    ),
    ),
    ),

    body: SafeArea(

    child: Column(

    children: [

    /// 상단
    Padding(

    padding: const EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 12,
    ),

    child: Row(

    children: [

    IconButton(

    onPressed: () {

    Navigator.pop(context);

    },

    icon: const Icon(
    Icons.arrow_back_ios_new,
    ),
    ),

    const Spacer(),

    PopupMenuButton(

    icon: const Icon(Icons.more_vert),

    itemBuilder: (_) => const [

    PopupMenuItem(
    value: "edit",
    child: Text("수정"),
    ),

    PopupMenuItem(
    value: "delete",
    child: Text("삭제"),
    ),

    ],
    ),

    ],
    ),
    ),

    Expanded(

    child: SingleChildScrollView(

    child: Column(

    crossAxisAlignment:
    CrossAxisAlignment.start,

    children: [
    /// 작성자
    Padding(
    padding: const EdgeInsets.symmetric(
    horizontal: 27,
    ),
    child: Row(
    crossAxisAlignment:
    CrossAxisAlignment.start,
    children: [

    Container(
    width: 54,
    height: 54,
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
    color: const Color(0xffBCC4D4),
    width: 3,
    ),
    ),
    child: const Icon(
    Icons.pets,
    size: 28,
    color: Color(0xff8A93A6),
    ),
    ),

    const SizedBox(width: 10),

    Expanded(
    child: Padding(
    padding:
    const EdgeInsets.only(
    top: 6,
    ),
    child: Text(
    post.author,
    style: const TextStyle(
    fontSize: 24,
    fontWeight:
    FontWeight.w700,
    ),
    ),
    ),
    ),
    ],
    ),
    ),

    const SizedBox(height: 15),

    /// 제목
    Padding(
    padding: const EdgeInsets.symmetric(
    horizontal: 30,
    ),
    child: Text(
    post.title,
    style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    ),
    ),
    ),

    const SizedBox(height: 10),

    /// 내용
    Padding(
    padding: const EdgeInsets.symmetric(
    horizontal: 30,
    ),
    child: Text(
    post.content,
    style: const TextStyle(
    fontSize: 18,
    height: 1.8,
    ),
    ),
    ),

    const SizedBox(height: 18),

    /// 태그
    Padding(
    padding: const EdgeInsets.symmetric(
    horizontal: 30,
    ),
    child: Container(
    padding:
    const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 5,
    ),
    decoration: BoxDecoration(
    color: const Color(0xffF5F5F5),
    borderRadius:
    BorderRadius.circular(15),
    ),
    child: Text(
    post.tag,
    style: const TextStyle(
    color: Color(0xff9BA9B0),
    fontSize: 18,
    ),
    ),
    ),
    ),

    const SizedBox(height: 20),

    const Divider(
    thickness: 2,
    color: Color(0xffF5F5F5),
    ),

    /// 댓글 개수
    Padding(
    padding: const EdgeInsets.fromLTRB(
    30,
    12,
    30,
    10,
    ),
    child: Text(
    "댓글 ${post.commentCount}개",
    style: const TextStyle(
    fontSize: 18,
    ),
    ),
    ),

    const Divider(
    thickness: 2,
    color: Color(0xffF5F5F5),
    ),

    /// 댓글 목록
    ListView.separated(

    physics:
    const NeverScrollableScrollPhysics(),

    shrinkWrap: true,

    itemCount: comments.length,

    separatorBuilder: (_, __) =>
    const Divider(
    thickness: 2,
    color: Color(0xffF5F5F5),
    ),

    itemBuilder: (context, index) {

    final comment =
    comments[index];

    return Padding(

    padding:
    const EdgeInsets.fromLTRB(
    27,
    16,
    27,
    16,
    ),

    child: Row(

    crossAxisAlignment:
    CrossAxisAlignment.start,

    children: [

    Container(
    width: 45,
    height: 45,
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
    color:
    const Color(
    0xffBCC4D4),
    width: 3,
    ),
    ),
    child: const Icon(
    Icons.pets,
    size: 22,
    color:
    Color(0xff8A93A6),
    ),
    ),

    const SizedBox(width: 12),

    Expanded(

    child: Column(

    crossAxisAlignment:
    CrossAxisAlignment
        .start,

    children: [

    Text(
    comment["author"],
    style:
    const TextStyle(
    fontSize: 18,
    fontWeight:
    FontWeight
        .w700,
    ),
    ),

    const SizedBox(
    height: 6),

    Text(
    comment["content"],
    style:
    const TextStyle(
    fontSize: 18,
    height: 1.6,
    ),
    ),
      const SizedBox(height: 12),

      Align(
        alignment:
        Alignment.centerRight,
        child: Container(
          height: 34,
          padding:
          const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color:
            comment["like"] > 0
                ? const Color(
                0xffCCE6FF)
                : Colors.white,
            border: Border.all(
              color: comment["like"] > 0
                  ? const Color(
                  0xff6AB0E3)
                  : const Color(
                  0xffF5F5F5),
              width: 2,
            ),
            borderRadius:
            BorderRadius.circular(
                15),
          ),
          child: Row(
            mainAxisSize:
            MainAxisSize.min,
            children: [

              Icon(
                Icons.thumb_up_alt_outlined,
                size: 16,
                color:
                comment["like"] > 0
                    ? const Color(
                    0xff1461FC)
                    : const Color(
                    0xff9BA9B0),
              ),

              const SizedBox(width: 6),

              Text(
                comment["like"]
                    .toString(),
                style: TextStyle(
                  fontSize: 16,
                  color:
                  comment["like"] > 0
                      ? const Color(
                      0xff1461FC)
                      : const Color(
                      0xff9BA9B0),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
    ),
    ),
    ],
    ),
    );
    },
    ),

      const SizedBox(height: 30),
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