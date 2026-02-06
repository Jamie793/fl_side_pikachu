import 'illust_type.dart';

class SiteThumb {
  final String id;
  final String title;
  final String thumbUrl;
  final double aspectRatio;
  final String avatarUrl;
  final String author;
  final List<String> tags;
  final int userId;
  final int pageCount;
  final IllustType illustType;
  final bool isFavorited;
  final bool isFollowed;

  const SiteThumb({
    required this.id,
    required this.title,
    required this.thumbUrl,
    required this.aspectRatio,
    required this.avatarUrl,
    required this.author,
    required this.tags,
    required this.userId,
    required this.pageCount,
    required this.illustType,
    required this.isFavorited,
    required this.isFollowed,
  });

  copyWith({
    String? id,
    String? title,
    String? thumbUrl,
    double? aspectRatio,
    String? avatarUrl,
    String? author,
    List<String>? tags,
    int? userId,
    int? pageCount,
    IllustType? illustType,
    bool? isFavorited,
    bool? isFollowed,
  }) => SiteThumb(
    id: id ?? this.id,
    title: title ?? this.title,
    thumbUrl: thumbUrl ?? this.thumbUrl,
    aspectRatio: aspectRatio ?? this.aspectRatio,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    author: author ?? this.author,
    tags: tags ?? this.tags,
    userId: userId ?? this.userId,
    pageCount: pageCount ?? this.pageCount,
    illustType: illustType ?? this.illustType,
    isFavorited: isFavorited ?? this.isFavorited,
    isFollowed: isFollowed ?? this.isFavorited,
  );

  @override
  toString() =>
      'SiteDataItem(id: $id, title: $title, thumb: $thumbUrl, author: $author, tags: $tags, pageCount: $pageCount)';
}
