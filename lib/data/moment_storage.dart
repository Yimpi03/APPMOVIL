import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/moment_item.dart';

class MomentStorage {
  static const _k = 'moments_v1';

  static Future<List<MomentItem>> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_k);
    if (raw == null) return <MomentItem>[];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((e) => MomentItem.fromJson(e)).toList();
  }

  static Future<void> save(List<MomentItem> items) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_k, jsonEncode(items.map((e)=>e.toJson()).toList()));
  }
}
