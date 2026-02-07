import 'package:flutter/material.dart';
import 'package:pikachu/datas/models/site_thumb.dart';
import 'package:pikachu/datas/models/illust_type.dart';
import 'package:pikachu/datas/services/bases/site_server.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pikachu/views/smart_image_view.dart';

class ThumbListController {
  Future<void> Function()? _onRefreshRequest;

  Future<void> refresh() async {
    await _onRefreshRequest?.call();
  }

  void dispose() {
    _onRefreshRequest = null;
  }
}

class ThumbListView extends StatefulWidget {
  final SiteServer site;
  final Future<List<SiteThumb>> Function()? onFetch;
  final Function(bool isLoading)? onStatusChange;
  final ThumbListController? controller;

  const ThumbListView({
    super.key,
    required this.site,
    this.onFetch,
    this.onStatusChange,
    this.controller,
  });

  @override
  State<ThumbListView> createState() => _ThumbListViewState();
}

class _ThumbListViewState extends State<ThumbListView> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final List<SiteThumb> _items = [];
  bool _isLoading = false;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();

    _bindController();

    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;

      if (direction == ScrollDirection.reverse) {
        if (_isFabVisible) {
          setState(() => _isFabVisible = false);
        }
      } else if (direction == ScrollDirection.forward) {
        if (!_isFabVisible) {
          setState(() => _isFabVisible = true);
        }
      }

      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          _scrollController.position.maxScrollExtent > 0) {
        loadMore(false);
      }
    });

    loadMore(false);
  }

  void _bindController() {
    if (widget.controller != null) {
      widget.controller!._onRefreshRequest = () async {
        _refreshIndicatorKey.currentState?.show();
      };
    }
  }

  Future<void> loadMore(bool isPassive) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    widget.onStatusChange?.call(true);

    try {
      final value = await widget.onFetch?.call();
      if (!mounted) return;

      if (value != null && value.isNotEmpty) {
        setState(() {
          if (isPassive) {
            _items.clear();
          }
          _items.addAll(value);
        });
      }
    } catch (error) {
      debugPrint("加载失败: $error");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        widget.onStatusChange?.call(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AnimatedScale(
        scale: _isFabVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: FloatingActionButton(
          onPressed: () => _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.linear,
          ),
          child: const Icon(Icons.arrow_upward),
        ),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          setState(() {
            _items.clear();
          });
          await loadMore(true);
        },
        child: MasonryGridView.count(
          physics: const AlwaysScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          addAutomaticKeepAlives: false,
          controller: _scrollController,
          padding: const EdgeInsets.all(5),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            // if (index < _items.length) {
            return _buildItem(_items[index], index);
            // } else {
            //   return const Padding(
            //     padding: EdgeInsets.all(16.0),
            //     child: Center(child: CircularProgressIndicator()),
            //   );
            // }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    widget.controller?.dispose();
    super.dispose();
  }

  Widget _buildItem(SiteThumb item, int index) {
    return RepaintBoundary(
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        margin: const EdgeInsets.all(5),
        child: InkWell(
          onTap: () async {
            final res =
                await Navigator.pushNamed(context, '/detail', arguments: item)
                    as SiteThumb?;
            if (res != null) {
              setState(() {
                _items[index] = res.copyWith();
              });
            }
          },
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: item.aspectRatio,
                    child: SmartImageView(
                      imageUrl: item.thumbUrl,
                      fit: BoxFit.cover,
                      cacheWidth: 350,
                      headers: widget.site.getHeaders(),
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
                                  if (await widget.site.unFavorIllust(
                                    item.id,
                                  )) {
                                    setState(() {
                                      _items[index] = item.copyWith(
                                        isFavorited: false,
                                      );
                                    });
                                  }
                                }
                              : () async {
                                  if (await widget.site.favorIllust(item.id)) {
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
                    '${item.illustType == IllustType.ai ? 'AI-' : ''}${item.pageCount}',
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
      ),
    );
  }
}
