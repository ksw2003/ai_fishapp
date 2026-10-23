class Post {
  final int postId;
  final String title;
  final String content;
  final String fishType;
  final String nickname;
  final String picture;
  final int commentCount;

  Post({
    required this.postId,
    required this.title,
    required this.content,
    required this.fishType,
    required this.nickname,
    required this.commentCount,
    required this.picture
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['post_id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      fishType: json['fish_type'] ?? '',
      commentCount: json['comment_count'] ?? 0,
      nickname: json['User']?['nickname'] ?? '익명의 한경이',
      picture: json['User']?['UserImage'],
    );
  }
}