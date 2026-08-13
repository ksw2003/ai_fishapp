class Fish {
  final int fishId;
  final String fishType;
  final int fishCount;

  Fish({
    required this.fishId,
    required this.fishType,
    required this.fishCount,
  });

  factory Fish.fromJson(Map<String, dynamic> json) {
    return Fish(
      fishId: json["fish_id"],
      fishType: json["fish_type"],
      fishCount: json["fish_count"],
    );
  }
}