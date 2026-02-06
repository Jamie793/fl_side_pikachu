import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pikachu/datas/models/site_config.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pikachu/providers/providers.dart';
import 'package:pikachu/datas/models/site_thumb.dart';
import 'package:pikachu/datas/models/illust_type.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final List<SiteThumb> _items = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _currentPage = 0;

  void _fetchNextPage() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    ref
        .read(activeSiteProvider)
        .getRecommend(_currentPage)
        .then((newData) {
          if (newData.isNotEmpty) {
            setState(() {
              _items.addAll(newData);
              _currentPage++;
              _isLoading = false;
            });
          }
        })
        .catchError((e) {
          setState(() => _isLoading = false);
          print("加载更多失败: $e");
        });
  }

  initState() {
    super.initState();
    _fetchNextPage();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _fetchNextPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _items.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _items.clear();
                  _currentPage = 0;
                  _isLoading = false;
                });
                _fetchNextPage();
              },
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                controller: _scrollController,
                padding: const EdgeInsets.all(5),
                itemCount: _items.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _items.length) {
                    return _buildItem(_items[index], index);
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              ),
            ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildItem(SiteThumb item, int index) {
    final site = ref.read(activeSiteProvider);
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      margin: const EdgeInsets.all(5),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/detail', arguments: item);
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: item.aspectRatio,
                  child: Image.network(
                    item.thumbUrl,
                    fit: BoxFit.cover,
                    cacheWidth: 450,
                    headers: site.getHeaders(),
                    errorBuilder: (context, error, stackTrace) {
                      print("图片加载失败: $error");
                      return const Icon(Icons.error);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item.author,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // const Spacer(),
                      IconButton(
                        icon: item.isFavorited
                            ? const Icon(Icons.favorite, color: Colors.red)
                            : const Icon(Icons.favorite_border),
                        onPressed: item.isFavorited
                            ? () async {
                                if (await site.unFavorIllust(item.id)) {
                                  setState(() {
                                    _items[index] = item.copyWith(
                                      isFavorited: false,
                                    );
                                  });
                                }
                              }
                            : () async {
                                if (await site.favorIllust(item.id)) {
                                  setState(() {
                                    _items[index] = item.copyWith(
                                      isFavorited: true,
                                    );
                                  });
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(193, 158, 158, 158),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  '${item.illustType == IllustType.ai ? 'AI ' : ''}${item.pageCount}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
