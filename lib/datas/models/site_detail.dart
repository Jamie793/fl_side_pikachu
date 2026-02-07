class SiteDetail {
  final List<String> urls;
  final String title;
  final String description;
  final int viewCount;
  final int favoriteCount;
  final int commentCount;
  final String createDate;

  const SiteDetail({
    required this.urls,
    required this.title,
    required this.description,
    required this.viewCount,
    required this.favoriteCount,
    required this.commentCount,
    required this.createDate,
  });

  SiteDetail.empty()
    : urls = [],
      title = '',
      description = '',
      viewCount = 0,
      favoriteCount = 0,
      commentCount = 0,
      createDate = '';
}
