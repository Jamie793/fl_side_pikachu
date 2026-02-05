import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pikachu/datas/services/bases/site_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pikachu/datas/models/site_type.dart';
import 'package:pikachu/datas/services/bases/site_server.dart';
import 'package:pikachu/providers/pixiv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pikachu/datas/services/pixiv_server.dart';

final preferenceProvider =
    AsyncNotifierProvider<PreferenceNotifier, Map<String, dynamic>>(() {
      return PreferenceNotifier();
    });

class PreferenceNotifier extends AsyncNotifier<Map<String, dynamic>> {
  final _secureStorage = const FlutterSecureStorage();

  @override
  Future<Map<String, dynamic>> build() async {
    final prefs = await SharedPreferences.getInstance();

    final pixivAccessToken = await _secureStorage.read(
      key: 'pixiv_access_token',
    );
    final pixivRefreshToken = await _secureStorage.read(
      key: 'pixiv_refresh_token',
    );

    return {
      'pixivAccessToken': pixivAccessToken ?? "",
      'pixivRefreshToken': pixivRefreshToken ?? "",
      'pikaCookie': prefs.getString('pika_cookie') ?? "",
      'isDarkMode': prefs.getBool('dark_mode') ?? false,
      'currentSite': prefs.getString('current_site') != null
          ? SiteType.fromString(prefs.getString('current_site')!)
          : SiteType.pixiv,
    };
  }

  Future<void> writePixivToken({
    String? accessToken,
    String? refreshToken,
  }) async {
    if (accessToken != null) {
      await _secureStorage.write(key: 'pixiv_access_token', value: accessToken);
    }
    if (refreshToken != null) {
      await _secureStorage.write(
        key: 'pixiv_refresh_token',
        value: refreshToken,
      );
    }

    state = AsyncData({
      ...state.value ?? {},
      if (accessToken != null) 'pixivAccessToken': accessToken,
      if (refreshToken != null) 'pixivRefreshToken': refreshToken,
    });
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

  Future<void> writeCurrentSite(String newSite) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_site', newSite);

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
    await ref.read(preferenceProvider.notifier).writeCurrentSite(site.name);
  }
}

final currentLoginProvider = Provider<bool>((ref) {
  final site = ref.watch(activeSiteProvider);
  if (site is SiteAuth) {
    return (site as SiteAuth).isLogin();
  }
  return false;
});
