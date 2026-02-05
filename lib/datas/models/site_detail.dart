
class SiteDetail {
  final List<Map<String, dynamic>> urls;
  final String title;
  final String description;
  final int likeCount;
  final int viewCount;
  final int favoriteCount;
  final int commentCount;
  final String createDate;

  const SiteDetail({
    required this.urls,
    required this.title,
    required this.description,
    required this.likeCount,
    required this.viewCount,
    required this.favoriteCount,
    required this.commentCount,
    required this.createDate,
  });
}
