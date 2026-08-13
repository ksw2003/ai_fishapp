import 'package:flutter/material.dart';
import '../../widgets/common_bottom_nav_bar.dart';
import '../../services/fishinfo_service.dart';
import '../../../models/fishinfo.dart';

class FishRowData {
  final int? fishId;

  final TextEditingController speciesController;
  final TextEditingController countController;

  bool isNew;

  FishRowData({
    this.fishId,
    required String species,
    required int count,
    this.isNew = false,
  })  : speciesController =
  TextEditingController(text: species),
        countController =
        TextEditingController(
          text: count == 0
              ? ""
              : count.toString(),
        );
}

class MyFishScreen extends StatefulWidget {
  const MyFishScreen({super.key});

  @override
  State<MyFishScreen> createState() =>
      _MyFishScreenState();
}

class _MyFishScreenState extends State<MyFishScreen> {
  bool isEdit = false;

  final List<FishRowData> fishes = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    loadFish();
  }

  Future<void> loadFish() async {
    try {
      final List<Fish> fishList =
      await FishService.getFishList();

      fishes.clear();

    for (var fish in fishList) {
      fishes.add(
        FishRowData(
          fishId: fish.fishId,
          species: fish.fishType,
          count: fish.fishCount,
        ),
      );
    }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("조회 실패 : $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    for (final fish in fishes) {
      fish.speciesController.dispose();
      fish.countController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),

      bottomNavigationBar: const CommonBottomNavBar(
        selectedIndex: 3,
      ),

      body: SafeArea(
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        ) : Column(
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              child: Row(
                children: [

                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xff8FA8D8),
                    ),
                  ),

                  const Spacer(),

                  GestureDetector(
  onTap: () async {

  if (isEdit) {

  for (final fish in fishes) {

  final fishType =
  fish.speciesController.text.trim();

  final fishCount =
  int.tryParse(
  fish.countController.text,
  ) ??
  0;

  if (fishType.isEmpty) continue;

  if (fish.isNew) {

  await FishService.addFish(
  fishType: fishType,
  fishCount: fishCount,
  );

  } else {

  await FishService.updateFish(
  fishId: fish.fishId!,
  fishType: fishType,
  fishCount: fishCount,
  );
  }
  }

  await loadFish();
  }

  setState(() {
  isEdit = !isEdit;
  });
  },
                    child: Text(
                      isEdit ? "저장" : "수정",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff9BA9B0),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "나의 물고기",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff50576B),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [

                  ...List.generate(
                    fishes.length,
                        (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FishRowWidget(
                        data: fishes[index],
                        isEdit: isEdit,
  onDelete: () async {

  final fish = fishes[index];

  if (fish.fishId != null) {

  await FishService.deleteFish(
  fish.fishId!,
  );
  }

  setState(() {

  fish.speciesController.dispose();
  fish.countController.dispose();

  fishes.removeAt(index);

  });

  },
                      ),
                    ),
                  ),

                  if (isEdit)

                    InkWell(
                      borderRadius:
                      BorderRadius.circular(16),
                      onTap: () {

                        setState(() {

                          fishes.add(
                            FishRowData(
                              species: "",
                              count: 0,
                              isNew: true,
                            ),
                          );

                        });

                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(
                                0xffCCE6FF),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "추가하기 +",
                            style: TextStyle(
                              color:
                              Color(0xff94ABCC),
                              fontSize: 17,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 22),

                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: loadFish,
                      style:
                      ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor:
                        const Color(
                            0xffCCE6FF),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                              12),
                        ),
                      ),
                      child: const Text(
                        "갱신하기",
                        style: TextStyle(
                          color:
                          Color(0xff50576B),
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FishRowWidget extends StatelessWidget {
  final FishRowData data;
  final bool isEdit;
  final VoidCallback onDelete;

  const FishRowWidget({
    super.key,
    required this.data,
    required this.isEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //----------------------------------
        // 물고기 종류
        //----------------------------------

        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xffF1F1F1),
                width: 2,
              ),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: isEdit
                ? TextField(
              controller: data.speciesController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "물고기 종류",
                hintStyle: TextStyle(
                  color: Color(0xffBCC4D4),
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
                : Text(
              data.speciesController.text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xff50576B),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        //----------------------------------
        // 개수
        //----------------------------------

        Container(
          width: 60,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xffF1F1F1),
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: isEdit
              ? TextField(
            controller: data.countController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "개수",
              hintStyle: TextStyle(
                color: Color(0xffBCC4D4),
                fontSize: 12,
              ),
            ),
          )
              : Text(
            data.countController.text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xff50576B),
            ),
          ),
        ),

        const SizedBox(width: 8),

        //----------------------------------
        // 삭제 버튼
        //----------------------------------

        if (isEdit)
          GestureDetector(
            onTap: onDelete,
            child: const SizedBox(
              width: 24,
              child: Center(
                child: Text(
                  "-",
                  style: TextStyle(
                    color: Color(0xffFFB7C3),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          )
        else
          const SizedBox(width: 24),
      ],
    );
  }
}