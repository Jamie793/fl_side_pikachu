import 'package:pikachu/datas/models/site_config.dart';
import 'package:pikachu/datas/services/pixiv_server.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pikachu/datas/models/site_type.dart';
import 'package:dio/dio.dart';
import 'package:pikachu/datas/models/user_info.dart';
import 'package:pikachu/providers/app.dart';
import 'package:flutter/foundation.dart';

final pixivConfigProvider = Provider<SiteConfig>((ref) {
  
  final preference = ref.watch(preferenceProvider);

  final header = {
    'User-Agent': 'PixivAndroidApp/5.0.234 (Android 11; Pixel 5)',
    'Content-Type': 'application/x-www-form-urlencoded',
    'Referer': 'https://i.pximg.net',
  };

  preference.maybeWhen(
    data: (data) => header['Authorization'] =
        'Bearer ${data['pixivInfo']?.accessToken ?? ''}',
    orElse: () {},
  );

  return SiteConfig(siteType: SiteType.pixiv, headers: header);
});

final pixivSiteProvider = Provider<PixivSite>((ref) {
  final dio = Dio();
  final UserInfo userInfo =
      ref.watch(
        preferenceProvider.select((value) => value.asData?.value['pixivInfo']),
      ) ??
      UserInfo.empty();
  final site = PixivSite(ref, dio, userInfo);

  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      onRequest: (options, handler) {
        final config = ref.read(pixivConfigProvider);
        options.headers.addAll(config.headers);
        // debugPrint(
        //   'http info: ${options.method} ${options.path} ${options.queryParameters} ${config.headers}',
        // );
        // options.queryParameters.addAll({'filter': 'for_android'});
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 400) {
          await site.refreshToken();
          final options = e.requestOptions;
          options.headers['Authorization'] =
              'Bearer ${site.userInfo.accessToken}';

          final response = await Dio().fetch(options);
          return handler.resolve(response);
        }
        return handler.next(e);
      },
    ),
  );

  return site;
});
