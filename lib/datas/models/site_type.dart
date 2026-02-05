enum SiteType {
  pixiv,
  pika,
  ehentai;

  static SiteType fromString(String site) {
    switch (site) {
      case 'pixiv':
        return SiteType.pixiv;
      case 'pika':
        return SiteType.pika;
      case 'ehentai':
        return SiteType.ehentai;
      default:
        return SiteType.pixiv;
    }
  }
}
