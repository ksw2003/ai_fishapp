import 'comment.dart';

class PostDetail {
  final int postId;
  final int userId;
  final String nickname;
  final String title;
  final String content;
  final String fishType;
  final bool mine;
  final List<Map<String, dynamic>> images;
  final List<Comment> comments;
  final List<Comment> replies;

  PostDetail({
    required this.postId,
    required this.userId,
    required this.nickname,
    required this.title,
    required this.content,
    required this.fishType,
    required this.mine,
    required this.images,
    required this.comments,
    required this.replies,
  });

  factory PostDetail.fromJson(Map<String, dynamic> json) {
    final post = json["Postdata"];

    return PostDetail(
      postId: post["post_id"],
      userId: post["user_id"],
      nickname: post["User"]["nickname"],
      title: post["title"],
      content: post["content"],
      fishType: post["fish_type"],
      mine: json["mine"],

      images: List<Map<String, dynamic>>.from(json["images"]),
      comments: ((json["commentDatas"] ?? []) as List)
          .map((e) => Comment.fromJson(e))
          .toList(),
      replies: ((json["replyData"] ?? []) as List)
          .map((e) => Comment.fromJson(e))
          .toList(),
    );
  }
}