import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business_profile.dart';
import '../models/ad_models.dart';

class StorageService {
  static const _profileKey = 'business_profile';
  static const _adsKey = 'ad_history';

  // ----- Business Profile -----

  Future<void> saveProfile(BusinessProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, profile.toJsonString());
  }

  Future<BusinessProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null) return null;
    try {
      return BusinessProfile.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  // ----- Ad History -----

  Future<void> saveAd(GeneratedAd ad) async {
    final ads = await loadAds();
    // replace if same id, otherwise prepend
    final idx = ads.indexWhere((a) => a.id == ad.id);
    if (idx >= 0) {
      ads[idx] = ad;
    } else {
      ads.insert(0, ad);
    }
    await _persistAds(ads);
  }

  Future<List<GeneratedAd>> loadAds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_adsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => GeneratedAd.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteAd(String id) async {
    final ads = await loadAds();
    ads.removeWhere((a) => a.id == id);
    await _persistAds(ads);
  }

  Future<void> _persistAds(List<GeneratedAd> ads) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _adsKey, jsonEncode(ads.map((a) => a.toJson()).toList()));
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
