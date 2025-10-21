import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'moment_item.dart';

class MomentsStorage {
  static const _k = 'moments_v1';

  static Future<List<MomentItem>> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_k);
    if (raw == null) {
      // lista default
      return [
        MomentItem(title: 'Momentos inolvidables'),
        MomentItem(title: 'Sábado en la mañana'),
        MomentItem(title: 'Sábado en la tarde'),
        MomentItem(title: 'Domingo en la noche'),
      ];
    }
    final list = (jsonDecode(raw) as List).cast<dynamic>();
    return list
        .map((e) => MomentItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> save(List<MomentItem> items) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await sp.setString(_k, raw);
  }
}
