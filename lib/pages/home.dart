import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pikachu/datas/models/site_data.dart';
import 'package:pikachu/providers/providers.dart';
import 'package:pikachu/datas/models/site_thumb.dart';
import 'package:pikachu/views/thumb_list_view.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {

  Future<SiteData<SiteThumb>> _fetchNextPage(Object? offset) async {
    return ref.read(activeSiteProvider).getRecommend(offset);
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
        initial: null,
        onFetch: (offset) => _fetchNextPage(offset),
        onStatusChange: (isLoading) {},
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
