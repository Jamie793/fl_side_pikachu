import 'illust_type.dart';

class SiteThumb {
  final String id;
  final String title;
  final String thumbUrl;
  final double aspectRatio;
  final String avatarUrl;
  final String author;
  final List<String> tags;
  final int pageCount;
  final IllustType illustType;

  const SiteThumb({
    required this.id,
    required this.title,
    required this.thumbUrl,
    required this.aspectRatio,
    required this.avatarUrl,
    required this.author,
    required this.tags,
    required this.pageCount,
    required this.illustType,
  });

  @override
  toString() =>
      'SiteDataItem(id: $id, title: $title, thumb: $thumbUrl, author: $author, tags: $tags, pageCount: $pageCount)';
}
