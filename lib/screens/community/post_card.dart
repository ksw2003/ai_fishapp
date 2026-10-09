import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../../services/community_service.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final String keyword;
  final String selectedTag;


  const PostCard({
    super.key,
    required this.post,
    required this.keyword,
    required this.selectedTag,
  });

  Widget buildHighlightedTitle() {
    if (keyword.trim().isEmpty) {
      return Text(
        post.title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      );
    }
    final title = post.title;
    final lowerTitle = title.toLowerCase();
    final lowerKeyword = keyword.toLowerCase();

    if (!lowerTitle.contains(lowerKeyword)) {
      return Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      );
    }

    List<TextSpan> spans = [];
    int start = 0;

    while (true) {
      final index = lowerTitle.indexOf(lowerKeyword, start);

      if (index == -1) {
        spans.add(
          TextSpan(
            text: title.substring(start),
          ),
        );
        break;
      }

      if (index > start) {
        spans.add(
          TextSpan(
            text: title.substring(start, index),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: title.substring(
            index,
            index + keyword.length,
          ),
          style: const TextStyle(
            color: Color(0xff005FEA),
            fontWeight: FontWeight.w800,
          ),
        ),
      );

      start = index + keyword.length;
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(27, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 작성자
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                padding: const EdgeInsets.all(8),
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
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    post.nickname,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// 제목
          buildHighlightedTitle(),

          const SizedBox(height: 8),

          /// 내용
          Text(
            post.content,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 18),

          /// 댓글 + 태그
          Row(
            children: [
              Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xffF5F5F5),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 18,
                      color: Color(0xff9BA9B0),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      post.commentCount,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xff9BA9B0),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: const Color(0xffF5F5F5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    post.fishType,
                    style: TextStyle(
                      color: keyword.isNotEmpty
                          ? Colors.blue
                          : const Color(0xff9BA9B0),
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Divider(
            thickness: 1,
            color: Color(0xffEFEFEF),
          ),
        ],
      ),
    );
  }
}