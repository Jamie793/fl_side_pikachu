import 'dart:math';

import 'package:dio/dio.dart';
import 'package:pikachu/datas/models/site_thumb.dart';
import 'package:pikachu/datas/models/site_detail.dart';
import 'package:pikachu/datas/models/user_info.dart';
import 'package:pikachu/datas/models/site_user.dart';

abstract class SiteServer {
  final Dio dio;

  abstract UserInfo userInfo;

  SiteServer(this.dio);

  String getLoginUrl();

  Future<List<SiteThumb>> getDiscoveryList(int page) async => [];

  Future<List<SiteThumb>> getRecommend(int page) async => [];

  Future<SiteDetail> getDetail(String id) async => SiteDetail.empty();

  Future<bool> favorIllust(String id) async => false;

  Future<bool> unFavorIllust(String id) async => false;

  Future<bool> followUser(String userId) async => false;

  Future<bool> unFollowUser(String userId) async => false;

  Future<List<SiteThumb>> searchIllust(String keyword, int page) async => [];

  Future<List<String>> getAutoCompleteWords(String keyword) async => [];

  Future<List<SiteThumb>> getRelatedIllusts(String id) async => [];

  Future<List<SiteThumb>> getFollowedMoment({
    int page = 0,
    String? restrict = 'public',
  }) async => [];

  Future<List<SiteThumb>> getFavoriteIllusts({
    int page = 0,
    String? userId,
    String? restrict = 'public',
  }) async => [];

  Future<List<SiteUser>> getFollowedUsers({
    int page = 0,
    String? userId,
    String? restrict = 'public',
  }) async => [];

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
