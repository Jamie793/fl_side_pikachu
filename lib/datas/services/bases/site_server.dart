import 'package:dio/dio.dart';
import 'package:pikachu/datas/models/site_thumb.dart';
import 'package:pikachu/datas/models/site_detail.dart';
import 'package:pikachu/datas/models/user_info.dart';
import 'package:pikachu/datas/models/site_user.dart';
import 'package:pikachu/datas/models/site_data.dart';

abstract class SiteServer {
  final Dio dio;

  abstract UserInfo userInfo;

  SiteServer(this.dio);

  String getLoginUrl();

  Future<List<SiteThumb>> getDiscoveryList(int page) async => [];

  Future<SiteData<SiteThumb>> getRecommend(Object? offset) async =>
      SiteData<SiteThumb>(data: []);

  Future<SiteDetail> getDetail(String id) async => SiteDetail.empty();

  Future<bool> favorIllust(String id) async => false;

  Future<bool> unFavorIllust(String id) async => false;

  Future<bool> followUser(String userId) async => false;

  Future<bool> unFollowUser(String userId) async => false;

  Future<SiteData<SiteThumb>> searchIllust({
    required String keyword,
    Object? offset,
  }) async => SiteData<SiteThumb>(data: []);

  Future<List<String>> getAutoCompleteWords(String keyword) async => [];

  Future<SiteData<SiteThumb>> getRelatedIllusts({
    required String id,
    Object? offset,
  }) async => SiteData<SiteThumb>(data: []);

  Future<SiteData<SiteThumb>> getFollowedMoment({
    String? restrict = 'public',
    Object? offset,
  }) async => SiteData<SiteThumb>(data: []);

  Future<SiteData<SiteThumb>> getFavoriteIllusts({
    String? userId,
    String? restrict = 'public',
    Object? offset,
  }) async => SiteData<SiteThumb>(data: []);

  Future<SiteData<SiteUser>> getFollowedUsers({
    String? userId,
    String? restrict = 'public',
    Object? offset,
  }) async => SiteData<SiteUser>(data: []);

  Future<UserInfo> getUserInfo() async => UserInfo.empty();

  Map<String, String> getHeaders();

  Future<Response> httpGet(String url) async {
    try {
      return await dio.get(url);
    } on DioException catch (e) {
      throw '网络请求失败: ${e.message}';
    }
  }

  Future<Response> httpPost(String url, Map<String, dynamic> data) async {
    try {
      return await dio.post(url, data: data);
    } on DioException catch (e) {
      throw '网络请求失败: ${e.message}';
    }
  }
}
