import 'package:flutter/material.dart';
import 'package:pikachu/datas/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pikachu/providers/providers.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:pikachu/datas/models/site_detail.dart';
import 'package:pikachu/datas/models/site_thumb.dart';

class DetailPage extends ConsumerStatefulWidget {
  const DetailPage({super.key});

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  SiteDetail? _detailData;
  SiteThumb? _thumbData;
  bool _isLoading = false;

  void _fetchDetail(SiteThumb thumbData) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    // ref.read(activeSiteProvider).getDetail(thumbData.id).then((value) {
    //   setState(() {
    //     _detailData = value;
    //     _isLoading = false;
    //   });
    // });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _thumbData = ModalRoute.of(context)!.settings.arguments as SiteThumb;
    });
    _fetchDetail(_thumbData!);
  }

  @override
  Widget build(BuildContext context) {
    final tags = _thumbData?.tags ?? [];
    final site = ref.read(activeSiteProvider);
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _detailData?.urls.length == null
                  ? 0
                  : _detailData!.urls.length + 1,
              itemBuilder: (context, index) {
                if (index < _detailData!.urls.length) {
                  return Image.network(
                    _detailData!.urls[index]['urls']['small'],
                    cacheWidth: 450,
                    fit: BoxFit.contain,
                    // headers: site.headers,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: Colors.grey[100],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 100,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  );
                } else {
                  return Padding(
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

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Wrap(
                            spacing: 6.0,
                            runSpacing: 0.0,
                            children: tags
                                .map(
                                  (tag) => Text(
                                    tag,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.tag_faces, size: 18.0),
                              Text(
                                '${_detailData?.likeCount ?? 0}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              SizedBox(width: 10.0),
                              Icon(Icons.favorite, size: 18.0),
                              Text(
                                '${_detailData?.favoriteCount ?? 0}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              SizedBox(width: 10.0),
                              Icon(Icons.remove_red_eye_sharp, size: 18.0),
                              Text(
                                '${_detailData?.viewCount ?? 0}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${DateTime.parse(_detailData?.createDate ?? '').toLocal()}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10.0),
                        Card(
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
                                            // headers: site.headers,
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
                                  onPressed: () {},
                                  child: Text(
                                    '+关注',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
    );
  }
}
