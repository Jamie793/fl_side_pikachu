import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pikachu/datas/services/bases/site_server.dart';
import 'package:pikachu/providers/providers.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:pikachu/datas/models/site_detail.dart';
import 'package:pikachu/datas/models/site_thumb.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';
import 'package:pikachu/views/smart_image_view.dart';

class DetailPage extends ConsumerStatefulWidget {
  const DetailPage({super.key});

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _relatedScrollController = ScrollController();
  final List<SiteThumb> _relatedIllusts = [];
  SiteDetail? _detailData;
  SiteThumb? _thumbData;
  bool _isLoading = false;
  bool _isFabVisible = true;
  bool _isBusy = false;

  void _fetchDetail(SiteThumb thumbData) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    ref.read(activeSiteProvider).getDetail(thumbData.id).then((value) {
      setState(() {
        _detailData = value;
        _isLoading = false;
      });
    });
  }

  void _fetchRelated(SiteThumb thumbData) async {
    ref.read(activeSiteProvider).getRelatedIllusts(thumbData.id).then((value) {
      setState(() {
        _relatedIllusts.addAll(value);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() => _isFabVisible = false);
      } else {
        setState(() => _isFabVisible = true);
      }
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _fetchRelated(_thumbData!);
      }
    });
    // _relatedScrollController.addListener(() {
    //   if (_relatedScrollController.position.pixels >=
    //       _relatedScrollController.position.maxScrollExtent - 200) {
    //     _fetchRelated(_thumbData!);
    //   }
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _thumbData = ModalRoute.of(context)!.settings.arguments as SiteThumb;
    });
    _fetchDetail(_thumbData!);
    _fetchRelated(_thumbData!);
  }

  @override
  Widget build(BuildContext context) {
    final tags = _thumbData?.tags ?? [];
    final site = ref.read(activeSiteProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        if (context.mounted) {
          Navigator.pop(context, _thumbData);
        }
      },
      child: Scaffold(
        floatingActionButton: AnimatedScale(
          scale: _isFabVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: FloatingActionButton(
            onPressed: _isBusy
                ? null
                : () async {
                    setState(() => _isBusy = true);
                    if (_thumbData?.isFavorited == true) {
                      if (await site.unFavorIllust(_thumbData?.id ?? '') ==
                          true) {
                        setState(
                          () => _thumbData = _thumbData?.copyWith(
                            isFavorited: false,
                          ),
                        );
                      }
                    } else {
                      if (await site.favorIllust(_thumbData?.id ?? '') ==
                          true) {
                        setState(
                          () => _thumbData = _thumbData?.copyWith(
                            isFavorited: true,
                          ),
                        );
                      }
                    }
                    setState(() => _isBusy = false);
                  },
            child: Icon(
              _thumbData?.isFavorited == true
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: _thumbData?.isFavorited == true ? Colors.red : Colors.grey,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buidMain(site, tags),
      ),
    );
  }

  ListView _buidMain(SiteServer site, List<String> tags) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _detailData?.urls.length == null
          ? 0
          : _detailData!.urls.length + 1,
      itemBuilder: (context, index) {
        if (index < _detailData!.urls.length) {
          return SmartImageView(
            imageUrl: _detailData!.urls[index],
            cacheWidth: 800,
            fit: BoxFit.contain,
            headers: site.getHeaders(),
          );
        } else {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _thumbData?.title ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    HtmlWidget(_detailData?.description ?? ''),

                    _buildTag(tags, context),
                    _buildInfo(),

                    Row(
                      children: [
                        Text(
                          '作品ID: ${_thumbData?.id ?? 0}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        SizedBox(width: 20.0),
                        Text(
                          '作者ID: ${_thumbData?.userId ?? 0}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    _buildUser(site),
                  ],
                ),
              ),
              _buildRelated(site),
            ],
          );
        }
      },
    );
  }

  Widget _buildRelated(SiteServer site) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _relatedIllusts.length,
      itemBuilder: (context, index) => InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detail',
            arguments: _relatedIllusts[index],
          );
        },
        child: SmartImageView(
          imageUrl: _relatedIllusts[index].thumbUrl,
          cacheWidth: 450,
          fit: BoxFit.cover,
          headers: site.getHeaders(),
        ),
      ),
    );
  }

  Card _buildUser(SiteServer site) {
    return Card(
      margin: const EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            if (_thumbData?.avatarUrl != null)
              CircleAvatar(
                radius: 25.0,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    _thumbData?.avatarUrl != null &&
                        _thumbData!.avatarUrl.isNotEmpty
                    ? NetworkImage(
                        _thumbData!.avatarUrl,
                        headers: site.getHeaders(),
                      )
                    : null,
                child: _thumbData?.avatarUrl == null
                    ? Icon(Icons.person)
                    : null,
              ),
            SizedBox(width: 10.0),
            Column(
              children: [
                Text(
                  '${_thumbData?.author}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Text(
                //   '${_thumbData?.likes ?? 0}',
                //   style: const TextStyle(fontSize: 16),
                // ),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _isBusy
                  ? null
                  : () async {
                      setState(() => _isBusy = true);
                      if (_thumbData?.isFollowed == true) {
                        if (await ref
                            .read(activeSiteProvider)
                            .followUser(_thumbData?.userId.toString() ?? '')) {
                          setState(() {
                            _thumbData = _thumbData?.copyWith(
                              isFollowed: false,
                            );
                          });
                        }
                      } else {
                        if (await ref
                            .read(activeSiteProvider)
                            .followUser(_thumbData?.userId.toString() ?? '')) {
                          setState(() {
                            _thumbData = _thumbData?.copyWith(isFollowed: true);
                          });
                        }
                      }
                      setState(() => _isBusy = false);
                    },
              child: Text(
                _thumbData?.isFollowed == true ? '取消关注' : '关注',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _buildInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(Icons.comment, size: 18.0),
          Text(
            '${_detailData?.commentCount ?? 0}',
            style: const TextStyle(fontSize: 14),
          ),

          SizedBox(width: 10.0),
          Icon(Icons.favorite, size: 18.0),
          Text(
            '${_detailData?.favoriteCount ?? 0}',
            style: const TextStyle(fontSize: 14),
          ),

          SizedBox(width: 10.0),
          Icon(Icons.remove_red_eye_sharp, size: 18.0),
          Text(
            '${_detailData?.viewCount ?? 0}',
            style: const TextStyle(fontSize: 14),
          ),

          SizedBox(width: 10.0),
          Icon(Icons.av_timer_rounded, size: 18.0),
          Text(
            DateFormat(
              'yyyy-MM-dd HH:mm',
            ).format(DateTime.parse(_detailData?.createDate ?? '').toLocal()),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Padding _buildTag(List<String> tags, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Wrap(
        spacing: 6.0,
        runSpacing: 0.0,
        children: tags
            .map(
              (tag) => GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/search', arguments: '$tag');
                },
                child: Text(
                  '#$tag  ',
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
