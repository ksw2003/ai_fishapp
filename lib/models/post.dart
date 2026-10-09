class Post {
  final int postId;
  final String title;
  final String content;
  final String fishType;
  final String nickname;
  final String commentCount;

  Post({
    required this.postId,
    required this.title,
    required this.content,
    required this.fishType,
    required this.nickname,
    required this.commentCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['post_id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      fishType: json['fish_type'] ?? '',
      commentCount: json['comment_count']?.toString() ?? '0',
      nickname: json['User']?['nickname'] ?? '익명의 한경이',
    );
  }
}