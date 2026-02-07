import 'package:pikachu/datas/models/site_thumb.dart';

class SiteUser {
  final String userId;
  final String userName;
  final String account;
  final String avatarUrl;
  final bool isFollowed;
  final List<SiteThumb> thumbs;

  const SiteUser({
    required this.userId,
    required this.userName,
    required this.account,
    required this.avatarUrl,
    required this.isFollowed,
    required this.thumbs,
  });

  SiteUser copyWith({
    String? userId,
    String? userName,
    String? account,
    String? avatarUrl,
    bool? isFollowed,
    List<SiteThumb>? thumbs,
  }) {
    return SiteUser(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      account: account ?? this.account,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isFollowed: isFollowed ?? this.isFollowed,
      thumbs: thumbs ?? this.thumbs,
    );
  }

  factory SiteUser.empty() => const SiteUser(
    userId: '',
    userName: '',
    account: '',
    avatarUrl: '',
    isFollowed: false,
    thumbs: [],
  );
}
