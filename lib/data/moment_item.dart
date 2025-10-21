import 'dart:convert';
import 'dart:typed_data';

class MomentItem {
  String id;
  String title;
  List<String> imagesBase64; // fotos guardadas (base64)

  MomentItem({
    String? id,
    required this.title,
    List<String>? imagesBase64,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        imagesBase64 = imagesBase64 ?? [];

  // Miniatura (primera foto) ya decodificada
  Uint8List? get coverBytes =>
      imagesBase64.isEmpty ? null : base64Decode(imagesBase64.first);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'imagesBase64': imagesBase64,
      };

  factory MomentItem.fromJson(Map<String, dynamic> j) => MomentItem(
        id: j['id']?.toString(),
        title: j['title'] ?? '',
        imagesBase64: (j['imagesBase64'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  MomentItem copyWith({String? title, List<String>? imagesBase64}) => MomentItem(
        id: id,
        title: title ?? this.title,
        imagesBase64: imagesBase64 ?? List.of(this.imagesBase64),
      );

  void addImageBytes(Uint8List bytes) => imagesBase64.add(base64Encode(bytes));
}
