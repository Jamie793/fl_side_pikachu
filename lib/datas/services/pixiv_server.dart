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
import 'package:pikachu/providers/pixiv.dart';

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
  Future<List<SiteThumb>> getRecommend(int page) async {
    final response = await httpGet(
      'https://app-api.pixiv.net/v1/illust/recommended?offset=${page * 30}',
    );
    return _parseThumb(response.data);
  }

  // @override
  // Future<List<SiteThumb>> getDiscoveryList(int page) async {
  //   final response = await httpGet(
  //     'https://www.pixiv.net/ajax/discovery/artworks?mode=all&limit=30&lang=zh',
  //   );
  //   final thumbnails = response.data['body']['thumbnails']['illust'];
  //   final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
  //     thumbnails.map((e) => Map<String, dynamic>.from(e)),
  //   );
  //   final res = data
  //       .map(
  //         (e) => SiteThumb(
  //           id: e['id'],
  //           title: e['title'],
  //           thumbUrl: e['url'],
  //           aspectRatio: e['width'] / e['height'],
  //           avatarUrl: e['profileImageUrl'],
  //           author: e['userName'],
  //           tags: List<String>.from(e['tags'].map((e) => e.toString())),
  //           pageCount: e['pageCount'],
  //           illustType: IllustType.values[e['illustType']],
  //         ),
  //       )
  //       .toList();
  //   return res;
  // }

  @override
  Future<SiteDetail> getDetail(String id) async {
    final detail = await httpGet(
      'https://app-api.pixiv.net/v1/illust/detail?illust_id=$id',
    );
    final data = detail.data['illust'];
    final urls = [
      if (data['meta_single_page'] != null &&
          data['meta_single_page'].isNotEmpty)
        data['meta_single_page']['original_image_url']
      else
        ...data['meta_pages'].map((e) => e['image_urls']['original']).toList(),
    ];
    final detailData = detail.data['illust'];
    return SiteDetail(
      urls: List.from(urls),
      title: detailData['title'],
      description: detailData['caption'],
      viewCount: detailData['total_view'],
      favoriteCount: detailData['total_bookmarks'],
      commentCount: detailData['total_comments'],
      createDate: detailData['create_date'],
    );
  }

  @override
  Future<bool> favorIllust(String id) async {
    if (id.isEmpty) {
      return false;
    }
    final response = await httpPost(
      'https://app-api.pixiv.net/v2/illust/bookmark/add',
      {"illust_id": id, "restrict": 'public'},
    );
    return response.statusCode == 200;
  }

  @override
  Future<bool> unFavorIllust(String id) async {
    if (id.isEmpty) {
      return false;
    }
    final response = await httpPost(
      'https://app-api.pixiv.net/v1/illust/bookmark/delete',
      {"illust_id": id},
    );
    return response.statusCode == 200;
  }

  @override
  Future<bool> followUser(String userId) async {
    if (userId.isEmpty) {
      return false;
    }
    final response = await httpPost(
      'https://app-api.pixiv.net/v1/user/follow/add',
      {"user_id": userId, "restrict": 'public'},
    );
    return response.statusCode == 200;
  }

  @override
  Future<bool> unFollowUser(String userId) async {
    if (userId.isEmpty) {
      return false;
    }
    final response = await httpPost(
      'https://app-api.pixiv.net/v1/user/follow/delete',
      {"user_id": userId},
    );
    return response.statusCode == 200;
  }

  @override
  Future<List<SiteThumb>> getDiscoveryList(int page) {
    // TODO: implement getDiscoveryList
    throw UnimplementedError();
  }

  @override
  Future<List<SiteThumb>> searchIllust(String keyword, int page) async {
    final response = await httpGet(
      'https://app-api.pixiv.net/v1/search/illust?word=$keyword&offset=${page * 30}',
    );
    return _parseThumb(response.data);
  }

  @override
  Future<List<String>> getAutoCompleteWords(String keyword) async {
    final response = await httpGet(
      'https://app-api.pixiv.net/v2/search/autocomplete?word=$keyword',
    );
    final data = response.data['tags'];
    return List<String>.from(data.map((e) => e['name']));
  }

  @override
  Future<List<SiteThumb>> getRelatedIllusts(String id) async {
    if (id.isEmpty) {
      return [];
    }
    final response = await httpGet(
      'https://app-api.pixiv.net/v2/illust/related?illust_id=$id',
    );
    return _parseThumb(response.data);
  }

  @override
  Future<List<SiteThumb>> getFollowedMoment({
    int page = 0,
    String? restrict = 'public',
  }) async {
    final response = await httpGet(
      'https://app-api.pixiv.net/v2/illust/follow?restrict=$restrict&offset=${page * 30}',
    );
    return _parseThumb(response.data);
  }

  @override
  Map<String, String> getHeaders() {
    // TODO: implement getHeaders
    return ref.read(pixivConfigProvider).headers;
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
    await ref
        .read(preferenceProvider.notifier)
        .writePixivToken(accessToken: accessToken, refreshToken: refreshToken);
    return true;
  }

  @override
  bool isLogin() {
    print('headers: ${ref.read(pixivConfigProvider).headers}');
    return ref.read(pixivConfigProvider).headers.containsKey('Authorization') &&
        ref.read(pixivConfigProvider).headers['Authorization'] != null &&
        ref.read(pixivConfigProvider).headers['Authorization'] != '' &&
        ref.read(pixivConfigProvider).headers['Authorization']?.trim() !=
            'Bearer';
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

  List<SiteThumb> _parseThumb(dynamic data) {
    final thumbnails = data['illusts'];
    final List<Map<String, dynamic>> mapData = List<Map<String, dynamic>>.from(
      thumbnails.map((e) => Map<String, dynamic>.from(e)),
    );
    final res = mapData
        .where((e) => e['visible'] != false)
        .map(
          (e) => SiteThumb(
            id: e['id'].toString(),
            title: e['title'],
            thumbUrl: e['image_urls']['medium'],
            aspectRatio: e['width'] / e['height'],
            avatarUrl: e['user']['profile_image_urls']['medium'],
            author: e['user']['account'],
            tags: List<String>.from(e['tags'].map((e) => e['name'].toString())),
            userId: e['user']['id'],
            pageCount: e['page_count'],
            illustType: IllustType.values[e['illust_ai_type']],
            isFavorited: e['is_bookmarked'],
            isFollowed: e['user']['is_followed'],
          ),
        )
        .toList();
    return res;
  }
}
