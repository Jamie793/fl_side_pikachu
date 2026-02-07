import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pikachu/providers/app.dart';
import 'package:pikachu/views/thumb_list_view.dart';
import 'package:pikachu/datas/models/site_user.dart';
import 'package:pikachu/views/smart_image_view.dart';

class MomentPage extends ConsumerStatefulWidget {
  const MomentPage({super.key});

  @override
  ConsumerState<MomentPage> createState() => _MomentPageState();
}

class _MomentPageState extends ConsumerState<MomentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _followPage = 0;
  bool _isLoading = false;
  bool _isBusy = false;
  List<SiteUser> _followedUsers = [];

  void _fetchFollow() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    ref
        .read(activeSiteProvider)
        .getFollowedUsers(page: _followPage++)
        .then((value) {
          setState(() {
            _followedUsers.addAll(value);
            setState(() => _isLoading = false);
          });
        })
        .onError((error, stackTrace) {
          debugPrint('获取关注用户失败: $error');
          setState(() => _isLoading = false);
        });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    _fetchFollow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: '动态'),
          Tab(text: '收藏'),
          Tab(text: '关注'),
        ],
      ),

      body: TabBarView(
        controller: _tabController,
        children: [_buildMoment(), _buildFavorite(), _buildFollow()],
      ),
    );
  }

  Widget _buildMoment() {
    return ThumbListView(
      site: ref.watch(activeSiteProvider),
      onFetch: (page) async {
        return await ref.read(activeSiteProvider).getFollowedMoment(page: page);
      },
    );
  }

  Widget _buildFavorite() {
    return ThumbListView(
      site: ref.watch(activeSiteProvider),
      onFetch: (page) async {
        return await ref
            .read(activeSiteProvider)
            .getFavoriteIllusts(page: page);
      },
    );
  }

  Widget _buildFollow() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _followedUsers.clear();
          _followPage = 0;
        });
        _fetchFollow();
      },
      child: ListView.builder(
        itemCount: _followedUsers.length,
        itemBuilder: (context, index) {
          return _buildItem(index);
        },
      ),
    );
  }

  Card _buildItem(int index) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                    _followedUsers[index].avatarUrl,
                    headers: ref.read(activeSiteProvider).getHeaders(),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _followedUsers[index].userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'ID: ${_followedUsers[index].userId}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                ElevatedButton(
                  child: Text(_followedUsers[index].isFollowed ? '取关' : '关注'),
                  onPressed: _isBusy
                      ? null
                      : () {
                          setState(() => _isBusy = true);
                          if (_followedUsers[index].isFollowed) {
                            ref
                                .read(activeSiteProvider)
                                .unFollowUser(_followedUsers[index].userId)
                                .then((value) {
                                  setState(() {
                                    _followedUsers[index] =
                                        _followedUsers[index].copyWith(
                                          isFollowed: false,
                                        );
                                    setState(() => _isBusy = false);
                                  });
                                })
                                .onError((error, stackTrace) {
                                  debugPrint('取关用户失败: $error');
                                  setState(() => _isBusy = false);
                                });
                          } else {
                            ref
                                .read(activeSiteProvider)
                                .followUser(_followedUsers[index].userId)
                                .then((value) {
                                  setState(() {
                                    _followedUsers[index] =
                                        _followedUsers[index].copyWith(
                                          isFollowed: true,
                                        );
                                    setState(() => _isBusy = false);
                                  });
                                })
                                .onError((error, stackTrace) {
                                  debugPrint('关注用户失败: $error');
                                  setState(() => _isBusy = false);
                                });
                          }
                        },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 120,
            child: GridView.builder(
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: _followedUsers[index].thumbs.length,
              itemBuilder: (context, index2) => InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/detail',
                    arguments: _followedUsers[index].thumbs[index2],
                  );
                },
                child: SmartImageView(
                  imageUrl: _followedUsers[index].thumbs[index2].thumbUrl,
                  fit: BoxFit.cover,
                  cacheWidth: 450,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
