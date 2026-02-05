import 'site_type.dart';

class SiteConfig {
  final SiteType siteType;
  final Map<String, String> headers;

  const SiteConfig({required this.siteType, required this.headers});

  SiteConfig copyWith({Map<String, String>? headers}) {
    return SiteConfig(siteType: siteType, headers: headers ?? this.headers);
  }
}
