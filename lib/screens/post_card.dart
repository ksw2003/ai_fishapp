import 'package:flutter/material.dart';
import '../models/community_post.dart';

class PostCard extends StatelessWidget {
  final CommunityPost post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 24,
                child: Icon(Icons.pets),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.author,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const Spacer(),

                        if (post.isMine)
                          PopupMenuButton(
                            icon: const Icon(
                              Icons.more_vert,
                            ),
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: "edit",
                                child: Text("수정"),
                              ),
                              const PopupMenuItem(
                                value: "delete",
                                child: Text("삭제"),
                              ),
                            ],
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      post.content,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                                    20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline,
                                size: 15,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                post.commentCount
                                    .toString(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xfff5f5f5),
                            borderRadius:
                                BorderRadius.circular(
                                    20),
                          ),
                          child: Text(
                            post.tag,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Divider(
            color: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }
}