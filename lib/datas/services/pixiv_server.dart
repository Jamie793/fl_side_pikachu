import 'dart:math';
import 'dart:convert';
import 'package:pikachu/datas/models/site_thumb.dart';
import 'package:pikachu/datas/models/site_detail.dart';
import 'package:pikachu/datas/models/illust_type.dart';
import 'package:pikachu/datas/services/bases/site_server.dart';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:pikachu/datas/services/bases/site_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pikachu/providers/app.dart';

class PixivSite extends SiteServer implements SiteAuth {
  final String clientID = "MOBrBDS8blbauoSck0ZfDbtuzpyT";
  final String clientSecret = "lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj";
  final String tokenURL = "https://oauth.secure.pixiv.net/auth/token";
  final String redirectURI =
      "https://app-api.pixiv.net/web/v1/users/auth/pixiv/callback";
  final String loginUrl =
      r'https://app-api.pixiv.net/web/v1/login?code_challenge=$code_challenge&code_challenge_method=S256&client=pixiv-android&redirect_uri=$redirect_uri';
  final String userAgent =
      "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Mobile Safari/537.36";
  String challengeCode = '';
  final Ref ref;
  PixivSite(this.ref, Dio dio) : super(dio);

  @override
  String getLoginUrl() {
    final bytes = sha256.convert(utf8.encode(_nextChallengeCode())).bytes;
    final challenge = base64UrlEncode(bytes).replaceAll('=', '');
    return loginUrl
        .replaceAll(r'$code_challenge', challenge)
        .replaceAll(r'$redirect_uri', redirectURI);
  }

  String _nextChallengeCode() {
    final bytes = List<int>.generate(32, (i) => Random.secure().nextInt(256));
    challengeCode = base64UrlEncode(bytes).replaceAll('=', '');
    return challengeCode;
  }

  Future<Map<String, dynamic>> fetchToken(String code) async {
    final response = await httpPost(tokenURL, {
      'client_id': clientID,
      'client_secret': clientSecret,
      'grant_type': 'authorization_code',
      'code_verifier': challengeCode,
      'code': code,
      'redirect_uri': redirectURI,
      'include_policy': true,
    });
    return response.data;
  }

  Future<void> refreshToken(String refreshToken) async {
    final response = await dio.post(
      "https://oauth.secure.pixiv.net/auth/token",
      data: {
        'client_id': clientID,
        'client_secret': clientSecret,
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'include_policy': 'true',
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final data = response.data as Map<String, dynamic>;
    if (data.containsKey('access_token')) {
      final accessToken = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String;
      await ref
          .read(preferenceProvider.notifier)
          .writePixivToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
    }
  }

  @override
  Future<List<SiteThumb>> getDiscoveryList(int page) async {
    final response = await httpGet(
      'https://www.pixiv.net/ajax/discovery/artworks?mode=all&limit=30&lang=zh',
    );
    final thumbnails = response.data['body']['thumbnails']['illust'];
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      thumbnails.map((e) => Map<String, dynamic>.from(e)),
    );
    final res = data
        .map(
          (e) => SiteThumb(
            id: e['id'],
            title: e['title'],
            thumbUrl: e['url'],
            aspectRatio: e['width'] / e['height'],
            avatarUrl: e['profileImageUrl'],
            author: e['userName'],
            tags: List<String>.from(e['tags'].map((e) => e.toString())),
            pageCount: e['pageCount'],
            illustType: IllustType.values[e['illustType']],
          ),
        )
        .toList();
    return res;
  }

  @override
  Future<SiteDetail> getDetail(String id) async {
    final images = await httpGet(
      'https://www.pixiv.net/ajax/illust/$id/pages?lang=zh',
    );

    final detial = await httpGet(
      'https://www.pixiv.net/ajax/illust/$id?lang=zh',
    );

    final urls = images.data['body'];
    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      urls.map((e) => Map<String, dynamic>.from(e)),
    );
    final detailData = detial.data['body'];
    return SiteDetail(
      urls: data,
      title: detailData['title'],
      description: detailData['description'],
      likeCount: detailData['likeCount'],
      viewCount: detailData['viewCount'],
      favoriteCount: detailData['bookmarkCount'],
      commentCount: detailData['commentCount'],
      createDate: detailData['createDate'],
    );
  }

  @override
  Future<bool> likeIllust(String id) async {
    final response = await httpPost(
      'https://www.pixiv.net/ajax/illust/$id/like',
      {"illust_id": id, "restrict": 0, "comment": "", "tags": []},
    );
    return response.data['error'] == 'false';
  }

  @override
  Future<bool> handleLogin(dynamic res) async {
    if (res is! Uri || res.scheme != 'pixiv') {
      return false;
    }

    final code = res.queryParameters['code'];
    if (code == null) {
      return false;
    }
    final data = await fetchToken(code);
    if (!data.containsKey('access_token')) {
      return false;
    }
    final accessToken = data['access_token'];
    final refreshToken = data['refresh_token'];
    ref
        .read(preferenceProvider.notifier)
        .writePixivToken(accessToken: accessToken, refreshToken: refreshToken);
    return true;
  }

  @override
  bool isLogin() {
    final preference = ref.watch(preferenceProvider);
    return preference.maybeWhen(
      data: (data) =>
          data['pixivAccessToken'] != '' && data['pixivRefreshToken'] != '',
      orElse: () => false,
    );
  }

  @override
  Future<bool> login() {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  bool logout() {
    ref
        .read(preferenceProvider.notifier)
        .writePixivToken(accessToken: '', refreshToken: '');
    return true;
  }
}
