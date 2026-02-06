import 'package:dio/dio.dart';
import 'package:pikachu/datas/models/site_config.dart';
import 'package:pikachu/datas/models/site_thumb.dart';
import 'package:pikachu/datas/models/site_detail.dart';

abstract class SiteServer {
  final Dio dio;

  const SiteServer(this.dio);

  String getLoginUrl();

  Future<List<SiteThumb>> getDiscoveryList(int page);

  Future<List<SiteThumb>> getRecommend(int page);

  Future<SiteDetail> getDetail(String id);

  Future<bool> favorIllust(String id);

  Future<bool> unFavorIllust(String id);

  Future<bool> followUser(String userId);

  Future<bool> unFollowUser(String userId);

  Future<List<SiteThumb>> searchIllust(String keyword, int page);

  Future<List<String>> getAutoCompleteWords(String keyword);

  Future<List<SiteThumb>> getRelatedIllusts(String id);

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
