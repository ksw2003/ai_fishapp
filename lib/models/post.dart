class Post {
  final int postId;
  final String title;
  final String content;
  final String fishType;
  final String nickname;

  Post({
    required this.postId,
    required this.title,
    required this.content,
    required this.fishType,
    required this.nickname,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['post_id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      fishType: json['fish_type'] ?? '',
      nickname: json['User']?['nickname'] ?? '익명의 한경이',
    );
  }
}