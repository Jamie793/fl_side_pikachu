import 'package:pikachu/datas/models/site_config.dart';
import 'package:pikachu/datas/services/pixiv_server.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pikachu/datas/models/site_type.dart';
import 'package:dio/dio.dart';

import 'package:pikachu/providers/providers.dart';

final pixivConfigProvider = Provider<SiteConfig>((ref) {
  final preference = ref.watch(preferenceProvider);
  final header = {
    'User-Agent': 'PixivAndroidApp/5.0.234 (Android 11; Pixel 5)',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  preference.maybeWhen(
    data: (data) =>
        header['Authorization'] = 'Bearer ${data['pixivAccessToken']}',
    orElse: () {},
  );

  return SiteConfig(siteType: SiteType.pixiv, headers: header);
});
// final pixivConfigProvider =
//     Provider<PixivSiteConfigProvider, SiteConfig>(() {
//       return PixivSiteConfigProvider();
//     });

// class PixivSiteConfigProvider extends AsyncNotifier<SiteConfig> {
//   @override
//   Future<SiteConfig> build() async {
//     // final preference = ref.watch(preferenceProvider);

//     final header = {
//       'User-Agent': 'PixivAndroidApp/5.0.234 (Android 11; Pixel 5)',
//       'Content-Type': 'application/x-www-form-urlencoded',
//     };

//     // final token = preference['pixivAccessToken'];

//     // if (token != null && token.toString().isNotEmpty) {
//     //   header['Authorization'] = 'Bearer $token';
//     // }

//     return SiteConfig(siteType: SiteType.pixiv, headers: header);
//   }
// }

final pixivSiteProvider = Provider<PixivSite>((ref) {
  final dio = Dio();
  final site = PixivSite(ref, dio);

  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      onRequest: (options, handler) {
        final config = ref.read(pixivConfigProvider);
        options.headers.addAll(config.headers);
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final prefs = ref.read(preferenceProvider).value;
          final refreshToken = prefs?['pixivRefreshToken'];

          if (refreshToken != null && refreshToken.isNotEmpty) {
            try {
              site.refreshToken(refreshToken);

              final options = e.requestOptions;
              options.headers['Authorization'] =
                  'Bearer ${prefs?['pixivAccessToken']}';

              final response = await dio.fetch(options);
              return handler.resolve(response);
            } catch (refreshError) {
              // ref.read(preferenceProvider.notifier).logout();
            }
          }
        }
        return handler.next(e);
      },
    ),
  );
  return site;
});
