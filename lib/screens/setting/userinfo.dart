class UserModel {
  final String nickname;
  final String profileImage;
  final List<FishData> fishes;

  UserModel({
    required this.nickname,
    required this.profileImage,
    required this.fishes,
  });
}

class FishData {
  final String species;
  final int count;
  bool isEditing;

  FishData({
    required this.species,
    required this.count,
    this.isEditing = false,
  });
}