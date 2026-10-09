import 'dart:convert';
import 'package:ai_fishapp/services/token_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/post.dart';
import '../models/post_detail.dart';
import '../api/api_client.dart';

class CommunityService {

  /// 게시글 목록
  static Future<List<Post>> getPosts() async {
    final response = await ApiClient.get(
      "/api/community/list",token: true
    );
    if (response.statusCode != 200) {
      throw Exception("게시글 목록 조회 실패");
    }

    final json = jsonDecode(response.body);

    print(json);
    return (json["datas"] as List)
        .map((e) => Post.fromJson(e))
        .toList();
  }

  /// 게시글 상세
  static Future<PostDetail> getPostDetail(int postId) async {
    final response = await ApiClient.get('/api/community/posts/$postId',token: true);
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
    final response = await ApiClient.postMultipart(
      "/api/community/posts",fields: {
        'title':title,
        'content':content,
        'fish_type':fishType
      },images: images,
      token: true
    );



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
    final response = await ApiClient.post(
      "/api/community/comment",
      jsonEncode({
        "post_id": postId,
        "content": content,
        "commentId": parentId,
      }),token: true
    );

    if (response.statusCode != 200) {
      throw Exception("댓글 작성 실패");
    }
  }

  /// 게시글 삭제
  static Future<void> deletePost(int postId,{bool retry = false}) async {
    final response = await ApiClient.delete(postId, '/api/community/posts/');

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
    final response = await ApiClient.postMultipart(
      "/api/community/update/$postId",fields: {
        'title':title,
        'content':content,
        'fish_type':fishType,
        'deleteImageId':jsonEncode(deletedImageIds)
      },images: images,
      token: true
    );
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

    final response = await ApiClient.post(
      "/api/community/deletecomment/$commentId",null,token: true
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

    final response = await ApiClient.post(
      "/api/community/comment/$commentId",
      
      jsonEncode({
        "update": content,
      }),
      token: true
    );

    if (response.statusCode != 204) {
      throw Exception("댓글 수정 실패");
    }
  }
  /// 댓글 좋아요
  static Future<bool> toggleCommentLike(
      int commentId,
      ) async {

    final response = await ApiClient.post(
      
      "/api/community/commentLike/$commentId",null,token: true
      
    );
    if (response.statusCode != 200) {
      throw Exception("추천 실패");
    }
    final data = jsonDecode(response.body);
    return data["like"];
  }
}

