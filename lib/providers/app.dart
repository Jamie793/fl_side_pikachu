import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pikachu/datas/services/bases/site_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pikachu/datas/models/site_type.dart';
import 'package:pikachu/datas/services/bases/site_server.dart';
import 'package:pikachu/providers/pixiv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pikachu/datas/models/user_info.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

final preferenceProvider =
    AsyncNotifierProvider<PreferenceNotifier, Map<String, dynamic>>(() {
      return PreferenceNotifier();
    });

class PreferenceNotifier extends AsyncNotifier<Map<String, dynamic>> {
  final _secureStorage = const FlutterSecureStorage();

  @override
  Future<Map<String, dynamic>> build() async {
    final prefs = await SharedPreferences.getInstance();

    final pixivInfo = base64Decode(
      await _secureStorage.read(key: 'pixiv_info') ?? '',
    );
    final pixivInfoObj = UserInfo.fromJson(jsonDecode(utf8.decode(pixivInfo)));
    // debugPrint('pixivInfoObj: ${pixivInfoObj.toJson()}');

    return {
      'pixivInfo': pixivInfoObj,
      'pikaCookie': prefs.getString('pika_cookie') ?? "",
      'isDarkMode': prefs.getBool('dark_mode') ?? false,
      'currentSite': prefs.getString('current_site') != null
          ? SiteType.fromString(prefs.getString('current_site')!)
          : SiteType.pixiv,
    };
  }

  Future<void> writePixivInfo(UserInfo userInfo) async {
    _secureStorage.write(
      key: 'pixiv_info',
      value: base64Encode(utf8.encode(jsonEncode(userInfo.toJson()))),
    );

    state = AsyncData({...state.value ?? {}, 'pixivInfo': userInfo});
  }

  Future<void> writePikaCookie(String newCookie) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pika_cookie', newCookie);

    state = AsyncData({...state.value!, 'pikaCookie': newCookie});
  }

  Future<void> writeDarkMode(bool newDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', newDarkMode);

    state = AsyncData({...state.value!, 'isDarkMode': newDarkMode});
  }

  Future<void> writeCurrentSite(SiteType newSite) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_site', newSite.name);

    state = AsyncData({...state.value!, 'currentSite': newSite});
  }
}

final activeSiteProvider = NotifierProvider<SiteNotifier, SiteServer>(
  () => SiteNotifier(),
);

class SiteNotifier extends Notifier<SiteServer> {
  @override
  SiteServer build() {
    final siteType =
        ref.watch(preferenceProvider).value?['currentSite'] ?? SiteType.pixiv;
    switch (siteType) {
      case SiteType.pixiv:
        return ref.read(pixivSiteProvider);
      case SiteType.pika:
      case _:
        return ref.read(pixivSiteProvider);
    }
  }

  void changeSite(SiteType site) async {
    await ref.read(preferenceProvider.notifier).writeCurrentSite(site);
  }
}

final currentLoginProvider = Provider<bool>((ref) {
  final site = ref.watch(activeSiteProvider);
  final pref = ref.watch(preferenceProvider);
  return pref.maybeWhen(
    data: (data) {
      if (site is SiteAuth) {
        return (site as SiteAuth).isLogin();
      }
      return false;
    },
    orElse: () => false,
  );
});
