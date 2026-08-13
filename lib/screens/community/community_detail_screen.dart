import 'package:flutter/material.dart';
import '../../models/post_detail.dart';
import '../../services/community_service.dart';
import '../community/post_writing_screen.dart';
import '../../models/comment.dart';
import '../../api/api_client.dart';

//게시글 상세화면, 화면 열때 postId로 받아옴
class CommunityDetailScreen extends StatefulWidget {
  final int postId;

  const CommunityDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  State<CommunityDetailScreen> createState() =>
      _CommunityDetailScreenState();
}

//댓글 입력창, 게시글 데이터 저장, 답글대상, 수정중인 댓글번호, 댓글 수정 입력창
class _CommunityDetailScreenState extends State<CommunityDetailScreen> {

  final TextEditingController commentController =
  TextEditingController();

  late Future<PostDetail> futurePost;

  Comment? replyTarget;
  int? editingCommentId;
  final TextEditingController editController =
    TextEditingController();

  //화면 열릴때 실행, 게시글 상세조회 API 호출
  @override
  void initState() {
    super.initState();
    futurePost =
        CommunityService.getPostDetail(widget.postId);
  }


  @override
  void dispose() { //화면 종료 후 메모리 정리
    commentController.dispose();
    editController.dispose();
    super.dispose();
  }
  Widget _buildComment({ //댓글
    required Comment comment,
    required bool isReply,
  }) {
    return GestureDetector( //댓글 눌렀을 때 (답댓 위해)
      onTap: () {
        if (comment.isDeleted) return;

        setState(() {
          replyTarget = comment;
        });
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isReply ? 70 : 27,
          16,
          27,
          16,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if (isReply)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.subdirectory_arrow_right,
                  size: 18,
                  color: Colors.grey,
                ),
              ),

            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xffBCC4D4),
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.pets,
                size: 22,
                color: Color(0xff8A93A6),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    comment.isDeleted
                        ? "삭제된 댓글"
                        : comment.nickname,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: comment.isDeleted
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 6),

                  editingCommentId == comment.commentId

                      ? TextField(
                    controller: editController,
                    autofocus: true,

                    // 삭제
                    // maxLines: null,

                    textInputAction: TextInputAction.done,

                    onSubmitted: (value) async {
                      print("onSubmitted 실행");
                      if (value.trim().isEmpty) return;

                      await CommunityService.updateComment(
                        commentId: comment.commentId,
                        content: value,
                      );
                      print("API 완료");
                      setState(() {
                        comment.content = value;
                        editingCommentId = null;
                      });

                      FocusScope.of(context).unfocus();
                    },

                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  )

                      : Text(

                    comment.content,

                    style: TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      color: comment.isDeleted
                          ? Colors.grey
                          : Colors.black,
                      fontStyle: comment.isDeleted
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),

                  ),

                  const SizedBox(height: 12),

                  if (!comment.isDeleted)
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () async {

                          if (comment.isDeleted) return;

                          final wasLiked =
                          await CommunityService.toggleCommentLike(
                            comment.commentId,
                          );

                          setState(() {

                            if (wasLiked) {

                              comment.likeCount--;

                              comment.isLiked = false;

                            } else {

                              comment.likeCount++;

                              comment.isLiked = true;

                            }

                          });

                        },

                        child: Container(
                          height: 34,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),

                          decoration: BoxDecoration(

                            color: comment.isLiked
                                ? const Color(0xffCCE6FF)
                                : Colors.white,

                            border: Border.all(

                              color: comment.isLiked
                                  ? const Color(0xff6AB0E3)
                                  : const Color(0xffF5F5F5),

                              width: 2,
                            ),

                            borderRadius:
                            BorderRadius.circular(15),
                          ),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              Icon(
                                Icons.thumb_up_alt_outlined,
                                size: 16,

                                color: comment.isLiked
                                    ? const Color(0xff1461FC)
                                    : const Color(0xff9BA9B0),
                              ),

                              const SizedBox(width: 6),

                              Text(
                                comment.likeCount.toString(),

                                style: TextStyle(
                                  fontSize: 16,

                                  color: comment.isLiked
                                      ? const Color(0xff1461FC)
                                      : const Color(0xff9BA9B0),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),

                ],
              ),
            ),

    /// 댓글 메뉴
    if (!comment.isDeleted)
    PopupMenuButton<String>(
    padding: EdgeInsets.zero,
    icon: const Icon(Icons.more_vert),

    onSelected: (value) async {

    if (value == "delete") {

    await CommunityService.deleteComment(
    comment.commentId,
    );

    setState(() {
    futurePost =
    CommunityService.getPostDetail(widget.postId);
    });

    }

    if (value == "edit") {

    setState(() {

    editingCommentId = comment.commentId;

    editController.text = comment.content;

    });

    }

    },

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
    );
  }
  @override
  Widget build(BuildContext context) {

    return FutureBuilder<PostDetail>(

        future: futurePost,

        builder: (context, snapshot) {

      if (snapshot.connectionState ==
          ConnectionState.waiting) {

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (snapshot.hasError) {

        return Scaffold(
          body: Center(
            child: Text(
              snapshot.error.toString(),
            ),
          ),
        );
      }

      final post = snapshot.data!;

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

    controller:
    commentController,

      decoration: InputDecoration(

        hintText: replyTarget == null
            ? "댓글을 입력해주세요."
            : "${replyTarget!.nickname}님에게 답글",

        hintStyle: const TextStyle(
          color: Color(0xffB8B8B8),
        ),

        border: InputBorder.none,

        contentPadding: const EdgeInsets.symmetric(
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

    style:
    ElevatedButton.styleFrom(

    elevation: 0,

    backgroundColor:
    const Color(0xffF5F5F5),

    foregroundColor:
    const Color(0xff9BA9B0),

    shape:
    RoundedRectangleBorder(

    borderRadius:
    BorderRadius.circular(
    15,
    ),

    ),
    ),

    onPressed: () async {

    if (commentController.text
        .trim()
        .isEmpty) {
    return;
    }

    await CommunityService.writeComment(
      postId: post.postId,
      content: commentController.text,
      parentId: replyTarget?.commentId,
    );
    commentController.clear();
    replyTarget = null;

    setState(() {
    futurePost =
    CommunityService
        .getPostDetail(
    widget.postId,
    );

    });
    },
        child: const Text("등록")

    ),
    ),

    ],
    ),
    ),
    ),

    body: GestureDetector(
    onTap: () {
          FocusScope.of(context).unfocus();

          if (editingCommentId != null) {
          setState(() {
          editingCommentId = null;
          });
          }
          },

          child: SafeArea(
          child: Column(

    children: [

    Padding(

    padding:
    const EdgeInsets.symmetric(
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
      if (post.mine)
        PopupMenuButton<String>(
          padding: EdgeInsets.zero,

          onSelected: (value) async {

            if (value == "delete") {

              try {

                await CommunityService.deletePost(
                  post.postId,
                );

                if (!mounted) return;

                Navigator.pop(context, true);

              } catch (e) {

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                  ),
                );

              }
            }

            if (value == "edit") {

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostWritingScreen(
                    post: post,
                  ),
                ),
              );

              if (result == true) {
                setState(() {
                  futurePost =
                      CommunityService.getPostDetail(widget.postId);
                });

                Navigator.pop(context, true);
              }

            }

          },

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

    child:
    SingleChildScrollView(

    child: Column(

    crossAxisAlignment:
    CrossAxisAlignment.start,

    children: [
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
              padding: const EdgeInsets.only(
                top: 6,
              ),
              child: Text(
                post.nickname,
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

        const SizedBox(height: 20),

        /// 사진
        if (post.images.isNotEmpty)
        Padding(
      padding: const EdgeInsets.symmetric(
      horizontal: 30,
      ),
    child: Column(
      children: post.images.map((image) {
    return Padding(
    padding:
    const EdgeInsets.only(
    bottom: 12,
    ),
    child: ClipRRect(
    borderRadius:
    BorderRadius.circular(
    15,
    ),
    child: Image.network(
      "${ApiClient.baseUrl}${image["Image_url"]}",
    width: double.infinity,
    height: 250,
    fit: BoxFit.cover,

    errorBuilder:
    (context,
    error,
    stackTrace) {
    return Container(
    height: 250,
    color:
    Colors.grey.shade200,
    child: const Center(
    child: Text(
    "사진을 불러올 수 없습니다.",
    ),
    ),
    );
    },
    ),
    ),
    );
    }).toList(),
    ),
    ),

    const SizedBox(height: 20),

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
    post.fishType,
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
      "댓글 ${ post.comments.where((e) => !e.isDeleted).length +
          post.replies.where((e) => !e.isDeleted).length}개",
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

        physics: const NeverScrollableScrollPhysics(),

        shrinkWrap: true,

        itemCount: post.comments.length,

        separatorBuilder: (_, __) => const Divider(
          thickness: 2,
          color: Color(0xffF5F5F5),
        ),

        itemBuilder: (context, index) {

          final comment = post.comments[index];

          final replies = post.replies
              .where(
                (e) => e.parentId == comment.commentId,
          )
              .toList();

          return Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              _buildComment(
                comment: comment,
                isReply: false,
              ),

              ...replies.map(
                    (reply) => _buildComment(
                  comment: reply,
                  isReply: true,
                ),
                ).toList(),

            ],
          );
        },
    ),
          ],

    ),

    ),

    ),
        ],

    ),
    ),
    ),
      );

        },

    );

  }

}