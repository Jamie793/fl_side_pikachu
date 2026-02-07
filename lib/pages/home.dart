import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pikachu/providers/providers.dart';
import 'package:pikachu/datas/models/site_thumb.dart';
import 'package:pikachu/views/thumb_list_view.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {

  Future<List<SiteThumb>> _fetchNextPage(int page) async {
    return ref.read(activeSiteProvider).getRecommend(page);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThumbListView(
        site: ref.read(activeSiteProvider),
        onFetch: (page) => _fetchNextPage(page),
        onStatusChange: (isLoading) {},
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
