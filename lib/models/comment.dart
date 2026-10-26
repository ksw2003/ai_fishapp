class Comment {
  final int commentId;
  final int userId;
  final String nickname;
  String content;
  int likeCount;
  bool isLiked;
  String userpicture;
  final bool isDeleted;
  final int? parentId;

  Comment({
    required this.commentId,
    required this.userId,
    required this.nickname,
    required this.content,
    required this.likeCount,
    required this.isLiked,
    required this.isDeleted,
    required this.userpicture,
    this.parentId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['comment_id'],
      userId: json['User']['user_id'],
      nickname: json['User']['nickname'],
      content: json['content'],
      userpicture: json['User']?['UserImage']?['Image_url'] ?? '',
      likeCount: int.tryParse(json['likeCount'].toString()) ?? 0,
      isLiked: json['isLiked'] ?? false,
      isDeleted: json['is_deleted'] ?? false,
      parentId: json["parent_id"],
    );
  }
}