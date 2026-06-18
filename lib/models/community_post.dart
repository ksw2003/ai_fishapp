class CommunityPost {
  final String title;
  final String content;
  final String author;
  final String tag;
  final int commentCount;
  final bool isMine;

  CommunityPost({
    required this.title,
    required this.content,
    required this.author,
    required this.tag,
    required this.commentCount,
    required this.isMine,
  });
}