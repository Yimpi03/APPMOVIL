import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_profile.dart';

class UserProfileStore {
  static const _kKey = 'user_profile_v1';

  Future<UserProfile> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kKey);
    if (raw == null) return UserProfile.defaults();
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(UserProfile p) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kKey, jsonEncode(p.toJson()));
  }
}
