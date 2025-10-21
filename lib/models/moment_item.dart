class MomentItem {
  String id;
  String title;
  List<String> photos; // base64

  MomentItem({required this.id, required this.title, List<String>? photos})
      : photos = photos ?? <String>[];

  factory MomentItem.fromJson(Map<String, dynamic> j) => MomentItem(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        photos: (j['photos'] as List?)?.cast<String>() ?? <String>[],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'photos': photos,
      };

  MomentItem copyWith({String? id, String? title, List<String>? photos}) =>
      MomentItem(
        id: id ?? this.id,
        title: title ?? this.title,
        photos: photos ?? List<String>.from(this.photos),
      );
}
