import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/post.dart';
import '../models/post_detail.dart';
import '../api/api_client.dart';

class CommunityService {

  /// 게시글 목록
  static Future<List<Post>> getPosts() async {
    final response = await http.get(
      Uri.parse("${ApiClient.baseUrl}/api/community/list"),
    );
    if (response.statusCode != 200) {
      throw Exception("게시글 목록 조회 실패");
    }

    final json = jsonDecode(response.body);

    return (json["datas"] as List)
        .map((e) => Post.fromJson(e))
        .toList();
  }

  /// 게시글 상세
  static Future<PostDetail> getPostDetail(int postId) async {
    final response = await http.get(
      Uri.parse(
        "${ApiClient.baseUrl}/api/community/posts/$postId",
      ),
    );
    print(response.body);

    final json = jsonDecode(response.body);

    print(json);
    if (response.statusCode != 200) {
      throw Exception("게시글 조회 실패");
    }

    return PostDetail.fromJson(
      jsonDecode(response.body),
    );
  }

  //게시글 작성
  static Future<void> createPost({
    required String title,
    required String content,
    required String fishType,
    required List<XFile> images,
  }) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse(
        "${ApiClient.baseUrl}/api/community/posts",
      ),
    );

    request.fields["title"] = title;
    request.fields["content"] = content;
    request.fields["fish_type"] = fishType;

    for (final image in images) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "images",
          image.path,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response =
    await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        "게시글 작성 실패 : ${response.body}",
      );
    }
  }
  /// 댓글 작성
  static Future<void> writeComment({
    required int postId,
    required String content,
    int? parentId,
  }) async {
    final response = await http.post(
      Uri.parse(
        "${ApiClient.baseUrl}/api/community/comment",
      ),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "post_id": postId,
        "content": content,
        "commentId": parentId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("댓글 작성 실패");
    }
  }

  /// 게시글 삭제
  static Future<void> deletePost(int postId) async {
    final response = await http.delete(
      Uri.parse(
        "${ApiClient.baseUrl}/api/community/posts/$postId",
      ),
    );

    if (response.statusCode != 204 &&
        response.statusCode != 200) {
      throw Exception("게시글 삭제 실패");
    }
  }
  /// 게시글 수정
  static Future<void> updatePost({
    required int postId,
    required String title,
    required String content,
    required String fishType,
    required List<XFile> images,
    required List<int> deletedImageIds,
  }) async {

    final request = http.MultipartRequest(
      "POST",
      Uri.parse(
        "${ApiClient.baseUrl}/api/community/update/$postId",
      ),
    );

    request.fields["title"] = title;
    request.fields["content"] = content;
    request.fields["fish_type"] = fishType;
    request.fields["deleteImageId"] =
        jsonEncode(deletedImageIds);

    for (final image in images) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "images",
          image.path,
          contentType: MediaType("image", "png"),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response =
    await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        "게시글 수정 실패 : ${response.body}",
      );
    }
  }
  ///댓글 삭제
  static Future<void> deleteComment(
      int commentId,
      ) async {

    final response = await http.post(
      Uri.parse(
        "${ApiClient.baseUrl}/api/community/deletecomment/$commentId",
      ),
    );

    if (response.statusCode != 200) {
      throw Exception("댓글 삭제 실패");
    }

  }
  ///댓글 수정
  static Future<void> updateComment({
    required int commentId,
    required String content,
  }) async {

    final response = await http.post(
      Uri.parse(
        "${ApiClient.baseUrl}/api/community/comment/$commentId",
      ),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "update": content,
      }),
    );

    if (response.statusCode != 204) {
      throw Exception("댓글 수정 실패");
    }
  }
  /// 댓글 좋아요
  static Future<bool> toggleCommentLike(
      int commentId,
      ) async {

    final response = await http.post(
      Uri.parse(
        "${ApiClient.baseUrl}/api/community/commentLike/$commentId",
      ),
    );
    if (response.statusCode != 200) {
      throw Exception("추천 실패");
    }
    final data = jsonDecode(response.body);
    return data["like"];
  }
}

