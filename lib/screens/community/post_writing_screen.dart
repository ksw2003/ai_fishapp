import 'package:flutter/material.dart';

class PostWritingScreen extends StatefulWidget {
  const PostWritingScreen({super.key});

  @override
  State<PostWritingScreen> createState() =>
      _PostWritingScreenState();
}

class _PostWritingScreenState
    extends State<PostWritingScreen> {

  final titleController = TextEditingController();
  final contentController = TextEditingController();

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
    onPressed: () {},

    child: const Text(
    "등록",
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
              children: const [

                Text(
                  "사진 등록",
                  style: TextStyle(
                    color: Color(0xff9BA9B0),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                Spacer(),

                Text(
                  "1/4",
                  style: TextStyle(
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

            child: ListView(
              scrollDirection: Axis.horizontal,

              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),

              children: [

                /// 더미 사진
                Container(
                  width: 108,
                  height: 108,
                  margin: const EdgeInsets.only(
                    right: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xff9BA9B0),
                      width: 2,
                    ),
                    image: const DecorationImage(
                      image: NetworkImage(
                        "https://picsum.photos/200",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                /// 사진 추가
                GestureDetector(
                  onTap: () {},

                  child: Container(
                    width: 108,
                    height: 108,

                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(20),

                      border: Border.all(
                        color: const Color(0xff9BA9B0),
                        width: 2,
                        style: BorderStyle.solid,
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
                ),

              ],
            ),
          ),

          const SizedBox(height: 20),

        ],
        ),
        ),
    );
  }
}