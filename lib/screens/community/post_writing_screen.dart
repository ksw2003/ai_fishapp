import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/community_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/post_detail.dart';
import '../../api/api_client.dart';

class PostWritingScreen extends StatefulWidget {
  final PostDetail? post;
  const PostWritingScreen({super.key, this.post});

  @override
  State<PostWritingScreen> createState() =>
      _PostWritingScreenState();
}

class _PostWritingScreenState
    extends State<PostWritingScreen> {

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  List<XFile> images = [];
  List<Map<String, dynamic>> oldImages = [];
  List<int> deletedImageIds = [];

  final List<String> tags = [
    "구피",
    "네온 테트라",
    "금붕어",
  ];

  String selectedTag = "구피";

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.post != null) {
      titleController.text = widget.post!.title;
      contentController.text = widget.post!.content;
      selectedTag = widget.post!.fishType;

      oldImages = List<Map<String, dynamic>>.from(widget.post!.images);
      print(widget.post!.images);
      print(oldImages);
    }
  }

  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      setState(() {
        images.addAll(picked);

        if (images.length > 4) {
          images = images.take(4).toList();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

        backgroundColor: Colors.white,

        body: SafeArea(
        child: Column(
        children: [

        /// 상단
        Padding(
        padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
    ),
    child: Row(
    children: [

    IconButton(
    onPressed: () {
    Navigator.pop(context);
    },
    icon: const Icon(
    Icons.arrow_back_ios_new,
    ),
    ),

    const Spacer(),

      TextButton(
        onPressed: () async {
          print("title = ${titleController.text}");
          print("content = ${contentController.text}");
          print("tag = $selectedTag");
          try {
            if (widget.post == null) {

              await CommunityService.createPost(
                title: titleController.text,
                content: contentController.text,
                fishType: selectedTag,
                images: images,
              );

            } else {

              await CommunityService.updatePost(
                postId: widget.post!.postId,
                title: titleController.text,
                content: contentController.text,
                fishType: selectedTag,
                images: images,
                deletedImageIds: deletedImageIds,
              );

            }

            if (!mounted) return;

            Navigator.pop(context, true);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
              ),
            );
          }
        },

        child: Text(
          widget.post == null ? "등록" : "수정",
          style: TextStyle(
            color: Color(0xff9BA9B0),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
    ),
        ),

    /// 태그
    Padding(
    padding: const EdgeInsets.symmetric(
    horizontal: 20,
    ),
    child: Wrap(
    spacing: 10,
    runSpacing: 10,
    children: [

    ...tags.map((tag) {

    final selected =
    selectedTag == tag;

    return GestureDetector(

    onTap: () {

    setState(() {

    selectedTag = tag;

    });

    },

    child: AnimatedContainer(

    duration: const Duration(
    milliseconds: 200,
    ),

    padding:
    const EdgeInsets.symmetric(
    horizontal: 15,
    vertical: 7,
    ),

    decoration: BoxDecoration(

    color: selected
    ? const Color(0xffCCE6FF)
        : const Color(0xffF5F5F5),

    borderRadius:
    BorderRadius.circular(15),

    ),

    child: Text(

    tag,

    style: TextStyle(

    fontSize: 18,

    color: selected
    ? const Color(0xff1461FC)
        : const Color(0xff9BA9B0),

    ),

    ),

    ),

    );

    }),

    /// 추가 버튼
    GestureDetector(

    onTap: () {},

    child: Container(

    padding:
    const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 7,
    ),

    decoration: BoxDecoration(

    border: Border.all(
    color: const Color(0xffF5F5F5),
    width: 3,
    ),

    borderRadius:
    BorderRadius.circular(15),

    ),

    child: const Row(

    mainAxisSize: MainAxisSize.min,

    children: [

    Text(

    "추가",

    style: TextStyle(

    color: Color(0xff9BA9B0),
    fontSize: 18,

    ),

    ),

    SizedBox(width: 5),

    Icon(
    Icons.add,
    color: Color(0xff9BA9B0),
    size: 18,
    ),

    ],

    ),

    ),

    ),

    ],
    ),
    ),

    const SizedBox(height: 25),

    /// 제목
    Padding(
    padding: const EdgeInsets.symmetric(
    horizontal: 30,
    ),
    child: TextField(

    controller: titleController,

    decoration: const InputDecoration(

    hintText: "제목을 입력하세요",

    border: InputBorder.none,

    hintStyle: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.black38,
    ),

    ),

    style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    ),

    ),
    ),

    const Divider(
    thickness: 2,
    color: Color(0xffF5F5F5),
    ),
          /// 내용 입력
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 20,
              ),
              child: TextField(
                controller: contentController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: "내용을 입력하세요.",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.black38,
                    height: 1.7,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.7,
                ),
              ),
            ),
          ),

          /// 구분선
          Container(
            height: 10,
            color: const Color(0xffF5F5F5),
          ),

          /// 사진 등록 제목
          Padding(
            padding: const EdgeInsets.fromLTRB(
              27,
              12,
              27,
              10,
            ),
            child: Row(
              children: [
                const Text(
                  "사진 등록",
                  style: TextStyle(
                    color: Color(0xff9BA9B0),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const Spacer(),

                Text(
                  "${oldImages.length + images.length}/4",
                  style: const TextStyle(
                    color: Color(0xff9BA9B0),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          /// 사진 영역
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: oldImages.length + images.length + 1,
                itemBuilder: (context, index) {
                  if (index < oldImages.length) {

                    print("${ApiClient.baseUrl}${oldImages[index]["Image_url"]}");

                    return Stack(
                      children: [

                        Container(
                          width: 108,
                          height: 108,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xff9BA9B0),
                              width: 2,
                            ),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.network(
                            "${ApiClient.baseUrl}${oldImages[index]["Image_url"]}",
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint("★★★★★ IMAGE ERROR ★★★★★");
                              debugPrint(error.toString());
                              debugPrint(stackTrace.toString());
                              return const Icon(Icons.error, color: Colors.red);
                            },
                          ),
                        ),

                        Positioned(
                          top: 5,
                          right: 15,
                          child: GestureDetector(
                            onTap: () {

                              setState(() {

                                deletedImageIds.add(
                                  oldImages[index]["Image_id"],
                                );

                                oldImages.removeAt(index);

                              });

                            },

                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(
                                Icons.close,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      ],
                    );
                  }

                  final newIndex = index - oldImages.length;

                  // 새로 선택한 사진
                  if (newIndex < images.length) {
                    return Container(
                      width: 108,
                      height: 108,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xff9BA9B0),
                          width: 2,
                        ),
                        image: DecorationImage(
                          image: FileImage(
                            File(images[newIndex].path),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }

                  // + 버튼
                  return GestureDetector(
                    onTap: pickImages,
                    child: Container(
                      width: 108,
                      height: 108,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xff9BA9B0),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          color: Color(0xff9BA9B0),
                          size: 45,
                        ),
                      ),
                    ),
                  );
                },
            ),
          ),

          const SizedBox(height: 20),
        ],
        ),
        ),
    );
  }
}