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

  // 일반 검색어와 일치하는 글자만 파란색으로 표시 (대소문자 구분 없음)
  Widget buildHighlightedText(
    String value, {
    required double fontSize,
    required FontWeight fontWeight,
    int? maxLines,
    TextOverflow? overflow,
    double? height,
  }) {
    final search = keyword.trim();
    final baseStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: Colors.black,
      height: height,
    );

    if (search.isEmpty) {
      return Text(
        value,
        style: baseStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final lowerValue = value.toLowerCase();
    final lowerSearch = search.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;

    while (true) {
      final index = lowerValue.indexOf(lowerSearch, start);
      if (index == -1) {
        spans.add(TextSpan(text: value.substring(start)));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: value.substring(start, index)));
      }
      spans.add(
        TextSpan(
          text: value.substring(index, index + search.length),
          style: const TextStyle(
            color: Color(0xff005FEA),
            fontWeight: FontWeight.w800,
          ),
        ),
      );
      start = index + search.length;
    }

    return Text.rich(
      TextSpan(style: baseStyle, children: spans),
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  Widget buildHighlightedTitle() {
    return buildHighlightedText(
      post.title,
      fontSize: 24,
      fontWeight: FontWeight.w700,
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
                  child: buildHighlightedText(
                    post.nickname,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          /// 제목: 일반 검색어에 일치하는 부분만 파란색
          buildHighlightedTitle(),
          const SizedBox(height: 8),

          /// 내용: 일반 검색어에 일치하는 부분만 파란색
          buildHighlightedText(
            post.content,
            fontSize: 18,
            fontWeight: FontWeight.normal,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            height: 1.6,
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
                      post.commentCount.toString(),
                      style: const TextStyle(
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
                      // 태그 필터를 적용했을 때만 파란색
                      color: selectedTag != '전체' &&
                              post.fishType == selectedTag
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
